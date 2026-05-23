#!/usr/bin/env python3
"""
import_bestiary.py

Reads a bestiary JSON (PHB or XPHB 5e-tools format) and generates a SQL file
that inserts all monsters into the 5e_data.sqlite database tables:
  - entities
  - entity_stats
  - creature_profiles
  - action_library  (only for new actions not already in the DB)
  - entity_actions
  - entity_damage_modifiers
  - entity_conditions

The script checks which monsters already exist by name (via a quick read of
the existing DB) and skips duplicates.  Generated IDs continue from the
existing max (e.g. mon-26, act-6).

Handles both PHB (2014) and XPHB (2024) 5e-tools JSON formats, including:
  - _versions sub-entries (expanded into separate monster records)
  - bonus/reaction action blocks
  - Plain-number AC arrays
  - Non-numeric special HP strings (extracts first number found)
  - Speed values as objects with a "number" key
  - type as a dict (Otherworldly Steed "choose" pattern)
  - summonedBySpell metadata (stored in notes)

Usage:
    python3 import_bestiary.py [--write] [json_path]
    # Default json_path: Assets/bestiary-phb.json
    # Example: python3 import_bestiary.py --write Assets/bestiary-xphb.json

The SQL is wrapped in BEGIN / COMMIT and uses INSERT OR IGNORE so it is safe
to apply multiple times (already-inserted rows are skipped).
"""

import json
import re
import sqlite3
import sys
from pathlib import Path

# ── Paths ───────────────────────────────────────────────────────────────────
REPO_ROOT = Path(__file__).resolve().parent
DEFAULT_JSON = REPO_ROOT / "Assets" / "bestiary-phb.json"
DB_PATH = REPO_ROOT / "Assets" / "5e_data.sqlite"
OUT_PATH = REPO_ROOT / "Assets" / "import_bestiary.sql"

# ── Size / alignment code lookup ────────────────────────────────────────────
SIZE_MAP = {
    "T": "Tiny",
    "S": "Small",
    "M": "Medium",
    "L": "Large",
    "H": "Huge",
    "G": "Gargantuan",
}

ALIGNMENT_MAP = {
    "LG": "Lawful Good",
    "NG": "Neutral Good",
    "CG": "Chaotic Good",
    "LN": "Lawful Neutral",
    "N": "Neutral",
    "CN": "Chaotic Neutral",
    "LE": "Lawful Evil",
    "NE": "Neutral Evil",
    "CE": "Chaotic Evil",
    "U": "Unaligned",
    "A": "Any Alignment",
    "L": "Lawful",
    "C": "Chaotic",
    "G": "Good",
    "E": "Evil",
    "LNY": "Lawful Neutral (LE, LN, or NE)",
    "NX": "Neutral (any non-LG)",
    "NY": "Neutral (any non-CE)",
}

# ── Helpers ─────────────────────────────────────────────────────────────────


def resolve_size(entry):
    """Return full-size string from a size code or array (first entry)."""
    if isinstance(entry, list) and entry:
        code = entry[0]
    elif isinstance(entry, str):
        code = entry
    else:
        return "Medium"
    return SIZE_MAP.get(code, code)


def resolve_alignment(entry):
    """Return full alignment string from code(s)."""
    if isinstance(entry, list):
        codes = [ALIGNMENT_MAP.get(c, c) for c in entry]
        return " ".join(codes)
    if isinstance(entry, str):
        return ALIGNMENT_MAP.get(entry, entry)
    return "Unaligned"


def resolve_ac(ac_list):
    """Return (ac_value, armor_desc) from an AC entry list.

    Handles:
      - [{"ac": 15, "from": ["natural armor"]}]       ← PHB format
      - [15]                                            ← plain number
      - [{"special": "11 + the spell's level"}]         ← special formula
    """
    if not ac_list or not isinstance(ac_list, list):
        return 10, None
    entry = ac_list[0]

    # Plain number directly in the list
    if isinstance(entry, (int, float)):
        return int(entry), None

    # Object with 'special' key (spell-level-based AC)
    if "special" in entry:
        return 10, entry["special"]

    # Standard object with 'ac' and optional 'from'
    ac_val = entry.get("ac", 10)
    from_list = entry.get("from", [])
    desc = from_list[0] if from_list else None
    return ac_val, desc


def resolve_hp(hp_obj):
    """Return (hit_points_max, hit_dice_type, hit_dice_max) from hp object.

    Supports:
      - {"special": "80"}                              ← numeric string
      - {"special": "40 + 10 per spell level"}          ← formula string
      - {"special": "20 (Air) or 30 (Land)"}            ← variant string
      - {"average": 30, "formula": "4d8+12"}           ← standard
      - {"formula": "4d8+12"}                           ← formula only
    """
    hit_points_max = 10
    hit_dice_max = 1
    hit_dice_type = "d8"

    if hp_obj is None or not isinstance(hp_obj, dict):
        return hit_points_max, hit_dice_type, hit_dice_max

    special = hp_obj.get("special")
    if special is not None:
        # Try to extract the first number from the special string
        m = re.search(r"(\d+)", str(special))
        if m:
            hit_points_max = int(m.group(1))
        return hit_points_max, hit_dice_type, hit_dice_max

    average = hp_obj.get("average")
    formula = hp_obj.get("formula", "")

    if average is not None:
        hit_points_max = average
    elif formula:
        m = re.match(r"(\d+)d(\d+)(?:\s*\+\s*(\d+))?", formula)
        if m:
            num_dice = int(m.group(1))
            die_type = m.group(2)
            mod = int(m.group(3)) if m.group(3) else 0
            hit_dice_max = num_dice
            hit_dice_type = f"d{die_type}"
            if average is None:
                hit_points_max = num_dice * (int(die_type) // 2 + 1) + mod
            else:
                hit_points_max = average

    return hit_points_max, hit_dice_type, hit_dice_max


def resolve_speed(speed_obj):
    """Return dict of speeds (walk, fly, swim, climb, burrow).

    Handles values that are objects with a "number" key
    (XPHB format: {"number": 30, "condition": "..."}).
    """
    if not isinstance(speed_obj, dict):
        return {"walk": 30, "fly": 0, "swim": 0, "climb": 0, "burrow": 0}
    result = {}
    for key in ("walk", "fly", "swim", "climb", "burrow"):
        val = speed_obj.get(key, 0)
        if val is None:
            val = 0
        elif isinstance(val, dict):
            val = val.get("number", 0)
        result[key] = int(val)
    return result


def resolve_senses(senses_list):
    """Return (darkvision, blindsight, tremorsense, truesight).

    Senses like: "Darkvision 60 ft.", "Blindsight 30 ft. (blind beyond this radius)"
    """
    dv = bs = ts = trs = 0
    if not senses_list:
        return dv, bs, ts, trs
    for s in senses_list:
        lower = s.lower()
        m = re.search(r"(\d+)", s)
        val = int(m.group(1)) if m else 0
        if "darkvision" in lower:
            dv = val
        elif "blindsight" in lower:
            bs = val
        elif "tremorsense" in lower:
            trs = val
        elif "truesight" in lower:
            ts = val
    return dv, bs, ts, trs


def resolve_type_name(type_entry):
    """Return a string creature_type from the JSON type field.

    Handles:
      - "aberration"                    ← plain string
      - {"type": {"choose": [...]}}    ← Otherworldly Steed pattern
      - "construct"                     ← already a string
    """
    if isinstance(type_entry, str):
        return type_entry.capitalize()
    if isinstance(type_entry, dict):
        # Try nested type → choose pattern
        inner = type_entry.get("type", type_entry)
        if isinstance(inner, dict) and "choose" in inner:
            choices = inner["choose"]
            return "/".join(c.capitalize() for c in choices)
        # Fallback: try to extract a meaningful string
        return str(type_entry.get("choose", type_entry))
    return "Humanoid"


def parse_attack_text(text):
    """Parse attack entry text.

    Handles both numeric and spell-attack formats:
      - "{@atk mw} {@hit 8} to hit, reach 5 ft. …"          ← numeric
      - "{@atkr m} {@hitYourSpellAttack …}"                  ← spell attack

    Returns (is_attack, attack_bonus, damage_dice, damage_type).
    """
    is_attack = 1
    attack_bonus = None
    damage_dice = None
    damage_type = None

    # Numeric attack bonus: {@hit 8}
    m = re.search(r"\{@hit\s+(-?\d+)\}", text)
    if m:
        attack_bonus = int(m.group(1))

    # Spell attack (no numeric bonus to extract) — flag with special value
    if "{@hitYourSpellAttack}" in text or "{@hitYourSpellAttack Bonus" in text:
        # No numeric bonus for spell attacks
        pass

    # Damage dice: {@damage 2d12 + 4}
    m = re.search(r"\{@damage\s+([^}]+)\}", text, re.IGNORECASE)
    if m:
        damage_dice = m.group(1).strip()

    # Damage type keyword at end of description
    lower = text.lower()
    damage_keywords = {
        "acid": "Acid",
        "bludgeoning": "Bludgeoning",
        "cold": "Cold",
        "fire": "Fire",
        "force": "Force",
        "lightning": "Lightning",
        "necrotic": "Necrotic",
        "piercing": "Piercing",
        "poison": "Poison",
        "psychic": "Psychic",
        "radiant": "Radiant",
        "slashing": "Slashing",
        "thunder": "Thunder",
    }
    for kw, dt in damage_keywords.items():
        if kw in lower:
            damage_type = dt
            break

    if not attack_bonus and not damage_dice:
        is_attack = 0

    return is_attack, attack_bonus, damage_dice, damage_type


def flatten_entries(entries):
    """Flatten a 5e-tools entries list (may contain nested dicts) to plain text."""
    parts = []
    for entry in entries:
        if isinstance(entry, str):
            parts.append(entry)
        elif isinstance(entry, dict):
            # Extract text from nested structures like {type: "list", items: [...]}
            if "entries" in entry:
                parts.extend(flatten_entries(entry["entries"]))
            if "items" in entry:
                for item in entry["items"]:
                    if isinstance(item, dict):
                        name = item.get("name", "")
                        if name:
                            parts.append(name)
                        if "entries" in item:
                            parts.extend(flatten_entries(item["entries"]))
            # Also grab top-level text fields
            for txt_key in ("text",):
                if txt_key in entry:
                    parts.append(str(entry[txt_key]))
    return parts


def sql_quote(val):
    """Quote a value for SQL.  None → NULL, str → escaped, int/float → as-is."""
    if val is None:
        return "NULL"
    if isinstance(val, int):
        return str(val)
    if isinstance(val, float):
        return str(val)
    escaped = str(val).replace("'", "''")
    return f"'{escaped}'"


def resolve_languages(lang_list):
    """Convert a languages list/string to a comma-separated string."""
    if not lang_list:
        return None
    if isinstance(lang_list, list):
        return ", ".join(lang_list)
    if isinstance(lang_list, str):
        return lang_list
    return None


# ── DB queries ──────────────────────────────────────────────────────────────

def get_existing_data(db_path):
    """Query the existing DB for current entity/action IDs and names."""
    conn = sqlite3.connect(str(db_path))
    cur = conn.cursor()

    cur.execute("SELECT name FROM entities WHERE entity_type='creature'")
    existing_names = {row[0].lower() for row in cur.fetchall()}

    cur.execute("SELECT id FROM entities WHERE entity_type='creature'")
    creature_ids = []
    for (row,) in cur.fetchall():
        m = re.match(r"mon-(\d+)", row)
        if m:
            creature_ids.append(int(m.group(1)))
    next_entity_num = max(creature_ids) + 1 if creature_ids else 1

    cur.execute("SELECT id FROM action_library")
    action_ids = []
    for (row,) in cur.fetchall():
        m = re.match(r"act-(\d+)", row)
        if m:
            action_ids.append(int(m.group(1)))
    next_action_num = max(action_ids) + 1 if action_ids else 1

    cur.execute("SELECT name FROM action_library")
    existing_actions = {row[0].lower() for row in cur.fetchall()}

    conn.close()
    return existing_names, next_entity_num, existing_actions, next_action_num


def get_cr_xp(cr):
    """Return (cr_float, xp_value) from a CR field (or (None, None))."""
    cr_float = None
    xp_value = None
    if cr is not None:
        if isinstance(cr, dict):
            cr_float = cr.get("cr")
            xp_value = cr.get("xp")
        elif isinstance(cr, (int, float)):
            cr_float = float(cr)
        if cr_float is not None and xp_value is None:
            cr_xp_map = {
                0: 0, 0.125: 25, 0.25: 50, 0.5: 100,
                1: 200, 2: 450, 3: 700, 4: 1100, 5: 1800,
                6: 2300, 7: 2900, 8: 3900, 9: 5000, 10: 5900,
                11: 7200, 12: 8400, 13: 10000, 14: 11500, 15: 13000,
                16: 15000, 17: 18000, 18: 20000, 19: 22000, 20: 25000,
                21: 33000, 22: 41000, 23: 50000, 24: 62000, 25: 75000,
                26: 90000, 27: 105000, 28: 120000, 29: 135000, 30: 155000,
            }
            xp_value = cr_xp_map.get(cr_float)
    return cr_float, xp_value


# ── Monster (JSON) → SQL row emission ───────────────────────────────────────

class MonsterEmitter:
    """Accumulates SQL lines for one monster entry.

    Manages a single monster dict from a 5e-tools JSON array and emits
    INSERT statements for entities, entity_stats, creature_profiles,
    action_library, entity_actions, entity_damage_modifiers, and
    entity_conditions.
    """

    def __init__(self, lines, next_entity_num, next_action_num,
                 existing_actions, existing_names):
        self.lines = lines
        self.next_entity_num = next_entity_num
        self.next_action_num = next_action_num
        self.existing_actions = existing_actions
        self.existing_names = existing_names
        self.skipped = False

    @property
    def entity_id(self):
        return f"mon-{self.next_entity_num}"

    @property
    def act_id(self):
        return f"act-{self.next_action_num}"

    def advance_entity(self):
        self.next_entity_num += 1

    def advance_action(self):
        self.next_action_num += 1

    def emit_entity(self, monster, notes=None):
        """INSERT INTO entities."""
        size = resolve_size(monster.get("size"))
        alignment = resolve_alignment(monster.get("alignment"))
        ac_val, armor_desc = resolve_ac(monster.get("ac"))
        hp_max, hd_type, hd_max = resolve_hp(monster.get("hp"))
        speeds = resolve_speed(monster.get("speed"))
        dv, bs, trs, ts = resolve_senses(monster.get("senses"))
        passive = monster.get("passive")
        languages = resolve_languages(monster.get("languages"))

        cols = [
            "id", "name", "entity_type", "size", "alignment",
            "armor_class", "armor_desc",
            "hit_points_max", "hit_points_current",
            "hit_dice_max", "hit_dice_current", "hit_dice_type",
            "speed_walk", "speed_fly", "speed_swim", "speed_climb", "speed_burrow",
            "darkvision", "blindsight", "tremorsense", "truesight",
            "passive_perception_override",
            "languages",
        ]
        vals = [
            self.entity_id, monster["name"], "creature", size, alignment,
            ac_val, armor_desc,
            hp_max, hp_max,
            hd_max, hd_max, hd_type,
            speeds["walk"], speeds["fly"], speeds["swim"],
            speeds["climb"], speeds["burrow"],
            dv, bs, trs, ts,
            passive,
            languages,
        ]

        # Optionally append notes (summonedBySpell etc.)
        if notes:
            cols.append("notes")
            vals.append(notes)

        self.lines.append(
            f"INSERT OR IGNORE INTO entities ({', '.join(cols)})\n"
            f"  VALUES ({', '.join(sql_quote(v) for v in vals)});"
        )

    def emit_stats(self, monster):
        """INSERT INTO entity_stats."""
        cols = [
            "entity_id",
            "strength", "dexterity", "constitution",
            "intelligence", "wisdom", "charisma",
        ]
        vals = [
            self.entity_id,
            monster.get("str", 10),
            monster.get("dex", 10),
            monster.get("con", 10),
            monster.get("int", 10),
            monster.get("wis", 10),
            monster.get("cha", 10),
        ]
        self.lines.append(
            f"INSERT OR IGNORE INTO entity_stats ({', '.join(cols)})\n"
            f"  VALUES ({', '.join(sql_quote(v) for v in vals)});"
        )

    def emit_creature_profile(self, monster):
        """INSERT INTO creature_profiles."""
        cr_float, xp_value = get_cr_xp(monster.get("cr"))
        monster_type = resolve_type_name(monster.get("type", "humanoid"))
        creature_subtype = monster.get("subtype")

        # challenge_rating and xp_value have NOT NULL constraints with defaults
        # (0.0 and 0).  Use defaults when no CR data is available.
        cols = [
            "entity_id", "challenge_rating", "xp_value",
            "creature_type", "creature_subtype",
        ]
        vals = [
            self.entity_id,
            cr_float if cr_float is not None else 0.0,
            xp_value if xp_value is not None else 0,
            monster_type,
            creature_subtype,
        ]

        legendary_actions = monster.get("legendary")
        legendary_resistances = monster.get("legendaryResistances")
        legendary = 1 if (legendary_actions or legendary_resistances) else 0
        leg_max = legendary_resistances or 0
        leg_cur = legendary_resistances or 0
        cols += ["is_legendary", "legendary_resistances_max", "legendary_resistances_current"]
        vals += [legendary, leg_max, leg_cur]

        self.lines.append(
            f"INSERT OR IGNORE INTO creature_profiles ({', '.join(cols)})\n"
            f"  VALUES ({', '.join(sql_quote(v) for v in vals)});"
        )

    def emit_actions(self, actions, action_type="action"):
        """INSERT actions into action_library and link via entity_actions.

        actions: list of dicts with "name" and "entries" keys.
        Shared action names are only inserted once (first occurrence wins);
        subsequent monsters link via SELECT subquery.
        """
        for action in actions:
            action_name = action["name"]
            action_entries = action.get("entries", [])
            action_text = " ".join(flatten_entries(action_entries))

            # Create new library entry if this action name is new
            if action_name.lower() not in self.existing_actions:
                is_atk, atk_bonus, dmg_dice, dmg_type = parse_attack_text(action_text)
                a_id = self.act_id
                self.advance_action()
                self.existing_actions.add(action_name.lower())

                self.lines.append(
                    f"INSERT OR IGNORE INTO action_library "
                    f"(id, name, action_type, description, "
                    f"is_attack, attack_bonus, damage_dice, damage_type)\n"
                    f"  VALUES ({sql_quote(a_id)}, {sql_quote(action_name)}, "
                    f"{sql_quote(action_type)}, {sql_quote(action_text)}, "
                    f"{sql_quote(is_atk)}, {sql_quote(atk_bonus)}, "
                    f"{sql_quote(dmg_dice)}, {sql_quote(dmg_type)});"
                )

            # Link entity → action via name lookup
            self.lines.append(
                f"INSERT OR IGNORE INTO entity_actions (entity_id, action_id)\n"
                f"  SELECT {sql_quote(self.entity_id)}, id "
                f"FROM action_library WHERE name = {sql_quote(action_name)};"
            )

    def emit_damage_modifiers(self, monster):
        """INSERT into entity_damage_modifiers from immune/resist/vulnerable fields."""
        def add(mod_type, field_name):
            entries = monster.get(field_name, [])
            if isinstance(entries, str):
                entries = [entries]
            for entry in entries:
                if isinstance(entry, dict):
                    dmg = entry.get("damageType", "")
                    if dmg:
                        self.lines.append(
                            f"INSERT OR IGNORE INTO entity_damage_modifiers "
                            f"(entity_id, damage_type, modifier_type)\n"
                            f"  VALUES ({sql_quote(self.entity_id)}, "
                            f"{sql_quote(dmg.capitalize())}, {sql_quote(mod_type)});"
                        )
                elif isinstance(entry, str) and entry:
                    self.lines.append(
                        f"INSERT OR IGNORE INTO entity_damage_modifiers "
                        f"(entity_id, damage_type, modifier_type)\n"
                        f"  VALUES ({sql_quote(self.entity_id)}, "
                        f"{sql_quote(entry.capitalize())}, {sql_quote(mod_type)});"
                    )

        add("immunity", "immune")
        add("immunity", "immuneRes")
        add("resistance", "resist")
        add("resistance", "resistRes")
        add("vulnerability", "vulnerable")

    def emit_condition_immunities(self, monster):
        """INSERT into entity_conditions from conditionImmune."""
        cond_immune = monster.get("conditionImmune", [])
        if isinstance(cond_immune, list):
            for ci in cond_immune:
                if isinstance(ci, str) and ci:
                    self.lines.append(
                        f"INSERT OR IGNORE INTO entity_conditions "
                        f"(entity_id, condition_name)\n"
                        f"  VALUES ({sql_quote(self.entity_id)}, "
                        f"{sql_quote(ci.capitalize())});"
                    )

    def emit_all(self, monster, notes=None):
        """Emit all INSERT statements for one monster record."""
        self.emit_entity(monster, notes)
        self.emit_stats(monster)
        self.emit_creature_profile(monster)

        # Actions, bonus actions, reactions, legendary actions
        self.emit_actions(monster.get("action", []), "action")
        self.emit_actions(monster.get("bonus", []), "bonus_action")
        self.emit_actions(monster.get("reaction", []), "reaction")
        self.emit_actions(monster.get("legendary", []), "legendary")

        self.emit_damage_modifiers(monster)
        self.emit_condition_immunities(monster)
        self.lines.append("")


def build_notes(monster):
    """Build a notes string from metadata fields not covered by the schema."""
    parts = []
    spell = monster.get("summonedBySpell")
    if spell:
        parts.append(f"Summoned by: {spell}")
    spl = monster.get("summonedBySpellLevel")
    if spl:
        parts.append(f"Spell level: {spl}")
    source = monster.get("source")
    if source:
        parts.append(f"Source: {source}")
    pb = monster.get("pbNote")
    if pb:
        parts.append(f"PB: {pb}")
    return "; ".join(parts) if parts else None


def _apply_mod_op(merged, block_key, op):
    """Apply a single _mod operation dict to merged."""
    mode = op.get("mode")
    if mode == "removeArr":
        names_to_remove = op.get("names", [])
        if block_key in merged and isinstance(merged[block_key], list):
            merged[block_key] = [
                item for item in merged[block_key]
                if item.get("name") not in names_to_remove
            ]
    elif mode == "renameArr":
        renames = op.get("renames", {})
        rename_from = renames.get("rename")
        rename_to = renames.get("with")
        if rename_from and rename_to:
            for item in merged.get(block_key, []):
                if isinstance(item, dict) and item.get("name") == rename_from:
                    item["name"] = rename_to
    elif mode == "replaceArr":
        replace_name = op.get("replace")
        items = op.get("items")
        if replace_name and items and block_key in merged and isinstance(merged[block_key], list):
            merged[block_key] = [
                items if isinstance(item, dict) and item.get("name") == replace_name
                else item
                for item in merged[block_key]
            ]


def _apply_abstract_template(abstract, variables):
    """Substitute {{var}} placeholders in abstract with concrete values."""
    import copy
    result = copy.deepcopy(abstract)

    def _subst(obj):
        if isinstance(obj, str):
            for key, val in variables.items():
                obj = obj.replace("{{" + key + "}}", val)
            return obj
        if isinstance(obj, dict):
            return {k: _subst(v) for k, v in obj.items()}
        if isinstance(obj, list):
            return [_subst(item) for item in obj]
        return obj

    return _subst(result)


def expand_versions(monster):
    """Yield (monster_dict, is_variant) for all records to insert.

    If the monster has _versions, the base entry is skipped and each version
    becomes its own record.  Versions are merged minimally — the version
    overrides specific fields from the parent.

    Handles:
      - Simple _versions array with _mod (removeArr, renameArr)
      - Single-dict _mod operations (replaceArr for Elemental Spirit)
      - _abstract + _implementations (Draconic Spirit)
      - null trait fields
    """
    versions = monster.pop("_versions", None)
    if not versions:
        yield (monster, False)
        return

    # ── Handle _abstract + _implementations pattern ──────────────────────
    # (e.g. Draconic Spirit: multiple resist types from one template)
    for v in versions:
        if "_abstract" in v:
            abstract = v["_abstract"]
            implementations = v.get("_implementations", [])
            for impl in implementations:
                variables = impl.get("_variables", {})
                concrete = _apply_abstract_template(abstract, variables)
                merged = dict(monster)
                # Apply concrete's overrides onto merged
                for key, val in concrete.items():
                    if key != "_mod":
                        merged[key] = val
                # Apply _mod from concrete
                concrete_mod = concrete.get("_mod", {})
                for block_key in ("action", "trait", "bonus", "reaction", "legendary"):
                    block_ops = concrete_mod.get(block_key)
                    if block_key in merged and block_ops is not None:
                        if isinstance(block_ops, list):
                            for op in block_ops:
                                _apply_mod_op(merged, block_key, op)
                        elif isinstance(block_ops, dict):
                            _apply_mod_op(merged, block_key, block_ops)
                        # If block_ops is None/null, keep merged's existing value
                # Also apply per-implementation variable overrides
                for key in impl:
                    if key != "_variables":
                        merged[key] = impl[key]
                yield (merged, True)
            continue

        # ── Normal version entry ─────────────────────────────────────────
        vname = v.get("name", monster["name"])
        mod = v.get("_mod", {})

        merged = dict(monster)
        merged["name"] = vname

        # Simple field overrides
        for key in ("hp", "ac", "speed", "type", "size", "alignment",
                     "str", "dex", "con", "int", "wis", "cha",
                     "passive", "senses", "languages", "conditionImmune",
                     "immune", "resist", "vulnerable",
                     "damageTags", "senseTags", "miscTags",
                     "summonedBySpell", "summonedBySpellLevel"):
            if key in v:
                merged[key] = v[key]

        # Apply _mod operations
        if mod:
            for block_key in ("action", "trait", "bonus", "reaction", "legendary"):
                block_ops = mod.get(block_key)
                if block_key in merged and block_ops is not None:
                    if isinstance(block_ops, list):
                        for op in block_ops:
                            _apply_mod_op(merged, block_key, op)
                    elif isinstance(block_ops, dict):
                        _apply_mod_op(merged, block_key, block_ops)

        yield (merged, True)


# ── Main ────────────────────────────────────────────────────────────────────

def generate_sql(json_path, db_path, out_path, write_mode=False):
    """Read JSON, query DB, produce SQL file."""
    with open(json_path) as f:
        data = json.load(f)
    monsters = data.get("monster", [])
    fname = Path(json_path).name
    print(f"Read {len(monsters)} monster(s) from {fname}")

    if db_path.exists():
        existing_names, next_entity_num, existing_actions, next_action_num = \
            get_existing_data(db_path)
        print(f"  Existing creatures: {len(existing_names)}")
        print(f"  Next entity ID: mon-{next_entity_num}")
        print(f"  Next action ID: act-{next_action_num}")
    else:
        print("  WARNING: Database not found — assuming clean import")
        existing_names = set()
        next_entity_num = 1
        existing_actions = set()
        next_action_num = 1

    lines = [
        "-- Generated by import_bestiary.py",
        f"-- Source: {fname}",
        "--",
        "-- Use: sqlite3 Assets/5e_data.sqlite < Assets/import_bestiary.sql",
        "",
        "PRAGMA foreign_keys = ON;",
        "BEGIN TRANSACTION;",
        "",
    ]

    emitter = MonsterEmitter(
        lines, next_entity_num, next_action_num,
        existing_actions, existing_names
    )
    new_count = 0
    skipped_count = 0

    for monster in monsters:
        name_lower = monster["name"].lower()

        # ── Expand _versions sub-entries ─────────────────────────────────
        has_versions = "_versions" in monster

        for variant, is_variant in expand_versions(monster):
            vname_lower = variant["name"].lower()

            if vname_lower in emitter.existing_names:
                skipped_count += 1
                label = f"  [SKIP] '{variant['name']}' already exists"
                if not is_variant:
                    # Only print base skip once
                    if not has_versions:
                        print(label)
                continue

            if not has_versions or is_variant:
                print(f"  [NEW]  '{variant['name']}'")

            emitter.skipped = False
            notes = build_notes(variant)
            emitter.emit_all(variant, notes=notes)
            emitter.advance_entity()
            new_count += 1

    lines.append("COMMIT;")
    lines.append("")
    sql = "\n".join(lines)

    print(f"\nSummary: {new_count} new, {skipped_count} skipped")
    print(f"SQL output: {len(lines)} lines")

    if write_mode:
        with open(out_path, "w") as f:
            f.write(sql)
        print(f"Wrote to {out_path}")
    else:
        print("\n" + "=" * 60)
        print(sql)


if __name__ == "__main__":
    args = [a for a in sys.argv[1:] if a != "--write"]
    write_mode = "--write" in sys.argv
    json_path = Path(args[0]) if args else DEFAULT_JSON
    generate_sql(json_path, DB_PATH, OUT_PATH, write_mode=write_mode)

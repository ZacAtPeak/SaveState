#!/usr/bin/env python3
"""Import spells from spells-phb.json into 5e_data.sqlite."""

import json
import re
import sqlite3
from pathlib import Path

SCHOOL_MAP = {
    "A": "Abjuration",
    "C": "Conjuration",
    "D": "Divination",
    "E": "Evocation",
    "I": "Illusion",
    "N": "Necromancy",
    "T": "Transmutation",
    "V": "Enchantment",
}

UNIT_LABELS = {
    "action": "action",
    "bonus": "bonus action",
    "reaction": "reaction",
    "minute": "minute",
    "hour": "hour",
    "day": "day",
}


def slugify(name: str) -> str:
    s = name.lower().strip()
    s = re.sub(r"[^a-z0-9\s-]", "", s)
    s = re.sub(r"\s+", "-", s)
    return s


def make_id(name: str) -> str:
    return f"spell-{slugify(name)}"


def format_time(time_list: list) -> str:
    parts = []
    for t in time_list:
        n = t.get("number", 1)
        u = t.get("unit", "")
        label = UNIT_LABELS.get(u, u)
        if n > 1:
            label += "s" if not label.endswith("s") else ""
        part = f"{n} {label}"
        if "condition" in t:
            part += f" (trigger: {t['condition']})"
        parts.append(part)
    return " or ".join(parts)


def format_range(range_obj: dict) -> str:
    rtype = range_obj.get("type", "")
    dist = range_obj.get("distance", {})
    dtype = dist.get("type", "")
    amount = dist.get("amount")

    if rtype == "special":
        return "Special"
    if dtype == "touch":
        return "Touch"
    if dtype == "self":
        return "Self"
    if dtype == "sight":
        return "Sight"
    if dtype == "unlimited":
        return "Unlimited"
    if dtype == "miles" and amount is not None:
        return f"{amount} mile{'s' if amount > 1 else ''}"
    if dtype == "feet" and amount is not None:
        return f"{amount} feet"
    return rtype.capitalize()


def format_components(comp_obj: dict) -> str:
    parts = []
    if comp_obj.get("v"):
        parts.append("V")
    if comp_obj.get("s"):
        parts.append("S")
    m = comp_obj.get("m")
    if m:
        text = m if isinstance(m, str) else m.get("text", "")
        parts.append(f"M ({text})" if text else "M")
    return ", ".join(parts)


def get_material_cost(comp_obj: dict) :
    m = comp_obj.get("m")
    if isinstance(m, dict):
        cost = m.get("cost")
        if cost is not None:
            return cost // 100
    return None


def get_material_consumed(comp_obj: dict) -> int:
    m = comp_obj.get("m")
    if isinstance(m, dict):
        val = m.get("consume", False)
        return 1 if val is True else 0
    return 0


def format_duration(dur_list: list) -> str:
    parts = []
    for d in dur_list:
        t = d.get("type", "")
        if t == "instant":
            parts.append("Instantaneous")
        elif t == "permanent":
            parts.append("Until dispelled")
        elif t == "special":
            parts.append("Special")
        elif t == "timed":
            dur = d.get("duration", {})
            dt = dur.get("type", "")
            amt = dur.get("amount", 1)
            label = dt + ("s" if amt > 1 else "")
            parts.append(f"{amt} {label}")
    return ", ".join(parts)


def is_concentration(dur_list: list) -> int:
    return 1 if any(d.get("concentration") for d in dur_list) else 0


def flatten_entries(entries: list) -> str:
    texts = []
    for entry in entries:
        if isinstance(entry, str):
            texts.append(entry)
        elif isinstance(entry, dict):
            etype = entry.get("type", "")
            if etype == "entries":
                name = entry.get("name", "")
                if name:
                    texts.append(f"{name}.")
                if "entries" in entry:
                    texts.append(flatten_entries(entry["entries"]))
            elif etype == "list":
                items = entry.get("items", [])
                for item in items:
                    if isinstance(item, str):
                        texts.append(f"- {item}")
                    elif isinstance(item, dict) and "entries" in item:
                        texts.append(f"- {flatten_entries(item['entries'])}")
                    elif isinstance(item, dict) and "item" in item:
                        texts.append(f"- {item['item']}")
            elif etype == "table":
                caption = entry.get("caption", "")
                if caption:
                    texts.append(f"[Table: {caption}]")
            elif "entry" in entry:
                texts.append(entry["entry"])
            elif "entries" in entry:
                texts.append(flatten_entries(entry["entries"]))
    return "\n".join(texts)


def strip_references(text: str) -> str:
    return re.sub(r"\{@\w+\s+(.*?)\}", r"\1", text)


def main():
    base = Path(__file__).resolve().parent
    db_path = base / "5e_data.sqlite"
    json_path = base / "spells-phb.json"

    with open(json_path) as f:
        data = json.load(f)

    conn = sqlite3.connect(str(db_path))
    cur = conn.cursor()

    spells = data["spell"]
    inserted = 0
    scaled = 0

    for s in spells:
        sid = make_id(s["name"])
        school = SCHOOL_MAP.get(s["school"], s["school"])
        casting_time = format_time(s.get("time", []))
        range_obj = s.get("range", {})
        range_text = format_range(range_obj)
        dist = range_obj.get("distance", {})
        comp = s.get("components", {})
        comp_text = format_components(comp)
        dur_list = s.get("duration", [])
        dur_text = format_duration(dur_list)
        conc = is_concentration(dur_list)
        ritual = 1 if s.get("meta", {}).get("ritual") else 0

        desc = strip_references(flatten_entries(s.get("entries", [])))
        higher = s.get("entriesHigherLevel")
        higher_text = (
            strip_references(flatten_entries(higher)) if higher else None
        )

        source = s.get("source", "PHB")
        page = s.get("page")
        srd_val = 1 if s.get("srd") else 0

        def ja(key):
            val = s.get(key)
            return json.dumps(val) if val else None

        cur.execute(
            """
            INSERT OR REPLACE INTO spell_library (
                id, name, level, school,
                casting_time, range, range_type, range_distance_type,
                range_distance_amount, components, material_cost,
                material_consumed, duration, is_concentration, is_ritual,
                description, higher_levels_desc, source, page, srd,
                saving_throw, damage_inflict, condition_inflict, spell_attack,
                damage_immune, damage_resist, damage_vulnerable,
                condition_immune, ability_check, affects_creature_type,
                misc_tags, area_tags
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,
                      ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """,
            (
                sid,
                s["name"],
                s["level"],
                school,
                casting_time,
                range_text,
                range_obj.get("type"),
                dist.get("type"),
                dist.get("amount"),
                comp_text,
                get_material_cost(comp),
                get_material_consumed(comp),
                dur_text,
                conc,
                ritual,
                desc,
                higher_text,
                source,
                page,
                srd_val,
                ja("savingThrow"),
                ja("damageInflict"),
                ja("conditionInflict"),
                ja("spellAttack"),
                ja("damageImmune"),
                ja("damageResist"),
                ja("damageVulnerable"),
                ja("conditionImmune"),
                ja("abilityCheck"),
                ja("affectsCreatureType"),
                ja("miscTags"),
                ja("areaTags"),
            ),
        )
        inserted += 1

        scaling = s.get("scalingLevelDice")
        if scaling and "scaling" in scaling:
            for lvl_str, dice in scaling["scaling"].items():
                cur.execute(
                    "INSERT OR REPLACE INTO spell_scaling (spell_id, character_level, dice) VALUES (?, ?, ?)",
                    (sid, int(lvl_str), dice),
                )
                scaled += 1

    conn.commit()
    conn.close()
    print(f"Imported {inserted} spells, {scaled} scaling entries")


if __name__ == "__main__":
    main()

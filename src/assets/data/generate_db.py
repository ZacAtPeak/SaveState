#!/usr/bin/env python3
import json
import sqlite3
from pathlib import Path
from typing import Any

DATA_DIR = Path(__file__).parent
DB_PATH = DATA_DIR / "data.db"


def to_int(value, default=0):
    try:
        return int(value)
    except (ValueError, TypeError):
        return default


def parse_range(range_obj: dict) -> str:
    if not range_obj:
        return ""
    dist = range_obj.get("distance", {})
    dist_type = dist.get("type", "")
    amount = dist.get("amount", "")
    range_type = range_obj.get("type", "")

    if dist_type == "self":
        return "Self"
    elif dist_type == "touch":
        return "Touch"
    elif dist_type == "unlimited":
        return "Unlimited"
    elif amount:
        return f"{amount} {dist_type}"
    return range_type


def parse_duration(duration: list) -> str:
    if not duration:
        return ""
    dur = duration[0]
    dur_type = dur.get("type", "")
    conc = dur.get("concentration", False)
    length = dur.get("duration", 0)
    time_len = dur.get("time", 0)

    if dur_type == "instant":
        return "Instantaneous"
    elif dur_type == "permanent":
        return "Permanent"
    elif conc:
        return f"Concentration, up to {length} {'rounds' if 'rounds' in dur else 'minutes'}"
    elif time_len:
        return f"{time_len} hours"
    return f"{length} minutes"


def parse_components(components: dict) -> dict:
    return {
        "v": components.get("v", False),
        "s": components.get("s", False),
        "m": bool(components.get("m", False)),
    }


def parse_casting_time(time: list) -> str:
    if not time:
        return ""
    result = []
    for t in time:
        if isinstance(t, str):
            result.append(t)
            continue
        if not isinstance(t, dict):
            continue
        num = t.get("number", 1)
        unit = t.get("unit", "action")
        result.append(f"{num} {unit}")
    return ", ".join(result)


def entries_to_text(entries: list) -> str:
    result = []
    for entry in entries:
        if isinstance(entry, str):
            result.append(entry)
        elif isinstance(entry, dict):
            if entry.get("type") == "entries" and entry.get("name"):
                result.append(f"{entry['name']}: ")
            if entry.get("entries"):
                result.append(entries_to_text(entry["entries"]))
            if entry.get("items"):
                for item in entry["items"]:
                    if isinstance(item, str):
                        result.append(f"  - {item}")
                    elif isinstance(item, dict):
                        result.append(f"  - {item.get('name', '')}: {item.get('entry', '')}")
    return "\n".join(result)


def create_tables(conn: sqlite3.Connection) -> None:
    conn.executescript("""
        CREATE TABLE IF NOT EXISTS sources (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            code TEXT UNIQUE NOT NULL,
            name TEXT NOT NULL
        );

        CREATE TABLE IF NOT EXISTS races (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            source TEXT NOT NULL,
            size TEXT,
            speed_walk INTEGER,
            speed_fly INTEGER,
            speed_swim INTEGER,
            page INTEGER,
            entries TEXT,
            FOREIGN KEY (source) REFERENCES sources(code)
        );

        CREATE TABLE IF NOT EXISTS race_abilities (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            race_id INTEGER NOT NULL,
            ability TEXT NOT NULL,
            value INTEGER NOT NULL,
            FOREIGN KEY (race_id) REFERENCES races(id)
        );

        CREATE TABLE IF NOT EXISTS classes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            source TEXT NOT NULL,
            hd_faces INTEGER,
            page INTEGER,
            entries TEXT,
            FOREIGN KEY (source) REFERENCES sources(code)
        );

        CREATE TABLE IF NOT EXISTS class_proficiencies (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            class_id INTEGER NOT NULL,
            prof_type TEXT NOT NULL,
            value TEXT NOT NULL,
            FOREIGN KEY (class_id) REFERENCES classes(id)
        );

        CREATE TABLE IF NOT EXISTS spells (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            source TEXT NOT NULL,
            level INTEGER,
            school TEXT,
            casting_time TEXT,
            range TEXT,
            duration TEXT,
            components_v INTEGER,
            components_s INTEGER,
            components_m INTEGER,
            page INTEGER,
            entries TEXT,
            damage_inflict TEXT,
            saving_throw TEXT,
            srd INTEGER DEFAULT 0,
            basic_rules INTEGER DEFAULT 0,
            FOREIGN KEY (source) REFERENCES sources(code)
        );

        CREATE TABLE IF NOT EXISTS spell_classes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            spell_id INTEGER NOT NULL,
            class_name TEXT NOT NULL,
            class_source TEXT,
            is_variant INTEGER DEFAULT 0,
            FOREIGN KEY (spell_id) REFERENCES spells(id)
        );

        CREATE TABLE IF NOT EXISTS feats (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            source TEXT NOT NULL,
            category TEXT,
            page INTEGER,
            entries TEXT,
            FOREIGN KEY (source) REFERENCES sources(code)
        );

        CREATE TABLE IF NOT EXISTS items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            source TEXT NOT NULL,
            type TEXT,
            rarity TEXT,
            weight REAL,
            req_attune TEXT,
            wondrous INTEGER DEFAULT 0,
            page INTEGER,
            entries TEXT,
            FOREIGN KEY (source) REFERENCES sources(code)
        );

        CREATE TABLE IF NOT EXISTS skills (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            source TEXT NOT NULL,
            ability TEXT NOT NULL,
            page INTEGER,
            entries TEXT,
            srd INTEGER DEFAULT 0,
            basic_rules INTEGER DEFAULT 0,
            FOREIGN KEY (source) REFERENCES sources(code)
        );

        CREATE TABLE IF NOT EXISTS conditions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            source TEXT NOT NULL,
            page INTEGER,
            entries TEXT,
            srd INTEGER DEFAULT 0,
            basic_rules INTEGER DEFAULT 0,
            FOREIGN KEY (source) REFERENCES sources(code)
        );

        CREATE TABLE IF NOT EXISTS actions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            source TEXT NOT NULL,
            page INTEGER,
            time TEXT,
            entries TEXT,
            srd INTEGER DEFAULT 0,
            basic_rules INTEGER DEFAULT 0,
            FOREIGN KEY (source) REFERENCES sources(code)
        );

        CREATE TABLE IF NOT EXISTS backgrounds (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            source TEXT NOT NULL,
            page INTEGER,
            entries TEXT,
            FOREIGN KEY (source) REFERENCES sources(code)
        );

        CREATE TABLE IF NOT EXISTS encounters (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            source TEXT NOT NULL,
            page INTEGER
        );

        CREATE TABLE IF NOT EXISTS encounter_tables (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            encounter_id INTEGER NOT NULL,
            min_lvl INTEGER,
            max_lvl INTEGER,
            dice_expression TEXT,
            FOREIGN KEY (encounter_id) REFERENCES encounters(id)
        );

        CREATE TABLE IF NOT EXISTS encounter_results (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            table_id INTEGER NOT NULL,
            min_val INTEGER NOT NULL,
            max_val INTEGER NOT NULL,
            result TEXT NOT NULL,
            FOREIGN KEY (table_id) REFERENCES encounter_tables(id)
        );

        CREATE INDEX IF NOT EXISTS idx_spells_name ON spells(name);
        CREATE INDEX IF NOT EXISTS idx_spells_source ON spells(source);
        CREATE INDEX IF NOT EXISTS idx_spells_level ON spells(level);
        CREATE INDEX IF NOT EXISTS idx_races_name ON races(name);
        CREATE INDEX IF NOT EXISTS idx_classes_name ON classes(name);
        CREATE INDEX IF NOT EXISTS idx_feats_name ON feats(name);
        CREATE INDEX IF NOT EXISTS idx_items_name ON items(name);
    """)


def load_spells(conn: sqlite3.Connection) -> None:
    spells_dir = DATA_DIR / "spells"
    index_file = spells_dir / "index.json"

    if not index_file.exists():
        return

    with open(index_file) as f:
        index = json.load(f)

    for source_code, filename in index.items():
        filepath = spells_dir / filename
        if not filepath.exists():
            continue

        with open(filepath) as f:
            data = json.load(f)

        spells = data.get("spell", [])
        for spell in spells:
            components = parse_components(spell.get("components", {}))
            time_str = parse_casting_time(spell.get("time", []))
            range_str = parse_range(spell.get("range", {}))
            duration_str = parse_duration(spell.get("duration", []))
            entries_str = entries_to_text(spell.get("entries", []))
            damage = ",".join(spell.get("damageInflict", []))
            save = ",".join(spell.get("savingThrow", []))

            cursor = conn.execute("""
                INSERT INTO spells (name, source, level, school, casting_time, range,
                    duration, components_v, components_s, components_m, page, entries,
                    damage_inflict, saving_throw, srd, basic_rules)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """, (
                spell.get("name"),
                spell.get("source"),
                spell.get("level"),
                spell.get("school"),
                time_str,
                range_str,
                duration_str,
                components["v"],
                components["s"],
                components["m"],
                spell.get("page"),
                entries_str,
                damage,
                save,
                to_int(spell.get("srd", False)),
                to_int(spell.get("basicRules", False))
            ))
            spell_id = cursor.lastrowid


def load_classes(conn: sqlite3.Connection) -> None:
    classes_dir = DATA_DIR / "class"
    index_file = classes_dir / "index.json"

    if not index_file.exists():
        return

    with open(index_file) as f:
        index = json.load(f)

    for class_name, filename in index.items():
        filepath = classes_dir / filename
        if not filepath.exists():
            continue

        with open(filepath) as f:
            data = json.load(f)

        classes = data.get("class", [])
        for cls in classes:
            entries_str = entries_to_text(cls.get("entries", []))
            hd = cls.get("hd", {})
            hd_faces = hd.get("faces")

            cursor = conn.execute("""
                INSERT INTO classes (name, source, hd_faces, page, entries)
                VALUES (?, ?, ?, ?, ?)
            """, (
                cls.get("name"),
                cls.get("source"),
                hd_faces,
                cls.get("page"),
                entries_str
            ))
            class_id = cursor.lastrowid

            for prof_type, values in cls.get("startingProficiencies", {}).items():
                if isinstance(values, list):
                    for v in values:
                        if isinstance(v, dict) and "choose" in v:
                            choices = ",".join(v["choose"].get("from", []))
                            conn.execute("""
                                INSERT INTO class_proficiencies (class_id, prof_type, value)
                                VALUES (?, ?, ?)
                            """, (class_id, f"{prof_type}_choice", f"choose {v['choose']['count']} from {choices}"))
                        else:
                            conn.execute("""
                                INSERT INTO class_proficiencies (class_id, prof_type, value)
                                VALUES (?, ?, ?)
                            """, (class_id, prof_type, str(v)))


def load_races(conn: sqlite3.Connection) -> None:
    races_file = DATA_DIR / "races.json"
    if not races_file.exists():
        return

    with open(races_file) as f:
        data = json.load(f)

    races = data.get("race", [])
    for race in races:
        speed_data = race.get("speed", {})
        entries_str = entries_to_text(race.get("entries", []))

        if isinstance(speed_data, dict):
            speed_walk = speed_data.get("walk")
            speed_fly = speed_data.get("fly")
            speed_swim = speed_data.get("swim")
        else:
            speed_walk = speed_data
            speed_fly = None
            speed_swim = None

        cursor = conn.execute("""
            INSERT INTO races (name, source, size, speed_walk, speed_fly, speed_swim, page, entries)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            race.get("name"),
            str(race.get("source")),
            ",".join(str(x) for x in race.get("size", [])),
            speed_walk,
            speed_fly,
            speed_swim,
            race.get("page"),
            entries_str
        ))
        race_id = cursor.lastrowid

        for ability in race.get("ability", []):
            for abil, val in ability.items():
                val_str = str(val) if not isinstance(val, int) else val
                conn.execute("""
                    INSERT INTO race_abilities (race_id, ability, value)
                    VALUES (?, ?, ?)
                """, (race_id, abil, val_str))


def load_feats(conn: sqlite3.Connection) -> None:
    feats_file = DATA_DIR / "feats.json"
    if not feats_file.exists():
        return

    with open(feats_file) as f:
        data = json.load(f)

    feats = data.get("feat", [])
    for feat in feats:
        entries_str = entries_to_text(feat.get("entries", []))

        conn.execute("""
            INSERT INTO feats (name, source, category, page, entries)
            VALUES (?, ?, ?, ?, ?)
        """, (
            feat.get("name"),
            feat.get("source"),
            feat.get("category"),
            feat.get("page"),
            entries_str
        ))


def load_items(conn: sqlite3.Connection) -> None:
    items_file = DATA_DIR / "items.json"
    if not items_file.exists():
        return

    with open(items_file) as f:
        data = json.load(f)

    items = data.get("item", [])
    for item in items:
        entries_str = entries_to_text(item.get("entries", []))

        conn.execute("""
            INSERT INTO items (name, source, type, rarity, weight, req_attune, wondrous, page, entries)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            item.get("name"),
            item.get("source"),
            item.get("type"),
            item.get("rarity"),
            item.get("weight"),
            item.get("reqAttune"),
            to_int(item.get("wondrous", False)),
            item.get("page"),
            entries_str
        ))


def load_skills(conn: sqlite3.Connection) -> None:
    skills_file = DATA_DIR / "skills.json"
    if not skills_file.exists():
        return

    with open(skills_file) as f:
        data = json.load(f)

    skills = data.get("skill", [])
    for skill in skills:
        entries_str = entries_to_text(skill.get("entries", []))

        conn.execute("""
            INSERT INTO skills (name, source, ability, page, entries, srd, basic_rules)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        """, (
            skill.get("name"),
            skill.get("source"),
            skill.get("ability"),
            skill.get("page"),
            entries_str,
            to_int(skill.get("srd", False)),
            to_int(skill.get("basicRules", False))
        ))


def load_conditions(conn: sqlite3.Connection) -> None:
    cond_file = DATA_DIR / "conditionsdiseases.json"
    if not cond_file.exists():
        return

    with open(cond_file) as f:
        data = json.load(f)

    conditions = data.get("condition", [])
    for cond in conditions:
        entries_str = entries_to_text(cond.get("entries", []))

        conn.execute("""
            INSERT INTO conditions (name, source, page, entries, srd, basic_rules)
            VALUES (?, ?, ?, ?, ?, ?)
        """, (
            cond.get("name"),
            cond.get("source"),
            cond.get("page"),
            entries_str,
            to_int(cond.get("srd", False)),
            to_int(cond.get("basicRules", False))
        ))


def load_actions(conn: sqlite3.Connection) -> None:
    actions_file = DATA_DIR / "actions.json"
    if not actions_file.exists():
        return

    with open(actions_file) as f:
        data = json.load(f)

    actions = data.get("action", [])
    for action in actions:
        entries_str = entries_to_text(action.get("entries", []))
        time_str = parse_casting_time(action.get("time", []))

        conn.execute("""
            INSERT INTO actions (name, source, page, time, entries, srd, basic_rules)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        """, (
            action.get("name"),
            action.get("source"),
            action.get("page"),
            time_str,
            entries_str,
            to_int(action.get("srd", False)),
            to_int(action.get("basicRules", False))
        ))


def load_backgrounds(conn: sqlite3.Connection) -> None:
    bg_file = DATA_DIR / "backgrounds.json"
    if not bg_file.exists():
        return

    with open(bg_file) as f:
        data = json.load(f)

    backgrounds = data.get("background", [])
    for bg in backgrounds:
        entries_str = entries_to_text(bg.get("entries", []))

        conn.execute("""
            INSERT INTO backgrounds (name, source, page, entries)
            VALUES (?, ?, ?, ?)
        """, (
            bg.get("name"),
            bg.get("source"),
            bg.get("page"),
            entries_str
        ))


def load_encounters(conn: sqlite3.Connection) -> None:
    enc_file = DATA_DIR / "encounters.json"
    if not enc_file.exists():
        return

    with open(enc_file) as f:
        data = json.load(f)

    encounters = data.get("encounter", [])
    for enc in encounters:
        cursor = conn.execute("""
            INSERT INTO encounters (name, source, page)
            VALUES (?, ?, ?)
        """, (enc.get("name"), enc.get("source"), enc.get("page")))
        enc_id = cursor.lastrowid

        for table in enc.get("tables", []):
            cursor = conn.execute("""
                INSERT INTO encounter_tables (encounter_id, min_lvl, max_lvl, dice_expression)
                VALUES (?, ?, ?, ?)
            """, (enc_id, table.get("minlvl"), table.get("maxlvl"), table.get("diceExpression")))
            table_id = cursor.lastrowid

            for row in table.get("table", []):
                conn.execute("""
                    INSERT INTO encounter_results (table_id, min_val, max_val, result)
                    VALUES (?, ?, ?, ?)
                """, (table_id, row.get("min"), row.get("max"), row.get("result")))


def main():
    if DB_PATH.exists():
        DB_PATH.unlink()

    conn = sqlite3.connect(DB_PATH)

    print("Creating tables...")
    create_tables(conn)

    print("Loading spells...")
    load_spells(conn)

    print("Loading classes...")
    load_classes(conn)

    print("Loading races...")
    load_races(conn)

    print("Loading feats...")
    load_feats(conn)

    print("Loading items...")
    load_items(conn)

    print("Loading skills...")
    load_skills(conn)

    print("Loading conditions...")
    load_conditions(conn)

    print("Loading actions...")
    load_actions(conn)

    print("Loading backgrounds...")
    load_backgrounds(conn)

    print("Loading encounters...")
    load_encounters(conn)

    conn.commit()

    cursor = conn.execute("SELECT COUNT(*) FROM spells")
    spell_count = cursor.fetchone()[0]
    cursor = conn.execute("SELECT COUNT(*) FROM classes")
    class_count = cursor.fetchone()[0]
    cursor = conn.execute("SELECT COUNT(*) FROM races")
    race_count = cursor.fetchone()[0]
    cursor = conn.execute("SELECT COUNT(*) FROM feats")
    feat_count = cursor.fetchone()[0]
    cursor = conn.execute("SELECT COUNT(*) FROM items")
    item_count = cursor.fetchone()[0]

    print(f"\nDatabase created: {DB_PATH}")
    print(f"  Spells: {spell_count}")
    print(f"  Classes: {class_count}")
    print(f"  Races: {race_count}")
    print(f"  Feats: {feat_count}")
    print(f"  Items: {item_count}")

    conn.close()


if __name__ == "__main__":
    main()
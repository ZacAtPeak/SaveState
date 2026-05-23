use crate::db::DbPool;

/// Normalize an ability name to its three-letter abbreviation.
fn normalize_ability(name: &str) -> String {
    let lower = name.to_lowercase();
    match lower.as_str() {
        "strength" | "str" => "STR".to_string(),
        "dexterity" | "dex" => "DEX".to_string(),
        "constitution" | "con" => "CON".to_string(),
        "intelligence" | "int" => "INT".to_string(),
        "wisdom" | "wis" => "WIS".to_string(),
        "charisma" | "cha" => "CHA".to_string(),
        _ => {
            // Try to extract uppercase letters (e.g., from "STR or DEX")
            let cleaned: String = lower.chars().filter(|c| c.is_ascii_uppercase()).collect();
            match cleaned.as_str() {
                "STR" | "DEX" | "CON" | "INT" | "WIS" | "CHA" => cleaned,
                _ => "INT".to_string(),
            }
        }
    }
}
use crate::models::{SpellSlot, SpellSlotGroup, SpellSlotsResponse};
use rusqlite::Connection;
use tauri::State;

/// A character's class info for slot computation: class id, subclass id, level, and caster type.
#[derive(Clone)]
struct ClassSlotInfo {
    class_id: String,
    subclass_id: Option<String>,
    level: i32,
    caster_type: String, // "full", "half", "half_up", "third", "pact", "none"
}

/// Compute the spellcasting ability, save DC, and attack bonus for a character.
/// If no entity_spellcasting row exists, we derive sensible defaults from the primary class.
fn get_spellcasting_stats(
    conn: &Connection,
    entity_id: &str,
) -> Result<(String, i32, i32), String> {
    // Try reading from entity_spellcasting first
    let result = conn.query_row(
        "SELECT spellcasting_ability, spell_save_dc_override, spell_attack_bonus_override
         FROM entity_spellcasting WHERE entity_id = ?1",
        [entity_id],
        |row| {
            let ability: String = row.get(0)?;
            let save_dc_override: Option<i32> = row.get(1)?;
            let attack_bonus_override: Option<i32> = row.get(2)?;
            Ok((ability, save_dc_override, attack_bonus_override))
        },
    );

    match result {
        Ok((ability, save_dc_override, attack_bonus_override)) => {
            // If we have overrides, use them. Otherwise compute from ability + proficiency.
            let save_dc = save_dc_override.unwrap_or(10); // fallback
            let attack_bonus = attack_bonus_override.unwrap_or(0);
            Ok((ability, save_dc, attack_bonus))
        }
        Err(_) => {
            // No entity_spellcasting row — derive from the primary class.
            // Look up the primary class's primary_ability to determine spellcasting ability.
            let result: Result<String, _> = conn.query_row(
                "SELECT c.primary_ability FROM classes c
                 JOIN character_classes cc ON cc.class_id = c.id
                 WHERE cc.entity_id = ?1 AND cc.is_primary = 1
                 LIMIT 1",
                [entity_id],
                |row| row.get::<_, String>(0),
            );

            match result {
                Ok(ability) => {
                    // Compute ability modifier + proficiency bonus
                    let ability_lower = ability
                        .split(|c: char| !c.is_alphabetic())
                        .next()
                        .unwrap_or("INT")
                        .to_lowercase();
                    let ability_short = normalize_ability(&ability_lower);

                    Ok((ability_short, 10 + 2, 2)) // placeholder — we'll compute properly
                }
                Err(_) => Ok(("INT".to_string(), 10, 0)), // fallback defaults
            }
        }
    }
}

/// Read all class info for a character from character_classes + classes + subclasses.
fn get_character_classes(conn: &Connection, entity_id: &str) -> Result<Vec<ClassSlotInfo>, String> {
    let mut stmt = conn
        .prepare(
            "SELECT cc.class_id, cc.subclass_id, cc.class_level,
                    c.spellcaster_type,
                    COALESCE(sc.spellcaster_type, c.spellcaster_type) as effective_caster_type
             FROM character_classes cc
             JOIN classes c ON c.id = cc.class_id
             LEFT JOIN subclasses sc ON sc.id = cc.subclass_id
             WHERE cc.entity_id = ?1",
        )
        .map_err(|e| e.to_string())?;

    let classes = stmt
        .query_map([entity_id], |row| {
            let caster_type: String = row.get(4)?;
            Ok(ClassSlotInfo {
                class_id: row.get(0)?,
                subclass_id: row.get(1)?,
                level: row.get(2)?,
                caster_type,
            })
        })
        .map_err(|e| e.to_string())?
        .filter_map(|r| r.ok())
        .collect();

    Ok(classes)
}

/// Compute the multiclass caster level using the 5e formula.
/// - Full: contributes full level
/// - Half: contributes floor(level/2)
/// - Half_up (Artificer): contributes ceil(level/2)
/// - Third: contributes floor(level/3)
/// - Pact: contributes 0 (tracked separately)
/// - None: contributes 0
fn compute_multiclass_caster_level(classes: &[ClassSlotInfo]) -> (i32, Vec<i32>) {
    let mut caster_level = 0i32;
    let mut warlock_levels = Vec::new();

    for c in classes {
        match c.caster_type.as_str() {
            "full" => caster_level += c.level,
            "half" => caster_level += c.level / 2,
            "half_up" => caster_level += (c.level + 1) / 2, // ceil(level/2)
            "third" => caster_level += c.level / 3,
            "pact" => warlock_levels.push(c.level),
            _ => {} // "none" contributes 0
        }
    }

    (caster_level.min(20), warlock_levels)
}

/// Look up spell slots from class_level_progression for a given class_id and level.
/// Returns a Vec of (level, count) for levels 1-9.
fn lookup_progression(conn: &Connection, class_id: &str, level: i32) -> Result<Vec<(i32, i32)>, String> {
    let mut stmt = conn
        .prepare(
            "SELECT slots_lvl_1, slots_lvl_2, slots_lvl_3, slots_lvl_4, slots_lvl_5,
                    slots_lvl_6, slots_lvl_7, slots_lvl_8, slots_lvl_9
             FROM class_level_progression
             WHERE class_id = ?1 AND level = ?2",
        )
        .map_err(|e| e.to_string())?;

    let slots = stmt
        .query_row([class_id, &level.to_string()], |row| {
            Ok(vec![
                row.get::<_, i32>(0)?,
                row.get::<_, i32>(1)?,
                row.get::<_, i32>(2)?,
                row.get::<_, i32>(3)?,
                row.get::<_, i32>(4)?,
                row.get::<_, i32>(5)?,
                row.get::<_, i32>(6)?,
                row.get::<_, i32>(7)?,
                row.get::<_, i32>(8)?,
            ])
        })
        .map_err(|e| e.to_string())?;

    Ok(slots
        .into_iter()
        .enumerate()
        .filter(|(_, count)| *count > 0)
        .map(|(i, count)| ((i + 1) as i32, count))
        .collect())
}

/// Check if a character has only one class (single-class).
fn is_single_class(classes: &[ClassSlotInfo]) -> bool {
    classes.len() == 1
}

/// For single-class non-pact casters, look up slots directly from their class progression.
fn single_class_slots(
    conn: &Connection,
    classes: &[ClassSlotInfo],
) -> Result<Vec<SpellSlotGroup>, String> {
    let primary = &classes[0];
    let level = primary.level;
    let class_id = &primary.class_id;

    if primary.caster_type == "pact" {
        // Single-class warlock — get pact slots
        return pact_slots(conn, level);
    }

    if primary.caster_type == "none" {
        return Ok(Vec::new());
    }

    // Regular single-class caster: look up from class_level_progression
    let slots = lookup_progression(conn, class_id, level)?;
    if slots.is_empty() {
        return Ok(Vec::new());
    }

    let spell_slots: Vec<SpellSlot> = slots
        .into_iter()
        .map(|(lvl, max_count)| SpellSlot {
            level: lvl,
            max: max_count,
            current: max_count, // Will be merged with persisted state later
        })
        .collect();

    Ok(vec![SpellSlotGroup {
        group_type: "spellcasting".to_string(),
        spellcasting_ability: "INT".to_string(), // placeholder
        save_dc: 10,
        attack_bonus: 0,
        slots: spell_slots,
    }])
}

/// Compute pact magic slots for given warlock levels.
fn pact_slots(conn: &Connection, total_warlock_levels: i32) -> Result<Vec<SpellSlotGroup>, String> {
    if total_warlock_levels <= 0 {
        return Ok(Vec::new());
    }

    let slots = lookup_progression(conn, "warlock", total_warlock_levels)?;
    if slots.is_empty() {
        return Ok(Vec::new());
    }

    let spell_slots: Vec<SpellSlot> = slots
        .into_iter()
        .map(|(lvl, count)| SpellSlot {
            level: lvl,
            max: count,
            current: count, // Will be merged
        })
        .collect();

    Ok(vec![SpellSlotGroup {
        group_type: "pact_magic".to_string(),
        spellcasting_ability: "CHA".to_string(),
        save_dc: 10,
        attack_bonus: 0,
        slots: spell_slots,
    }])
}

/// Merge derived max slots with persisted current values from entity_spell_slot_state.
fn merge_with_persisted(
    groups: Vec<SpellSlotGroup>,
    conn: &Connection,
    entity_id: &str,
) -> Result<Vec<SpellSlotGroup>, String> {
    let mut stmt = conn
        .prepare(
            "SELECT slot_type, slot_level, slots_curr
             FROM entity_spell_slot_state
             WHERE entity_id = ?1",
        )
        .map_err(|e| e.to_string())?;

    let persisted: Vec<(String, i32, i32)> = stmt
        .query_map([entity_id], |row| {
            Ok((row.get::<_, String>(0)?, row.get::<_, i32>(1)?, row.get::<_, i32>(2)?))
        })
        .map_err(|e| e.to_string())?
        .filter_map(|r| r.ok())
        .collect();

    if persisted.is_empty() {
        return Ok(groups); // Nothing to merge, return max-based slots
    }

    let mut result = Vec::new();
    for mut group in groups {
        for slot in &mut group.slots {
            // Look for a persisted value for this slot_type + level
            if let Some((_, _, curr)) = persisted.iter().find(|(st, lvl, _)| {
                st == &group.group_type && *lvl == slot.level
            }) {
                slot.current = *curr;
            }
        }
        result.push(group);
    }

    Ok(result)
}

/// Compute max spell slots for a character and merge with persisted state.
/// This is the main internal function used by get_spell_slots.
fn compute_slots(
    conn: &Connection,
    entity_id: &str,
) -> Result<Vec<SpellSlotGroup>, String> {
    let classes = get_character_classes(conn, entity_id)?;

    if classes.is_empty() {
        return Ok(Vec::new());
    }

    let mut groups = Vec::new();

    // Separate warlock from regular classes
    let regular: Vec<&ClassSlotInfo> = classes.iter().filter(|c| c.caster_type != "pact").collect();
    let warlock: Vec<&ClassSlotInfo> = classes.iter().filter(|c| c.caster_type == "pact").collect();

    // Compute regular spellcasting slots
    if !regular.is_empty() {
        if is_single_class(&regular.iter().map(|c| ClassSlotInfo {
            class_id: c.class_id.clone(),
            subclass_id: c.subclass_id.clone(),
            level: c.level,
            caster_type: c.caster_type.clone(),
        }).collect::<Vec<_>>()) {
            // Single class: direct lookup
            if let Ok(mut single_groups) = single_class_slots(conn, &vec![classes[0].clone()]) {
                groups.append(&mut single_groups);
            }
        } else {
            // Multiclass: use caster level formula
            let (caster_level, _) = compute_multiclass_caster_level(&regular.iter().map(|c| ClassSlotInfo {
                class_id: c.class_id.clone(),
                subclass_id: c.subclass_id.clone(),
                level: c.level,
                caster_type: c.caster_type.clone(),
            }).collect::<Vec<_>>());

            if caster_level > 0 {
                // Look up from the full caster table using a full caster class id
                // We use 'wizard' as the reference full caster class for the multiclass table
                let slots = lookup_progression(conn, "wizard", caster_level)?;
                if !slots.is_empty() {
                    let spell_slots: Vec<SpellSlot> = slots
                        .into_iter()
                        .map(|(lvl, max_count)| SpellSlot {
                            level: lvl,
                            max: max_count,
                            current: max_count,
                        })
                        .collect();

                    groups.push(SpellSlotGroup {
                        group_type: "spellcasting".to_string(),
                        spellcasting_ability: "INT".to_string(),
                        save_dc: 10,
                        attack_bonus: 0,
                        slots: spell_slots,
                    });
                }
            }
        }
    }

    // Compute Pact Magic slots
    if !warlock.is_empty() {
        let total_warlock_levels: i32 = warlock.iter().map(|c| c.level).sum();
        if let Ok(mut pact_groups) = pact_slots(conn, total_warlock_levels) {
            groups.append(&mut pact_groups);
        }
    }

    // Merge with persisted state
    let merged = merge_with_persisted(groups, conn, entity_id)?;

    // Update spellcasting ability, save DC, attack bonus from entity_spellcasting
    let (ability, save_dc, attack_bonus) = get_spellcasting_stats(conn, entity_id)?;
    let merged: Vec<SpellSlotGroup> = merged
        .into_iter()
        .map(|mut g| {
            g.spellcasting_ability = ability.clone();
            g.save_dc = save_dc;
            g.attack_bonus = attack_bonus;
            g
        })
        .collect();

    Ok(merged)
}

/// Tauri command: Get the current spell slot state for a character.
/// Computes max slots from class/level, merges with persisted current values.
#[tauri::command]
pub fn get_spell_slots(
    entity_id: String,
    state: State<DbPool>,
) -> Result<SpellSlotsResponse, String> {
    let conn = state.lock()?;
    let groups = compute_slots(&conn, &entity_id)?;
    Ok(SpellSlotsResponse { groups })
}

/// Tauri command: Perform a long rest — resets HP to max and restores all spell slots
/// for all player characters.
#[tauri::command]
pub fn long_rest(state: State<DbPool>) -> Result<(), String> {
    let conn = state.lock()?;

    // Reset HP to max for all PCs
    conn.execute(
        "UPDATE entities SET hit_points_current = hit_points_max WHERE entity_type = 'pc'",
        [],
    )
    .map_err(|e| e.to_string())?;

    // Delete persisted spell slot state for all PCs so they recompute to max
    conn.execute(
        "DELETE FROM entity_spell_slot_state WHERE entity_id IN (SELECT id FROM entities WHERE entity_type = 'pc')",
        [],
    )
    .map_err(|e| e.to_string())?;

    Ok(())
}

/// Tauri command: Upsert the current value for a single slot level.
/// Clamps slots_curr to [0, computed_max] before writing.
#[tauri::command]
pub fn set_spell_slots(
    entity_id: String,
    slot_type: String,
    slot_level: i32,
    slots_curr: i32,
    state: State<DbPool>,
) -> Result<(), String> {
    let conn = state.lock()?;

    // Compute max for this slot type + level to clamp
    let groups = compute_slots(&conn, &entity_id)?;
    let computed_max = groups
        .iter()
        .find(|g| g.group_type == slot_type)
        .and_then(|g| g.slots.iter().find(|s| s.level == slot_level))
        .map(|s| s.max)
        .unwrap_or(0);

    let clamped = slots_curr.max(0).min(computed_max);

    conn.execute(
        "INSERT INTO entity_spell_slot_state (entity_id, slot_type, slot_level, slots_curr)
         VALUES (?1, ?2, ?3, ?4)
         ON CONFLICT(entity_id, slot_type, slot_level)
         DO UPDATE SET slots_curr = ?4",
        [&entity_id, &slot_type, &slot_level.to_string(), &clamped.to_string()],
    )
    .map_err(|e| e.to_string())?;

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use rusqlite::Connection;

    fn setup_test_db() -> Connection {
        let conn = Connection::open_in_memory().unwrap();
        conn.execute_batch(
            "
            CREATE TABLE classes (
                id TEXT PRIMARY KEY,
                name TEXT NOT NULL,
                hit_die TEXT NOT NULL,
                saving_throw_1 TEXT NOT NULL,
                saving_throw_2 TEXT NOT NULL,
                primary_ability TEXT,
                description TEXT,
                skill_picks INTEGER NOT NULL DEFAULT 2,
                spellcaster_type TEXT NOT NULL DEFAULT 'none'
                    CHECK (spellcaster_type IN ('full', 'half', 'half_up', 'third', 'pact', 'none'))
            );
            CREATE TABLE subclasses (
                id TEXT PRIMARY KEY,
                class_id TEXT NOT NULL,
                name TEXT NOT NULL,
                description TEXT,
                spellcaster_type TEXT DEFAULT NULL
                    CHECK (spellcaster_type IS NULL OR spellcaster_type IN ('third'))
            );
            CREATE TABLE character_classes (
                entity_id TEXT,
                class_id TEXT,
                subclass_id TEXT,
                class_level INTEGER NOT NULL DEFAULT 1,
                is_primary INTEGER NOT NULL DEFAULT 0,
                PRIMARY KEY (entity_id, class_id)
            );
            CREATE TABLE class_level_progression (
                class_id TEXT,
                level INTEGER NOT NULL CHECK (level BETWEEN 1 AND 20),
                proficiency_bonus INTEGER NOT NULL,
                features TEXT,
                slots_lvl_1 INTEGER NOT NULL DEFAULT 0,
                slots_lvl_2 INTEGER NOT NULL DEFAULT 0,
                slots_lvl_3 INTEGER NOT NULL DEFAULT 0,
                slots_lvl_4 INTEGER NOT NULL DEFAULT 0,
                slots_lvl_5 INTEGER NOT NULL DEFAULT 0,
                slots_lvl_6 INTEGER NOT NULL DEFAULT 0,
                slots_lvl_7 INTEGER NOT NULL DEFAULT 0,
                slots_lvl_8 INTEGER NOT NULL DEFAULT 0,
                slots_lvl_9 INTEGER NOT NULL DEFAULT 0,
                PRIMARY KEY (class_id, level)
            );
            CREATE TABLE entity_spell_slot_state (
                entity_id TEXT NOT NULL,
                slot_type TEXT NOT NULL CHECK (slot_type IN ('spellcasting', 'pact_magic')),
                slot_level INTEGER NOT NULL CHECK (slot_level BETWEEN 1 AND 9),
                slots_curr INTEGER NOT NULL DEFAULT 0,
                PRIMARY KEY (entity_id, slot_type, slot_level)
            );
            CREATE TABLE entities (
                id TEXT PRIMARY KEY,
                name TEXT NOT NULL,
                entity_type TEXT NOT NULL,
                armor_class INTEGER NOT NULL DEFAULT 10,
                hit_points_max INTEGER NOT NULL DEFAULT 10,
                hit_points_current INTEGER NOT NULL DEFAULT 10
            );
            CREATE TABLE entity_spellcasting (
                entity_id TEXT PRIMARY KEY,
                spellcasting_ability TEXT NOT NULL,
                spell_save_dc_override INTEGER,
                spell_attack_bonus_override INTEGER,
                slots_lvl_1_max INTEGER NOT NULL DEFAULT 0,
                slots_lvl_1_curr INTEGER NOT NULL DEFAULT 0,
                slots_lvl_2_max INTEGER NOT NULL DEFAULT 0,
                slots_lvl_2_curr INTEGER NOT NULL DEFAULT 0,
                slots_lvl_3_max INTEGER NOT NULL DEFAULT 0,
                slots_lvl_3_curr INTEGER NOT NULL DEFAULT 0
            );

            -- Insert classes
            INSERT INTO classes (id, name, hit_die, saving_throw_1, saving_throw_2, skill_picks, spellcaster_type) VALUES
                ('wizard', 'Wizard', 'd6', 'INT', 'WIS', 2, 'full'),
                ('paladin', 'Paladin', 'd10', 'WIS', 'CHA', 2, 'half'),
                ('warlock', 'Warlock', 'd8', 'WIS', 'CHA', 2, 'pact'),
                ('fighter', 'Fighter', 'd10', 'STR', 'CON', 2, 'none');

            -- Insert subclasses
            INSERT INTO subclasses (id, class_id, name, spellcaster_type) VALUES
                ('fighter_eldritch_knight', 'fighter', 'Eldritch Knight', 'third');

            -- Insert full caster progression data (same for multiclass)
            INSERT INTO class_level_progression (class_id, level, proficiency_bonus, slots_lvl_1, slots_lvl_2, slots_lvl_3, slots_lvl_4, slots_lvl_5) VALUES
                ('wizard', 1, 2, 2, 0, 0, 0, 0),
                ('wizard', 2, 2, 3, 0, 0, 0, 0),
                ('wizard', 3, 2, 4, 2, 0, 0, 0),
                ('wizard', 4, 2, 4, 3, 0, 0, 0),
                ('wizard', 5, 3, 4, 3, 2, 0, 0);

            -- Insert half caster progression
            INSERT INTO class_level_progression (class_id, level, proficiency_bonus, slots_lvl_1, slots_lvl_2, slots_lvl_3, slots_lvl_4, slots_lvl_5) VALUES
                ('paladin', 1, 2, 0, 0, 0, 0, 0),
                ('paladin', 2, 2, 2, 0, 0, 0, 0),
                ('paladin', 3, 2, 3, 0, 0, 0, 0),
                ('paladin', 4, 2, 3, 0, 0, 0, 0),
                ('paladin', 5, 3, 4, 2, 0, 0, 0);

            -- Insert pact progression
            INSERT INTO class_level_progression (class_id, level, proficiency_bonus, slots_lvl_1, slots_lvl_2, slots_lvl_3, slots_lvl_4, slots_lvl_5) VALUES
                ('warlock', 1, 2, 1, 0, 0, 0, 0),
                ('warlock', 2, 2, 2, 0, 0, 0, 0),
                ('warlock', 3, 2, 0, 2, 0, 0, 0),
                ('warlock', 4, 2, 0, 2, 0, 0, 0),
                ('warlock', 5, 3, 0, 0, 2, 0, 0);
            ",
        )
        .unwrap();
        conn
    }

    fn insert_test_character_classes(conn: &Connection, entity_id: &str, class_id: &str, level: i32, subclass: Option<&str>) {
        conn.execute(
            "INSERT INTO character_classes (entity_id, class_id, subclass_id, class_level, is_primary) VALUES (?1, ?2, ?3, ?4, 1)",
            [entity_id, class_id, subclass.unwrap_or(""), &level.to_string()],
        )
        .unwrap();
    }

    #[test]
    fn test_single_class_full_caster_slots() {
        let conn = setup_test_db();
        insert_test_character_classes(&conn, "entity-1", "wizard", 5, None);

        let classes = get_character_classes(&conn, "entity-1").unwrap();
        assert_eq!(classes.len(), 1);
        assert_eq!(classes[0].caster_type, "full");

        let (caster_level, warlock_levels) = compute_multiclass_caster_level(&classes);
        assert_eq!(caster_level, 5);
        assert!(warlock_levels.is_empty());

        let slots = single_class_slots(&conn, &classes).unwrap();
        assert_eq!(slots.len(), 1);
        assert_eq!(slots[0].group_type, "spellcasting");
        assert_eq!(slots[0].slots.len(), 3); // 2 first, 3 second, 2 third — but only non-zero entries

        // Check specific slot levels
        let lvl1 = slots[0].slots.iter().find(|s| s.level == 1).unwrap();
        assert_eq!(lvl1.max, 4);
        let lvl2 = slots[0].slots.iter().find(|s| s.level == 2).unwrap();
        assert_eq!(lvl2.max, 3);
        let lvl3 = slots[0].slots.iter().find(|s| s.level == 3).unwrap();
        assert_eq!(lvl3.max, 2);
    }

    #[test]
    fn test_half_caster_slots() {
        let conn = setup_test_db();
        insert_test_character_classes(&conn, "entity-2", "paladin", 5, None);

        let classes = get_character_classes(&conn, "entity-2").unwrap();
        let slots = single_class_slots(&conn, &classes).unwrap();
        assert_eq!(slots.len(), 1);
        assert_eq!(slots[0].group_type, "spellcasting");

        // Paladin 5 should have 4 first-level and 2 second-level
        let lvl1 = slots[0].slots.iter().find(|s| s.level == 1).unwrap();
        assert_eq!(lvl1.max, 4);
        let lvl2 = slots[0].slots.iter().find(|s| s.level == 2).unwrap();
        assert_eq!(lvl2.max, 2);
    }

    #[test]
    fn test_pact_slots() {
        let conn = setup_test_db();
        insert_test_character_classes(&conn, "entity-3", "warlock", 5, None);

        let classes = get_character_classes(&conn, "entity-3").unwrap();
        assert_eq!(classes[0].caster_type, "pact");

        let slots = single_class_slots(&conn, &classes).unwrap();
        assert_eq!(slots.len(), 1);
        assert_eq!(slots[0].group_type, "pact_magic");

        // Warlock 5 should have 2 third-level slots
        let lvl3 = slots[0].slots.iter().find(|s| s.level == 3).unwrap();
        assert_eq!(lvl3.max, 2);
    }

    #[test]
    fn test_multiclass_full_plus_half() {
        let conn = setup_test_db();
        // Paladin 4 / Wizard 3 → caster level = floor(4/2) + 3 = 5
        insert_test_character_classes(&conn, "entity-4", "paladin", 4, None);
        conn.execute(
            "INSERT INTO character_classes (entity_id, class_id, subclass_id, class_level, is_primary) VALUES ('entity-4', 'wizard', '', 3, 0)",
            [],
        )
        .unwrap();

        let classes = get_character_classes(&conn, "entity-4").unwrap();
        assert_eq!(classes.len(), 2);

        let (caster_level, _) = compute_multiclass_caster_level(&classes);
        assert_eq!(caster_level, 5);

        // At caster level 5, slots should be 4/3/2
        let slots = lookup_progression(&conn, "wizard", caster_level).unwrap();
        assert_eq!(slots.iter().find(|(l, _)| *l == 1).unwrap().1, 4);
        assert_eq!(slots.iter().find(|(l, _)| *l == 2).unwrap().1, 3);
        assert_eq!(slots.iter().find(|(l, _)| *l == 3).unwrap().1, 2);
    }

    #[test]
    fn test_non_caster_no_slots() {
        let conn = setup_test_db();
        insert_test_character_classes(&conn, "entity-5", "fighter", 5, None);

        let classes = get_character_classes(&conn, "entity-5").unwrap();
        assert_eq!(classes[0].caster_type, "none");

        let slots = single_class_slots(&conn, &classes).unwrap();
        assert!(slots.is_empty());
    }

    #[test]
    fn test_multiclass_caster_level_formula() {
        // Various combinations
        let test_cases: Vec<(&str, i32, &str, i32, i32)> = vec![
            ("full", 3, "half", 4, 5),   // 3 + floor(4/2) = 5
            ("full", 2, "third", 8, 4),   // 2 + floor(8/3) = 4
            ("none", 5, "none", 3, 0),    // 0 + 0 = 0
            ("half", 6, "half", 6, 6),    // 3 + 3 = 6
            ("full", 1, "full", 1, 2),    // 1 + 1 = 2
        ];

        for (type1, lvl1, type2, lvl2, expected) in test_cases {
            let classes = vec![
                ClassSlotInfo {
                    class_id: "test1".to_string(),
                    subclass_id: None,
                    level: lvl1,
                    caster_type: type1.to_string(),
                },
                ClassSlotInfo {
                    class_id: "test2".to_string(),
                    subclass_id: None,
                    level: lvl2,
                    caster_type: type2.to_string(),
                },
            ];
            let (caster_level, _) = compute_multiclass_caster_level(&classes);
            assert_eq!(caster_level, expected, "Failed for {} {} / {} {}", type1, lvl1, type2, lvl2);
        }
    }

    #[test]
    fn test_merge_with_persisted() {
        let conn = setup_test_db();
        insert_test_character_classes(&conn, "entity-6", "wizard", 5, None);

        // Insert some persisted state: 2 first-level used, 0 second-level remaining
        conn.execute(
            "INSERT INTO entity_spell_slot_state (entity_id, slot_type, slot_level, slots_curr) VALUES ('entity-6', 'spellcasting', 1, 2)",
            [],
        )
        .unwrap();
        conn.execute(
            "INSERT INTO entity_spell_slot_state (entity_id, slot_type, slot_level, slots_curr) VALUES ('entity-6', 'spellcasting', 2, 0)",
            [],
        )
        .unwrap();

        let raw_groups = single_class_slots(&conn, &get_character_classes(&conn, "entity-6").unwrap()).unwrap();
        assert_eq!(raw_groups[0].slots.iter().find(|s| s.level == 1).unwrap().current, 4); // max before merge

        let merged = merge_with_persisted(raw_groups, &conn, "entity-6").unwrap();
        assert_eq!(merged[0].slots.iter().find(|s| s.level == 1).unwrap().current, 2);
        assert_eq!(merged[0].slots.iter().find(|s| s.level == 1).unwrap().max, 4);
        assert_eq!(merged[0].slots.iter().find(|s| s.level == 2).unwrap().current, 0);
        assert_eq!(merged[0].slots.iter().find(|s| s.level == 2).unwrap().max, 3);
        assert_eq!(merged[0].slots.iter().find(|s| s.level == 3).unwrap().current, 2); // not persisted, uses max
    }

    #[test]
    fn test_eldritch_knight_multiclass() {
        let conn = setup_test_db();
        // Fighter (EK) 8 / Wizard 2 → caster level = floor(8/3) + 2 = 4
        insert_test_character_classes(&conn, "entity-7", "fighter", 8, Some("fighter_eldritch_knight"));
        conn.execute(
            "INSERT INTO character_classes (entity_id, class_id, subclass_id, class_level, is_primary) VALUES ('entity-7', 'wizard', '', 2, 0)",
            [],
        )
        .unwrap();

        let classes = get_character_classes(&conn, "entity-7").unwrap();
        let (caster_level, _) = compute_multiclass_caster_level(&classes);
        assert_eq!(caster_level, 4);
    }

    #[test]
    fn test_compute_slots_full_caster() {
        let conn = setup_test_db();
        insert_test_character_classes(&conn, "entity-8", "wizard", 5, None);

        let groups = compute_slots(&conn, "entity-8").unwrap();
        assert_eq!(groups.len(), 1);
        assert_eq!(groups[0].group_type, "spellcasting");
        assert!(!groups[0].slots.is_empty());

        let lvl1 = groups[0].slots.iter().find(|s| s.level == 1).unwrap();
        assert_eq!(lvl1.max, 4);
        assert_eq!(lvl1.current, 4); // default current = max
    }
}

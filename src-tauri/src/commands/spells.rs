use crate::db::{queries, DbPool};
use crate::models::{CharacterSpell, Spell, SpellSlotData, SpellSlotPair};
use std::collections::HashMap;
use tauri::State;

#[tauri::command]
pub fn get_character_spells(
    entity_id: String,
    state: State<DbPool>,
) -> Result<Vec<CharacterSpell>, String> {
    let conn = state.lock()?;
    let mut stmt = conn.prepare(queries::GET_CHARACTER_SPELLS).map_err(|e| e.to_string())?;

    let spells = stmt.query_map([&entity_id], |row| {
        let is_concentration: i32 = row.get(4)?;
        let is_ritual: i32 = row.get(5)?;
        let is_prepared: i32 = row.get(7)?;

        Ok(CharacterSpell {
            spell_id: row.get(0)?,
            name: row.get(1)?,
            level: row.get(2)?,
            school: row.get(3)?,
            is_concentration: is_concentration == 1,
            is_ritual: is_ritual == 1,
            description: row.get(6)?,
            is_prepared: is_prepared == 1,
        })
    })
    .map_err(|e| e.to_string())?
    .filter_map(|r| r.ok())
    .collect();

    Ok(spells)
}

#[tauri::command]
pub fn get_spell_library(
    state: State<DbPool>,
) -> Result<Vec<Spell>, String> {
    let conn = state.lock()?;
    let mut stmt = conn.prepare(queries::GET_SPELL_LIBRARY).map_err(|e| e.to_string())?;

    let spells = stmt.query_map([], |row| {
        let is_concentration: i32 = row.get(8)?;
        let is_ritual: i32 = row.get(9)?;

        Ok(Spell {
            id: row.get(0)?,
            name: row.get(1)?,
            level: row.get(2)?,
            school: row.get(3)?,
            casting_time: row.get(4)?,
            range: row.get(5)?,
            components: row.get(6)?,
            duration: row.get(7)?,
            is_concentration: is_concentration == 1,
            is_ritual: is_ritual == 1,
            description: row.get(10)?,
            higher_levels_desc: row.get(11)?,
        })
    })
    .map_err(|e| e.to_string())?
    .filter_map(|r| r.ok())
    .collect();

    Ok(spells)
}

#[tauri::command]
pub fn get_entity_spell_slots(
    entity_id: String,
    state: State<DbPool>,
) -> Result<Option<SpellSlotData>, String> {
    let conn = state.lock()?;
    let result = conn.query_row(
        queries::GET_ENTITY_SPELL_SLOTS,
        [&entity_id],
        |row| {
            let mut slots: HashMap<String, SpellSlotPair> = HashMap::new();
            for i in 0..9usize {
                let max: i32 = row.get(1 + i * 2)?;
                let curr: i32 = row.get(2 + i * 2)?;
                if max > 0 {
                    let level = (i + 1).to_string();
                    slots.insert(level, SpellSlotPair { max, current: curr });
                }
            }
            Ok(SpellSlotData {
                spellcasting_ability: row.get(0)?,
                slots,
            })
        },
    );
    match result {
        Ok(data) => Ok(Some(data)),
        Err(rusqlite::Error::QueryReturnedNoRows) => Ok(None),
        Err(e) => Err(e.to_string()),
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use rusqlite::Connection;

    fn setup_test_db() -> Connection {
        let conn = Connection::open_in_memory().unwrap();

        conn.execute_batch(
            "
            CREATE TABLE spell_library (
                id TEXT PRIMARY KEY,
                name TEXT NOT NULL,
                level INTEGER NOT NULL,
                school TEXT NOT NULL,
                casting_time TEXT NOT NULL,
                range TEXT NOT NULL,
                components TEXT NOT NULL,
                duration TEXT NOT NULL,
                is_concentration INTEGER NOT NULL DEFAULT 0,
                is_ritual INTEGER NOT NULL DEFAULT 0,
                description TEXT NOT NULL,
                higher_levels_desc TEXT
            );
            CREATE TABLE entity_spells (
                entity_id TEXT,
                spell_id TEXT,
                is_prepared INTEGER NOT NULL DEFAULT 1,
                PRIMARY KEY (entity_id, spell_id)
            );
        ",
        )
        .unwrap();

        conn
    }

    fn insert_test_spells(conn: &Connection) {
        conn.execute_batch(
            "
            INSERT INTO spell_library (id, name, level, school, casting_time, range, components, duration, is_concentration, is_ritual, description, higher_levels_desc) VALUES
                ('spell-1', 'Fireball', 3, 'Evocation', '1 action', '150 feet', 'V, S, M', 'Instant', 0, 0, 'A bright streak flashes from your finger.', 'When you cast this spell using a slot of 4th level or higher, the damage increases by 1d6 for each slot level above 3rd.'),
                ('spell-2', 'Mage Hand', 0, 'Conjuration', '1 action', '30 feet', 'V, S', '1 minute', 0, 0, 'A spectral hand appears.', NULL),
                ('spell-3', 'Shield', 1, 'Abjuration', '1 reaction', 'Self', 'V, S', '1 round', 0, 0, 'An invisible barrier.', NULL),
                ('spell-4', 'Bless', 1, 'Enchantment', '1 action', '30 feet', 'V, S, M', 'Concentration, up to 1 minute', 1, 0, 'You bless up to three creatures.', 'When you cast this spell using a slot of 2nd level or higher, you can target one additional creature for each slot level above 1st.');

            INSERT INTO entity_spells (entity_id, spell_id, is_prepared) VALUES
                ('entity-1', 'spell-1', 1),
                ('entity-1', 'spell-2', 0),
                ('entity-1', 'spell-3', 1);
        ",
        )
        .unwrap();
    }

    #[test]
    fn test_get_character_spells_returns_correct_fields() {
        let conn = setup_test_db();
        insert_test_spells(&conn);

        let mut stmt = conn.prepare(queries::GET_CHARACTER_SPELLS).unwrap();
        let rows: Vec<CharacterSpell> = stmt
            .query_map(["entity-1"], |row| {
                let is_concentration: i32 = row.get(4)?;
                let is_ritual: i32 = row.get(5)?;
                let is_prepared: i32 = row.get(7)?;
                Ok(CharacterSpell {
                    spell_id: row.get(0)?,
                    name: row.get(1)?,
                    level: row.get(2)?,
                    school: row.get(3)?,
                    is_concentration: is_concentration == 1,
                    is_ritual: is_ritual == 1,
                    description: row.get(6)?,
                    is_prepared: is_prepared == 1,
                })
            })
            .unwrap()
            .filter_map(|r| r.ok())
            .collect();

        assert_eq!(rows.len(), 3, "entity-1 should have 3 spells");

        // Order: Mage Hand (cantrip), Shield (1st), Fireball (3rd)
        assert_eq!(rows[0].spell_id, "spell-2");
        assert_eq!(rows[0].name, "Mage Hand");
        assert_eq!(rows[0].level, 0);
        assert_eq!(rows[0].school, "Conjuration");
        assert!(!rows[0].is_prepared, "Mage Hand should not be prepared");
        assert!(!rows[0].is_concentration);
        assert!(!rows[0].is_ritual);

        assert_eq!(rows[1].spell_id, "spell-3");
        assert_eq!(rows[1].name, "Shield");
        assert_eq!(rows[1].level, 1);
        assert!(rows[1].is_prepared);

        assert_eq!(rows[2].spell_id, "spell-1");
        assert_eq!(rows[2].name, "Fireball");
        assert_eq!(rows[2].level, 3);
        assert!(rows[2].is_prepared);
    }

    #[test]
    fn test_get_character_spells_empty_for_unknown_entity() {
        let conn = setup_test_db();
        insert_test_spells(&conn);

        let mut stmt = conn.prepare(queries::GET_CHARACTER_SPELLS).unwrap();
        let rows: Vec<CharacterSpell> = stmt
            .query_map(["nonexistent-entity"], |row| {
                Ok(CharacterSpell {
                    spell_id: row.get(0)?,
                    name: row.get(1)?,
                    level: row.get(2)?,
                    school: row.get(3)?,
                    is_concentration: row.get::<_, i32>(4)? == 1,
                    is_ritual: row.get::<_, i32>(5)? == 1,
                    description: row.get(6)?,
                    is_prepared: row.get::<_, i32>(7)? == 1,
                })
            })
            .unwrap()
            .filter_map(|r| r.ok())
            .collect();

        assert_eq!(rows.len(), 0, "unknown entity should have no spells");
    }

    #[test]
    fn test_get_spell_library_returns_all_spells_in_order() {
        let conn = setup_test_db();
        insert_test_spells(&conn);

        let mut stmt = conn.prepare(queries::GET_SPELL_LIBRARY).unwrap();
        let rows: Vec<Spell> = stmt
            .query_map([], |row| {
                let is_concentration: i32 = row.get(8)?;
                let is_ritual: i32 = row.get(9)?;
                Ok(Spell {
                    id: row.get(0)?,
                    name: row.get(1)?,
                    level: row.get(2)?,
                    school: row.get(3)?,
                    casting_time: row.get(4)?,
                    range: row.get(5)?,
                    components: row.get(6)?,
                    duration: row.get(7)?,
                    is_concentration: is_concentration == 1,
                    is_ritual: is_ritual == 1,
                    description: row.get(10)?,
                    higher_levels_desc: row.get(11)?,
                })
            })
            .unwrap()
            .filter_map(|r| r.ok())
            .collect();

        assert_eq!(rows.len(), 4, "library should have 4 spells");

        // Order by level then name: Mage Hand (0), Bless (1), Shield (1), Fireball (3)
        assert_eq!(rows[0].name, "Mage Hand");
        assert_eq!(rows[0].level, 0);

        assert_eq!(rows[1].name, "Bless");
        assert_eq!(rows[1].level, 1);
        assert!(rows[1].is_concentration, "Bless should be concentration");

        assert_eq!(rows[2].name, "Shield");
        assert_eq!(rows[2].level, 1);

        assert_eq!(rows[3].name, "Fireball");
        assert_eq!(rows[3].level, 3);

        // Verify metadata fields on Fireball
        assert_eq!(rows[3].casting_time, "1 action");
        assert_eq!(rows[3].range, "150 feet");
        assert_eq!(rows[3].components, "V, S, M");
        assert_eq!(rows[3].duration, "Instant");
        assert!(!rows[3].is_concentration);
        assert!(!rows[3].is_ritual);
        assert!(rows[3].higher_levels_desc.is_some());

        // Verify nullable higher_levels_desc on Mage Hand
        assert!(rows[0].higher_levels_desc.is_none());
    }

    #[test]
    fn test_get_spell_library_empty_db() {
        let conn = setup_test_db();

        let mut stmt = conn.prepare(queries::GET_SPELL_LIBRARY).unwrap();
        let rows: Vec<Spell> = stmt
            .query_map([], |_| {
                unreachable!("no rows should be returned");
            })
            .unwrap()
            .filter_map(|r| r.ok())
            .collect();

        assert_eq!(rows.len(), 0, "empty library should return empty vec");
    }

    #[test]
    fn test_character_spell_bool_conversion() {
        let conn = setup_test_db();
        conn.execute_batch(
            "
            INSERT INTO spell_library (id, name, level, school, casting_time, range, components, duration, is_concentration, is_ritual, description)
            VALUES ('spell-conc', 'Test Concentration', 2, 'Test', '1 action', 'Self', 'V', '1 hour', 1, 0, 'A test spell.');
            INSERT INTO entity_spells (entity_id, spell_id, is_prepared) VALUES ('entity-2', 'spell-conc', 1);
        ",
        )
        .unwrap();

        let mut stmt = conn.prepare(queries::GET_CHARACTER_SPELLS).unwrap();
        let rows: Vec<CharacterSpell> = stmt
            .query_map(["entity-2"], |row| {
                Ok(CharacterSpell {
                    spell_id: row.get(0)?,
                    name: row.get(1)?,
                    level: row.get(2)?,
                    school: row.get(3)?,
                    is_concentration: row.get::<_, i32>(4)? == 1,
                    is_ritual: row.get::<_, i32>(5)? == 1,
                    description: row.get(6)?,
                    is_prepared: row.get::<_, i32>(7)? == 1,
                })
            })
            .unwrap()
            .filter_map(|r| r.ok())
            .collect();

        assert_eq!(rows.len(), 1);
        assert!(rows[0].is_concentration, "should be concentration");
        assert!(!rows[0].is_ritual, "should not be ritual");
        assert!(rows[0].is_prepared, "should be prepared");
    }
}

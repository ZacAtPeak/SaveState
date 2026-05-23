use rusqlite::Connection;
use std::fs;
use std::path::Path;
use std::path::PathBuf;
use std::sync::Mutex;

pub struct DbPool(pub Mutex<Connection>);

impl DbPool {
    /// Create a pool from a database file path (production use).
    pub fn new(db_path: PathBuf) -> Result<Self, String> {
        let conn = Connection::open(&db_path).map_err(|e| e.to_string())?;
        Ok(DbPool(Mutex::new(conn)))
    }

    /// Create a pool from an existing connection (testing use).
    pub fn from_conn(conn: Connection) -> Self {
        DbPool(Mutex::new(conn))
    }

    pub fn lock(&self) -> Result<std::sync::MutexGuard<Connection>, String> {
        self.0.lock().map_err(|e| e.to_string())
    }
}

/// Ensure a writable copy of the seed database exists at `dest`.
///
/// If `dest` already exists, does nothing.
/// First launch migration: if the old source-tree DB exists (pre-change),
/// it is copied to preserve any user data already in it.
/// Otherwise, the bundled `seed` file is copied.
pub fn seed_database(dest: &Path, seed: &Path) -> Result<(), String> {
    if dest.exists() {
        return Ok(());
    }

    // Ensure parent directory exists
    if let Some(parent) = dest.parent() {
        fs::create_dir_all(parent)
            .map_err(|e| format!("Failed to create database directory {:?}: {}", parent, e))?;
    }

    // One-time migration: if the old source-tree DB exists, copy it
    // to preserve user data that may have been written before this change.
    let old_source_path = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .parent()
        .unwrap()
        .join("Assets/5e_data.sqlite");

    let source: &Path = if old_source_path.exists() {
        &old_source_path
    } else {
        seed
    };

    fs::copy(source, dest)
        .map_err(|e| format!("Failed to copy database from {:?} to {:?}: {}", source, dest, e))?;

    Ok(())
}

pub mod row_indexes {
    pub const IDX: usize = 0;
    pub const NAME: usize = 1;
    pub const ENTITY_TYPE: usize = 2;
    pub const ARMOR_CLASS: usize = 3;
    pub const HP_MAX: usize = 4;
    pub const HP_CURRENT: usize = 5;
    pub const STRENGTH: usize = 6;
    pub const DEXTERITY: usize = 7;
    pub const CONSTITUTION: usize = 8;
    pub const INTELLIGENCE: usize = 9;
    pub const WISDOM: usize = 10;
    pub const CHARISMA: usize = 11;
    pub const PLAYER_NAME: usize = 12;
    pub const RACE: usize = 13;
    pub const PROFICIENCY_BONUS: usize = 14;
    pub const CLASS: usize = 15;
    pub const LEVEL: usize = 16;
    pub const CHALLENGE_RATING: usize = 6;
}

pub mod queries {
    pub const GET_PLAYER_CHARACTERS: &str = r#"
        SELECT e.id, e.name, e.entity_type, e.armor_class, e.hit_points_max, e.hit_points_current,
               s.strength, s.dexterity, s.constitution, s.intelligence, s.wisdom, s.charisma,
               cp.player_name, cp.race, cp.proficiency_bonus,
               COALESCE(GROUP_CONCAT(c.name || ' ' || cc.class_level, ', '), cp.class, '') as class,
               COALESCE(SUM(cc.class_level), cp.level, 1) as level
        FROM entities e
        JOIN entity_stats s ON e.id = s.entity_id
        LEFT JOIN character_profiles cp ON e.id = cp.entity_id
        LEFT JOIN character_classes cc ON e.id = cc.entity_id
        LEFT JOIN classes c ON cc.class_id = c.id
        WHERE e.entity_type = 'pc'
        GROUP BY e.id
    "#;

    pub const GET_MONSTERS: &str = r#"
        SELECT e.id, e.name, e.entity_type, e.armor_class, e.hit_points_max, e.hit_points_current,
               c.challenge_rating,
               s.strength, s.dexterity, s.constitution, s.intelligence, s.wisdom, s.charisma
        FROM entities e
        JOIN entity_stats s ON e.id = s.entity_id
        JOIN creature_profiles c ON e.id = c.entity_id
        WHERE e.entity_type = 'creature'
        ORDER BY e.name
    "#;

    pub const GET_NPCS: &str = r#"
        SELECT e.id, e.name, e.entity_type, e.armor_class, e.hit_points_max, e.hit_points_current,
               s.strength, s.dexterity, s.constitution, s.intelligence, s.wisdom, s.charisma
        FROM entities e
        JOIN entity_stats s ON e.id = s.entity_id
        WHERE e.entity_type = 'npc'
        ORDER BY e.name
    "#;

    pub const GET_CHARACTER_SKILLS: &str = r#"
        SELECT s.id, s.name, s.associated_ability_score,
               CASE s.associated_ability_score
                   WHEN 'strength' THEN es.strength
                   WHEN 'dexterity' THEN es.dexterity
                   WHEN 'constitution' THEN es.constitution
                   WHEN 'intelligence' THEN es.intelligence
                   WHEN 'wisdom' THEN es.wisdom
                   WHEN 'charisma' THEN es.charisma
               END as ability_score,
               COALESCE(eskill.is_proficient, 0) as is_proficient,
               COALESCE(eskill.is_expert, 0) as is_expert
        FROM skills s
        JOIN entity_stats es ON es.entity_id = ?1
        LEFT JOIN entity_skills eskill ON eskill.skill_id = s.id AND eskill.entity_id = ?1
        ORDER BY s.name
    "#;

    pub const INSERT_ENTITY: &str = r#"
        INSERT INTO entities (id, name, entity_type, armor_class, hit_points_max, hit_points_current)
        VALUES (?1, ?2, 'pc', ?3, ?4, ?5)
    "#;

    pub const INSERT_ENTITY_STATS: &str = r#"
        INSERT INTO entity_stats (entity_id, strength, dexterity, constitution, intelligence, wisdom, charisma)
        VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7)
    "#;

    pub const INSERT_CHARACTER_PROFILE: &str = r#"
        INSERT INTO character_profiles (entity_id, class, level, race, player_name, proficiency_bonus)
        VALUES (?1, ?2, ?3, ?4, ?5, ?6)
    "#;

    pub const GET_CHARACTER_SPELLS: &str = r#"
        SELECT sl.id, sl.name, sl.level, sl.school, sl.is_concentration, sl.is_ritual, sl.description,
               COALESCE(es.is_prepared, 0) as is_prepared
        FROM entity_spells es
        JOIN spell_library sl ON es.spell_id = sl.id
        WHERE es.entity_id = ?1
        ORDER BY sl.level, sl.name
    "#;

    pub const GET_SPELL_LIBRARY: &str = r#"
        SELECT id, name, level, school, casting_time, range, components, duration,
               is_concentration, is_ritual, description, higher_levels_desc
        FROM spell_library
        ORDER BY level, name
    "#;

    pub const UPDATE_ENTITY_HP: &str = r#"
        UPDATE entities SET hit_points_current = ?1 WHERE id = ?2
    "#;

    pub const GET_CLASSES: &str = r#"
        SELECT id, name, hit_die, saving_throw_1, saving_throw_2, primary_ability, description, skill_picks
        FROM classes
        ORDER BY name
    "#;

    pub const GET_SUBCLASSES: &str = r#"
        SELECT id, name, description
        FROM subclasses
        WHERE class_id = ?1
        ORDER BY name
    "#;

    pub const GET_RACES: &str = r#"
        SELECT id, name, size, speed_walk, darkvision
        FROM races
        WHERE parent_race_id IS NULL
        ORDER BY name
    "#;

    pub const GET_RACE_ABILITY_BONUSES: &str = r#"
        SELECT ability, bonus
        FROM race_ability_bonuses
        WHERE race_id = ?1
    "#;

    pub const GET_SUBRACES: &str = r#"
        SELECT id, name, race_id, description
        FROM subraces
        WHERE race_id = ?1
        ORDER BY name
    "#;

    pub const GET_BACKGROUNDS: &str = r#"
        SELECT id, name, description, skill_proficiencies, feature_name, feature_description
        FROM backgrounds
        ORDER BY name
    "#;

    pub const UPDATE_ENTITY_STATS_SAVE_PROFS: &str = r#"
        UPDATE entity_stats SET
            save_prof_strength = ?2,
            save_prof_dexterity = ?3,
            save_prof_constitution = ?4,
            save_prof_intelligence = ?5,
            save_prof_wisdom = ?6,
            save_prof_charisma = ?7
        WHERE entity_id = ?1
    "#;

    pub const INSERT_CHARACTER_CLASS: &str = r#"
        INSERT INTO character_classes (entity_id, class_id, subclass_id, class_level, is_primary)
        VALUES (?1, ?2, ?3, ?4, ?5)
    "#;

    pub const INSERT_ENTITY_SKILL: &str = r#"
        INSERT INTO entity_skills (entity_id, skill_id, is_proficient, is_expert)
        VALUES (?1, ?2, 1, 0)
    "#;
}
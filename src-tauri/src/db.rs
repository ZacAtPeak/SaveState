use rusqlite::Connection;
use std::path::PathBuf;
use std::sync::Mutex;
use std::env;

pub struct DbPool(pub Mutex<Connection>);

impl DbPool {
    pub fn new() -> Result<Self, String> {
        let db_path = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
            .parent()
            .unwrap()
            .join("Assets/5e_data.sqlite");

        let conn = Connection::open(&db_path).map_err(|e| e.to_string())?;
        Ok(DbPool(Mutex::new(conn)))
    }

    pub fn lock(&self) -> Result<std::sync::MutexGuard<Connection>, String> {
        self.0.lock().map_err(|e| e.to_string())
    }
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
               GROUP_CONCAT(c.name || ' ' || cc.class_level, ', ') as class_levels,
               SUM(cc.class_level) as total_level
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
}
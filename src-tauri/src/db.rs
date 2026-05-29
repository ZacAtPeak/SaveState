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
/// In development (when the source-tree DB is present), always re-copies
/// if the source is newer than `dest` so that schema/data changes made to
/// `Assets/5e_data.sqlite` propagate to the running app automatically.
/// In production (bundled app where seed comes from resources), only copies
/// if `dest` doesn't exist yet.
pub fn seed_database(dest: &Path, seed: &Path) -> Result<(), String> {
    // Ensure parent directory exists
    if let Some(parent) = dest.parent() {
        fs::create_dir_all(parent)
            .map_err(|e| format!("Failed to create database directory {:?}: {}", parent, e))?;
    }

    // In development the source-tree DB takes priority.
    // In release builds the bundled "seed" path from resources is the only source.
    let source_tree = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .parent()
        .unwrap()
        .join("Assets/5e_data.sqlite");

    let source: &Path = if source_tree.exists() { &source_tree } else { seed };

    // If dest doesn't exist yet, always copy (first launch).
    // If source is newer than dest, re-copy so schema/data changes propagate.
    // Otherwise leave it alone (avoids wiping user data unnecessarily).
    if dest.exists() {
        let src_modified = fs::metadata(source)
            .and_then(|m| m.modified())
            .ok();
        let dst_modified = fs::metadata(dest)
            .and_then(|m| m.modified())
            .ok();

        match (src_modified, dst_modified) {
            (Some(src_time), Some(dst_time)) if src_time <= dst_time => return Ok(()),
            // If we can't compare timestamps (unlikely), fall through and re-copy.
            (_, _) => {}
        }
    }

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

    pub const GET_ENTITY_ACTIONS: &str = r#"
        SELECT al.id, al.name, al.action_type, al.description, al.is_attack, al.attack_bonus, al.damage_dice, al.damage_type,
               ea.uses_per_day, ea.uses_current, ea.recharge_formula
        FROM entity_actions ea
        JOIN action_library al ON ea.action_id = al.id
        WHERE ea.entity_id = ?1
        ORDER BY al.action_type, al.name
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

    // ── Items & Inventory ────────────────────────────────────────────

    pub const GET_ITEM_LIBRARY: &str = r#"
        SELECT id, name, item_type, description, rarity, weight, value_gp,
               is_magical, attack_bonus, damage_bonus, damage_bonus_type,
               source, page
        FROM item_library
        ORDER BY name
    "#;

    pub const GET_WEAPON_PROFILE: &str = r#"
        SELECT item_id, weapon_category, weapon_range, damage_dice, damage_type,
               range_normal, range_long, versatile_dice, properties
        FROM weapon_profiles
        WHERE item_id = ?1
    "#;

    pub const GET_ARMOR_PROFILE: &str = r#"
        SELECT item_id, armor_category, base_armor_class, dex_bonus_cap,
               strength_requirement, stealth_disadvantage
        FROM armor_profiles
        WHERE item_id = ?1
    "#;

    pub const GET_ENTITY_INVENTORY: &str = r#"
        SELECT ei.entity_id, ei.item_id, ei.quantity, ei.is_equipped, ei.equipped_slot,
               il.id, il.name, il.item_type, il.description, il.rarity, il.weight, il.value_gp,
               il.is_magical, il.attack_bonus, il.damage_bonus, il.damage_bonus_type, il.source, il.page
        FROM entity_items ei
        JOIN item_library il ON ei.item_id = il.id
        WHERE ei.entity_id = ?1
        ORDER BY ei.is_equipped DESC, il.name
    "#;

    pub const EQUIP_ITEM: &str = r#"
        UPDATE entity_items
        SET is_equipped = 1, equipped_slot = ?1
        WHERE entity_id = ?2 AND item_id = ?3
    "#;

    pub const UNEQUIP_ITEM: &str = r#"
        UPDATE entity_items
        SET is_equipped = 0, equipped_slot = NULL
        WHERE entity_id = ?1 AND item_id = ?2
    "#;

    /// Actions from equipped items via the item_actions join
    pub const GET_EQUIPPED_ITEM_ACTIONS: &str = r#"
        SELECT al.id, al.name, al.action_type, al.description, al.is_attack,
               al.attack_bonus, al.damage_dice, al.damage_type,
               NULL, NULL, NULL,
               il.name
        FROM entity_items ei
        JOIN item_actions ia ON ei.item_id = ia.item_id
        JOIN action_library al ON ia.action_id = al.id
        JOIN item_library il ON ei.item_id = il.id
        WHERE ei.entity_id = ?1 AND ei.is_equipped = 1
        ORDER BY al.action_type, al.name
    "#;

    pub const ADD_ITEM_TO_ENTITY: &str = r#"
        INSERT INTO entity_items (entity_id, item_id, quantity, is_equipped, equipped_slot)
        VALUES (?1, ?2, ?3, 0, NULL)
        ON CONFLICT(entity_id, item_id)
        DO UPDATE SET quantity = quantity + ?3
    "#;

    pub const REMOVE_ITEM_FROM_ENTITY: &str = r#"
        DELETE FROM entity_items
        WHERE entity_id = ?1 AND item_id = ?2
    "#;
}
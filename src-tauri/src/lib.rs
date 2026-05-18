use serde::{Deserialize, Serialize};
use std::sync::Mutex;
use rusqlite::Connection;

#[derive(Debug, Serialize, Deserialize)]
pub struct PlayerCharacter {
    pub id: String,
    pub name: String,
    pub entity_type: String,
    pub class: String,
    pub level: i32,
    pub race: String,
    pub player_name: Option<String>,
    pub armor_class: i32,
    pub hit_points_max: i32,
    pub hit_points_current: i32,
    pub strength: i32,
    pub dexterity: i32,
    pub constitution: i32,
    pub intelligence: i32,
    pub wisdom: i32,
    pub charisma: i32,
    pub proficiency_bonus: i32,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct CharacterSkill {
    pub skill_id: String,
    pub skill_name: String,
    pub associated_ability: String,
    pub ability_score: i32,
    pub is_proficient: bool,
    pub is_expert: bool,
    pub proficiency_bonus: i32,
    pub total_modifier: i32,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct Monster {
    pub id: String,
    pub name: String,
    pub entity_type: String,
    pub armor_class: i32,
    pub hit_points_max: i32,
    pub hit_points_current: i32,
    pub challenge_rating: f64,
    pub strength: i32,
    pub dexterity: i32,
    pub constitution: i32,
    pub intelligence: i32,
    pub wisdom: i32,
    pub charisma: i32,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct Npc {
    pub id: String,
    pub name: String,
    pub entity_type: String,
    pub armor_class: i32,
    pub hit_points_max: i32,
    pub hit_points_current: i32,
    pub strength: i32,
    pub dexterity: i32,
    pub constitution: i32,
    pub intelligence: i32,
    pub wisdom: i32,
    pub charisma: i32,
}

struct AppState {
    db: Mutex<Connection>,
}

#[tauri::command]
fn get_player_characters(state: tauri::State<AppState>) -> Result<Vec<PlayerCharacter>, String> {
    let conn = state.db.lock().map_err(|e| e.to_string())?;

    let mut stmt = conn.prepare(
        r#"
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
        "#,
    ).map_err(|e| e.to_string())?;

    let chars = stmt.query_map([], |row| {
        Ok(PlayerCharacter {
            id: row.get(0)?,
            name: row.get(1)?,
            entity_type: row.get(2)?,
            race: row.get(13)?,
            player_name: row.get(12)?,
            class: row.get(15)?,
            level: row.get(16)?,
            armor_class: row.get(3)?,
            hit_points_max: row.get(4)?,
            hit_points_current: row.get(5)?,
            strength: row.get(6)?,
            dexterity: row.get(7)?,
            constitution: row.get(8)?,
            intelligence: row.get(9)?,
            wisdom: row.get(10)?,
            charisma: row.get(11)?,
            proficiency_bonus: row.get(14)?,
        })
    }).map_err(|e| e.to_string())?
    .filter_map(|r| r.ok())
    .collect();

    Ok(chars)
}

#[derive(Debug, Serialize, Deserialize)]
pub struct CreateCharacterRequest {
    pub name: String,
    pub class: String,
    pub level: i32,
    pub race: String,
    pub player_name: Option<String>,
    pub armor_class: i32,
    pub hit_points_max: i32,
    pub hit_points_current: i32,
    pub strength: i32,
    pub dexterity: i32,
    pub constitution: i32,
    pub intelligence: i32,
    pub wisdom: i32,
    pub charisma: i32,
}

#[tauri::command]
fn create_player_character(req: CreateCharacterRequest, state: tauri::State<AppState>) -> Result<PlayerCharacter, String> {
    let conn = state.db.lock().map_err(|e| e.to_string())?;

    let id = uuid::Uuid::new_v4().to_string();
    let proficiency_bonus = (req.level - 1) / 4 + 2;

    conn.execute(
        "INSERT INTO entities (id, name, entity_type, armor_class, hit_points_max, hit_points_current) VALUES (?1, ?2, 'pc', ?3, ?4, ?5)",
        [&id, &req.name, &req.armor_class.to_string(), &req.hit_points_max.to_string(), &req.hit_points_current.to_string()],
    ).map_err(|e| e.to_string())?;

    conn.execute(
        "INSERT INTO entity_stats (entity_id, strength, dexterity, constitution, intelligence, wisdom, charisma) VALUES (?1, ?2, ?3, ?4, ?5, ?6, ?7)",
        [&id, &req.strength.to_string(), &req.dexterity.to_string(), &req.constitution.to_string(), &req.intelligence.to_string(), &req.wisdom.to_string(), &req.charisma.to_string()],
    ).map_err(|e| e.to_string())?;

    conn.execute(
        "INSERT INTO character_profiles (entity_id, class, level, race, player_name, proficiency_bonus) VALUES (?1, ?2, ?3, ?4, ?5, ?6)",
        [&id, &req.class, &req.level.to_string(), &req.race, &req.player_name.clone().unwrap_or_default(), &proficiency_bonus.to_string()],
    ).map_err(|e| e.to_string())?;

    Ok(PlayerCharacter {
        id,
        name: req.name,
        entity_type: "pc".to_string(),
        class: req.class,
        level: req.level,
        race: req.race,
        player_name: req.player_name,
        armor_class: req.armor_class,
        hit_points_max: req.hit_points_max,
        hit_points_current: req.hit_points_current,
        strength: req.strength,
        dexterity: req.dexterity,
        constitution: req.constitution,
        intelligence: req.intelligence,
        wisdom: req.wisdom,
        charisma: req.charisma,
        proficiency_bonus,
    })
}

#[tauri::command]
fn get_monsters(state: tauri::State<AppState>) -> Result<Vec<Monster>, String> {
    let conn = state.db.lock().map_err(|e| e.to_string())?;

    let mut stmt = conn.prepare(
        r#"
        SELECT e.id, e.name, e.entity_type, e.armor_class, e.hit_points_max, e.hit_points_current,
               c.challenge_rating,
               s.strength, s.dexterity, s.constitution, s.intelligence, s.wisdom, s.charisma
        FROM entities e
        JOIN entity_stats s ON e.id = s.entity_id
        JOIN creature_profiles c ON e.id = c.entity_id
        WHERE e.entity_type = 'creature'
        ORDER BY e.name
        "#,
    ).map_err(|e| e.to_string())?;

    let monsters = stmt.query_map([], |row| {
        Ok(Monster {
            id: row.get(0)?,
            name: row.get(1)?,
            entity_type: row.get(2)?,
            armor_class: row.get(3)?,
            hit_points_max: row.get(4)?,
            hit_points_current: row.get(5)?,
            challenge_rating: row.get(6)?,
            strength: row.get(7)?,
            dexterity: row.get(8)?,
            constitution: row.get(9)?,
            intelligence: row.get(10)?,
            wisdom: row.get(11)?,
            charisma: row.get(12)?,
        })
    }).map_err(|e| e.to_string())?
    .filter_map(|r| r.ok())
    .collect();

    Ok(monsters)
}

#[tauri::command]
fn get_npcs(state: tauri::State<AppState>) -> Result<Vec<Npc>, String> {
    let conn = state.db.lock().map_err(|e| e.to_string())?;

    let mut stmt = conn.prepare(
        r#"
        SELECT e.id, e.name, e.entity_type, e.armor_class, e.hit_points_max, e.hit_points_current,
               s.strength, s.dexterity, s.constitution, s.intelligence, s.wisdom, s.charisma
        FROM entities e
        JOIN entity_stats s ON e.id = s.entity_id
        WHERE e.entity_type = 'npc'
        ORDER BY e.name
        "#,
    ).map_err(|e| e.to_string())?;

    let npcs = stmt.query_map([], |row| {
        Ok(Npc {
            id: row.get(0)?,
            name: row.get(1)?,
            entity_type: row.get(2)?,
            armor_class: row.get(3)?,
            hit_points_max: row.get(4)?,
            hit_points_current: row.get(5)?,
            strength: row.get(6)?,
            dexterity: row.get(7)?,
            constitution: row.get(8)?,
            intelligence: row.get(9)?,
            wisdom: row.get(10)?,
            charisma: row.get(11)?,
        })
    }).map_err(|e| e.to_string())?
    .filter_map(|r| r.ok())
    .collect();

    Ok(npcs)
}

#[tauri::command]
fn get_character_skills(entity_id: String, proficiency_bonus: i32, state: tauri::State<AppState>) -> Result<Vec<CharacterSkill>, String> {
    let conn = state.db.lock().map_err(|e| e.to_string())?;

    let mut stmt = conn.prepare(
        r#"
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
        "#,
    ).map_err(|e| e.to_string())?;

    let skills = stmt.query_map([&entity_id], |row| {
        let skill_id: String = row.get(0)?;
        let skill_name: String = row.get(1)?;
        let associated_ability: String = row.get(2)?;
        let ability_score: i32 = row.get(3)?;
        let is_proficient: i32 = row.get(4)?;
        let is_expert: i32 = row.get(5)?;

        let ability_modifier = (ability_score - 10) / 2;
        let proficiency_multiplier = is_expert + is_proficient;
        let proficiency_add = proficiency_multiplier as i32 * proficiency_bonus;
        let total_modifier = ability_modifier + proficiency_add;

        Ok(CharacterSkill {
            skill_id,
            skill_name,
            associated_ability,
            ability_score,
            is_proficient: is_proficient == 1,
            is_expert: is_expert == 1,
            proficiency_bonus,
            total_modifier,
        })
    }).map_err(|e| e.to_string())?
    .filter_map(|r| r.ok())
    .collect();

    Ok(skills)
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    let db_path = std::path::PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .parent()
        .unwrap()
        .join("Assets/5e_data.sqlite");
    let conn = Connection::open(&db_path).expect("Failed to open database");

    tauri::Builder::default()
        .plugin(tauri_plugin_opener::init())
        .manage(AppState { db: Mutex::new(conn) })
        .invoke_handler(tauri::generate_handler![get_player_characters, get_character_skills, create_player_character, get_monsters, get_npcs])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}

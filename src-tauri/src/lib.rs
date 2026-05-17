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
               cp.class, cp.level, cp.race, cp.player_name
        FROM entities e
        JOIN entity_stats s ON e.id = s.entity_id
        LEFT JOIN character_profiles cp ON e.id = cp.entity_id
        WHERE e.entity_type = 'pc'
        "#,
    ).map_err(|e| e.to_string())?;

    let chars = stmt.query_map([], |row| {
        Ok(PlayerCharacter {
            id: row.get(0)?,
            name: row.get(1)?,
            entity_type: row.get(2)?,
            class: row.get(12)?,
            level: row.get(13)?,
            race: row.get(14)?,
            player_name: row.get(15)?,
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

    Ok(chars)
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
        .invoke_handler(tauri::generate_handler![get_player_characters])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}

use rusqlite::Connection;
use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize)]
pub struct Actor {
    pub id: String,
    pub system_id: String,
    pub name: String,
    pub actor_type: String,
    pub base_hp: i32,
    pub base_ac: i32,
    pub stats_blob: Option<String>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct GameSystem {
    pub id: String,
    pub name: String,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct EntityEntry {
    pub id: String,
    pub entity_type_id: String,
    pub name: String,
    pub description: Option<String>,
    pub system_id: Option<String>,
    pub metadata_blob: Option<String>,
    pub type_name: Option<String>,
    pub type_desc: Option<String>,
    pub tags: Option<String>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct EntityType {
    pub id: String,
    pub name: String,
    pub description: Option<String>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct Skill {
    pub id: String,
    pub system_id: String,
    pub name: String,
    pub description: Option<String>,
    pub associated_stat: Option<String>,
    pub mechanics_blob: Option<String>,
}

fn get_db_path() -> Result<std::path::PathBuf, String> {
    std::env::current_dir()
        .map_err(|e| e.to_string())?
        .join("../src/assets/demo-UTS.db")
        .canonicalize()
        .map_err(|e| e.to_string())
}

#[tauri::command]
fn get_actors(system_id: Option<String>) -> Result<Vec<Actor>, String> {
    let db_path = get_db_path()?;
    let conn = Connection::open(&db_path).map_err(|e| e.to_string())?;

    let actors: Vec<Actor> = match system_id {
        Some(sid) => {
            let mut stmt = conn
                .prepare("SELECT id, system_id, name, actor_type, base_hp, base_ac, stats_blob FROM actors WHERE system_id = ?1")
                .map_err(|e| e.to_string())?;
            let rows = stmt.query_map([sid], |row| {
                Ok(Actor {
                    id: row.get(0)?,
                    system_id: row.get(1)?,
                    name: row.get(2)?,
                    actor_type: row.get(3)?,
                    base_hp: row.get(4)?,
                    base_ac: row.get(5)?,
                    stats_blob: row.get(6)?,
                })
            }).map_err(|e| e.to_string())?;
            rows.collect::<Result<Vec<_>, _>>().map_err(|e| e.to_string())?
        }
        None => {
            let mut stmt = conn
                .prepare("SELECT id, system_id, name, actor_type, base_hp, base_ac, stats_blob FROM actors")
                .map_err(|e| e.to_string())?;
            let rows = stmt.query_map([], |row| {
                Ok(Actor {
                    id: row.get(0)?,
                    system_id: row.get(1)?,
                    name: row.get(2)?,
                    actor_type: row.get(3)?,
                    base_hp: row.get(4)?,
                    base_ac: row.get(5)?,
                    stats_blob: row.get(6)?,
                })
            }).map_err(|e| e.to_string())?;
            rows.collect::<Result<Vec<_>, _>>().map_err(|e| e.to_string())?
        }
    };

    Ok(actors)
}

#[tauri::command]
fn get_game_systems() -> Result<Vec<GameSystem>, String> {
    let db_path = get_db_path()?;
    let conn = Connection::open(&db_path).map_err(|e| e.to_string())?;

    let mut stmt = conn
        .prepare("SELECT id, name FROM game_systems")
        .map_err(|e| e.to_string())?;

    let systems = stmt
        .query_map([], |row| {
            Ok(GameSystem {
                id: row.get(0)?,
                name: row.get(1)?,
            })
        })
        .map_err(|e| e.to_string())?
        .collect::<Result<Vec<_>, _>>()
        .map_err(|e| e.to_string())?;

    Ok(systems)
}

#[tauri::command]
fn get_entity_entries(system_id: Option<String>) -> Result<Vec<EntityEntry>, String> {
    let db_path = get_db_path()?;
    let conn = Connection::open(&db_path).map_err(|e| e.to_string())?;

    let entries: Vec<EntityEntry> = match system_id {
        Some(sid) => {
            let mut stmt = conn
                .prepare(
                    "SELECT e.id, e.entity_type_id, e.name, e.description, e.system_id, e.metadata_blob,
                            t.name as type_name, t.description as type_desc,
                            GROUP_CONCAT(gt.tag_name, ',') as tags
                     FROM entity_entries e
                     LEFT JOIN entity_types t ON e.entity_type_id = t.id
                     LEFT JOIN entity_tags gt ON e.id = gt.entity_id
                     WHERE e.system_id = ?1
                     GROUP BY e.id"
                )
                .map_err(|e| e.to_string())?;
            let rows = stmt.query_map([sid], |row| {
                Ok(EntityEntry {
                    id: row.get(0)?,
                    entity_type_id: row.get(1)?,
                    name: row.get(2)?,
                    description: row.get(3)?,
                    system_id: row.get(4)?,
                    metadata_blob: row.get(5)?,
                    type_name: row.get::<_, Option<String>>(6)?,
                    type_desc: row.get::<_, Option<String>>(7)?,
                    tags: row.get::<_, Option<String>>(8)?,
                })
            }).map_err(|e| e.to_string())?;
            rows.collect::<Result<Vec<_>, _>>().map_err(|e| e.to_string())?
        }
        None => {
            let mut stmt = conn
                .prepare(
                    "SELECT e.id, e.entity_type_id, e.name, e.description, e.system_id, e.metadata_blob,
                            t.name as type_name, t.description as type_desc,
                            GROUP_CONCAT(gt.tag_name, ',') as tags
                     FROM entity_entries e
                     LEFT JOIN entity_types t ON e.entity_type_id = t.id
                     LEFT JOIN entity_tags gt ON e.id = gt.entity_id
                     GROUP BY e.id"
                )
                .map_err(|e| e.to_string())?;
            let rows = stmt.query_map([], |row| {
                Ok(EntityEntry {
                    id: row.get(0)?,
                    entity_type_id: row.get(1)?,
                    name: row.get(2)?,
                    description: row.get(3)?,
                    system_id: row.get(4)?,
                    metadata_blob: row.get(5)?,
                    type_name: row.get::<_, Option<String>>(6)?,
                    type_desc: row.get::<_, Option<String>>(7)?,
                    tags: row.get::<_, Option<String>>(8)?,
                })
            }).map_err(|e| e.to_string())?;
            rows.collect::<Result<Vec<_>, _>>().map_err(|e| e.to_string())?
        }
    };

    Ok(entries)
}

#[tauri::command]
fn get_skills(system_id: Option<String>) -> Result<Vec<Skill>, String> {
    let db_path = get_db_path()?;
    let conn = Connection::open(&db_path).map_err(|e| e.to_string())?;

    let skills: Vec<Skill> = match system_id {
        Some(sid) => {
            let mut stmt = conn
                .prepare("SELECT id, system_id, name, description, associated_stat, mechanics_blob FROM skills WHERE system_id = ?1")
                .map_err(|e| e.to_string())?;
            let rows = stmt.query_map([sid], |row| {
                Ok(Skill {
                    id: row.get(0)?,
                    system_id: row.get(1)?,
                    name: row.get(2)?,
                    description: row.get(3)?,
                    associated_stat: row.get(4)?,
                    mechanics_blob: row.get(5)?,
                })
            }).map_err(|e| e.to_string())?;
            rows.collect::<Result<Vec<_>, _>>().map_err(|e| e.to_string())?
        }
        None => {
            let mut stmt = conn
                .prepare("SELECT id, system_id, name, description, associated_stat, mechanics_blob FROM skills")
                .map_err(|e| e.to_string())?;
            let rows = stmt.query_map([], |row| {
                Ok(Skill {
                    id: row.get(0)?,
                    system_id: row.get(1)?,
                    name: row.get(2)?,
                    description: row.get(3)?,
                    associated_stat: row.get(4)?,
                    mechanics_blob: row.get(5)?,
                })
            }).map_err(|e| e.to_string())?;
            rows.collect::<Result<Vec<_>, _>>().map_err(|e| e.to_string())?
        }
    };

    Ok(skills)
}

#[tauri::command]
fn reset_database() -> Result<(), String> {
    let source = get_db_path()?;
    let destination = std::env::current_dir()
        .map_err(|e| e.to_string())?
        .join("../src/assets/main.db");
    std::fs::copy(&source, &destination).map_err(|e| e.to_string())?;
    Ok(())
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_opener::init())
        .invoke_handler(tauri::generate_handler![get_actors, get_game_systems, get_entity_entries, get_skills, reset_database])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}

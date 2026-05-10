use rusqlite::Connection;
use std::sync::Mutex;
use tauri::Manager;

struct CharDb(Mutex<Option<Connection>>);

fn open_mem_db(data: &[u8]) -> Result<Connection, Box<dyn std::error::Error>> {
    let conn = Connection::open_in_memory()?;
    
    let temp_path = std::env::temp_dir().join("temp_characters.db");
    std::fs::write(&temp_path, data)?;
    
    conn.execute("ATTACH DATABASE ? AS extdb", [temp_path.to_str().unwrap()])?;
    
    for row in conn.prepare("SELECT name FROM extdb.sqlite_master WHERE type='table'")?.query_map([], |row| row.get::<_, String>(0))? {
        let table_name = row?;
        conn.execute(&format!("CREATE TABLE {} AS SELECT * FROM extdb.{}", table_name, table_name), [])?;
    }
    
    conn.execute("DETACH DATABASE extdb", [])?;
    let _ = std::fs::remove_file(temp_path);
    
    Ok(conn)
}

#[derive(serde::Serialize)]
struct CharacterSummary {
    id: i64,
    name: String,
}

#[derive(serde::Serialize)]
struct CharacterDetail {
    name: String,
    class_name: String,
    level: i64,
    race: String,
    background: String,
    armor_class: i64,
    hit_points: i64,
    max_hp: i64,
    speed: i64,
    strength: i64,
    dexterity: i64,
    constitution: i64,
    intelligence: i64,
    wisdom: i64,
    charisma: i64,
    proficiency_bonus: i64,
    notes: String,
}

#[tauri::command]
fn get_all_characters(state: tauri::State<CharDb>) -> Result<Vec<CharacterSummary>, String> {
    let conn = state.0.lock().unwrap();
    let conn = conn.as_ref().ok_or("Database not loaded")?;
    let mut stmt = conn
        .prepare("SELECT id, name FROM player_characters ORDER BY name")
        .map_err(|e| e.to_string())?;
    let chars = stmt
        .query_map([], |row| {
            Ok(CharacterSummary {
                id: row.get(0)?,
                name: row.get(1)?,
            })
        })
        .map_err(|e| e.to_string())?
        .collect::<std::result::Result<Vec<_>, _>>()
        .map_err(|e| e.to_string())?;
    Ok(chars)
}

#[tauri::command]
fn get_character_detail(state: tauri::State<CharDb>, id: i64) -> Result<CharacterDetail, String> {
    let conn = state.0.lock().unwrap();
    let conn = conn.as_ref().ok_or("Database not loaded")?;
    let mut stmt = conn
        .prepare(
            "SELECT pc.name, c.name, pc.level, r.name, b.name,
                    pc.armor_class, pc.hit_points, pc.max_hp, pc.speed,
                    pc.strength, pc.dexterity, pc.constitution, pc.intelligence, pc.wisdom, pc.charisma,
                    pc.proficiency_bonus, pc.notes
             FROM player_characters pc
             LEFT JOIN classes c ON pc.class_id = c.id
             LEFT JOIN races r ON pc.race_id = r.id
             LEFT JOIN backgrounds b ON pc.background_id = b.id
             WHERE pc.id = ?"
        )
        .map_err(|e| e.to_string())?;
    let pc = stmt
        .query_row([id], |row| {
            Ok(CharacterDetail {
                name: row.get(0)?,
                class_name: row.get(1)?,
                level: row.get(2)?,
                race: row.get::<_, Option<String>>(3)?.unwrap_or_default(),
                background: row.get::<_, Option<String>>(4)?.unwrap_or_default(),
                armor_class: row.get(5)?,
                hit_points: row.get(6)?,
                max_hp: row.get(7)?,
                speed: row.get(8)?,
                strength: row.get(9)?,
                dexterity: row.get(10)?,
                constitution: row.get(11)?,
                intelligence: row.get(12)?,
                wisdom: row.get(13)?,
                charisma: row.get(14)?,
                proficiency_bonus: row.get(15)?,
                notes: row.get::<_, Option<String>>(16)?.unwrap_or_default(),
            })
        })
        .map_err(|e| e.to_string())?;
    Ok(pc)
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_opener::init())
        .manage(CharDb(Mutex::new(None)))
        .setup(|app| {
            let resource_path = app.path().resource_dir()
                .expect("Failed to get resource dir")
                .join("characters.db");
            let data = std::fs::read(&resource_path)
                .expect("Failed to read characters.db");
            let conn = open_mem_db(&data).expect("Failed to open characters.db in memory");
            app.state::<CharDb>().0.lock().unwrap().replace(conn);
            Ok(())
        })
        .invoke_handler(tauri::generate_handler![get_all_characters, get_character_detail])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}

mod commands;
mod db;
mod models;

use db::DbPool;
use commands::characters::{create_player_character, get_player_characters, update_entity_hp};
use commands::creatures::{get_monsters, get_npcs};
use commands::skills::get_character_skills;

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    let db_pool = DbPool::new().expect("Failed to open database");

    tauri::Builder::default()
        .plugin(tauri_plugin_opener::init())
        .manage(db_pool)
        .invoke_handler(tauri::generate_handler![
            get_player_characters,
            create_player_character,
            get_monsters,
            get_npcs,
            get_character_skills,
            update_entity_hp,
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
mod commands;
mod db;
mod models;
pub mod rules;

use db::DbPool;
use std::path::PathBuf;
use tauri::Manager;
use commands::characters::{create_player_character, get_player_characters, update_entity_hp, validate_character_stats};
use commands::creatures::{get_monsters, get_npcs};
use commands::encounters::{delete_encounter, delete_state, load_encounters, load_state, load_states, save_encounter, save_state};
use commands::reference::{get_backgrounds, get_classes, get_races, get_subclasses, get_subraces};
use commands::skills::get_character_skills;
use commands::spells::{get_character_spells, get_spell_library, get_entity_spell_slots};

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_opener::init())
        .setup(|app| {
            // Resolve the seed database path.
            // In bundled/release builds the file comes from bundle resources.
            // In development (npm run tauri dev) we fall back to the source-tree path.
            let seed_path = app
                .path()
                .resource_dir()
                .map(|mut p| {
                    p.push("Assets/5e_data.sqlite");
                    p
                })
                .unwrap_or_else(|_| {
                    PathBuf::from(env!("CARGO_MANIFEST_DIR"))
                        .parent()
                        .unwrap()
                        .join("Assets/5e_data.sqlite")
                });

            // Resolve the runtime database path in the app data directory
            let mut data_dir = app
                .path()
                .app_data_dir()
                .map_err(|e| Box::new(std::io::Error::new(std::io::ErrorKind::Other, e)) as Box<dyn std::error::Error>)?;
            let dest_path = {
                data_dir.push("5e_data.sqlite");
                data_dir
            };

            // Seed/copy the database if it doesn't exist yet
            db::seed_database(&dest_path, &seed_path).map_err(|e| {
                Box::new(std::io::Error::new(std::io::ErrorKind::Other, e))
                    as Box<dyn std::error::Error>
            })?;

            // Create the pool and register it with Tauri's state management
            let db_pool = DbPool::new(dest_path).map_err(|e| {
                Box::new(std::io::Error::new(std::io::ErrorKind::Other, e))
                    as Box<dyn std::error::Error>
            })?;
            app.manage(db_pool);

            Ok(())
        })
        .invoke_handler(tauri::generate_handler![
            get_player_characters,
            create_player_character,
            get_monsters,
            get_npcs,
            get_character_skills,
            get_character_spells,
            get_spell_library,
            get_entity_spell_slots,
            update_entity_hp,
            save_encounter,
            load_encounters,
            delete_encounter,
            save_state,
            load_states,
            load_state,
            delete_state,
            // Reference data commands
            get_classes,
            get_subclasses,
            get_races,
            get_subraces,
            get_backgrounds,
            // Validation
            validate_character_stats,
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}

use crate::db::{queries, row_indexes, DbPool};
use crate::models::{Monster, Npc};
use tauri::State;

#[tauri::command]
pub fn get_monsters(state: State<DbPool>) -> Result<Vec<Monster>, String> {
    let conn = state.lock()?;
    eprintln!("[DEBUG get_monsters] Starting...");
    let mut stmt = conn.prepare(queries::GET_MONSTERS).map_err(|e| {
        eprintln!("[DEBUG get_monsters] Prepare error: {}", e);
        e.to_string()
    })?;

    eprintln!("[DEBUG get_monsters] Query prepared, executing...");
    let monsters = stmt.query_map([], |row| {
        let id: String = row.get(row_indexes::IDX).unwrap_or_default();
        let name: String = row.get(row_indexes::NAME).unwrap_or_default();
        eprintln!("[DEBUG get_monsters] Row: id={}, name={}", id, name);
        Ok(Monster {
            id: row.get(row_indexes::IDX)?,
            name: row.get(row_indexes::NAME)?,
            entity_type: row.get(row_indexes::ENTITY_TYPE)?,
            armor_class: row.get(row_indexes::ARMOR_CLASS)?,
            hit_points_max: row.get(row_indexes::HP_MAX)?,
            hit_points_current: row.get(row_indexes::HP_CURRENT)?,
            challenge_rating: row.get(row_indexes::CHALLENGE_RATING)?,
            strength: row.get(row_indexes::STRENGTH)?,
            dexterity: row.get(row_indexes::DEXTERITY)?,
            constitution: row.get(row_indexes::CONSTITUTION)?,
            intelligence: row.get(row_indexes::INTELLIGENCE)?,
            wisdom: row.get(row_indexes::WISDOM)?,
            charisma: row.get(row_indexes::CHARISMA)?,
        })
    })
    .map_err(|e| e.to_string())?
    .filter_map(|r| r.ok())
    .collect();

    eprintln!("[DEBUG get_monsters] Found {} monsters", monsters.len());
    Ok(monsters)
}

#[tauri::command]
pub fn get_npcs(state: State<DbPool>) -> Result<Vec<Npc>, String> {
    let conn = state.lock()?;
    let mut stmt = conn.prepare(queries::GET_NPCS).map_err(|e| e.to_string())?;

    let npcs = stmt.query_map([], |row| {
        Ok(Npc {
            id: row.get(row_indexes::IDX)?,
            name: row.get(row_indexes::NAME)?,
            entity_type: row.get(row_indexes::ENTITY_TYPE)?,
            armor_class: row.get(row_indexes::ARMOR_CLASS)?,
            hit_points_max: row.get(row_indexes::HP_MAX)?,
            hit_points_current: row.get(row_indexes::HP_CURRENT)?,
            strength: row.get(row_indexes::STRENGTH)?,
            dexterity: row.get(row_indexes::DEXTERITY)?,
            constitution: row.get(row_indexes::CONSTITUTION)?,
            intelligence: row.get(row_indexes::INTELLIGENCE)?,
            wisdom: row.get(row_indexes::WISDOM)?,
            charisma: row.get(row_indexes::CHARISMA)?,
        })
    })
    .map_err(|e| e.to_string())?
    .filter_map(|r| r.ok())
    .collect();

    Ok(npcs)
}
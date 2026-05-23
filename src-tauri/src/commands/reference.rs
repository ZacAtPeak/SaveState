use crate::db::{queries, DbPool};
use crate::models::{AbilityBonus, Background, Class, Race, Subclass, Subrace};
use tauri::State;

#[tauri::command]
pub fn get_classes(state: State<DbPool>) -> Result<Vec<Class>, String> {
    let conn = state.lock()?;
    let mut stmt = conn.prepare(queries::GET_CLASSES).map_err(|e| e.to_string())?;

    let classes = stmt
        .query_map([], |row| {
            Ok(Class {
                id: row.get(0)?,
                name: row.get(1)?,
                hit_die: row.get(2)?,
                saving_throw_1: row.get(3)?,
                saving_throw_2: row.get(4)?,
                primary_ability: row.get(5)?,
                description: row.get(6)?,
                skill_picks: row.get(7)?,
            })
        })
        .map_err(|e| e.to_string())?
        .filter_map(|r| r.ok())
        .collect();

    Ok(classes)
}

#[tauri::command]
pub fn get_subclasses(class_id: String, state: State<DbPool>) -> Result<Vec<Subclass>, String> {
    let conn = state.lock()?;
    let mut stmt = conn.prepare(queries::GET_SUBCLASSES).map_err(|e| e.to_string())?;

    let subclasses = stmt
        .query_map([&class_id], |row| {
            Ok(Subclass {
                id: row.get(0)?,
                name: row.get(1)?,
                description: row.get(2)?,
            })
        })
        .map_err(|e| e.to_string())?
        .filter_map(|r| r.ok())
        .collect();

    Ok(subclasses)
}

#[tauri::command]
pub fn get_races(state: State<DbPool>) -> Result<Vec<Race>, String> {
    let conn = state.lock()?;

    // Get all parent races
    let mut stmt = conn.prepare(queries::GET_RACES).map_err(|e| e.to_string())?;

    let races = stmt
        .query_map([], |row| {
            let id: String = row.get(0)?;
            Ok((id, row.get(1)?, row.get(2)?, row.get(3)?, row.get(4)?))
        })
        .map_err(|e| e.to_string())?
        .filter_map(|r| r.ok())
        .collect::<Vec<(String, String, String, i32, i32)>>();

    // Fetch ability bonuses for each race
    let mut bonus_stmt = conn
        .prepare(queries::GET_RACE_ABILITY_BONUSES)
        .map_err(|e| e.to_string())?;

    let result = races
        .into_iter()
        .map(|(id, name, size, speed_walk, darkvision)| {
            let bonuses = bonus_stmt
                .query_map([&id], |row| {
                    Ok(AbilityBonus {
                        ability: row.get(0)?,
                        bonus: row.get(1)?,
                    })
                })
                .map_err(|e| e.to_string())?
                .filter_map(|r| r.ok())
                .collect();

            Ok(Race {
                id,
                name,
                size,
                speed_walk,
                darkvision,
                ability_bonuses: bonuses,
            })
        })
        .collect::<Result<Vec<_>, String>>()?;

    Ok(result)
}

#[tauri::command]
pub fn get_subraces(race_id: String, state: State<DbPool>) -> Result<Vec<Subrace>, String> {
    let conn = state.lock()?;
    let mut stmt = conn.prepare(queries::GET_SUBRACES).map_err(|e| e.to_string())?;

    let subraces = stmt
        .query_map([&race_id], |row| {
            Ok(Subrace {
                id: row.get(0)?,
                name: row.get(1)?,
                race_id: row.get(2)?,
                description: row.get(3)?,
            })
        })
        .map_err(|e| e.to_string())?
        .filter_map(|r| r.ok())
        .collect();

    Ok(subraces)
}

#[tauri::command]
pub fn get_backgrounds(state: State<DbPool>) -> Result<Vec<Background>, String> {
    let conn = state.lock()?;
    let mut stmt = conn.prepare(queries::GET_BACKGROUNDS).map_err(|e| e.to_string())?;

    let backgrounds = stmt
        .query_map([], |row| {
            Ok(Background {
                id: row.get(0)?,
                name: row.get(1)?,
                description: row.get(2)?,
                skill_proficiencies: row.get(3)?,
                feature_name: row.get(4)?,
                feature_description: row.get(5)?,
            })
        })
        .map_err(|e| e.to_string())?
        .filter_map(|r| r.ok())
        .collect();

    Ok(backgrounds)
}

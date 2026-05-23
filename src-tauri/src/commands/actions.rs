use crate::db::{queries, DbPool};
use crate::models::EntityAction;
use tauri::State;

#[tauri::command]
pub fn get_entity_actions(
    entity_id: String,
    state: State<DbPool>,
) -> Result<Vec<EntityAction>, String> {
    let conn = state.lock()?;
    let mut stmt = conn.prepare(queries::GET_ENTITY_ACTIONS).map_err(|e| e.to_string())?;

    let actions = stmt
        .query_map([&entity_id], |row| {
            let is_attack: i32 = row.get(4)?;

            Ok(EntityAction {
                action_id: row.get(0)?,
                name: row.get(1)?,
                action_type: row.get(2)?,
                description: row.get(3)?,
                is_attack: is_attack == 1,
                attack_bonus: row.get(5)?,
                damage_dice: row.get(6)?,
                damage_type: row.get(7)?,
                uses_per_day: row.get(8)?,
                uses_current: row.get(9)?,
                recharge_formula: row.get(10)?,
            })
        })
        .map_err(|e| e.to_string())?
        .filter_map(|r| r.ok())
        .collect();

    Ok(actions)
}

use crate::db::{queries, DbPool};
use crate::models::CharacterSkill;
use tauri::State;

#[tauri::command]
pub fn get_character_skills(
    entity_id: String,
    proficiency_bonus: i32,
    state: State<DbPool>,
) -> Result<Vec<CharacterSkill>, String> {
    let conn = state.lock()?;
    let mut stmt = conn.prepare(queries::GET_CHARACTER_SKILLS).map_err(|e| e.to_string())?;

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
    })
    .map_err(|e| e.to_string())?
    .filter_map(|r| r.ok())
    .collect();

    Ok(skills)
}
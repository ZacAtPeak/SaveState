use crate::db::{queries, row_indexes, DbPool};
use crate::models::{CreateCharacterRequest, PlayerCharacter};
use tauri::State;

#[tauri::command]
pub fn get_player_characters(state: State<DbPool>) -> Result<Vec<PlayerCharacter>, String> {
    let conn = state.lock()?;
    let mut stmt = conn.prepare(queries::GET_PLAYER_CHARACTERS).map_err(|e| e.to_string())?;

    let chars = stmt.query_map([], |row| {
        Ok(PlayerCharacter {
            id: row.get(row_indexes::IDX)?,
            name: row.get(row_indexes::NAME)?,
            entity_type: row.get(row_indexes::ENTITY_TYPE)?,
            race: row.get(row_indexes::RACE)?,
            player_name: row.get(row_indexes::PLAYER_NAME)?,
            class: row.get(row_indexes::CLASS)?,
            level: row.get(row_indexes::LEVEL)?,
            armor_class: row.get(row_indexes::ARMOR_CLASS)?,
            hit_points_max: row.get(row_indexes::HP_MAX)?,
            hit_points_current: row.get(row_indexes::HP_CURRENT)?,
            strength: row.get(row_indexes::STRENGTH)?,
            dexterity: row.get(row_indexes::DEXTERITY)?,
            constitution: row.get(row_indexes::CONSTITUTION)?,
            intelligence: row.get(row_indexes::INTELLIGENCE)?,
            wisdom: row.get(row_indexes::WISDOM)?,
            charisma: row.get(row_indexes::CHARISMA)?,
            proficiency_bonus: row.get(row_indexes::PROFICIENCY_BONUS)?,
        })
    })
    .map_err(|e| e.to_string())?
    .filter_map(|r| r.ok())
    .collect();

    Ok(chars)
}

#[tauri::command]
pub fn create_player_character(
    req: CreateCharacterRequest,
    state: State<DbPool>,
) -> Result<PlayerCharacter, String> {
    let conn = state.lock()?;
    let id = uuid::Uuid::new_v4().to_string();
    let proficiency_bonus = (req.level - 1) / 4 + 2;

    conn.execute(
        queries::INSERT_ENTITY,
        [&id, &req.name, &req.armor_class.to_string(), &req.hit_points_max.to_string(), &req.hit_points_current.to_string()],
    ).map_err(|e| e.to_string())?;

    conn.execute(
        queries::INSERT_ENTITY_STATS,
        [&id, &req.strength.to_string(), &req.dexterity.to_string(), &req.constitution.to_string(), &req.intelligence.to_string(), &req.wisdom.to_string(), &req.charisma.to_string()],
    ).map_err(|e| e.to_string())?;

    conn.execute(
        queries::INSERT_CHARACTER_PROFILE,
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
pub fn update_entity_hp(
    entity_id: String,
    hit_points_current: i32,
    state: State<DbPool>,
) -> Result<(), String> {
    let conn = state.lock()?;
    conn.execute(
        queries::UPDATE_ENTITY_HP,
        [&hit_points_current.to_string(), &entity_id],
    )
    .map_err(|e| e.to_string())?;
    Ok(())
}
use crate::db::{queries, row_indexes, DbPool};
use crate::models::{CreateCharacterRequest, PlayerCharacter, ValidationResult};
use crate::rules;
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
    let proficiency_bonus = rules::proficiency_bonus(req.level);

    // Insert base entity
    conn.execute(
        queries::INSERT_ENTITY,
        [
            &id,
            &req.name,
            &req.armor_class.to_string(),
            &req.hit_points_max.to_string(),
            &req.hit_points_current.to_string(),
        ],
    )
    .map_err(|e| e.to_string())?;

    // Insert entity stats (ability scores)
    conn.execute(
        queries::INSERT_ENTITY_STATS,
        [
            &id,
            &req.strength.to_string(),
            &req.dexterity.to_string(),
            &req.constitution.to_string(),
            &req.intelligence.to_string(),
            &req.wisdom.to_string(),
            &req.charisma.to_string(),
        ],
    )
    .map_err(|e| e.to_string())?;

    // Write save proficiencies to entity_stats if provided
    if let Some(save_ids) = &req.proficient_save_ids {
        let str_prof = if save_ids.contains(&"strength".to_string()) { 1 } else { 0 };
        let dex_prof = if save_ids.contains(&"dexterity".to_string()) { 1 } else { 0 };
        let con_prof = if save_ids.contains(&"constitution".to_string()) { 1 } else { 0 };
        let int_prof = if save_ids.contains(&"intelligence".to_string()) { 1 } else { 0 };
        let wis_prof = if save_ids.contains(&"wisdom".to_string()) { 1 } else { 0 };
        let cha_prof = if save_ids.contains(&"charisma".to_string()) { 1 } else { 0 };

        conn.execute(
            queries::UPDATE_ENTITY_STATS_SAVE_PROFS,
            [
                &id,
                &str_prof.to_string(),
                &dex_prof.to_string(),
                &con_prof.to_string(),
                &int_prof.to_string(),
                &wis_prof.to_string(),
                &cha_prof.to_string(),
            ],
        )
        .map_err(|e| e.to_string())?;
    }

    // Determine primary class name and total level
    let (primary_class_name, total_level) = if let Some(class_pairs) = &req.class_ids_and_levels {
        // Look up the first class name from the classes table
        let primary_name: String = class_pairs.first().map_or(req.class.clone(), |first_pair| {
            if let Ok(mut stmt) = conn.prepare("SELECT name FROM classes WHERE id = ?1") {
                if let Ok(mut rows) = stmt.query_map([&first_pair.class_id], |row| row.get::<_, String>(0)) {
                    if let Some(Ok(name)) = rows.next() {
                        return name;
                    }
                }
            }
            req.class.clone()
        });

        let total: i32 = class_pairs.iter().map(|p| p.level).sum();

        // Insert character_classes rows
        for (i, pair) in class_pairs.iter().enumerate() {
            let subclass_id = if i == 0 {
                req.subclass_id.clone()
            } else {
                None
            };
            conn.execute(
                queries::INSERT_CHARACTER_CLASS,
                [
                    &id,
                    &pair.class_id,
                    &subclass_id.unwrap_or_default(),
                    &pair.level.to_string(),
                    &(if i == 0 { "1" } else { "0" }.to_string()),
                ],
            )
            .map_err(|e| e.to_string())?;
        }

        (primary_name, total)
    } else {
        (req.class.clone(), req.level)
    };

    // Insert character profile (backward-compatible denormalized write)
    let final_class = if !req.class.is_empty() {
        req.class.clone()
    } else {
        primary_class_name.clone()
    };

    conn.execute(
        queries::INSERT_CHARACTER_PROFILE,
        [
            &id,
            &final_class,
            &total_level.to_string(),
            &req.race,
            &req.player_name.clone().unwrap_or_default(),
            &proficiency_bonus.to_string(),
        ],
    )
    .map_err(|e| e.to_string())?;

    // Write skill proficiencies to entity_skills if provided
    if let Some(skill_ids) = &req.proficient_skill_ids {
        for skill_id in skill_ids {
            conn.execute(queries::INSERT_ENTITY_SKILL, [&id, skill_id])
                .map_err(|e| e.to_string())?;
        }
    }

    Ok(PlayerCharacter {
        id,
        name: req.name,
        entity_type: "pc".to_string(),
        class: primary_class_name,
        level: total_level,
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

/// Validate character stats without modifying any database state.
#[tauri::command]
pub fn validate_character_stats(
    stat_roll_method: String,
    raw_scores: Vec<i32>,
    class_ids: Vec<String>,
    subclass_id: Option<String>,
    selected_skill_count: usize,
) -> Result<ValidationResult, String> {
    // Convert scores to fixed array
    let scores: [i32; 6] = [
        raw_scores.first().copied().unwrap_or(10),
        raw_scores.get(1).copied().unwrap_or(10),
        raw_scores.get(2).copied().unwrap_or(10),
        raw_scores.get(3).copied().unwrap_or(10),
        raw_scores.get(4).copied().unwrap_or(10),
        raw_scores.get(5).copied().unwrap_or(10),
    ];

    let result = rules::validate_character_stats(
        &stat_roll_method,
        &scores,
        &class_ids,
        subclass_id.as_deref(),
        selected_skill_count,
    );

    Ok(result)
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



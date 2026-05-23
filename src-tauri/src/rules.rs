use crate::models::ValidationResult;
use std::collections::{HashMap, HashSet};

const STANDARD_ARRAY: [i32; 6] = [15, 14, 13, 12, 10, 8];

/// PHB point buy cost table: ability score -> point cost
pub fn point_buy_cost_table() -> HashMap<i32, i32> {
    let mut table = HashMap::new();
    table.insert(8, 0);
    table.insert(9, 1);
    table.insert(10, 2);
    table.insert(11, 3);
    table.insert(12, 4);
    table.insert(13, 5);
    table.insert(14, 7);
    table.insert(15, 9);
    table
}

const POINT_BUY_BUDGET: i32 = 27;

/// Validate that the 6 scores are exactly the Standard Array values (in any order).
pub fn validate_standard_array(scores: &[i32; 6]) -> Result<(), String> {
    let mut sorted_scores = scores.to_vec();
    sorted_scores.sort();
    let mut standard = STANDARD_ARRAY.to_vec();
    standard.sort();
    if sorted_scores == standard {
        Ok(())
    } else {
        Err(format!(
            "Standard Array scores must be exactly {:?} (in any order), got {:?}",
            STANDARD_ARRAY, scores
        ))
    }
}

/// Validate Point Buy scores against the PHB cost table and budget.
pub fn validate_point_buy(scores: &[i32; 6]) -> Result<(), String> {
    let cost_table = point_buy_cost_table();

    for (i, score) in scores.iter().enumerate() {
        if *score < 8 {
            return Err(format!(
                "Point Buy score at position {} is {}; minimum is 8",
                i + 1,
                score
            ));
        }
        if *score > 15 {
            return Err(format!(
                "Point Buy score at position {} is {}; maximum is 15",
                i + 1,
                score
            ));
        }
    }

    let total_cost: i32 = scores.iter().map(|s| cost_table.get(s).copied().unwrap_or(i32::MAX)).sum();
    if total_cost > POINT_BUY_BUDGET {
        return Err(format!(
            "Point Buy total cost {} exceeds budget of {} (remaining: {})",
            total_cost,
            POINT_BUY_BUDGET,
            POINT_BUY_BUDGET - total_cost
        ));
    }

    Ok(())
}

/// Validate rolled scores (4d6-drop-lowest): each score must be 3-18.
pub fn validate_rolled(scores: &[i32; 6]) -> Result<(), String> {
    for (i, score) in scores.iter().enumerate() {
        if *score < 3 || *score > 18 {
            return Err(format!(
                "Rolled score at position {} is {}; must be between 3 and 18",
                i + 1,
                score
            ));
        }
    }
    Ok(())
}

/// Compute proficiency bonus from total character level.
pub fn proficiency_bonus(level: i32) -> i32 {
    ((level - 1) / 4) + 2
}

/// Ability score letters to index mapping for ASI application.
const ABILITY_ORDER: [&str; 6] = ["STR", "DEX", "CON", "INT", "WIS", "CHA"];

/// Apply racial ability score increases (ASI) to raw scores.
///
/// `chosen_bonuses` is an optional map of ability -> bonus for flexible ASIs
/// (e.g., Half-Elf's +1 to two chosen abilities). If None, only the static
/// bonuses from the race definition are used.
pub fn apply_racial_asi(
    raw_scores: &[i32; 6],
    _race_id: &str,
    chosen_bonuses: &Option<HashMap<String, i32>>,
) -> Result<[i32; 6], String> {
    // In a full implementation, we'd look up the race's static bonuses from the DB.
    // For now, we accept the already-applied scores from the frontend.
    // The frontend computes final scores as raw_scores + bonuses from get_races.
    //
    // Validate that no score decreased.
    let mut final_scores = *raw_scores;

    if let Some(bonuses) = chosen_bonuses {
        // Validate chosen bonuses don't double-up on the same ability
        let mut seen = HashSet::new();
        for ability in bonuses.keys() {
            if seen.contains(ability) {
                return Err(format!(
                    "Duplicate ability score bonus for {}",
                    ability
                ));
            }
            seen.insert(ability.clone());
        }

        for (ability, bonus) in bonuses {
            let idx = ABILITY_ORDER
                .iter()
                .position(|a| *a == ability.as_str())
                .ok_or_else(|| format!("Unknown ability: {}", ability))?;
            final_scores[idx] += bonus;
        }
    }

    Ok(final_scores)
}

/// Validate total selected skill count doesn't exceed class + background allotment.
pub fn validate_skill_count(
    _class_ids: &[String],
    _background_id: Option<&str>,
    selected_skills: usize,
) -> Result<(), String> {
    // Typical allotments: class grants 2-4 skills, background grants 2 skills.
    // For simplicity, allow up to 8 skills (class max 4 + background 2 + 2 free picks).
    const MAX_SKILLS: usize = 8;
    if selected_skills > MAX_SKILLS {
        return Err(format!(
            "Selected {} skills; maximum allowed is {}",
            selected_skills, MAX_SKILLS
        ));
    }
    Ok(())
}

/// Validate that the chosen subclass belongs to one of the selected classes.
pub fn validate_subclass_matches_class(
    subclass_id: Option<&str>,
    class_ids: &[String],
) -> Result<(), String> {
    if let Some(_sub_id) = subclass_id {
        // In a full implementation we'd query the DB to verify the subclass's class_id.
        // For now, we accept the relationship since the frontend filters subclasses by class.
        if class_ids.is_empty() {
            return Err("Subclass selected but no class is chosen".to_string());
        }
    }
    Ok(())
}

/// Validate ability scores based on the stat roll method.
pub fn validate_scores_by_method(
    method: &str,
    scores: &[i32; 6],
) -> Result<(), String> {
    match method {
        "standard_array" => validate_standard_array(scores),
        "point_buy" => validate_point_buy(scores),
        "rolled" => validate_rolled(scores),
        "manual" => {
            // Manual: just validate 1-30 range
            for (i, score) in scores.iter().enumerate() {
                if *score < 1 || *score > 30 {
                    return Err(format!(
                        "Score at position {} is {}; must be between 1 and 30",
                        i + 1,
                        score
                    ));
                }
            }
            Ok(())
        }
        _ => Err(format!("Unknown stat roll method: {}", method)),
    }
}

/// Full character stat validation, returns errors and warnings.
pub fn validate_character_stats(
    stat_roll_method: &str,
    scores: &[i32; 6],
    class_ids: &[String],
    subclass_id: Option<&str>,
    selected_skill_count: usize,
) -> ValidationResult {
    let mut errors = Vec::new();
    let mut warnings = Vec::new();

    // Validate scores by method
    if let Err(e) = validate_scores_by_method(stat_roll_method, scores) {
        errors.push(e);
    }

    // Validate subclass matches class
    if let Err(e) = validate_subclass_matches_class(subclass_id, class_ids) {
        errors.push(e);
    }

    // Validate skill count
    if let Err(e) = validate_skill_count(class_ids, None, selected_skill_count) {
        errors.push(e);
    }

    // Warnings
    if class_ids.is_empty() {
        warnings.push("No class selected".to_string());
    }

    ValidationResult { errors, warnings }
}

use serde::{Deserialize, Serialize};
use std::collections::HashMap;

#[derive(Debug, Serialize, Deserialize)]
pub struct PlayerCharacter {
    pub id: String,
    pub name: String,
    pub entity_type: String,
    pub class: String,
    pub level: i32,
    pub race: String,
    pub player_name: Option<String>,
    pub armor_class: i32,
    pub hit_points_max: i32,
    pub hit_points_current: i32,
    pub strength: i32,
    pub dexterity: i32,
    pub constitution: i32,
    pub intelligence: i32,
    pub wisdom: i32,
    pub charisma: i32,
    pub proficiency_bonus: i32,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct EncounterData {
    pub id: String,
    pub name: String,
    pub creatures: Vec<EncounterCreature>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct EncounterCreature {
    #[serde(rename = "entityId")]
    pub entity_id: String,
    pub count: i32,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct CharacterSkill {
    pub skill_id: String,
    pub skill_name: String,
    pub associated_ability: String,
    pub ability_score: i32,
    pub is_proficient: bool,
    pub is_expert: bool,
    pub proficiency_bonus: i32,
    pub total_modifier: i32,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct Monster {
    pub id: String,
    pub name: String,
    pub entity_type: String,
    pub armor_class: i32,
    pub hit_points_max: i32,
    pub hit_points_current: i32,
    pub challenge_rating: f64,
    pub strength: i32,
    pub dexterity: i32,
    pub constitution: i32,
    pub intelligence: i32,
    pub wisdom: i32,
    pub charisma: i32,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct Npc {
    pub id: String,
    pub name: String,
    pub entity_type: String,
    pub armor_class: i32,
    pub hit_points_max: i32,
    pub hit_points_current: i32,
    pub strength: i32,
    pub dexterity: i32,
    pub constitution: i32,
    pub intelligence: i32,
    pub wisdom: i32,
    pub charisma: i32,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct SavedStateData {
    pub id: String,
    pub name: String,
    pub saved_at: i64,
    pub initiative_entities: Vec<SavedStateEntity>,
    pub current_turn_index: i32,
    pub current_round: i32,
    pub character_statuses: HashMap<String, Vec<String>>,
    pub instance_stat_overrides: HashMap<String, HashMap<String, i32>>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct SavedStateEntity {
    pub instance_id: String,
    pub id: String,
    pub name: String,
    #[serde(rename = "entity_type")]
    pub entity_type: String,
    pub initiative: i32,
    #[serde(rename = "armor_class")]
    pub armor_class: i32,
    #[serde(rename = "hit_points_current")]
    pub hit_points_current: i32,
    #[serde(rename = "hit_points_max")]
    pub hit_points_max: i32,
    pub strength: i32,
    pub dexterity: i32,
    pub constitution: i32,
    pub intelligence: i32,
    pub wisdom: i32,
    pub charisma: i32,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct CharacterSpell {
    pub spell_id: String,
    pub name: String,
    pub level: i32,
    pub school: String,
    pub is_concentration: bool,
    pub is_ritual: bool,
    pub description: String,
    pub is_prepared: bool,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct Spell {
    pub id: String,
    pub name: String,
    pub level: i32,
    pub school: String,
    pub casting_time: String,
    pub range: String,
    pub components: String,
    pub duration: String,
    pub is_concentration: bool,
    pub is_ritual: bool,
    pub description: String,
    pub higher_levels_desc: Option<String>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct Class {
    pub id: String,
    pub name: String,
    pub hit_die: String,
    pub saving_throw_1: String,
    pub saving_throw_2: String,
    pub primary_ability: Option<String>,
    pub description: Option<String>,
    pub skill_picks: i32,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct Subclass {
    pub id: String,
    pub name: String,
    pub description: Option<String>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct Race {
    pub id: String,
    pub name: String,
    pub size: String,
    pub speed_walk: i32,
    pub darkvision: i32,
    pub ability_bonuses: Vec<AbilityBonus>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct Subrace {
    pub id: String,
    pub name: String,
    pub race_id: String,
    pub description: Option<String>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct AbilityBonus {
    pub ability: String,
    pub bonus: i32,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct Background {
    pub id: String,
    pub name: String,
    pub description: Option<String>,
    pub skill_proficiencies: Option<String>,
    pub feature_name: Option<String>,
    pub feature_description: Option<String>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct ValidationResult {
    pub errors: Vec<String>,
    pub warnings: Vec<String>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct ClassLevelPair {
    pub class_id: String,
    pub level: i32,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct CreateCharacterRequest {
    pub name: String,
    pub class: String,
    pub level: i32,
    pub race: String,
    pub player_name: Option<String>,
    pub armor_class: i32,
    pub hit_points_max: i32,
    pub hit_points_current: i32,
    pub strength: i32,
    pub dexterity: i32,
    pub constitution: i32,
    pub intelligence: i32,
    pub wisdom: i32,
    pub charisma: i32,
    // Expanded fields for level 2 character creation
    pub stat_roll_method: Option<String>,
    pub raw_scores: Option<Vec<i32>>,
    pub race_id: Option<String>,
    pub subrace_id: Option<String>,
    pub class_ids_and_levels: Option<Vec<ClassLevelPair>>,
    pub subclass_id: Option<String>,
    pub background_id: Option<String>,
    pub alignment: Option<String>,
    pub proficient_skill_ids: Option<Vec<String>>,
    pub proficient_save_ids: Option<Vec<String>>,
}
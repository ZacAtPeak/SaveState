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
}
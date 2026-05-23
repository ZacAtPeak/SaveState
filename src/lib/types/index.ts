export interface Entity {
  id: string;
  name: string;
  entity_type: string;
  armor_class: number;
  hit_points_max: number;
  hit_points_current: number;
  strength: number;
  dexterity: number;
  constitution: number;
  intelligence: number;
  wisdom: number;
  charisma: number;
  race?: string;
  class?: string;
  level?: number;
  player_name?: string | null;
  proficiency_bonus?: number;
  challenge_rating?: number;
  skills?: { name: string; bonus: number }[];
  equipment?: string[];
  spells?: string[];
  speed?: number;
}

export interface PlayerCharacter extends Entity {
  race: string;
  class: string;
  level: number;
  player_name: string | null;
  proficiency_bonus: number;
}

export interface Creature extends Entity {
  challenge_rating: number;
}

export interface InitiativeEntity {
  instance_id: string;
  id: string;
  name: string;
  entity_type: string;
  initiative: number;
  armor_class: number;
  hit_points_current: number;
  hit_points_max: number;
  strength: number;
  dexterity: number;
  constitution: number;
  intelligence: number;
  wisdom: number;
  charisma: number;
}

export interface CharacterSkill {
  skill_id: string;
  skill_name: string;
  associated_ability: string;
  ability_score: number;
  is_proficient: boolean;
  is_expert: boolean;
  proficiency_bonus: number;
  total_modifier: number;
}

export interface CharacterSpell {
  spell_id: string;
  name: string;
  level: number;
  school: string;
  is_concentration: boolean;
  is_ritual: boolean;
  description: string;
  is_prepared: boolean;
}

export interface CharacterAction {
  action_id: string;
  name: string;
  action_type: string;
  description: string;
  is_attack: boolean;
  attack_bonus: number | null;
  damage_dice: string | null;
  damage_type: string | null;
  uses_per_day: number | null;
  uses_current: number | null;
  recharge_formula: string | null;
}

export interface Spell {
  id: string;
  name: string;
  level: number;
  school: string;
  casting_time: string;
  range: string;
  components: string;
  duration: string;
  is_concentration: boolean;
  is_ritual: boolean;
  description: string;
  higher_levels_desc: string | null;
}

export interface DndClass {
  id: string;
  name: string;
  hit_die: string;
  saving_throw_1: string;
  saving_throw_2: string;
  primary_ability: string | null;
  description: string | null;
  skill_picks: number;
}

export interface Subclass {
  id: string;
  name: string;
  description: string | null;
}

export interface Race {
  id: string;
  name: string;
  size: string;
  speed_walk: number;
  darkvision: number;
  ability_bonuses: { ability: string; bonus: number }[];
}

export interface Subrace {
  id: string;
  name: string;
  race_id: string;
  description: string | null;
}

export interface Background {
  id: string;
  name: string;
  description: string | null;
  skill_proficiencies: string | null;
  feature_name: string | null;
  feature_description: string | null;
}

export interface ValidationResult {
  errors: string[];
  warnings: string[];
}

export type StatRollMethod = 'standard_array' | 'point_buy' | 'rolled' | 'manual';

export interface ClassLevelPair {
  class_id: string;
  level: number;
}

export interface CreateCharacterRequest {
  name: string;
  class: string;
  level: number;
  race: string;
  player_name: string | null;
  armor_class: number;
  hit_points_max: number;
  hit_points_current: number;
  strength: number;
  dexterity: number;
  constitution: number;
  intelligence: number;
  wisdom: number;
  charisma: number;
  // Expanded fields for level 2 character creation
  stat_roll_method?: string;
  raw_scores?: number[];
  race_id?: string;
  subrace_id?: string;
  class_ids_and_levels?: ClassLevelPair[];
  subclass_id?: string;
  background_id?: string;
  alignment?: string;
  proficient_skill_ids?: string[];
  proficient_save_ids?: string[];
}

export interface DiceRoll {
  id: string;
  dice: string;
  sides: number;
  count: number;
  results: number[];
  modifier: number;
  math: string;
  total: number;
  timestamp: number;
}

export interface SavedEncounter {
  id: string;
  name: string;
  creatures: { entityId: string; count: number }[];
}

export interface SpellSlotGroup {
  group_type: 'spellcasting' | 'pact_magic';
  spellcasting_ability: string;
  save_dc: number;
  attack_bonus: number;
  slots: SpellSlot[];
}

export interface SpellSlot {
  level: number;
  max: number;
  current: number;
}

export interface SpellSlotsResponse {
  groups: SpellSlotGroup[];
}

export interface SavedState {
  id: string;
  name: string;
  saved_at: number;
  initiative_entities: InitiativeEntity[];
  current_turn_index: number;
  current_round: number;
  character_statuses: Record<string, string[]>;
  instance_stat_overrides: Record<string, Record<string, number>>;
}
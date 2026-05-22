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
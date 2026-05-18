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
  challenge_rating?: string;
}

export interface PlayerCharacter extends Entity {
  race: string;
  class: string;
  level: number;
  player_name: string | null;
  proficiency_bonus: number;
}

export interface InitiativeEntity {
  id: string;
  name: string;
  initiative: number;
  armor_class: number;
  hit_points_current: number;
  hit_points_max: number;
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
-- Explicitly enable foreign keys for your session (Run this when connecting!)
PRAGMA foreign_keys = ON;

---
-- 1. CORE ENTITY TABLES
---

CREATE TABLE entities (
    id TEXT PRIMARY KEY, -- Use a generated UUID, integer string, or slug
    name TEXT NOT NULL,
    entity_type TEXT NOT NULL CHECK (entity_type IN ('pc', 'npc', 'creature')),
    size TEXT DEFAULT 'Medium',
    alignment TEXT DEFAULT 'Neutral',
    armor_class INTEGER NOT NULL DEFAULT 10,
    armor_desc TEXT, -- e.g., "Natural Armor", "Leather Armor"
    hit_points_max INTEGER NOT NULL DEFAULT 10,
    hit_points_current INTEGER NOT NULL DEFAULT 10,
    hit_points_temp INTEGER NOT NULL DEFAULT 0,
    hit_dice_max INTEGER NOT NULL DEFAULT 1,
    hit_dice_current INTEGER NOT NULL DEFAULT 1,
    hit_dice_type TEXT DEFAULT 'd8', -- e.g., 'd6', 'd8', 'd10', 'd12'
    
    -- Speeds (Stored in feet)
    speed_walk INTEGER NOT NULL DEFAULT 30,
    speed_fly INTEGER NOT NULL DEFAULT 0,
    speed_swim INTEGER NOT NULL DEFAULT 0,
    speed_climb INTEGER NOT NULL DEFAULT 0,
    speed_burrow INTEGER NOT NULL DEFAULT 0,
    
    -- Senses
    darkvision INTEGER NOT NULL DEFAULT 0,
    blindsight INTEGER NOT NULL DEFAULT 0,
    tremorsense INTEGER NOT NULL DEFAULT 0,
    truesight INTEGER NOT NULL DEFAULT 0,
    passive_perception_override INTEGER, -- NULL means calculate dynamically
    
    languages TEXT, -- JSON array string or comma-separated text
    notes TEXT,
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);

-- Core Ability Scores (1-30 scale) and Saving Throws
CREATE TABLE entity_stats (
    entity_id TEXT PRIMARY KEY,
    strength INTEGER NOT NULL DEFAULT 10,
    dexterity INTEGER NOT NULL DEFAULT 10,
    constitution INTEGER NOT NULL DEFAULT 10,
    intelligence INTEGER NOT NULL DEFAULT 10,
    wisdom INTEGER NOT NULL DEFAULT 10,
    charisma INTEGER NOT NULL DEFAULT 10,
    
    -- Saving Throw Proficiencies (0 = False, 1 = True)
    save_prof_strength INTEGER NOT NULL DEFAULT 0 CHECK (save_prof_strength IN (0, 1)),
    save_prof_dexterity INTEGER NOT NULL DEFAULT 0 CHECK (save_prof_dexterity IN (0, 1)),
    save_prof_constitution INTEGER NOT NULL DEFAULT 0 CHECK (save_prof_constitution IN (0, 1)),
    save_prof_intelligence INTEGER NOT NULL DEFAULT 0 CHECK (save_prof_intelligence IN (0, 1)),
    save_prof_wisdom INTEGER NOT NULL DEFAULT 0 CHECK (save_prof_wisdom IN (0, 1)),
    save_prof_charisma INTEGER NOT NULL DEFAULT 0 CHECK (save_prof_charisma IN (0, 1)),
    FOREIGN KEY (entity_id) REFERENCES entities(id) ON DELETE CASCADE
);

---
-- 2. TYPE-SPECIFIC SUB-TABLES (1:1 Relationships)
---

-- Data exclusive to Player Characters
CREATE TABLE character_profiles (
    entity_id TEXT PRIMARY KEY,
    player_name TEXT,
    class TEXT NOT NULL,       -- e.g., "Fighter" (Can store multiple if comma/JSON parsed)
    subclass TEXT,
    level INTEGER NOT NULL DEFAULT 1,
    xp INTEGER NOT NULL DEFAULT 0,
    background TEXT,
    race TEXT NOT NULL,
    subrace TEXT,
    proficiency_bonus INTEGER NOT NULL DEFAULT 2,
    personality_traits TEXT,
    ideals TEXT,
    bonds TEXT,
    flaws TEXT,
    FOREIGN KEY (entity_id) REFERENCES entities(id) ON DELETE CASCADE
);

-- Data exclusive to Monsters / Stat-block NPCs
CREATE TABLE creature_profiles (
    entity_id TEXT PRIMARY KEY,
    challenge_rating REAL NOT NULL DEFAULT 0.0, -- Handles fractions like 0.25 (1/4) or 0.125 (1/8)
    xp_value INTEGER NOT NULL DEFAULT 0,
    creature_type TEXT NOT NULL, -- e.g., Fiend, Undead, Dragon
    creature_subtype TEXT,       -- e.g., Shapechanger, Demon
    is_legendary INTEGER NOT NULL DEFAULT 0 CHECK (is_legendary IN (0, 1)),
    legendary_resistances_max INTEGER NOT NULL DEFAULT 0,
    legendary_resistances_current INTEGER NOT NULL DEFAULT 0,
    habitat TEXT,                -- e.g., Coastal, Underdark
    FOREIGN KEY (entity_id) REFERENCES entities(id) ON DELETE CASCADE
);

---
-- 3. ACTIONS, FEATURES, AND TRAITS
---

-- Global library of actions/features
CREATE TABLE action_library (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    action_type TEXT NOT NULL CHECK (action_type IN ('action', 'bonus_action', 'reaction', 'legendary', 'mythic', 'lair', 'passive_trait')),
    description TEXT NOT NULL,
    is_attack INTEGER NOT NULL DEFAULT 0 CHECK (is_attack IN (0, 1)),
    attack_bonus INTEGER,       -- e.g., 5 for +5 to hit
    damage_dice TEXT,          -- e.g., "2d6 + 3"
    damage_type TEXT           -- e.g., "Slashing", "Fire"
);

-- Many-to-Many join table mapping entities to their specific actions
CREATE TABLE entity_actions (
    entity_id TEXT,
    action_id TEXT,
    uses_per_day INTEGER,      -- NULL if unlimited
    uses_current INTEGER,
    recharge_formula TEXT,     -- e.g., "Recharge 5-6" or "Short Rest"
    PRIMARY KEY (entity_id, action_id),
    FOREIGN KEY (entity_id) REFERENCES entities(id) ON DELETE CASCADE,
    FOREIGN KEY (action_id) REFERENCES action_library(id) ON DELETE CASCADE
);

---
-- 4. SPELLS AND SPELLCASTING
---

-- Global Spellbook Reference Table
CREATE TABLE spell_library (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    level INTEGER NOT NULL CHECK (level BETWEEN 0 AND 9), -- 0 = Cantrip
    school TEXT NOT NULL, -- e.g., Evocation, Necromancy
    casting_time TEXT NOT NULL,
    range TEXT NOT NULL,
    range_type TEXT,                 -- 'point', 'cone', 'radius', 'cube', 'line', 'sphere', 'hemisphere', 'special'
    range_distance_type TEXT,        -- 'feet', 'miles', 'touch', 'sight', 'self', 'unlimited'
    range_distance_amount INTEGER,   -- numeric value when range_distance_type is 'feet' or 'miles'
    components TEXT NOT NULL,        -- e.g., "V, S, M (a pinch of dust)"
    material_cost INTEGER,           -- gp value when M component has a cost (e.g., 2500 for Arcane Lock)
    material_consumed INTEGER NOT NULL DEFAULT 0 CHECK (material_consumed IN (0, 1)),
    duration TEXT NOT NULL,
    is_concentration INTEGER NOT NULL DEFAULT 0 CHECK (is_concentration IN (0, 1)),
    is_ritual INTEGER NOT NULL DEFAULT 0 CHECK (is_ritual IN (0, 1)),
    description TEXT NOT NULL,
    higher_levels_desc TEXT,

    -- Reference / Provenance
    source TEXT NOT NULL DEFAULT 'PHB',
    page INTEGER,
    srd INTEGER NOT NULL DEFAULT 0 CHECK (srd IN (0, 1)),

    -- Gameplay mechanics (JSON arrays — NULL when inapplicable)
    saving_throw TEXT,              -- e.g., '["dexterity"]'
    damage_inflict TEXT,            -- e.g., '["acid"]'
    condition_inflict TEXT,         -- e.g., '["paralyzed"]'
    spell_attack TEXT,              -- e.g., '["R"]' (ranged), '["M"]' (melee)
    damage_immune TEXT,             -- e.g., '["poison"]'
    damage_resist TEXT,             -- e.g., '["fire"]'
    damage_vulnerable TEXT,         -- e.g., '["acid","cold"]'
    condition_immune TEXT,          -- e.g., '["paralyzed","restrained"]'
    ability_check TEXT,             -- e.g., '["strength"]'
    affects_creature_type TEXT,     -- e.g., '["undead","celestial"]'
    misc_tags TEXT,                 -- e.g., '["SCL","SGT"]'
    area_tags TEXT                  -- e.g., '["MT","ST"]'
);

-- Cantrip scaling dice per character level
CREATE TABLE spell_scaling (
    spell_id TEXT,
    character_level INTEGER NOT NULL CHECK (character_level IN (1, 5, 11, 17)),
    dice TEXT NOT NULL,             -- e.g., '2d6'
    PRIMARY KEY (spell_id, character_level),
    FOREIGN KEY (spell_id) REFERENCES spell_library(id) ON DELETE CASCADE
);

-- Tracks an entity's spellcasting stats and current slot inventory
CREATE TABLE entity_spellcasting (
    entity_id TEXT PRIMARY KEY,
    spellcasting_ability TEXT NOT NULL CHECK (spellcasting_ability IN ('STR', 'DEX', 'CON', 'INT', 'WIS', 'CHA')),
    spell_save_dc_override INTEGER, -- If NULL, calculate using runtime logic
    spell_attack_bonus_override INTEGER,
    
    -- Spell slots (Max vs Current)
    slots_lvl_1_max INTEGER NOT NULL DEFAULT 0, slots_lvl_1_curr INTEGER NOT NULL DEFAULT 0,
    slots_lvl_2_max INTEGER NOT NULL DEFAULT 0, slots_lvl_2_curr INTEGER NOT NULL DEFAULT 0,
    slots_lvl_3_max INTEGER NOT NULL DEFAULT 0, slots_lvl_3_curr INTEGER NOT NULL DEFAULT 0,
    slots_lvl_4_max INTEGER NOT NULL DEFAULT 0, slots_lvl_4_curr INTEGER NOT NULL DEFAULT 0,
    slots_lvl_5_max INTEGER NOT NULL DEFAULT 0, slots_lvl_5_curr INTEGER NOT NULL DEFAULT 0,
    slots_lvl_6_max INTEGER NOT NULL DEFAULT 0, slots_lvl_6_curr INTEGER NOT NULL DEFAULT 0,
    slots_lvl_7_max INTEGER NOT NULL DEFAULT 0, slots_lvl_7_curr INTEGER NOT NULL DEFAULT 0,
    slots_lvl_8_max INTEGER NOT NULL DEFAULT 0, slots_lvl_8_curr INTEGER NOT NULL DEFAULT 0,
    slots_lvl_9_max INTEGER NOT NULL DEFAULT 0, slots_lvl_9_curr INTEGER NOT NULL DEFAULT 0,
    FOREIGN KEY (entity_id) REFERENCES entities(id) ON DELETE CASCADE
);

-- Many-to-Many join table for known/prepared spells
CREATE TABLE entity_spells (
    entity_id TEXT,
    spell_id TEXT,
    is_prepared INTEGER NOT NULL DEFAULT 1 CHECK (is_prepared IN (0, 1)),
    PRIMARY KEY (entity_id, spell_id),
    FOREIGN KEY (entity_id) REFERENCES entities(id) ON DELETE CASCADE,
    FOREIGN KEY (spell_id) REFERENCES spell_library(id) ON DELETE CASCADE
);

-- Tracks current (remaining) spell slot counts per entity, per slot type, per level
-- Max slots are always derived from class_level_progression (not stored here)
CREATE TABLE entity_spell_slot_state (
    entity_id   TEXT NOT NULL,
    slot_type   TEXT NOT NULL CHECK (slot_type IN ('spellcasting', 'pact_magic')),
    slot_level  INTEGER NOT NULL CHECK (slot_level BETWEEN 1 AND 9),
    slots_curr  INTEGER NOT NULL DEFAULT 0,
    PRIMARY KEY (entity_id, slot_type, slot_level),
    FOREIGN KEY (entity_id) REFERENCES entities(id) ON DELETE CASCADE
);

---
-- 5. DEFENSES, CONDITIONS & RESISTANCES
---

CREATE TABLE entity_damage_modifiers (
    entity_id TEXT,
    damage_type TEXT NOT NULL, -- e.g., 'Fire', 'Bludgeoning'
    modifier_type TEXT NOT NULL CHECK (modifier_type IN ('immunity', 'resistance', 'vulnerability')),
    PRIMARY KEY (entity_id, damage_type, modifier_type),
    FOREIGN KEY (entity_id) REFERENCES entities(id) ON DELETE CASCADE
);

CREATE TABLE entity_conditions (
    entity_id TEXT,
    condition_name TEXT NOT NULL, -- e.g., 'Blinded', 'Prone', 'Stunned'
    PRIMARY KEY (entity_id, condition_name),
    FOREIGN KEY (entity_id) REFERENCES entities(id) ON DELETE CASCADE
);

CREATE TABLE skills (
    id text primary key,
    name text,
    description text,
    associated_ability_score text
);

CREATE TABLE entity_skills (
    entity_id text,
    skill_id text,
    is_proficient int,
    is_expert int
);

CREATE TABLE abilities (
    id text primary key,
    name text,
    description text
);

CREATE TABLE classes (
    id TEXT PRIMARY KEY,       -- e.g., 'fighter', 'wizard', 'cleric'
    name TEXT NOT NULL UNIQUE,  -- e.g., 'Fighter'
    hit_die TEXT NOT NULL CHECK (hit_die IN ('d6', 'd8', 'd10', 'd12')),
    -- Primary ability scores for multiclassing prerequisites (optional data)
    primary_ability TEXT,       -- e.g., 'STR or DEX' for Fighter, 'INT' for Wizard
    -- Default saving throw proficiencies granted at level 1
    saving_throw_1 TEXT NOT NULL CHECK (saving_throw_1 IN ('STR', 'DEX', 'CON', 'INT', 'WIS', 'CHA')),
    saving_throw_2 TEXT NOT NULL CHECK (saving_throw_2 IN ('STR', 'DEX', 'CON', 'INT', 'WIS', 'CHA')),
    description TEXT,
    -- Number of skill proficiencies the class may select at level 1
    skill_picks INTEGER NOT NULL DEFAULT 2 CHECK (skill_picks BETWEEN 1 AND 6),
    spellcaster_type TEXT NOT NULL DEFAULT 'none'
        CHECK (spellcaster_type IN ('full', 'half', 'half_up', 'third', 'pact', 'none'))
);

CREATE TABLE subclasses (
    id TEXT PRIMARY KEY,
    class_id TEXT NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    spellcaster_type TEXT DEFAULT NULL
        CHECK (spellcaster_type IS NULL OR spellcaster_type IN ('third')),
    FOREIGN KEY (class_id) REFERENCES classes(id) ON DELETE CASCADE
);

CREATE TABLE class_level_progression (
    class_id TEXT,
    level INTEGER NOT NULL CHECK (level BETWEEN 1 AND 20),
    proficiency_bonus INTEGER NOT NULL,
    features TEXT, -- JSON array string of feature IDs unlocked at this level, e.g., "['action_surge', 'indomitable']"

    -- Standard Spell Slot Progression Lookup for this level
    slots_lvl_1 INTEGER NOT NULL DEFAULT 0,
    slots_lvl_2 INTEGER NOT NULL DEFAULT 0,
    slots_lvl_3 INTEGER NOT NULL DEFAULT 0,
    slots_lvl_4 INTEGER NOT NULL DEFAULT 0,
    slots_lvl_5 INTEGER NOT NULL DEFAULT 0,
    slots_lvl_6 INTEGER NOT NULL DEFAULT 0,
    slots_lvl_7 INTEGER NOT NULL DEFAULT 0,
    slots_lvl_8 INTEGER NOT NULL DEFAULT 0,
    slots_lvl_9 INTEGER NOT NULL DEFAULT 0,

    PRIMARY KEY (class_id, level),
    FOREIGN KEY (class_id) REFERENCES classes(id) ON DELETE CASCADE
);

CREATE TABLE character_classes (
    entity_id TEXT,
    class_id TEXT,
    subclass_id TEXT, -- Can be NULL if they haven't picked a subclass yet
    class_level INTEGER NOT NULL DEFAULT 1 CHECK (class_level BETWEEN 1 AND 20),
    is_primary INTEGER NOT NULL DEFAULT 0 CHECK (is_primary IN (0, 1)), -- 1 if it was their starting level 1 class

    PRIMARY KEY (entity_id, class_id),
    FOREIGN KEY (entity_id) REFERENCES entities(id) ON DELETE CASCADE,
    FOREIGN KEY (class_id) REFERENCES classes(id) ON DELETE CASCADE,
    FOREIGN KEY (subclass_id) REFERENCES subclasses(id) ON DELETE SET NULL
);

--
-- 6. RACES, SUBRACES, AND ABILITY BONUSES
--

CREATE TABLE races (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    size TEXT NOT NULL DEFAULT 'Medium',
    speed_walk INTEGER NOT NULL DEFAULT 30,
    darkvision INTEGER NOT NULL DEFAULT 0,
    parent_race_id TEXT,
    source TEXT DEFAULT 'PHB',
    FOREIGN KEY (parent_race_id) REFERENCES races(id) ON DELETE SET NULL
);

CREATE TABLE race_ability_bonuses (
    race_id TEXT NOT NULL,
    ability TEXT NOT NULL CHECK (ability IN ('STR', 'DEX', 'CON', 'INT', 'WIS', 'CHA')),
    bonus INTEGER NOT NULL DEFAULT 0,
    PRIMARY KEY (race_id, ability),
    FOREIGN KEY (race_id) REFERENCES races(id) ON DELETE CASCADE
);

CREATE TABLE subraces (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    race_id TEXT NOT NULL,
    description TEXT,
    FOREIGN KEY (race_id) REFERENCES races(id) ON DELETE CASCADE
);

--
-- 7. BACKGROUNDS
--

CREATE TABLE backgrounds (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    skill_proficiencies TEXT, -- JSON array of skill IDs, e.g., '["arc","his"]'
    tool_proficiencies TEXT, -- JSON array of tool IDs
    feature_name TEXT,
    feature_description TEXT,
    source TEXT DEFAULT 'PHB'
);



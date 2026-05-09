-- 1. Game Systems
CREATE TABLE game_systems (
    id TEXT PRIMARY KEY NOT NULL, -- UUIDs stored as strings
    name TEXT NOT NULL,
    action_economy_type TEXT NOT NULL CHECK (action_economy_type IN ('Standard', 'Action_Points', 'Three_Action')),
    uses_bounded_accuracy INTEGER NOT NULL CHECK (uses_bounded_accuracy IN (0, 1)) -- Boolean 0/1
);

-- 2. Actors
CREATE TABLE actors (
    id TEXT PRIMARY KEY NOT NULL,
    system_id TEXT NOT NULL,
    name TEXT NOT NULL,
    actor_type TEXT NOT NULL CHECK (actor_type IN ('Player', 'NPC', 'Hazard')),
    base_hp INTEGER NOT NULL,
    base_ac INTEGER NOT NULL,
    stats_blob TEXT, -- JSON content stored as text
    FOREIGN KEY (system_id) REFERENCES game_systems(id) ON DELETE CASCADE
);

-- 3. Abilities and Actions
CREATE TABLE abilities_and_actions (
    id TEXT PRIMARY KEY NOT NULL,
    actor_id TEXT NOT NULL,
    name TEXT NOT NULL,
    action_cost INTEGER NOT NULL,
    traits TEXT, -- SQLite handles arrays as JSON arrays in text
    effect_payload TEXT, -- JSON content
    FOREIGN KEY (actor_id) REFERENCES actors(id) ON DELETE CASCADE
);

-- 4. Encounters
CREATE TABLE encounters (
    id TEXT PRIMARY KEY NOT NULL,
    name TEXT NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('Draft', 'Active', 'Completed')),
    current_round INTEGER DEFAULT 1,
    active_combatant_id TEXT, -- Forward reference
    FOREIGN KEY (active_combatant_id) REFERENCES encounter_combatants(id)
);

-- 5. Encounter Combatants
CREATE TABLE encounter_combatants (
    id TEXT PRIMARY KEY NOT NULL,
    encounter_id TEXT NOT NULL,
    actor_id TEXT NOT NULL,
    initiative_score REAL, -- Float/Real
    current_hp INTEGER NOT NULL,
    temporary_hp INTEGER DEFAULT 0,
    available_actions INTEGER,
    FOREIGN KEY (encounter_id) REFERENCES encounters(id) ON DELETE CASCADE,
    FOREIGN KEY (actor_id) REFERENCES actors(id) ON DELETE CASCADE
);

-- 6. Combatant Conditions
CREATE TABLE combatant_conditions (
    id TEXT PRIMARY KEY NOT NULL,
    combatant_id TEXT NOT NULL,
    condition_name TEXT NOT NULL,
    value INTEGER,
    duration_rounds INTEGER,
    source_combatant_id TEXT,
    FOREIGN KEY (combatant_id) REFERENCES encounter_combatants(id) ON DELETE CASCADE,
    FOREIGN KEY (source_combatant_id) REFERENCES encounter_combatants(id)
);

-- 7. Combat Log
CREATE TABLE combat_log (
    id TEXT PRIMARY KEY NOT NULL,
    encounter_id TEXT NOT NULL,
    source_combatant_id TEXT NOT NULL,
    target_combatant_id TEXT,
    action_id TEXT,
    event_type TEXT NOT NULL CHECK (event_type IN ('Roll', 'Damage', 'Heal', 'Condition_Applied', 'Turn_Start')),
    raw_roll INTEGER,
    calculated_result INTEGER,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP, -- Added for chronological ledgering
    FOREIGN KEY (encounter_id) REFERENCES encounters(id) ON DELETE CASCADE,
    FOREIGN KEY (source_combatant_id) REFERENCES encounter_combatants(id),
    FOREIGN KEY (target_combatant_id) REFERENCES encounter_combatants(id),
    FOREIGN KEY (action_id) REFERENCES abilities_and_actions(id)
);

-- 8. Entity Types (The Categories)
CREATE TABLE entity_types (
    id TEXT PRIMARY KEY NOT NULL,
    name TEXT NOT NULL UNIQUE, -- e.g., 'Item', 'Spell', 'Location', 'Lore'
    description TEXT
);

-- 9. Entity Entries (The Registry)
-- This table acts as a central hub for all specific world objects.
CREATE TABLE entity_entries (
    id TEXT PRIMARY KEY NOT NULL,
    entity_type_id TEXT NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    system_id TEXT, -- Optional: Link to a specific game system if the item is system-specific
    metadata_blob TEXT, -- JSONB: Stores common attributes (weight, level, rarity)
    FOREIGN KEY (entity_type_id) REFERENCES entity_types(id),
    FOREIGN KEY (system_id) REFERENCES game_systems(id) ON DELETE SET NULL
);

-- 10. Entity Tags (For categorization/filtering)
-- Useful for "Healing", "Legendary", "Cursed", etc.
CREATE TABLE entity_tags (
    entity_id TEXT NOT NULL,
    tag_name TEXT NOT NULL,
    PRIMARY KEY (entity_id, tag_name),
    FOREIGN KEY (entity_id) REFERENCES entity_entries(id) ON DELETE CASCADE
);

-- 11. Actor Inventory / Spellbook
-- Connects Actors to Entity Entries (Items they own or Spells they know)
CREATE TABLE actor_entity_relations (
    actor_id TEXT NOT NULL,
    entity_id TEXT NOT NULL,
    quantity INTEGER DEFAULT 1,
    is_equipped INTEGER DEFAULT 0 CHECK (is_equipped IN (0, 1)),
    custom_notes TEXT, -- For specific modifications to a base item
    PRIMARY KEY (actor_id, entity_id),
    FOREIGN KEY (actor_id) REFERENCES actors(id) ON DELETE CASCADE,
    FOREIGN KEY (entity_id) REFERENCES entity_entries(id) ON DELETE CASCADE
);

-- 12. Location Hierarchy (Self-referencing for sub-locations)
-- Special handling for when an Entity is a 'Location'
CREATE TABLE location_data (
    entity_id TEXT PRIMARY KEY NOT NULL,
    parent_location_id TEXT, -- e.g., Room 101 is inside The Dungeon
    is_discovered INTEGER DEFAULT 0 CHECK (is_discovered IN (0, 1)),
    coordinate_blob TEXT, -- JSON: Stores X, Y, Z or Map ID
    FOREIGN KEY (entity_id) REFERENCES entity_entries(id) ON DELETE CASCADE,
    FOREIGN KEY (parent_location_id) REFERENCES location_data(entity_id)
);


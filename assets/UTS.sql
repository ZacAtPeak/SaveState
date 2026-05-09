-- 1. Core System Registry
-- Defines the game systems (e.g., 'D&D 5e', 'Call of Cthulhu')
CREATE TABLE systems (
    system_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    version TEXT,
    mechanic_type TEXT -- 'D20', 'Percentile', 'Dice Pool'
);

-- 2. Entity Definitions
-- Everything is an entity: a Character, an Item, a Spell, or a Monster
CREATE TABLE entities (
    entity_id INTEGER PRIMARY KEY,
    system_id INTEGER NOT NULL,
    entity_type TEXT NOT NULL, -- 'character', 'item', 'feature', 'spell'
    name TEXT NOT NULL,
    description TEXT,
    metadata JSON, -- Stores unique quirks (e.g., D&D Spell components or CoC Sanity cost)
    FOREIGN KEY (system_id) REFERENCES systems(system_id)
);

-- 3. Attribute Definitions
-- Defines what "Strength" or "Sanity" means for a specific system
CREATE TABLE attribute_definitions (
    attr_def_id INTEGER PRIMARY KEY,
    system_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    abbreviation TEXT,
    data_type TEXT DEFAULT 'integer', -- 'integer', 'string', 'boolean'
    FOREIGN KEY (system_id) REFERENCES systems(system_id)
);

-- 4. Entity Attribute Values (The EAV Engine)
-- This stores the actual values for an entity's stats
CREATE TABLE entity_attributes (
    entity_id INTEGER NOT NULL,
    attr_def_id INTEGER NOT NULL,
    value_numeric INTEGER,
    value_text TEXT,
    PRIMARY KEY (entity_id, attr_def_id),
    FOREIGN KEY (entity_id) REFERENCES entities(entity_id),
    FOREIGN KEY (attr_def_id) REFERENCES attribute_definitions(attr_def_id)
);

-- 5. Relationships (Linking Entities)
-- Maps Spells to Characters, Items to Inventory, or Features to Classes
CREATE TABLE entity_relationships (
    parent_id INTEGER NOT NULL,
    child_id INTEGER NOT NULL,
    relationship_type TEXT NOT NULL, -- 'inventory', 'spellbook', 'class_feature'
    quantity INTEGER DEFAULT 1,
    metadata JSON, -- Specifics like 'is_equipped' or 'slots_occupied'
    PRIMARY KEY (parent_id, child_id, relationship_type),
    FOREIGN KEY (parent_id) REFERENCES entities(entity_id),
    FOREIGN KEY (child_id) REFERENCES entities(entity_id)
);

-- 6. Tags & Categories
-- For quick filtering (e.g., 'Fire', 'Melee', 'Level 1', 'Cyberware')
CREATE TABLE tags (
    tag_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE entity_tags (
    entity_id INTEGER NOT NULL,
    tag_id INTEGER NOT NULL,
    PRIMARY KEY (entity_id, tag_id),
    FOREIGN KEY (entity_id) REFERENCES entities(entity_id),
    FOREIGN KEY (tag_id) REFERENCES tags(tag_id)
);
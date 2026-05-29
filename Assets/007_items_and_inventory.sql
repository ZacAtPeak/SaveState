-- Items & Inventory Schema Migration
-- Adds weapon/item catalog, entity inventory/equipment, and item-to-action linking
-- Part of the items-and-inventory OpenSpec change

BEGIN TRANSACTION;

--------------------------------------------------------------------------------
-- 1.1 Item library — base catalog for all items (weapons, armor, gear, etc.)
--------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS item_library (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    item_type TEXT NOT NULL CHECK (item_type IN ('weapon', 'armor', 'shield', 'potion', 'wand', 'ring', 'wondrous', 'ammunition', 'other')),
    description TEXT,
    rarity TEXT NOT NULL DEFAULT 'common' CHECK (rarity IN ('common', 'uncommon', 'rare', 'very_rare', 'legendary')),
    weight REAL,
    value_gp INTEGER,
    is_magical INTEGER NOT NULL DEFAULT 0 CHECK (is_magical IN (0, 1)),
    attack_bonus INTEGER,        -- +X magic weapons (e.g., 1 for +1 longsword)
    damage_bonus INTEGER,        -- bonus damage dice label (e.g., 6 for +1d6)
    damage_bonus_type TEXT,      -- e.g., 'Fire', 'Radiant' (for bonus damage)
    source TEXT DEFAULT 'PHB',
    page INTEGER
);

--------------------------------------------------------------------------------
-- 1.2 Weapon profiles — 1:1 with item_library for weapon-specific stats
--------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS weapon_profiles (
    item_id TEXT PRIMARY KEY,
    weapon_category TEXT NOT NULL CHECK (weapon_category IN ('simple', 'martial')),
    weapon_range TEXT NOT NULL CHECK (weapon_range IN ('melee', 'ranged')),
    damage_dice TEXT NOT NULL,         -- e.g., '1d8'
    damage_type TEXT NOT NULL,          -- e.g., 'Slashing', 'Piercing', 'Bludgeoning'
    range_normal INTEGER,              -- feet (NULL for melee without thrown)
    range_long INTEGER,                -- feet (for ranged & thrown weapons)
    versatile_dice TEXT,               -- e.g., '1d10' when wielded two-handed
    properties TEXT,                    -- JSON array: '["finesse","light","reach"]'
    FOREIGN KEY (item_id) REFERENCES item_library(id) ON DELETE CASCADE
);

--------------------------------------------------------------------------------
-- 1.3 Armor profiles — 1:1 with item_library for armor/shield stats
--------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS armor_profiles (
    item_id TEXT PRIMARY KEY,
    armor_category TEXT NOT NULL CHECK (armor_category IN ('light', 'medium', 'heavy', 'shield')),
    base_armor_class INTEGER NOT NULL,  -- e.g., 12 for leather, 14 for chain shirt
    dex_bonus_cap INTEGER,              -- max DEX mod (NULL = full, 0 = none)
    strength_requirement INTEGER,       -- min STR to wear without speed penalty
    stealth_disadvantage INTEGER NOT NULL DEFAULT 0 CHECK (stealth_disadvantage IN (0, 1)),
    FOREIGN KEY (item_id) REFERENCES item_library(id) ON DELETE CASCADE
);

--------------------------------------------------------------------------------
-- 1.4 Entity inventory — who has what items and what's equipped
--------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS entity_items (
    entity_id TEXT NOT NULL,
    item_id TEXT NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    is_equipped INTEGER NOT NULL DEFAULT 0 CHECK (is_equipped IN (0, 1)),
    equipped_slot TEXT,
    PRIMARY KEY (entity_id, item_id),
    FOREIGN KEY (entity_id) REFERENCES entities(id) ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES item_library(id) ON DELETE CASCADE
);

--------------------------------------------------------------------------------
-- 1.5 Item → Actions — links items to actions they grant when equipped
--------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS item_actions (
    item_id TEXT NOT NULL,
    action_id TEXT NOT NULL,
    PRIMARY KEY (item_id, action_id),
    FOREIGN KEY (item_id) REFERENCES item_library(id) ON DELETE CASCADE,
    FOREIGN KEY (action_id) REFERENCES action_library(id) ON DELETE CASCADE
);

COMMIT;

-- Seed weapons, actions, and inventory for demo entities
-- Part of the items-and-inventory OpenSpec change

BEGIN TRANSACTION;

--------------------------------------------------------------------------------
-- 2.1 Seed item_library with standard weapons
--------------------------------------------------------------------------------
INSERT OR IGNORE INTO item_library (id, name, item_type, description, weight, value_gp, source) VALUES
('wpn-longsword',     'Longsword',     'weapon', 'A versatile blade, deadly in one or two hands.',      3,   15,   'PHB'),
('wpn-shortsword',    'Shortsword',    'weapon', 'A light, quick blade.',                               2,   10,   'PHB'),
('wpn-scimitar',      'Scimitar',      'weapon', 'A curved, light blade.',                              3,   25,   'PHB'),
('wpn-dagger',        'Dagger',        'weapon', 'A small, easily concealed blade.',                    1,   2,    'PHB'),
('wpn-shortbow',      'Shortbow',      'weapon', 'A small bow for ranged attacks.',                     2,   25,   'PHB'),
('wpn-crossbow-light','Light Crossbow','weapon', 'A simple crossbow.',                                  5,   25,   'PHB'),
('wpn-quarterstaff',  'Quarterstaff',  'weapon', 'A simple wooden staff.',                              4,   0.2,  'PHB'),
('wpn-handaxe',       'Handaxe',       'weapon', 'A small throwing axe.',                               2,   5,    'PHB'),
('wpn-warhammer',     'Warhammer',     'weapon', 'A heavy hammer with a wooden haft.',                   5,   15,   'PHB'),
('wpn-greataxe',      'Greataxe',      'weapon', 'A massive two-handed axe.',                           7,   30,   'PHB'),
('wpn-battleaxe',     'Battleaxe',     'weapon', 'A versatile axe, deadly in one or two hands.',         4,   10,   'PHB');

--------------------------------------------------------------------------------
-- 2.2 Seed weapon_profiles
--------------------------------------------------------------------------------
INSERT OR IGNORE INTO weapon_profiles (item_id, weapon_category, weapon_range, damage_dice, damage_type, range_normal, range_long, versatile_dice, properties) VALUES
('wpn-longsword',      'martial', 'melee',  '1d8',  'Slashing',   NULL, NULL, '1d10', '["versatile"]'),
('wpn-shortsword',     'martial', 'melee',  '1d6',  'Piercing',   NULL, NULL, NULL,   '["finesse","light"]'),
('wpn-scimitar',       'martial', 'melee',  '1d6',  'Slashing',   NULL, NULL, NULL,   '["finesse","light"]'),
('wpn-dagger',         'simple',  'melee',  '1d4',  'Piercing',   20,  60,  NULL,   '["finesse","light","thrown"]'),
('wpn-shortbow',       'simple',  'ranged', '1d6',  'Piercing',   80,  320, NULL,   '["two-handed","ammunition"]'),
('wpn-crossbow-light', 'simple',  'ranged', '1d8',  'Piercing',   80,  320, NULL,   '["two-handed","ammunition","loading"]'),
('wpn-quarterstaff',   'simple',  'melee',  '1d6',  'Bludgeoning',NULL, NULL, '1d8',  '["versatile"]'),
('wpn-handaxe',        'simple',  'melee',  '1d6',  'Slashing',   20,  60,  NULL,   '["light","thrown"]'),
('wpn-warhammer',      'martial', 'melee',  '1d8',  'Bludgeoning',NULL, NULL, '1d10', '["versatile"]'),
('wpn-greataxe',       'martial', 'melee',  '1d12', 'Slashing',   NULL, NULL, NULL,   '["heavy","two-handed"]'),
('wpn-battleaxe',      'martial', 'melee',  '1d8',  'Slashing',   NULL, NULL, '1d10', '["versatile"]');

--------------------------------------------------------------------------------
-- 2.3 Create corresponding actions in action_library
-------------------------------------------------------------------------------
-- attack_bonus is 0 (base weapon value) — the actual bonus is computed at
-- runtime by adding the entity's proficiency + STR/DEX modifier.
INSERT OR IGNORE INTO action_library (id, name, action_type, description, is_attack, attack_bonus, damage_dice, damage_type) VALUES
('act-wpn-longsword',     'Longsword',              'action', 'Melee Weapon Attack',                                  1, 0, '1d8',  'Slashing'),
('act-wpn-longsword-2h',  'Longsword (Versatile)',  'action', 'Melee Weapon Attack (two-handed)',                    1, 0, '1d10', 'Slashing'),
('act-wpn-shortsword',    'Shortsword',             'action', 'Melee Weapon Attack',                                  1, 0, '1d6',  'Piercing'),
('act-wpn-scimitar',      'Scimitar',               'action', 'Melee Weapon Attack',                                  1, 0, '1d6',  'Slashing'),
('act-wpn-dagger',        'Dagger',                 'action', 'Melee or Ranged Weapon Attack',                        1, 0, '1d4',  'Piercing'),
('act-wpn-shortbow',      'Shortbow',               'action', 'Ranged Weapon Attack',                                 1, 0, '1d6',  'Piercing'),
('act-wpn-crossbow',      'Light Crossbow',         'action', 'Ranged Weapon Attack',                                 1, 0, '1d8',  'Piercing'),
('act-wpn-quarterstaff',  'Quarterstaff',           'action', 'Melee Weapon Attack',                                  1, 0, '1d6',  'Bludgeoning'),
('act-wpn-quarterstaff-2h','Quarterstaff (Versatile)','action','Melee Weapon Attack (two-handed)',                    1, 0, '1d8',  'Bludgeoning'),
('act-wpn-handaxe',       'Handaxe',                'action', 'Melee or Ranged Weapon Attack',                        1, 0, '1d6',  'Slashing'),
('act-wpn-warhammer',     'Warhammer',              'action', 'Melee Weapon Attack',                                  1, 0, '1d8',  'Bludgeoning'),
('act-wpn-warhammer-2h',  'Warhammer (Versatile)',  'action', 'Melee Weapon Attack (two-handed)',                    1, 0, '1d10', 'Bludgeoning'),
('act-wpn-greataxe',      'Greataxe',               'action', 'Melee Weapon Attack',                                  1, 0, '1d12', 'Slashing'),
('act-wpn-battleaxe',     'Battleaxe',              'action', 'Melee Weapon Attack',                                  1, 0, '1d8',  'Slashing'),
('act-wpn-battleaxe-2h',  'Battleaxe (Versatile)',  'action', 'Melee Weapon Attack (two-handed)',                    1, 0, '1d10', 'Slashing');

--------------------------------------------------------------------------------
-- 2.4 Link items to the actions they provide (item_actions)
--------------------------------------------------------------------------------
INSERT OR IGNORE INTO item_actions (item_id, action_id) VALUES
('wpn-longsword',      'act-wpn-longsword'),
('wpn-longsword',      'act-wpn-longsword-2h'),
('wpn-shortsword',     'act-wpn-shortsword'),
('wpn-scimitar',       'act-wpn-scimitar'),
('wpn-dagger',         'act-wpn-dagger'),
('wpn-shortbow',       'act-wpn-shortbow'),
('wpn-crossbow-light', 'act-wpn-crossbow'),
('wpn-quarterstaff',   'act-wpn-quarterstaff'),
('wpn-quarterstaff',   'act-wpn-quarterstaff-2h'),
('wpn-handaxe',        'act-wpn-handaxe'),
('wpn-warhammer',      'act-wpn-warhammer'),
('wpn-warhammer',      'act-wpn-warhammer-2h'),
('wpn-greataxe',       'act-wpn-greataxe'),
('wpn-battleaxe',      'act-wpn-battleaxe'),
('wpn-battleaxe',      'act-wpn-battleaxe-2h');

--------------------------------------------------------------------------------
-- 2.5 Assign items to demo entities (inventory + equipment)
--------------------------------------------------------------------------------
-- Tharivol (pc-1, rogue): Scimitar (main hand), Shortbow + 2 Daggers in inventory
INSERT OR IGNORE INTO entity_items (entity_id, item_id, quantity, is_equipped, equipped_slot) VALUES
('pc-1', 'wpn-scimitar', 1, 1, 'weapon_main'),
('pc-1', 'wpn-shortbow', 1, 0, NULL),
('pc-1', 'wpn-dagger',   2, 0, NULL);

-- Morgran (pc-2, fighter): Warhammer (main hand)
INSERT OR IGNORE INTO entity_items (entity_id, item_id, quantity, is_equipped, equipped_slot) VALUES
('pc-2', 'wpn-warhammer', 1, 1, 'weapon_main');

-- Aria (pc-3, wizard): Quarterstaff (main hand), Dagger (inventory)
INSERT OR IGNORE INTO entity_items (entity_id, item_id, quantity, is_equipped, equipped_slot) VALUES
('pc-3', 'wpn-quarterstaff', 1, 1, 'weapon_main'),
('pc-3', 'wpn-dagger',       1, 0, NULL);

-- Kallista (pc-4, cleric): Warhammer (main hand)
INSERT OR IGNORE INTO entity_items (entity_id, item_id, quantity, is_equipped, equipped_slot) VALUES
('pc-4', 'wpn-warhammer', 1, 1, 'weapon_main');

-- Garrick (pc-5, bard): Shortsword (main hand), Dagger (inventory)
INSERT OR IGNORE INTO entity_items (entity_id, item_id, quantity, is_equipped, equipped_slot) VALUES
('pc-5', 'wpn-shortsword', 1, 1, 'weapon_main'),
('pc-5', 'wpn-dagger',     1, 0, NULL);

-- Goblin (mon-1): Scimitar (main hand), Shortbow (inventory)
INSERT OR IGNORE INTO entity_items (entity_id, item_id, quantity, is_equipped, equipped_slot) VALUES
('mon-1', 'wpn-scimitar', 1, 1, 'weapon_main'),
('mon-1', 'wpn-shortbow', 1, 0, NULL);

-- Orc (mon-2): Greataxe (main hand), 2 Handaxes (inventory)
INSERT OR IGNORE INTO entity_items (entity_id, item_id, quantity, is_equipped, equipped_slot) VALUES
('mon-2', 'wpn-greataxe', 1, 1, 'weapon_main'),
('mon-2', 'wpn-handaxe',  2, 0, NULL);

-- Skeleton (mon-3): Shortsword (main hand), Shortbow (inventory)
INSERT OR IGNORE INTO entity_items (entity_id, item_id, quantity, is_equipped, equipped_slot) VALUES
('mon-3', 'wpn-shortsword', 1, 1, 'weapon_main'),
('mon-3', 'wpn-shortbow',   1, 0, NULL);

-- Ogre (mon-5): Greataxe (main hand)
INSERT OR IGNORE INTO entity_items (entity_id, item_id, quantity, is_equipped, equipped_slot) VALUES
('mon-5', 'wpn-greataxe', 1, 1, 'weapon_main');

-- Kobold (mon-13): Dagger (main hand), Shortbow (inventory)
INSERT OR IGNORE INTO entity_items (entity_id, item_id, quantity, is_equipped, equipped_slot) VALUES
('mon-13', 'wpn-dagger',   1, 1, 'weapon_main'),
('mon-13', 'wpn-shortbow', 1, 0, NULL);

-- Minotaur (mon-19): Greataxe (main hand)
INSERT OR IGNORE INTO entity_items (entity_id, item_id, quantity, is_equipped, equipped_slot) VALUES
('mon-19', 'wpn-greataxe', 1, 1, 'weapon_main');

-- Town Guard (npc-1): Longsword (main hand)
INSERT OR IGNORE INTO entity_items (entity_id, item_id, quantity, is_equipped, equipped_slot) VALUES
('npc-1', 'wpn-longsword', 1, 1, 'weapon_main');

-- Bandit (npc-2): Shortsword (main hand), Light Crossbow (inventory)
INSERT OR IGNORE INTO entity_items (entity_id, item_id, quantity, is_equipped, equipped_slot) VALUES
('npc-2', 'wpn-shortsword',     1, 1, 'weapon_main'),
('npc-2', 'wpn-crossbow-light', 1, 0, NULL);

-- Cultist (npc-3): Dagger (main hand)
INSERT OR IGNORE INTO entity_items (entity_id, item_id, quantity, is_equipped, equipped_slot) VALUES
('npc-3', 'wpn-dagger', 1, 1, 'weapon_main');

-- Assassin (npc-5): Shortsword (main hand), Dagger (offhand)
INSERT OR IGNORE INTO entity_items (entity_id, item_id, quantity, is_equipped, equipped_slot) VALUES
('npc-5', 'wpn-shortsword', 1, 1, 'weapon_main'),
('npc-5', 'wpn-dagger',     1, 1, 'weapon_offhand');

-- Blacksmith (npc-10): Warhammer (main hand), Handaxe (inventory)
INSERT OR IGNORE INTO entity_items (entity_id, item_id, quantity, is_equipped, equipped_slot) VALUES
('npc-10', 'wpn-warhammer', 1, 1, 'weapon_main'),
('npc-10', 'wpn-handaxe',   1, 0, NULL);

COMMIT;

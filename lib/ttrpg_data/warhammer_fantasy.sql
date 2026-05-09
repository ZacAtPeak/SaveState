-- Warhammer Fantasy Roleplay 4th Edition Data
-- Entities: characters, creatures, items, careers

-- Characters (entity_type: 'character')
INSERT INTO entities (entity_id, system_id, entity_type, name, description, metadata) VALUES
(177, 6, 'character', 'Otto Müller', 'Empire soldier turned mercenary seeking fortune', '{"career": "Soldier", "species": "Human", "status": "Professional"}'),
(178, 6, 'character', 'Elspeth von Draken', 'Bright Wizard studying fire magic', '{"career": "Wizard", "species": "Human", "college": "Bright"}'),
(179, 6, 'character', 'Grimli Ironfist', 'Dwarf engineer with explosive inventions', '{"career": "Engineer", "species": "Dwarf", "specialization": "Alchemy"}'),
(180, 6, 'character', 'Tomas Greymane', 'Witch Hunter rooting out corruption', '{"career": "Witch Hunter", "species": "Human", "order": "Sigmar"}'),
(181, 6, 'character', 'Mira Shadowstep', 'Wood Elf scout navigating forests', '{"career": "Scout", "species": "Elf", "wood": "Asrai"}');

-- NPCs (entity_type: 'npc')
INSERT INTO entities (entity_id, system_id, entity_type, name, description, metadata) VALUES
(182, 6, 'npc', 'Father Aldric', 'Kindly priest of Sigmar providing guidance', '{"career": "Priest", "deity": "Sigmar"}'),
(183, 6, 'npc', 'Hedda the Trader', 'Halfling merchant with valuable connections', '{"career": "Merchant", "species": "Halfling"}'),
(184, 6, 'npc', 'Captain Greta von Hofstadt', 'Imperial officer commanding garrison', '{"career": "Soldier", "rank": "Captain"}');

-- Creatures (entity_type: 'creature')
INSERT INTO entities (entity_id, system_id, entity_type, name, description, metadata) VALUES
(185, 6, 'creature', 'Rat Ogre', 'Massive mutant rat with razored claws', '{"tb": 4, "wb": 35, "size": "Large"}'),
(186, 6, 'creature', 'Skaven Warlord', 'Dominant rat-man clan leader', '{"tb": 3, "wb": 35, "size": "Medium"}'),
(187, 6, 'creature', 'Chaos Warrior', 'Corrupted human in dark armor', '{"tb": 5, "wb": 45, "size": "Large"}'),
(188, 6, 'creature', 'Tree Kin', 'Animated forest guardian', '{"tb": 6, "wb": 55, "size": "Huge"}'),
(189, 6, 'creature', 'Daemon of Khorne', 'Bloodthirsty entity from the warp', '{"tb": 7, "wb": 60, "size": "Large"}'),
(190, 6, 'creature', 'Tomb Scorpion', 'Giant scorpion from ancient tombs', '{"tb": 4, "wb": 40, "size": "Large"}');

-- Items (entity_type: 'item')
INSERT INTO entities (entity_id, system_id, entity_type, name, description, metadata) VALUES
(191, 6, 'item', 'Sigmarite Hammer', 'Blessed warhammer of the witch hunter', '{"damage": "5", "reach": 1, "blessed": true}'),
(192, 6, 'item', 'Bright Wizard Staff', 'Focus for fire magic', '{"damage": "3", "reach": 3, "magic": true}'),
(193, 6, 'item', 'Dwarven Rune Axe', 'Master-forged axe with protective runes', '{"damage": "6", "reach": 1, "runes": ["Grudge"]}'),
(194, 6, 'item', 'Healing Salve', 'Halfling remedy for wounds', '{"effect": "Heal 1d5 TB", "uses": 1}'),
(195, 6, 'item', 'Lucky Charm', 'Elf-made charm bringing fortune', '{"effect": "+10 to Critical", "blessed": true}');

-- Weapons (entity_type: 'weapon')
INSERT INTO entities (entity_id, system_id, entity_type, name, description, metadata) VALUES
(196, 6, 'weapon', 'Halberd', 'Long-reach polearm favored by soldiers', '{"damage": "5", "reach": 3, "group": "Polearm"}'),
(197, 6, 'weapon', 'Repeater Crossbow', 'Dwarven ranged weapon with volley', '{"damage": "4", "range": 30, "group": "Crossbow"}'),
(198, 6, 'weapon', 'Sword Breyer', 'Cavalry sword for mounted combat', '{"damage": "4", "reach": 1, "group": "Fencing"}'),
(199, 6, 'weapon', 'Dual Axes', 'Pair of balanced throwing axes', '{"damage": "3", "reach": 1, "group": "Axes"}'),
(200, 6, 'weapon', 'Warhammer', 'Dwarven two-handed crusher', '{"damage": "7", "reach": 2, "group": "Hammer"}');

-- Warhammer Fantasy Character Attributes (Otto - entity 177)
INSERT INTO entity_attributes (entity_id, attr_def_id, value_numeric) VALUES
(177, 51, 46), (177, 52, 30), (177, 53, 41), (177, 54, 34), (177, 55, 33), (177, 56, 34), (177, 57, 32), (177, 58, 25), (177, 59, 31), (177, 60, 43);

-- Warhammer Fantasy Character Attributes (Elspeth - entity 178)
INSERT INTO entity_attributes (entity_id, attr_def_id, value_numeric) VALUES
(178, 51, 26), (178, 52, 28), (178, 53, 30), (178, 54, 32), (178, 55, 33), (178, 56, 30), (178, 57, 30), (178, 58, 48), (178, 59, 42), (178, 60, 25);

-- Warhammer Fantasy Character Attributes (Grimli - entity 179)
INSERT INTO entity_attributes (entity_id, attr_def_id, value_numeric) VALUES
(179, 51, 50), (179, 52, 24), (179, 53, 46), (179, 54, 32), (179, 55, 25), (179, 56, 28), (179, 57, 45), (179, 58, 40), (179, 59, 28), (179, 60, 20);

-- Warhammer Fantasy Character Attributes (Tomas - entity 180)
INSERT INTO entity_attributes (entity_id, attr_def_id, value_numeric) VALUES
(180, 51, 40), (180, 52, 30), (180, 53, 38), (180, 54, 30), (180, 55, 44), (180, 56, 32), (180, 57, 32), (180, 58, 28), (180, 59, 50), (180, 60, 35);

-- Warhammer Fantasy Character Attributes (Mira - entity 181)
INSERT INTO entity_attributes (entity_id, attr_def_id, value_numeric) VALUES
(181, 51, 34), (181, 52, 50), (181, 53, 30), (181, 54, 28), (181, 55, 36), (181, 56, 56), (181, 57, 44), (181, 58, 36), (181, 59, 30), (181, 60, 42);

-- Tags for Warhammer Fantasy entities
INSERT INTO entity_tags (entity_id, tag_id) VALUES
(177, 22), (178, 22), (179, 22), (180, 22), (181, 22), -- Characters
(182, 21), (183, 21), (184, 21), -- NPCs
(185, 48), (186, 49), (187, 54), (188, 52), (189, 54), (190, 48), -- Creatures
(191, 16), (192, 16), (193, 16), (194, 5), (195, 6), -- Items
(196, 13), (197, 14), (198, 13), (199, 13), (200, 13); -- Weapons

-- Character-Weapon relationships
INSERT INTO entity_relationships (parent_id, child_id, relationship_type, metadata) VALUES
(177, 196, 'carried', '{"equipped": true}'),
(178, 192, 'carried', '{"equipped": true}'),
(179, 200, 'carried', '{"equipped": true}'),
(180, 191, 'carried', '{"equipped": true}'),
(181, 199, 'carried', '{"equipped": true}');

-- Character-Item relationships
INSERT INTO entity_relationships (parent_id, child_id, relationship_type, quantity, metadata) VALUES
(177, 194, 'inventory', 2, '{}'),
(178, 194, 'inventory', 1, '{}'),
(179, 197, 'inventory', 1, '{}'),
(180, 195, 'inventory', 1, '{}'),
(181, 193, 'inventory', 1, '{}');

-- Career relationships (characters have careers)
INSERT INTO entity_relationships (parent_id, child_id, relationship_type, metadata) VALUES
(177, 177, 'career_path', '{"current": true}'), -- Self-reference for career
(182, 182, 'career_path', '{"current": true}'),
(183, 183, 'career_path', '{"current": true}'),
(184, 184, 'career_path', '{"current": true}');
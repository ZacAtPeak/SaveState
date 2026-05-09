-- Cyberpunk Red Data
-- Entities: mercs, cyberware, weapons, items

-- Characters (entity_type: 'character')
INSERT INTO entities (entity_id, system_id, entity_type, name, description, metadata) VALUES
(154, 5, 'character', 'Riptide', 'Ex-military cybered up for urban survival', '{"role": "Solo", "age": 28, "origin": "Combat Zone"}'),
(155, 5, 'character', 'Neon Prophet', 'Netrunner with a message from beyond', '{"role": "Netrunner", "age": 24, "origin": "Night City"}'),
(156, 5, 'character', 'Chimera', 'Media with cutting-edge implants', '{"role": "Media", "age": 31, "origin": "Watson"}'),
(157, 5, 'character', 'Iron Maiden', 'Fixer with connections everywhere', '{"role": "Fixer", "age": 35, "origin": "HellsKitchen"}'),
(158, 5, 'character', 'Doc Shock', 'Medtech who works on the edge of legality', '{"role": "Medtech", "age": 42, "origin": "Pacific"]');

-- NPCs (entity_type: 'npc')
INSERT INTO entities (entity_id, system_id, entity_type, name, description, metadata) VALUES
(159, 5, 'npc', 'Sebastian Kaine', 'NCPD officer with a badge and secrets', '{"role": "Cop", "division": "MaxTac"}'),
(160, 5, 'npc', 'Yuki Tanaka', 'Arasaka corporate operative', '{"role": "Corporate", "faction": "Arasaka"}'),
(161, 5, 'npc', 'Bobby Bones', 'Booster gang leader in the Combat Zone', '{"role": "Gang Leader", "gang": "The Bones"}');

-- Cyberware (entity_type: 'item')
INSERT INTO entities (entity_id, system_id, entity_type, name, description, metadata) VALUES
(162, 5, 'item', 'Sandevistan', 'Reflex booster for faster-than-thought movement', '{"type": "Cyberware", "cost": 5000, "grade": "Quality"}'),
(163, 5, 'item', 'Mantis Blades', 'Retractable forearm blades', '{"type": "Cyberware", "cost": 3500, "grade": "Standard"}'),
(164, 5, 'item', 'Kiroshi Optics', 'Subdermal eye implants', '{"type": "Cyberware", "cost": 500, "grade": "Standard"}'),
(165, 5, 'item', 'Subdermal Armor', 'Woven body armor under the skin', '{"type": "Cyberware", "cost": 4000, "grade": "Quality"}'),
(166, 5, 'item', 'Neural Link', 'Brain-computer interface', '{"type": "Cyberware", "cost": 1000, "grade": "Standard"}');

-- Weapons (entity_type: 'weapon')
INSERT INTO entities (entity_id, system_id, entity_type, name, description, metadata) VALUES
(167, 5, 'weapon', 'Malorian Overture', 'Iconic hand cannon favored by solos', '{"damage": "4d6", "type": "Pistol", "fire_modes": ["SA", "A"], "cost": 4500}'),
(168, 5, 'weapon', 'HMG-60', 'Heavy machine gun for vehicle combat', '{"damage": "6d6", "type": "Heavy", "fire_modes": ["A"], "cost": 6000}'),
(169, 5, 'weapon', 'Zhang-Dao Sword', 'Mono-molecular edge weapon', '{"damage": "3d6", "type": "Melee", "cost": 800}'),
(170, 5, 'weapon', 'Mantis Blade Implant', 'Natural weapon integrated with arm', '{"damage": "2d6", "type": "Melee", "cost": 1200}'),
(171, 5, 'weapon', 'Techtronika Avalanche', 'Smart submachine gun', '{"damage": "2d6+1", "type": "SMG", "fire_modes": ["A", "3B"], "cost": 1800}');

-- Items (entity_type: 'item')
INSERT INTO entities (entity_id, system_id, entity_type, name, description, metadata) VALUES
(172, 5, 'item', 'Medea Exocyt', 'Combat stimulant drug', '{"type": "Drug", "cost": 100, "side_effects": "Addiction"}'),
(173, 5, 'item', 'Memory Chip', 'Data storage device', '{"type": "Tech", "cost": 50, "capacity": "128TB"}'),
(174, 5, 'item', 'Agent', 'Personal AI assistant device', '{"type": "Tech", "cost": 500, "model": "Standard"}'),
(175, 5, 'item', 'Synth-Cocktail', 'Alcohol substitute', '{"type": "Food", "cost": 20}'),
(176, 5, 'item', 'Militech Ronin', 'Military-grade armor vest', '{"type": "Armor", "cost": 2200, "sp": 11}');

-- Cyberpunk Red Character Attributes (Riptide - entity 154)
INSERT INTO entity_attributes (entity_id, attr_def_id, value_numeric) VALUES
(154, 41, 8), (154, 42, 10), (154, 43, 9), (154, 44, 6), (154, 45, 8), (154, 46, 9), (154, 47, 3), (154, 48, 8), (154, 49, 9), (154, 50, 7);

-- Cyberpunk Red Character Attributes (Neon Prophet - entity 155)
INSERT INTO entity_attributes (entity_id, attr_def_id, value_numeric) VALUES
(155, 41, 10), (155, 42, 6), (155, 43, 7), (155, 44, 14), (155, 45, 5), (155, 46, 8), (155, 47, 7), (155, 48, 7), (155, 49, 5), (155, 50, 9);

-- Cyberpunk Red Character Attributes (Chimera - entity 156)
INSERT INTO entity_attributes (entity_id, attr_def_id, value_numeric) VALUES
(156, 41, 8), (156, 42, 8), (156, 43, 6), (156, 44, 10), (156, 45, 10), (156, 46, 7), (156, 47, 4), (156, 48, 9), (156, 49, 5), (156, 50, 11);

-- Cyberpunk Red Character Attributes (Iron Maiden - entity 157)
INSERT INTO entity_attributes (entity_id, attr_def_id, value_numeric) VALUES
(157, 41, 8), (157, 42, 7), (157, 43, 6), (157, 44, 9), (157, 45, 11), (157, 46, 6), (157, 47, 5), (157, 48, 8), (157, 49, 6), (157, 50, 10);

-- Cyberpunk Red Character Attributes (Doc Shock - entity 158)
INSERT INTO entity_attributes (entity_id, attr_def_id, value_numeric) VALUES
(158, 41, 9), (158, 42, 5), (158, 43, 7), (158, 44, 12), (158, 45, 6), (158, 46, 8), (158, 47, 6), (158, 48, 5), (158, 49, 7), (158, 50, 10);

-- Tags for Cyberpunk Red entities
INSERT INTO entity_tags (entity_id, tag_id) VALUES
(154, 22), (155, 22), (156, 22), (157, 22), (158, 22), -- Mercs
(159, 21), (160, 21), (161, 21), -- NPCs
(162, 11), (163, 11), (164, 11), (165, 11), (166, 11), -- Cyberware
(167, 12), (168, 12), (169, 13), (170, 13), (171, 12), -- Weapons
(172, 4), (173, 10), (174, 10), (175, 6), (176, 15); -- Items

-- Character-Cyberware relationships
INSERT INTO entity_relationships (parent_id, child_id, relationship_type, metadata) VALUES
(154, 162, 'implanted', '{"installed": true}'),
(154, 165, 'implanted', '{"installed": true}'),
(155, 166, 'implanted', '{"installed": true}'),
(155, 164, 'implanted', '{"installed": true}'),
(156, 164, 'implanted', '{"installed": true}'),
(156, 174, 'inventory', '{}'),
(157, 166, 'implanted', '{"installed": true}'),
(158, 166, 'implanted', '{"installed": true}');

-- Character-Weapon relationships
INSERT INTO entity_relationships (parent_id, child_id, relationship_type, metadata) VALUES
(154, 167, 'inventory', '{"equipped": true}'),
(154, 163, 'implanted', '{"installed": true}'),
(155, 171, 'inventory', '{"equipped": false}'),
(157, 169, 'inventory', '{"equipped": true}'),
(158, 171, 'inventory', '{"equipped": false}');

-- Character-Item relationships
INSERT INTO entity_relationships (parent_id, child_id, relationship_type, quantity, metadata) VALUES
(154, 172, 'inventory', 3, '{}'),
(154, 176, 'inventory', 1, '{"equipped": true}'),
(155, 173, 'inventory', 5, '{}'),
(156, 174, 'inventory', 1, '{}'),
(157, 172, 'inventory', 2, '{}'),
(158, 175, 'inventory', 4, '{}');
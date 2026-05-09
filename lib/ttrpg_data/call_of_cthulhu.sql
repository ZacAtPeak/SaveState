-- Call of Cthulhu Data
-- Entities: investigators, creatures, items, spells

-- Characters (entity_type: 'character')
INSERT INTO entities (entity_id, system_id, entity_type, name, description, metadata) VALUES
(115, 3, 'character', 'Dr. Harold H. Williams', 'Retired professor of archaeology, now investigating dark mysteries', '{"occupation": "Professor", "age": 58, "residence": "Arkham"}'),
(116, 3, 'character', 'Martha "Marty" O''Brien', 'Hard-boiled private detective with a troubled past', '{"occupation": "Detective", "age": 35, "residence": "Boston"}'),
(117, 3, 'character', 'Li Chen Wei', 'Circus performer with hidden talents', '{"occupation": "Performer", "age": 28, "residence": "San Francisco"}'),
(118, 3, 'character', 'Father John Murphy', 'Exorcist wrestling with his faith', '{"occupation": "Priest", "age": 45, "residence": "New York"}'),
(119, 3, 'character', 'Beatrice Ashworth', 'Wealthy socialite with secrets', '{"occupation": "Dilettante", "age": 32, "residence": "Providence"}');

-- Creatures (entity_type: 'creature')
INSERT INTO entities (entity_id, system_id, entity_type, name, description, metadata) VALUES
(120, 3, 'creature', 'Deep One', 'Amphibious humanoid servant of Cthulhu', '{"hit_dice": 6, "move": "Swim 9, Walk 4", "armor": 8}'),
(121, 3, 'creature', 'Byakhee', 'Wingless flying horror from space', '{"hit_dice": 9, "move": "Fly 16", "armor": 4}'),
(122, 3, 'creature', 'Chthonian', 'Massive earth-burrowing entity', '{"hit_dice": 25, "move": "Burrow 10", "armor": 20}'),
(123, 3, 'creature', 'Mi-Go', 'Fungal alien with advanced technology', '{"hit_dice": 7, "move": "Fly 10, Walk 6", "armor": 5}'),
(124, 3, 'creature', 'Shoggoth', ' shapeless amoeboid creature', '{"hit_dice": 20, "move": "Amphibious 10", "armor": 15}'),
(125, 3, 'creature', 'Dimensional Shambler', 'Puzzling entity from other dimensions', '{"hit_dice": 5, "move": "Walk 6", "armor": 3}');

-- Items (entity_type: 'item')
INSERT INTO entities (entity_id, system_id, entity_type, name, description, metadata) VALUES
(126, 3, 'item', 'Ancient Tome', 'Forbidden book containing dark knowledge', '{"damage": "1d6 sanity", "magic_points": 15, "study_time": 20}'),
(127, 3, 'item', 'Revolver .38', 'Standard sidearm for investigators', '{"damage": "1d10+2", "range": 15, "bullets": 6}'),
(128, 3, 'item', 'Flashlight', 'Essential for exploring dark places', '{"damage": 0, "range": 20, "duration": 10}'),
(129, 3, 'item', 'First Aid Kit', 'Medical supplies for healing', '{"healing": "1d4 HP", "uses": 3}'),
(130, 3, 'item', 'Tentacles of the Void', 'Cthulhu artifact of power', '{"damage": "2d6", "sanity_cost": 5, "magic_points": 20}');

-- Spells (entity_type: 'spell')
INSERT INTO entities (entity_id, system_id, entity_type, name, description, metadata) VALUES
(131, 3, 'spell', 'Contact Deity', 'Contact an outer god for power', '{"cost": 20, "difficulty": 90, "sanity_cost": "1d10"}'),
(132, 3, 'spell', 'Dimensional Sword', 'Summon a blade from another dimension', '{"cost": 15, "difficulty": 60, "sanity_cost": "1d6"}'),
(133, 3, 'spell', 'Heal', 'Minor healing for wounds', '{"cost": 10, "difficulty": 45, "sanity_cost": "1d4"}'),
(134, 3, 'spell', 'Eldritch Blast', 'Pure magical energy attack', '{"cost": 8, "difficulty": 50, "sanity_cost": "1d4"}'),
(135, 3, 'spell', 'Dominate', 'Mental control over target', '{"cost": 25, "difficulty": 95, "sanity_cost": "2d6"}');

-- Call of Cthulhu Character Attributes (Dr. Williams - entity 115)
INSERT INTO entity_attributes (entity_id, attr_def_id, value_numeric) VALUES
(115, 21, 45), (115, 22, 50), (115, 23, 40), (115, 24, 70), (115, 25, 55), (115, 26, 50), (115, 27, 60), (115, 28, 36), (115, 29, 12), (115, 30, 65);

-- Call of Cthulhu Character Attributes (Marty - entity 116)
INSERT INTO entity_attributes (entity_id, attr_def_id, value_numeric) VALUES
(116, 21, 65), (116, 22, 60), (116, 23, 55), (116, 24, 50), (116, 25, 45), (116, 26, 55), (116, 27, 40), (116, 28, 32), (116, 29, 10), (116, 30, 60);

-- Call of Cthulhu Character Attributes (Li Chen Wei - entity 117)
INSERT INTO entity_attributes (entity_id, attr_def_id, value_numeric) VALUES
(117, 21, 50), (117, 22, 75), (117, 23, 45), (117, 24, 55), (117, 25, 60), (117, 26, 60), (117, 27, 55), (117, 28, 30), (117, 29, 14), (117, 30, 55);

-- Call of Cthulhu Character Attributes (Father Murphy - entity 118)
INSERT INTO entity_attributes (entity_id, attr_def_id, value_numeric) VALUES
(118, 21, 50), (118, 22, 40), (118, 23, 55), (118, 24, 45), (118, 25, 65), (118, 26, 70), (118, 27, 45), (118, 28, 38), (118, 29, 12), (118, 30, 50);

-- Call of Cthulhu Character Attributes (Beatrice - entity 119)
INSERT INTO entity_attributes (entity_id, attr_def_id, value_numeric) VALUES
(119, 21, 35), (119, 22, 45), (119, 23, 40), (119, 24, 60), (119, 25, 55), (119, 26, 70), (119, 27, 50), (119, 28, 34), (119, 29, 15), (119, 30, 45);

-- Call of Cthulhu Creature Attributes
INSERT INTO entity_attributes (entity_id, attr_def_id, value_numeric) VALUES
(120, 28, 36), -- Deep One
(121, 28, 54), -- Byakhee
(122, 28, 150), -- Chthonian
(123, 28, 42), -- Mi-Go
(124, 28, 120), -- Shoggoth
(125, 28, 30); -- Dimensional Shambler

-- Tags for Call of Cthulhu entities
INSERT INTO entity_tags (entity_id, tag_id) VALUES
(115, 22), (116, 22), (117, 22), (118, 22), (119, 22), -- Investigators
(120, 9), (121, 9), (122, 9), (123, 9), (124, 9), (125, 9), -- Creatures
(126, 9), (127, 12), (128, 8), (129, 5), (130, 9), -- Items
(131, 39), (132, 40), (133, 5), (134, 40), (135, 38); -- Spells

-- Character-Item relationships
INSERT INTO entity_relationships (parent_id, child_id, relationship_type, quantity, metadata) VALUES
(115, 126, 'inventory', 2, '{}'),
(115, 128, 'inventory', 1, '{}'),
(116, 127, 'inventory', 2, '{}'),
(116, 128, 'inventory', 1, '{}'),
(117, 127, 'inventory', 1, '{}'),
(118, 129, 'inventory', 2, '{}'),
(119, 130, 'inventory', 1, '{}');

-- Character-Spell relationships
INSERT INTO entity_relationships (parent_id, child_id, relationship_type, metadata) VALUES
(115, 131, 'spellbook', '{"known": true}'),
(116, 134, 'spellbook', '{"known": false}'),
(117, 132, 'spellbook', '{"known": true}'),
(118, 133, 'spellbook', '{"known": true}');
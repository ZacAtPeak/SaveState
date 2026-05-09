-- Vampire: The Masquerade Data
-- Entities: vampires, ghouls, items, disciplines

-- Characters (entity_type: 'character')
INSERT INTO entities (entity_id, system_id, entity_type, name, description, metadata) VALUES
(136, 4, 'character', 'Marcus the Ancient', 'Ventrue elder with centuries of experience', '{"generation": 5, "clan": "Ventrue", "age": 534, "status": "Elder"}'),
(137, 4, 'character', 'Whisper in Darkness', 'Tremere apprentice studying forbidden blood magic', '{"generation": 8, "clan": "Tremere", "age": 89, "status": "Neonate"}'),
(138, 4, 'character', 'Scarlet Fade', 'Toreador artist painting masterpieces', '{"generation": 7, "clan": "Toreador", "age": 156, "status": "Ancilla"}'),
(139, 4, 'character', 'Rage Born', 'Gangrel feral survivor of the wild', '{"generation": 9, "clan": "Gangrel", "age": 45, "status": "Neonate"}'),
(140, 4, 'character', 'Silent Veil', 'Nosferatu information broker in the underworld', '{"generation": 8, "clan": "Nosferatu", "age": 203, "status": "Ancilla"}');

-- NPCs (entity_type: 'npc')
INSERT INTO entities (entity_id, system_id, entity_type, name, description, metadata) VALUES
(141, 4, 'npc', 'Victor Ashworth', 'Ghoul servant to Beatrice', '{"humanity": 5, "sire": "Beatrice Ashworth", "role": "Butler"}'),
(142, 4, 'npc', 'The Snake', 'Infamous kine with a dark reputation', '{"humanity": 2, "clan": "Malkavian", "role": "Information Broker"}'),
(143, 4, 'npc', 'Sister Margaret', 'Human priest covering for kindred activities', '{"humanity": 7, "role": "Confidant"}');

-- Items (entity_type: 'item')
INSERT INTO entities (entity_id, system_id, entity_type, name, description, metadata) VALUES
(144, 4, 'item', 'Blood Potion', 'Concentrated vitae for emergency healing', '{"quality": "Standard", "uses": 1}'),
(145, 4, 'item', 'Ritual Dagger', 'Ceremonial blade for the渴血仪式', '{"material": "Silver", "rarity": "Rare"}'),
(146, 4, 'item', 'Cell Phone', 'Modern communication device', '{"model": "Encrypted", "age": 2020}'),
(147, 4, 'item', 'Embrace Scroll', 'Ancient document recording the Embrace ritual', '{"age": 400, "language": "Latin"}');

-- Disciplines (entity_type: 'spell' - representing vampiric powers)
INSERT INTO entities (entity_id, system_id, entity_type, name, description, metadata) VALUES
(148, 4, 'spell', 'Presence', 'Awe and manipulate emotions', '{"level": 2, "clan": "Toreador", "effects": ["Awe", "Entrancement", "Majesty"]}'),
(149, 4, 'spell', 'Dominate', 'Control mortal minds', '{"level": 3, "clan": "Ventrue", "effects": ["Command", "Dalliance", "Subliminal"]}'),
(150, 4, 'spell', 'Obfuscate', 'Hide from sight', '{"level": 2, "clan": "Nosferatu", "effects": ["Cloak", "Silence", "Unseen"]}'),
(151, 4, 'spell', 'Animalism', 'Control and communicate with animals', '{"level": 1, "clan": "Gangrel", "effects": ["Feral Whispers", "Beckoning", "Quell"]}'),
(152, 4, 'spell', 'Thaumatology', 'Blood magic rituals', '{"level": 4, "clan": "Tremere", "effects": ["Path of Blood", "Lure of Flames", "Theft of Vitae"]}'),
(153, 4, 'spell', 'Celerity', 'Superhuman speed', '{"level": 1, "clan": "Toreador", "effects": ["Rapid Reflexes", "Fleetness", "Blurring"]}');

-- Vampire Attributes (Marcus - entity 136)
INSERT INTO entity_attributes (entity_id, attr_def_id, value_numeric) VALUES
(136, 31, 4), (136, 32, 3), (136, 33, 5), (136, 34, 5), (136, 35, 6), (136, 36, 4), (136, 37, 5), (136, 38, 3), (136, 39, 5), (136, 40, 4);

-- Vampire Attributes (Whisper - entity 137)
INSERT INTO entity_attributes (entity_id, attr_def_id, value_numeric) VALUES
(137, 31, 2), (137, 32, 3), (137, 33, 3), (137, 34, 3), (137, 35, 5), (137, 36, 4), (137, 37, 6), (137, 38, 4), (137, 39, 5), (137, 40, 3);

-- Vampire Attributes (Scarlet - entity 138)
INSERT INTO entity_attributes (entity_id, attr_def_id, value_numeric) VALUES
(138, 31, 2), (138, 32, 4), (138, 33, 3), (138, 34, 6), (138, 35, 5), (138, 36, 6), (138, 37, 4), (138, 38, 3), (138, 39, 4), (138, 40, 3);

-- Vampire Attributes (Rage Born - entity 139)
INSERT INTO entity_attributes (entity_id, attr_def_id, value_numeric) VALUES
(139, 31, 5), (139, 32, 4), (139, 33, 4), (139, 34, 3), (139, 35, 2), (139, 36, 3), (139, 37, 2), (139, 38, 4), (139, 39, 3), (139, 40, 2);

-- Vampire Attributes (Silent Veil - entity 140)
INSERT INTO entity_attributes (entity_id, attr_def_id, value_numeric) VALUES
(140, 31, 3), (140, 32, 4), (140, 33, 4), (140, 34, 2), (140, 35, 5), (140, 36, 3), (140, 37, 4), (140, 38, 5), (140, 39, 5), (140, 40, 3);

-- Tags for Vampire: The Masquerade entities
INSERT INTO entity_tags (entity_id, tag_id) VALUES
(136, 22), (136, 45), (137, 22), (137, 45), (138, 22), (138, 45), (139, 22), (139, 45), (140, 22), (140, 45), -- PCs
(141, 21), (142, 21), (143, 21), -- NPCs
(144, 5), (145, 16), (146, 10), (147, 60), -- Items
(148, 38), (149, 38), (150, 57), (151, 9), (152, 37), (153, 8); -- Disciplines

-- Vampire-Discipline relationships
INSERT INTO entity_relationships (parent_id, child_id, relationship_type, metadata) VALUES
(136, 149, 'discipline', '{"level": 4}'),
(136, 153, 'discipline', '{"level": 3}'),
(137, 152, 'discipline', '{"level": 3}'),
(137, 150, 'discipline', '{"level": 1}'),
(138, 148, 'discipline', '{"level": 5}'),
(138, 153, 'discipline', '{"level": 2}'),
(139, 151, 'discipline', '{"level": 3}'),
(140, 150, 'discipline', '{"level": 4}');

-- Vampire-Item relationships
INSERT INTO entity_relationships (parent_id, child_id, relationship_type, quantity, metadata) VALUES
(136, 144, 'inventory', 3, '{}'),
(137, 145, 'inventory', 1, '{}'),
(137, 147, 'inventory', 1, '{}'),
(138, 146, 'inventory', 1, '{}'),
(139, 144, 'inventory', 2, '{}');
-- Pathfinder 2e Data
-- Entities: player characters, creatures, items, spells, weapons

-- Characters (entity_type: 'character')
INSERT INTO entities (entity_id, system_id, entity_type, name, description, metadata) VALUES
(89, 2, 'character', 'Kyra Sunblade', 'Human champion of the sun', '{"level": 6, "class": "Champion", "ancestry": "Human", "background": "Acolyte"}'),
(90, 2, 'character', 'Elminster Truecload', 'Elf alchemist with explosive innovations', '{"level": 5, "class": "Alchemist", "ancestry": "Elf", "background": "Merchant"}'),
(91, 2, 'character', 'Gorthak the Unbroken', 'Orc barbarian with unyielding rage', '{"level": 6, "class": "Barbarian", "ancestry": "Orc", "background": "Soldier"}'),
(92, 2, 'character', 'Lira Whisperwind', 'Halfling ranger tracking prey', '{"level": 5, "class": "Ranger", "ancestry": "Halfling", "background": "Hunter"}'),
(93, 2, 'character', 'Zan-Nex the Mystery', 'Gnome investigator seeking truth', '{"level": 4, "class": "Investigator", "ancestry": "Gnome", "background": "Scholar"}');

-- Creatures (entity_type: 'creature')
INSERT INTO entities (entity_id, system_id, entity_type, name, description, metadata) VALUES
(94, 2, 'creature', 'Garrote', 'Intelligent constructs used in gladiatorial arenas', '{"level": 6, "size": "Medium", "type": "Construct"}'),
(95, 2, 'creature', 'Young White Dragon', 'Young dragon with frost breath', '{"level": 7, "size": "Large", "type": "Dragon"}'),
(96, 2, 'creature', 'Gogitann Smog Demon', 'Air-borne pollution spirit', '{"level": 8, "size": "Large", "type": "Demon"}'),
(97, 2, 'creature', 'Mammoth', 'Great beast of the frozen north', '{"level": 5, "size": "Huge", "type": "Animal"}'),
(98, 2, 'creature', 'Bone Prophet', 'Undead oracle speaking for dark powers', '{"level": 9, "size": "Medium", "type": "Undead"}'),
(99, 2, 'creature', 'Troll', 'Regenerating monster that fears fire', '{"level": 4, "size": "Large", "type": "Giant"}');

-- Items (entity_type: 'item')
INSERT INTO entities (entity_id, system_id, entity_type, name, description, metadata) VALUES
(100, 2, 'item', 'Rune of Striking', 'Property rune adding weapon damage', '{"rarity": "Uncommon", "type": "Rune", "level": 5}'),
(101, 2, 'item', 'Healing Potion', 'Minor healing draught', '{"rarity": "Common", "type": "Potion", "level": 1}'),
(102, 2, 'item', 'Cloak of Elvenkind', 'Makes wearer stealthy', '{"rarity": "Uncommon", "type": "Worn", "level": 5}'),
(103, 2, 'item', 'Explosive Dogs', 'Alchemical bomblet delivery system', '{"rarity": "Uncommon", "type": "Alchemical", "level": 3}'),
(104, 2, 'item', 'Goggles of Night', 'Grants darkvision', '{"rarity": "Uncommon", "type": "Worn", "level": 4}');

-- Spells (entity_type: 'spell')
INSERT INTO entities (entity_id, system_id, entity_type, name, description, metadata) VALUES
(105, 2, 'spell', 'Heal', 'Positive energy heals or harms undead', '{"level": 1, "school": "Necromancy", "casting_time": "2 actions", "range": "30 feet", "duration": "Sustained", "tradition": "Divine"}'),
(106, 2, 'spell', 'Acid Arrow', 'Magical acid damages creatures', '{"level": 1, "school": "Evocation", "casting_time": "2 actions", "range": "60 feet", "duration": "1 minute", "tradition": "Arcane"}'),
(107, 2, 'spell', 'Fear', 'Creatures become frightened', '{"level": 2, "school": "Enchantment", "casting_time": "2 actions", "range": "30 feet", "duration": "1 minute", "tradition": "Arcane"}'),
(108, 2, 'spell', 'Haste', 'Target gains extra actions', '{"level": 3, "school": "Transmutation", "casting_time": "2 actions", "range": "30 feet", "duration": "1 minute", "tradition": "Arcane"}'),
(109, 2, 'spell', 'Wall of Fire', 'Creates a barrier of flame', '{"level": 4, "school": "Evocation", "casting_time": "3 actions", "range": "120 feet", "duration": "1 minute", "tradition": "Arcane"}');

-- Weapons (entity_type: 'weapon')
INSERT INTO entities (entity_id, system_id, entity_type, name, description, metadata) VALUES
(110, 2, 'weapon', 'Falchion', 'Curved two-handed sword', '{"damage": "1d10 slashing", "bulk": 2, "traits": "Deadly, Forceful"}'),
(111, 2, 'weapon', 'Composite Longbow', 'Reflexive ranged weapon', '{"damage": "1d8 piercing", "bulk": 2, "traits": "Deadly, Volley"}'),
(112, 2, 'weapon', 'Rapier', 'Precise fencing weapon', '{"damage": "1d6 piercing", "bulk": 1, "traits": "Deadly, Finesse"}'),
(113, 2, 'weapon', 'War Flail', 'Flail with spiked chains', '{"damage": "1d8 bludgeoning", "bulk": 2, "traits": "Sweep"}'),
(114, 2, 'weapon', 'Starknife', 'Dwarf throwing knife', '{"damage": "1d4 piercing", "bulk": 1, "traits": "Deadly, Finesse, Throw"}');

-- Pathfinder 2e Character Attributes (Kyra - entity 89)
INSERT INTO entity_attributes (entity_id, attr_def_id, value_numeric) VALUES
(89, 11, 14), (89, 12, 12), (89, 13, 14), (89, 14, 10), (89, 15, 16), (89, 16, 12), (89, 17, 52), (89, 18, 20), (89, 19, 6), (89, 20, 3);

-- Pathfinder 2e Character Attributes (Elminster - entity 90)
INSERT INTO entity_attributes (entity_id, attr_def_id, value_numeric) VALUES
(90, 11, 10), (90, 12, 14), (90, 13, 12), (90, 14, 18), (90, 15, 12), (90, 16, 10), (90, 17, 32), (90, 18, 15), (90, 19, 5), (90, 20, 2);

-- Pathfinder 2e Character Attributes (Gorthak - entity 91)
INSERT INTO entity_attributes (entity_id, attr_def_id, value_numeric) VALUES
(91, 11, 18), (91, 12, 10), (91, 13, 16), (91, 14, 8), (91, 15, 12), (91, 16, 9), (91, 17, 72), (91, 18, 18), (91, 19, 6), (91, 20, 3);

-- Pathfinder 2e Character Attributes (Lira - entity 92)
INSERT INTO entity_attributes (entity_id, attr_def_id, value_numeric) VALUES
(92, 11, 12), (92, 12, 16), (92, 13, 12), (92, 14, 10), (92, 15, 14), (92, 16, 14), (92, 17, 40), (92, 18, 16), (92, 19, 5), (92, 20, 2);

-- Pathfinder 2e Character Attributes (Zan-Nex - entity 93)
INSERT INTO entity_attributes (entity_id, attr_def_id, value_numeric) VALUES
(93, 11, 10), (93, 12, 14), (93, 13, 10), (93, 14, 16), (93, 15, 12), (93, 16, 14), (93, 17, 28), (93, 18, 14), (93, 19, 4), (93, 20, 2);

-- Pathfinder 2e Creature Attributes
INSERT INTO entity_attributes (entity_id, attr_def_id, value_numeric) VALUES
(94, 17, 63), (94, 18, 24), -- Garrote
(95, 17, 115), (95, 18, 22), -- Young White Dragon
(96, 17, 150), (96, 18, 20), -- Gogitann Smog Demon
(97, 17, 85), (97, 18, 18), -- Mammoth
(98, 17, 100), (98, 18, 22); -- Bone Prophet

-- Tags for Pathfinder 2e entities
INSERT INTO entity_tags (entity_id, tag_id) VALUES
(89, 22), (90, 22), (91, 22), (92, 22), (93, 22), -- PCs
(94, 50), (95, 51), (96, 54), (97, 48), (98, 47), (99, 49), -- Creatures
(100, 16), (101, 5), (102, 57), (103, 10), (104, 10), -- Items
(105, 5), (106, 40), (107, 38), (108, 42), (109, 40), -- Spells
(110, 13), (111, 14), (112, 13), (113, 13), (114, 13); -- Weapons

-- Character-Spell relationships
INSERT INTO entity_relationships (parent_id, child_id, relationship_type, metadata) VALUES
(89, 105, 'spellbook', '{"committed": true}'),
(90, 106, 'spellbook', '{"known": true}'),
(90, 103, 'inventory', '{}'),
(92, 107, 'spellbook', '{"known": true}');

-- Character-Weapon relationships
INSERT INTO entity_relationships (parent_id, child_id, relationship_type, metadata) VALUES
(89, 112, 'inventory', '{"equipped": true}'),
(90, 114, 'inventory', '{"equipped": false}'),
(91, 110, 'inventory', '{"equipped": true}'),
(92, 111, 'inventory', '{"equipped": true}'),
(93, 112, 'inventory', '{"equipped": true}');

-- Character-Item relationships
INSERT INTO entity_relationships (parent_id, child_id, relationship_type, quantity, metadata) VALUES
(89, 101, 'inventory', 3, '{}'),
(90, 100, 'inventory', 1, '{}'),
(92, 102, 'inventory', 1, '{}');
-- Dungeons & Dragons 5e Data
-- Entities: player characters, creatures, items, spells, weapons

-- Characters (entity_type: 'character')
INSERT INTO entities (entity_id, system_id, entity_type, name, description, metadata) VALUES
(61, 1, 'character', 'Aldric the Brave', 'Human fighter, retired soldier seeking one last adventure', '{"level": 5, "class": "Fighter", "race": "Human", "background": "Soldier"}'),
(62, 1, 'character', 'Seraphina Nightwhisper', 'Elf wizard specializing in evocation magic', '{"level": 7, "class": "Wizard", "race": "Elf", "background": "Sage"}'),
(63, 1, 'character', 'Thorne Ironhide', 'Dwarf paladin devoted to the god of war', '{"level": 4, "class": "Paladin", "race": "Dwarf", "background": "Acolyte"}'),
(64, 1, 'character', 'Lyra Swiftarrow', 'Halfling rogue with a checkered past', '{"level": 6, "class": "Rogue", "race": "Halfling", "background": "Criminal"}'),
(65, 1, 'character', 'Grimjaw the Destroyer', 'Half-orc barbarian seeking vengeance', '{"level": 5, "class": "Barbarian", "race": "Half-Orc", "background": "Hermit"}');

-- Creatures (entity_type: 'creature')
INSERT INTO entities (entity_id, system_id, entity_type, name, description, metadata) VALUES
(66, 1, 'creature', 'Adult Red Dragon', 'Massive fire-breathing dragon, territorial and dangerous', '{"cr": 17, "size": "Huge", "type": "Dragon"}'),
(67, 1, 'creature', 'Lich', 'Undead spellcaster clutching forbidden knowledge', '{"cr": 21, "size": "Medium", "type": "Undead"}'),
(68, 1, 'creature', 'Goblin Boss', 'Cunning goblin leading a raiding party', '{"cr": 1, "size": "Small", "type": "Humanoid"}'),
(69, 1, 'creature', 'Owlbear', 'Fearsome predator combining bear and owl features', '{"cr": 3, "size": "Large", "type": "Monstrosity"}'),
(70, 1, 'creature', 'Mind Flayer', 'Psionic humanoid from the Far Realm', '{"cr": 7, "size": "Medium", "type": "Aberration"}'),
(71, 1, 'creature', 'Gelatinous Cube', 'Transparent slime sweeping through dungeons', '{"cr": 2, "size": "Large", "type": "Ooze"}'),
(72, 1, 'creature', 'Tarrasque', 'Legendary apocalyptic beast', '{"cr": 30, "size": "Gargantuan", "type": "Monstrosity"}');

-- Items (entity_type: 'item')
INSERT INTO entities (entity_id, system_id, entity_type, name, description, metadata) VALUES
(73, 1, 'item', 'Ring of Invisibility', 'Grants invisibility for short periods', '{"rarity": "Legendary", "attunement": true, "type": "Ring"}'),
(74, 1, 'item', 'Potion of Greater Healing', 'Restores 4d8+4 hit points', '{"rarity": "Uncommon", "type": "Potion"}'),
(75, 1, 'item', 'Bag of Holding', 'Extradimensional storage container', '{"rarity": "Uncommon", "type": "Wondrous Item"}'),
(76, 1, 'item', 'Boots of Speed', 'Doubles movement speed', '{"rarity": "Rare", "attunement": true, "type": "Boots"}'),
(77, 1, 'item', 'Cloak of Protection', 'Grants +1 AC and saving throws', '{"rarity": "Uncommon", "attunement": true, "type": "Cloak"}');

-- Spells (entity_type: 'spell')
INSERT INTO entities (entity_id, system_id, entity_type, name, description, metadata) VALUES
(78, 1, 'spell', 'Fireball', 'Explosion of fire damages creatures in area', '{"level": 3, "school": "Evocation", "casting_time": "1 action", "range": "150 ft", "duration": "Instantaneous", "components": "V S M"}'),
(79, 1, 'spell', 'Counterspell', 'Interrupt a creature casting a spell', '{"level": 3, "school": "Abjuration", "casting_time": "Reaction", "range": "60 ft", "duration": "Instantaneous", "components": "V"}'),
(80, 1, 'spell', 'Fly', 'Target gains flying speed', '{"level": 3, "school": "Transmutation", "casting_time": "1 action", "range": "Touch", "duration": "10 minutes", "components": "V S M"}'),
(81, 1, 'spell', 'Hold Person', 'Paralysis on humanoid', '{"level": 2, "school": "Enchantment", "casting_time": "1 action", "range": "60 ft", "duration": "1 minute", "components": "V S M"}'),
(82, 1, 'spell', 'Magic Missile', 'Force darts always hit', '{"level": 1, "school": "Evocation", "casting_time": "1 action", "range": "120 ft", "duration": "Instantaneous", "components": "V S"}'),
(83, 1, 'spell', 'Revivify', 'Return dead creature to life', '{"level": 3, "school": "Necromancy", "casting_time": "1 action", "range": "Touch", "duration": "Instantaneous", "components": "V S M", "cost": "300 gp diamond"}');

-- Weapons (entity_type: 'weapon')
INSERT INTO entities (entity_id, system_id, entity_type, name, description, metadata) VALUES
(84, 1, 'weapon', 'Greatsword', 'Large two-handed sword', '{"damage": "2d6 slashing", "weight": 6, "properties": "Heavy, Two-Handed"}'),
(85, 1, 'weapon', 'Longbow', 'Standard ranged weapon', '{"damage": "1d8 piercing", "weight": 2, "properties": "Ammunition, Range, Two-Handed"}'),
(86, 1, 'weapon', 'Dagger', 'Small versatile blade', '{"damage": "1d4 piercing", "weight": 1, "properties": "Finesse, Light, Thrown"}'),
(87, 1, 'weapon', 'Warhammer', 'Dwarven combat hammer', '{"damage": "1d8 bludgeoning", "weight": 2, "properties": "Versatile"}'),
(88, 1, 'weapon', 'Flame Tongue', 'Magic sword that deals extra fire damage', '{"damage": "2d6 slashing + 1d6 fire", "weight": 4, "properties": "Heavy, Two-Handed", "rarity": "Rare", "attunement": true}');

-- D&D 5e Character Attributes (Aldric the Brave - entity 61)
INSERT INTO entity_attributes (entity_id, attr_def_id, value_numeric) VALUES
(61, 1, 16), (61, 2, 12), (61, 3, 15), (61, 4, 10), (61, 5, 13), (61, 6, 11), (61, 7, 44), (61, 8, 18), (61, 9, 5);

-- D&D 5e Character Attributes (Seraphina - entity 62)
INSERT INTO entity_attributes (entity_id, attr_def_id, value_numeric) VALUES
(62, 1, 8), (62, 2, 14), (62, 3, 12), (62, 4, 18), (62, 5, 15), (62, 6, 11), (62, 7, 38), (62, 8, 13), (62, 9, 7);

-- D&D 5e Character Attributes (Thorne - entity 63)
INSERT INTO entity_attributes (entity_id, attr_def_id, value_numeric) VALUES
(63, 1, 17), (63, 2, 9), (63, 3, 16), (63, 4, 10), (63, 5, 14), (63, 6, 12), (63, 7, 36), (63, 8, 19), (63, 9, 4);

-- D&D 5e Character Attributes (Lyra - entity 64)
INSERT INTO entity_attributes (entity_id, attr_def_id, value_numeric) VALUES
(64, 1, 10), (64, 2, 18), (64, 3, 12), (64, 4, 14), (64, 5, 12), (64, 6, 16), (64, 7, 32), (64, 8, 15), (64, 9, 6);

-- D&D 5e Character Attributes (Grimjaw - entity 65)
INSERT INTO entity_attributes (entity_id, attr_def_id, value_numeric) VALUES
(65, 1, 18), (65, 2, 10), (65, 3, 16), (65, 4, 8), (65, 5, 11), (65, 6, 9), (65, 7, 52), (65, 8, 16), (65, 9, 5);

-- D&D 5e Creature Attributes
INSERT INTO entity_attributes (entity_id, attr_def_id, value_numeric) VALUES
(66, 7, 256), (66, 8, 22), (66, 10, 17), -- Adult Red Dragon
(67, 7, 135), (67, 8, 17), (67, 10, 21), -- Lich
(68, 7, 21), (68, 8, 15), (68, 10, 1), -- Goblin Boss
(69, 7, 52), (69, 8, 13), (69, 10, 3), -- Owlbear
(70, 7, 71), (70, 8, 16), (70, 10, 7); -- Mind Flayer

-- Tags for D&D 5e entities
INSERT INTO entity_tags (entity_id, tag_id) VALUES
(61, 22), (62, 22), (63, 22), (64, 22), (65, 22), -- PCs
(66, 51), (67, 47), (68, 49), (69, 48), (70, 36), (71, 48), (72, 51), -- Creatures
(73, 16), (74, 5), (75, 8), (76, 8), (77, 15), -- Items
(78, 40), (79, 44), (80, 42), (81, 38), (82, 40), (83, 37), -- Spells
(84, 13), (85, 14), (86, 13), (87, 13), (88, 13); -- Weapons

-- Character-Spell relationships (wizards know spells)
INSERT INTO entity_relationships (parent_id, child_id, relationship_type, metadata) VALUES
(62, 78, 'spellbook', '{"known": true}'),
(62, 82, 'spellbook', '{"known": true}'),
(62, 80, 'spellbook', '{"known": true}');

-- Character-Weapon relationships
INSERT INTO entity_relationships (parent_id, child_id, relationship_type, metadata) VALUES
(61, 84, 'inventory', '{"equipped": true}'),
(62, 86, 'inventory', '{"equipped": false}'),
(63, 87, 'inventory', '{"equipped": true}'),
(64, 86, 'inventory', '{"equipped": true}'),
(65, 84, 'inventory', '{"equipped": true}');

-- Character-Item relationships
INSERT INTO entity_relationships (parent_id, child_id, relationship_type, quantity, metadata) VALUES
(61, 74, 'inventory', 2, '{}'),
(62, 73, 'inventory', 1, '{"attuned": true}'),
(64, 76, 'inventory', 1, '{"attuned": false}');
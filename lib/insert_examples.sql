-- 25 New Example Entities for UTS Database
-- Generated entities across all 6 game systems

-- D&D 5e Entities (system_id = 1)
INSERT INTO entities (entity_id, system_id, entity_type, name, description, metadata) VALUES (201, 1, 'character', 'Kael Shadowmend', 'Half-elf bard who uses music to heal and inspire allies', '{"level": 6, "class": "Bard", "race": "Half-Elf", "background": "Entertainer"}');
INSERT INTO entities (entity_id, system_id, entity_type, name, description, metadata) VALUES (202, 1, 'creature', 'Displacer Beast', 'Tentacled predator that bends light to appear distant', '{"cr": 3, "size": "Large", "type": "Monstrosity"}');
INSERT INTO entities (entity_id, system_id, entity_type, name, description, metadata) VALUES (203, 1, 'item', 'Deck of Many Things', 'Magical deck containing cards of immense power and danger', '{"rarity": "Legendary", "type": "Wondrous Item", "cards": 22}');
INSERT INTO entities (entity_id, system_id, entity_type, name, description, metadata) VALUES (204, 1, 'spell', 'Sleep', 'Pink-colored magic causes creatures to fall into magical slumber', '{"level": 1, "school": "Enchantment", "casting_time": "1 action", "range": "90 ft", "duration": "1 minute", "components": "V S M"}');
INSERT INTO entities (entity_id, system_id, entity_type, name, description, metadata) VALUES (205, 1, 'weapon', 'Shortbow', 'Compact ranged weapon favored by archers', '{"damage": "1d6 piercing", "weight": 2, "properties": "Ammunition, Range, Two-Handed"}');

-- Pathfinder 2e Entities (system_id = 2)
INSERT INTO entities (entity_id, system_id, entity_type, name, description, metadata) VALUES (206, 2, 'character', 'Shelyn Ashari', 'Half-elf sorcerer with draconic bloodline', '{"level": 5, "class": "Sorcerer", "ancestry": "Half-Elf", "heritage": "Draconic"}');
INSERT INTO entities (entity_id, system_id, entity_type, name, description, metadata) VALUES (207, 2, 'creature', 'Giant Spider', ' Massive arachnid with potent venom', '{"level": 3, "size": "Large", "type": "Animal"}');
INSERT INTO entities (entity_id, system_id, entity_type, name, description, metadata) VALUES (208, 2, 'item', 'Scorpion Whip', 'Whip with有毒 scorpion tail attached', '{"rarity": "Uncommon", "type": "Weapon", "level": 3}');
INSERT INTO entities (entity_id, system_id, entity_type, name, description, metadata) VALUES (209, 2, 'spell', 'Spirit Sense', 'Detect spirits and see into the Ethereal Plane', '{"level": 1, "school": "Divination", "casting_time": "2 actions", "range": "30 feet", "duration": "Sustained", "tradition": "Arcane"}');
INSERT INTO entities (entity_id, system_id, entity_type, name, description, metadata) VALUES (210, 2, 'weapon', 'Greatpick', 'Heavy pick for penetrating armor', '{"damage": "1d10 piercing", "bulk": 2, "traits": "Deadly, Versatile"}');

-- Call of Cthulhu Entities (system_id = 3)
INSERT INTO entities (entity_id, system_id, entity_type, name, description, metadata) VALUES (211, 3, 'character', 'Agnes Ashworth', 'Wealthy socialite with forbidden knowledge', '{"occupation": "Dilettante", "age": 28, "residence": "Providence"}');
INSERT INTO entities (entity_id, system_id, entity_type, name, description, metadata) VALUES (212, 3, 'creature', 'Flying Polyp', 'Non-Euclidean horror with wings of prismatic color', '{"hit_dice": 16, "move": "Fly 12, Walk 4", "armor": 12}');
INSERT INTO entities (entity_id, system_id, entity_type, name, description, metadata) VALUES (213, 3, 'item', 'Whiskey', 'Blended scotch for courage in dark times', '{"damage": 0, "uses": 99, "effect": "Sanity restoration"}');
INSERT INTO entities (entity_id, system_id, entity_type, name, description, metadata) VALUES (214, 3, 'spell', 'Find Gate', 'Locate dimensional portals', '{"cost": 5, "difficulty": 50, "sanity_cost": "1d4"}');

-- Vampire: The Masquerade Entities (system_id = 4)
INSERT INTO entities (entity_id, system_id, entity_type, name, description, metadata) VALUES (215, 4, 'character', 'The Wanderer', 'Malkavian prophet speaking in riddles', '{"generation": 7, "clan": "Malkavian", "age": 89, "status": "Neonate"}');
INSERT INTO entities (entity_id, system_id, entity_type, name, description, metadata) VALUES (216, 4, 'npc', 'Dr. Samuel Vance', 'Ghoul physician maintaining false health records', '{"humanity": 6, "sire": "Unknown", "role": "Physician"}');
INSERT INTO entities (entity_id, system_id, entity_type, name, description, metadata) VALUES (217, 4, 'item', 'Elder Chronicle', 'Ancient manuscript of vampire history', '{"age": 800, "language": "Aramaic", "rarity": "Unique"}');

-- Cyberpunk Red Entities (system_id = 5)
INSERT INTO entities (entity_id, system_id, entity_type, name, description, metadata) VALUES (218, 5, 'character', 'Road Runner', 'Nomad driving armored convoy between cities', '{"role": "Nomad", "age": 32, "origin": "Badlands"}');
INSERT INTO entities (entity_id, system_id, entity_type, name, description, metadata) VALUES (219, 5, 'npc', 'Agent Miller', 'Federal agent investigating corporate crimes', '{"role": "Agent", "faction": "FBI"}');
INSERT INTO entities (entity_id, system_id, entity_type, name, description, metadata) VALUES (220, 5, 'item', 'Memory Blank', 'Neuro-poison that erases specific memories', '{"type": "Drug", "cost": 2000, "effect": "Memory Erasure"}');

-- Warhammer Fantasy Roleplay Entities (system_id = 6)
INSERT INTO entities (entity_id, system_id, entity_type, name, description, metadata) VALUES (221, 6, 'character', 'Brother Aldric', 'Warrior Priest of Sigmar leading holy crusade', '{"career": "Priest", "species": "Human", "deity": "Sigmar", "status": "Veteran"}');
INSERT INTO entities (entity_id, system_id, entity_type, name, description, metadata) VALUES (222, 6, 'creature', 'Chaos Spawn', 'Mutated horror of unknowable form', '{"tb": 3, "wb": 20, "size": "Large"}');
INSERT INTO entities (entity_id, system_id, entity_type, name, description, metadata) VALUES (223, 6, 'item', 'Witch Hunters Handbook', 'Guide to identifying and fighting mutants', '{"effect": "+10 to secret checks", "pages": 350}');
INSERT INTO entities (entity_id, system_id, entity_type, name, description, metadata) VALUES (224, 6, 'spell', 'Smite', 'Holy fire damages creatures of Chaos', '{"damage": 4, "range": 24, "duration": "Instantaneous"}');
INSERT INTO entities (entity_id, system_id, entity_type, name, description, metadata) VALUES (225, 6, 'weapon', 'Flail', 'Spiked chain weapon for crushing blows', '{"damage": 4, "reach": 2, "group": "Flail"}');

-- Entity Tags for new entities
INSERT INTO entity_tags (entity_id, tag_id) VALUES (201, 20);  -- character
INSERT INTO entity_tags (entity_id, tag_id) VALUES (201, 7);   -- social
INSERT INTO entity_tags (entity_id, tag_id) VALUES (201, 5);   -- healing
INSERT INTO entity_tags (entity_id, tag_id) VALUES (202, 48);  -- beast
INSERT INTO entity_tags (entity_id, tag_id) VALUES (202, 13);  -- melee
INSERT INTO entity_tags (entity_id, tag_id) VALUES (203, 23);  -- legendary
INSERT INTO entity_tags (entity_id, tag_id) VALUES (203, 24);  -- unique
INSERT INTO entity_tags (entity_id, tag_id) VALUES (204, 17);  -- spell
INSERT INTO entity_tags (entity_id, tag_id) VALUES (204, 28);  -- level-1
INSERT INTO entity_tags (entity_id, tag_id) VALUES (204, 7);   -- social
INSERT INTO entity_tags (entity_id, tag_id) VALUES (205, 14);  -- ranged
INSERT INTO entity_tags (entity_id, tag_id) VALUES (205, 16);  -- weapon
INSERT INTO entity_tags (entity_id, tag_id) VALUES (206, 20);  -- character
INSERT INTO entity_tags (entity_id, tag_id) VALUES (206, 2);   -- magic
INSERT INTO entity_tags (entity_id, tag_id) VALUES (207, 48);  -- beast
INSERT INTO entity_tags (entity_id, tag_id) VALUES (207, 35);  -- poison
INSERT INTO entity_tags (entity_id, tag_id) VALUES (208, 16);  -- weapon
INSERT INTO entity_tags (entity_id, tag_id) VALUES (208, 35);  -- poison
INSERT INTO entity_tags (entity_id, tag_id) VALUES (209, 17);  -- spell
INSERT INTO entity_tags (entity_id, tag_id) VALUES (209, 40);  -- evocation
INSERT INTO entity_tags (entity_id, tag_id) VALUES (210, 16);  -- weapon
INSERT INTO entity_tags (entity_id, tag_id) VALUES (210, 13);  -- melee
INSERT INTO entity_tags (entity_id, tag_id) VALUES (211, 20);  -- character
INSERT INTO entity_tags (entity_id, tag_id) VALUES (211, 9);   -- supernatural
INSERT INTO entity_tags (entity_id, tag_id) VALUES (211, 23);  -- legendary
INSERT INTO entity_tags (entity_id, tag_id) VALUES (212, 54);  -- fiend
INSERT INTO entity_tags (entity_id, tag_id) VALUES (212, 9);   -- supernatural
INSERT INTO entity_tags (entity_id, tag_id) VALUES (213, 10);  -- technical
INSERT INTO entity_tags (entity_id, tag_id) VALUES (213, 7);   -- social
INSERT INTO entity_tags (entity_id, tag_id) VALUES (214, 17);  -- spell
INSERT INTO entity_tags (entity_id, tag_id) VALUES (214, 9);   -- supernatural
INSERT INTO entity_tags (entity_id, tag_id) VALUES (215, 45);  -- vampire
INSERT INTO entity_tags (entity_id, tag_id) VALUES (215, 9);   -- supernatural
INSERT INTO entity_tags (entity_id, tag_id) VALUES (215, 46);  -- zombie
INSERT INTO entity_tags (entity_id, tag_id) VALUES (216, 21);  -- npc
INSERT INTO entity_tags (entity_id, tag_id) VALUES (216, 10);  -- technical
INSERT INTO entity_tags (entity_id, tag_id) VALUES (217, 24);  -- unique
INSERT INTO entity_tags (entity_id, tag_id) VALUES (217, 59);  -- lore
INSERT INTO entity_tags (entity_id, tag_id) VALUES (218, 20);  -- character
INSERT INTO entity_tags (entity_id, tag_id) VALUES (218, 13);  -- melee
INSERT INTO entity_tags (entity_id, tag_id) VALUES (218, 8);   -- exploration
INSERT INTO entity_tags (entity_id, tag_id) VALUES (219, 21);  -- npc
INSERT INTO entity_tags (entity_id, tag_id) VALUES (219, 12);  -- firearms
INSERT INTO entity_tags (entity_id, tag_id) VALUES (220, 10);  -- technical
INSERT INTO entity_tags (entity_id, tag_id) VALUES (220, 35);  -- poison
INSERT INTO entity_tags (entity_id, tag_id) VALUES (221, 20);  -- character
INSERT INTO entity_tags (entity_id, tag_id) VALUES (221, 9);   -- supernatural
INSERT INTO entity_tags (entity_id, tag_id) VALUES (221, 7);   -- social
INSERT INTO entity_tags (entity_id, tag_id) VALUES (222, 54);  -- fiend
INSERT INTO entity_tags (entity_id, tag_id) VALUES (222, 35);  -- poison
INSERT INTO entity_tags (entity_id, tag_id) VALUES (223, 60);  -- ritual
INSERT INTO entity_tags (entity_id, tag_id) VALUES (223, 56);  -- investigation
INSERT INTO entity_tags (entity_id, tag_id) VALUES (224, 17);  -- spell
INSERT INTO entity_tags (entity_id, tag_id) VALUES (224, 31);  -- fire
INSERT INTO entity_tags (entity_id, tag_id) VALUES (224, 4);   -- damage
INSERT INTO entity_tags (entity_id, tag_id) VALUES (225, 16);  -- weapon
INSERT INTO entity_tags (entity_id, tag_id) VALUES (225, 13);  -- melee

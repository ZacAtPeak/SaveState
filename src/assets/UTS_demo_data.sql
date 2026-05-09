-- ==========================================
-- 1. FOUNDATIONAL DATA (Systems & Types)
-- ==========================================
INSERT INTO game_systems (id, name, action_economy_type, uses_bounded_accuracy) VALUES
('sys_5e', 'Dungeons & Dragons 5e', 'Standard', 1),
('sys_pf2e', 'Pathfinder 2e', 'Three_Action', 0),
('sys_coc', 'Call of Cthulhu 7e', 'Standard', 0);

INSERT INTO entity_types (id, name, description) VALUES
('et_item', 'Item', 'Standard items, adventuring gear, and tools'),
('et_spell', 'Spell', 'Magical spells, cantrips, and rituals'),
('et_loc', 'Location', 'Points of interest, rooms, and regions'),
('et_weap', 'Weapon', 'Offensive equipment for combat'),
('et_arm', 'Armor', 'Defensive equipment and shields');

-- ==========================================
-- 2. ACTORS (3 Players, 3 NPCs, 3 Monsters per system)
-- Note: Monsters use the 'NPC' actor_type per schema constraints.
-- ==========================================
INSERT INTO actors (id, system_id, name, actor_type, base_hp, base_ac, stats_blob) VALUES
-- D&D 5e: Players
('act_5e_p1', 'sys_5e', 'Grog the Barbarian', 'Player', 115, 17, '{"str": 20, "dex": 15, "con": 18, "int": 6, "wis": 10, "cha": 13}'),
('act_5e_p2', 'sys_5e', 'Keyleth the Druid', 'Player', 75, 15, '{"str": 10, "dex": 14, "con": 14, "int": 14, "wis": 20, "cha": 10}'),
('act_5e_p3', 'sys_5e', 'Vax the Rogue', 'Player', 68, 18, '{"str": 12, "dex": 20, "con": 12, "int": 16, "wis": 14, "cha": 14}'),
-- D&D 5e: NPCs
('act_5e_npc1', 'sys_5e', 'Lord Neverember', 'NPC', 40, 14, '{"str": 12, "dex": 10, "con": 12, "int": 16, "wis": 14, "cha": 18}'),
('act_5e_npc2', 'sys_5e', 'Bob the Barkeep', 'NPC', 10, 10, '{"str": 14, "dex": 10, "con": 12, "int": 10, "wis": 10, "cha": 12}'),
('act_5e_npc3', 'sys_5e', 'Captain Zodge', 'NPC', 58, 16, '{"str": 16, "dex": 12, "con": 14, "int": 10, "wis": 12, "cha": 14}'),
-- D&D 5e: Monsters
('act_5e_mon1', 'sys_5e', 'Adult Red Dragon', 'NPC', 256, 19, '{"str": 27, "dex": 10, "con": 25, "int": 16, "wis": 13, "cha": 21}'),
('act_5e_mon2', 'sys_5e', 'Beholder', 'NPC', 180, 18, '{"str": 10, "dex": 14, "con": 18, "int": 17, "wis": 15, "cha": 17}'),
('act_5e_mon3', 'sys_5e', 'Goblin Boss', 'NPC', 21, 15, '{"str": 10, "dex": 14, "con": 10, "int": 10, "wis": 8, "cha": 10}'),

-- Pathfinder 2e: Players
('act_pf2e_p1', 'sys_pf2e', 'Ezren the Wizard', 'Player', 38, 18, '{"str": 10, "dex": 14, "con": 12, "int": 18, "wis": 12, "cha": 10}'),
('act_pf2e_p2', 'sys_pf2e', 'Valeros the Fighter', 'Player', 56, 21, '{"str": 18, "dex": 14, "con": 14, "int": 10, "wis": 10, "cha": 12}'),
('act_pf2e_p3', 'sys_pf2e', 'Kyra the Cleric', 'Player', 45, 19, '{"str": 14, "dex": 12, "con": 12, "int": 10, "wis": 18, "cha": 14}'),
-- Pathfinder 2e: NPCs
('act_pf2e_npc1', 'sys_pf2e', 'Ameiko Kaijitsu', 'NPC', 35, 17, '{"str": 12, "dex": 16, "con": 10, "int": 12, "wis": 10, "cha": 18}'),
('act_pf2e_npc2', 'sys_pf2e', 'Aldern Foxglove', 'NPC', 25, 15, '{"str": 10, "dex": 14, "con": 12, "int": 14, "wis": 8, "cha": 16}'),
('act_pf2e_npc3', 'sys_pf2e', 'Koya Mvashti', 'NPC', 20, 13, '{"str": 8, "dex": 10, "con": 10, "int": 14, "wis": 16, "cha": 14}'),
-- Pathfinder 2e: Monsters
('act_pf2e_mon1', 'sys_pf2e', 'Owlbear', 'NPC', 70, 21, '{"str": 21, "dex": 13, "con": 18, "int": -4, "wis": 14, "cha": -2}'),
('act_pf2e_mon2', 'sys_pf2e', 'Lich', 'NPC', 190, 31, '{"str": 10, "dex": 16, "con": 0, "int": 24, "wis": 16, "cha": 18}'),
('act_pf2e_mon3', 'sys_pf2e', 'Kobold Scout', 'NPC', 16, 16, '{"str": 10, "dex": 16, "con": 12, "int": 10, "wis": 12, "cha": 10}'),

-- Call of Cthulhu 7e: Players
('act_coc_p1', 'sys_coc', 'Harvey Walters (Journalist)', 'Player', 10, 0, '{"str": 40, "con": 50, "siz": 50, "dex": 60, "app": 65, "edu": 80, "int": 75, "pow": 60}'),
('act_coc_p2', 'sys_coc', 'Joe Diamond (Private Eye)', 'Player', 12, 0, '{"str": 65, "con": 60, "siz": 60, "dex": 70, "app": 50, "edu": 60, "int": 60, "pow": 50}'),
('act_coc_p3', 'sys_coc', 'Wendy Adams (Orphan)', 'Player', 8, 0, '{"str": 30, "con": 45, "siz": 35, "dex": 80, "app": 60, "edu": 40, "int": 70, "pow": 85}'),
-- Call of Cthulhu 7e: NPCs
('act_coc_npc1', 'sys_coc', 'Professor Armitage', 'NPC', 9, 0, '{"str": 35, "con": 40, "siz": 50, "dex": 40, "app": 50, "edu": 95, "int": 85, "pow": 70}'),
('act_coc_npc2', 'sys_coc', 'Jackson Elias', 'NPC', 11, 0, '{"str": 50, "con": 60, "siz": 50, "dex": 65, "app": 55, "edu": 80, "int": 75, "pow": 60}'),
('act_coc_npc3', 'sys_coc', 'Cultist Thug', 'NPC', 12, 0, '{"str": 70, "con": 60, "siz": 65, "dex": 50, "app": 40, "edu": 40, "int": 50, "pow": 40}'),
-- Call of Cthulhu 7e: Monsters
('act_coc_mon1', 'sys_coc', 'Deep One', 'NPC', 15, 2, '{"str": 70, "con": 50, "siz": 65, "dex": 50, "int": 60, "pow": 50}'),
('act_coc_mon2', 'sys_coc', 'Shoggoth', 'NPC', 63, 0, '{"str": 315, "con": 210, "siz": 420, "dex": 25, "int": 35, "pow": 50}'),
('act_coc_mon3', 'sys_coc', 'Mi-Go', 'NPC', 10, 0, '{"str": 50, "con": 50, "siz": 50, "dex": 70, "int": 65, "pow": 65}');

-- ==========================================
-- 3. ENTITIES (Items, Spells, Locations, Weapons, Armor)
-- ==========================================
INSERT INTO entity_entries (id, entity_type_id, name, description, system_id, metadata_blob) VALUES

-- D&D 5e: Items
('ent_5e_it1', 'et_item', 'Potion of Healing', 'A magical red fluid that restores hit points.', 'sys_5e', '{"weight": 0.5, "rarity": "Common"}'),
('ent_5e_it2', 'et_item', 'Bag of Holding', 'A bag that is larger on the inside.', 'sys_5e', '{"weight": 15, "rarity": "Uncommon"}'),
('ent_5e_it3', 'et_item', 'Thieves Tools', 'Tools for picking locks and disarming traps.', 'sys_5e', '{"weight": 1, "cost": "25 gp"}'),
-- D&D 5e: Spells
('ent_5e_sp1', 'et_spell', 'Fireball', 'A bright streak flashes from your finger and explodes.', 'sys_5e', '{"level": 3, "school": "Evocation", "damage": "8d6 fire"}'),
('ent_5e_sp2', 'et_spell', 'Magic Missile', 'Create three glowing darts of magical force.', 'sys_5e', '{"level": 1, "school": "Evocation", "damage": "1d4+1 force per dart"}'),
('ent_5e_sp3', 'et_spell', 'Shield', 'An invisible barrier of magical force appears.', 'sys_5e', '{"level": 1, "school": "Abjuration", "effect": "+5 AC"}'),
-- D&D 5e: Locations
('ent_5e_lc1', 'et_loc', 'Phandalin', 'A frontier mining town.', 'sys_5e', '{"population": 500, "region": "Sword Coast"}'),
('ent_5e_lc2', 'et_loc', 'Waterdeep', 'The City of Splendors.', 'sys_5e', '{"population": 130000, "region": "Sword Coast"}'),
('ent_5e_lc3', 'et_loc', 'Undermountain', 'A massive dungeon complex beneath Waterdeep.', 'sys_5e', '{"type": "Dungeon", "levels": 23}'),
-- D&D 5e: Weapons
('ent_5e_wp1', 'et_weap', 'Longsword', 'A versatile melee weapon.', 'sys_5e', '{"damage": "1d8 slashing", "weight": 3, "properties": ["Versatile"]}'),
('ent_5e_wp2', 'et_weap', 'Longbow', 'A large bow made for hunting and war.', 'sys_5e', '{"damage": "1d8 piercing", "weight": 2, "properties": ["Heavy", "Two-Handed"]}'),
('ent_5e_wp3', 'et_weap', 'Dagger', 'A small, concealable blade.', 'sys_5e', '{"damage": "1d4 piercing", "weight": 1, "properties": ["Finesse", "Light", "Thrown"]}'),
-- D&D 5e: Armor
('ent_5e_ar1', 'et_arm', 'Chain Mail', 'Heavy interlocking metal rings.', 'sys_5e', '{"ac": 16, "weight": 55, "type": "Heavy"}'),
('ent_5e_ar2', 'et_arm', 'Studded Leather', 'Leather armor reinforced with metal rivets.', 'sys_5e', '{"ac": 12, "weight": 13, "type": "Light"}'),
('ent_5e_ar3', 'et_arm', 'Plate Armor', 'Full body suit of interlocking metal plates.', 'sys_5e', '{"ac": 18, "weight": 65, "type": "Heavy"}'),

-- Pathfinder 2e: Items
('ent_pf2e_it1', 'et_item', 'Elixir of Life (Minor)', 'Alchemical healing draught.', 'sys_pf2e', '{"level": 1, "bulk": "L"}'),
('ent_pf2e_it2', 'et_item', 'Wayfinder', 'A magical compass that holds aeon stones.', 'sys_pf2e', '{"level": 2, "bulk": "-", "traits": ["Magical", "Evocation"]}'),
('ent_pf2e_it3', 'et_item', 'Climbing Kit', 'Ropes, pitons, and gear for scaling walls.', 'sys_pf2e', '{"level": 0, "bulk": 1}'),
-- Pathfinder 2e: Spells
('ent_pf2e_sp1', 'et_spell', 'Heal', 'Channel positive energy to heal living creatures.', 'sys_pf2e', '{"level": 1, "traditions": ["Divine", "Primal"]}'),
('ent_pf2e_sp2', 'et_spell', 'Electric Arc', 'An arc of lightning leaps from one target to another.', 'sys_pf2e', '{"level": 0, "traditions": ["Arcane", "Primal"]}'),
('ent_pf2e_sp3', 'et_spell', 'Slow', 'You warp time around a creature.', 'sys_pf2e', '{"level": 3, "traditions": ["Arcane", "Occult"]}'),
-- Pathfinder 2e: Locations
('ent_pf2e_lc1', 'et_loc', 'Absalom', 'The City at the Center of the World.', 'sys_pf2e', '{"type": "Metropolis", "region": "Isle of Kortos"}'),
('ent_pf2e_lc2', 'et_loc', 'Sandpoint', 'A quaint coastal town with a dark history.', 'sys_pf2e', '{"type": "Town", "region": "Varisia"}'),
('ent_pf2e_lc3', 'et_loc', 'Otari', 'A logging town known for its lumber and dungeons.', 'sys_pf2e', '{"type": "Town", "region": "Isle of Kortos"}'),
-- Pathfinder 2e: Weapons
('ent_pf2e_wp1', 'et_weap', 'Bastard Sword', 'A large sword wielded in one or two hands.', 'sys_pf2e', '{"damage": "1d8 S", "bulk": 1, "traits": ["Two-Hand d12"]}'),
('ent_pf2e_wp2', 'et_weap', 'Halberd', 'A polearm combining a spear and an axe.', 'sys_pf2e', '{"damage": "1d10 P", "bulk": 2, "traits": ["Reach", "Versatile S"]}'),
('ent_pf2e_wp3', 'et_weap', 'Clan Dagger', 'A traditional dwarven dagger.', 'sys_pf2e', '{"damage": "1d4 P", "bulk": "L", "traits": ["Agile", "Dwarf", "Parry"]}'),
-- Pathfinder 2e: Armor
('ent_pf2e_ar1', 'et_arm', 'Breastplate', 'Metal plate protecting the torso.', 'sys_pf2e', '{"ac_bonus": 4, "dex_cap": 1, "bulk": 2, "type": "Medium"}'),
('ent_pf2e_ar2', 'et_arm', 'Hide Armor', 'Thick animal hides.', 'sys_pf2e', '{"ac_bonus": 3, "dex_cap": 2, "bulk": 2, "type": "Medium"}'),
('ent_pf2e_ar3', 'et_arm', 'Explorers Clothing', 'Sturdy clothes suitable for adventuring.', 'sys_pf2e', '{"ac_bonus": 0, "dex_cap": 5, "bulk": "L", "type": "Unarmored"}'),

-- Call of Cthulhu 7e: Items
('ent_coc_it1', 'et_item', 'Flashlight', 'Heavy duty electric torch.', 'sys_coc', '{"era": "1920s", "battery_life": "10 hours"}'),
('ent_coc_it2', 'et_item', 'Elder Sign', 'A five-pointed stone amulet to ward off Mythos creatures.', 'sys_coc', '{"mythos_item": true, "sanity_cost": 0}'),
('ent_coc_it3', 'et_item', 'Medical Kit', 'Bandages, morphine, and surgical tools.', 'sys_coc', '{"bonus": "+20 to First Aid"}'),
-- Call of Cthulhu 7e: Spells
('ent_coc_sp1', 'et_spell', 'Create Gate', 'Tear a hole in space to travel vast distances instantly.', 'sys_coc', '{"cost": "Permanent POW", "sanity_loss": "1d6"}'),
('ent_coc_sp2', 'et_spell', 'Shriveling', 'Blasts the target with destructive dark energy.', 'sys_coc', '{"cost": "Magic Points", "sanity_loss": "1/1d6"}'),
('ent_coc_sp3', 'et_spell', 'Contact Deep One', 'Draws a Deep One from the ocean depths to the caster.', 'sys_coc', '{"cost": "3 Magic Points", "cast_time": "1d6 hours"}'),
-- Call of Cthulhu 7e: Locations
('ent_coc_lc1', 'et_loc', 'Arkham', 'A moody, fog-swept town in Massachusetts.', 'sys_coc', '{"type": "City", "established": 1692}'),
('ent_coc_lc2', 'et_loc', 'Miskatonic University', 'Ivy-league university housing dark secrets in its library.', 'sys_coc', '{"type": "Campus", "location": "Arkham"}'),
('ent_coc_lc3', 'et_loc', 'Dunwich', 'An isolated, decrepit village in the Miskatonic Valley.', 'sys_coc', '{"type": "Village", "population": "Sparse"}'),
-- Call of Cthulhu 7e: Weapons
('ent_coc_wp1', 'et_weap', '.38 Revolver', 'A standard issue police revolver.', 'sys_coc', '{"damage": "1d10", "base_range": 15, "malfunction": 100}'),
('ent_coc_wp2', 'et_weap', '12-Gauge Shotgun (Pump)', 'Devastating at close range.', 'sys_coc', '{"damage": "4d6/2d6/1d6", "base_range": 10, "malfunction": 100}'),
('ent_coc_wp3', 'et_weap', 'Switchblade', 'A concealable spring-loaded knife.', 'sys_coc', '{"damage": "1d4+db", "base_range": "Touch", "malfunction": 99}'),
-- Call of Cthulhu 7e: Armor
('ent_coc_ar1', 'et_arm', 'Heavy Leather Jacket', 'A thick biker jacket.', 'sys_coc', '{"armor_value": 1, "era": "1920s"}'),
('ent_coc_ar2', 'et_arm', 'Kevlar Vest', 'Modern bullet-resistant vest.', 'sys_coc', '{"armor_value": 8, "era": "Modern"}'),
('ent_coc_ar3', 'et_arm', 'WW1 Steel Helmet', 'Military surplus head protection.', 'sys_coc', '{"armor_value": 2, "notes": "Protects head only"}');

-- ==========================================
-- 4. LOCATION DATA (Required for Loc entities)
-- ==========================================
INSERT INTO location_data (entity_id, parent_location_id, is_discovered, coordinate_blob) VALUES
('ent_5e_lc1', NULL, 1, '{"x": 100, "y": 250, "map_id": "sword_coast"}'),
('ent_5e_lc2', NULL, 1, '{"x": 150, "y": 100, "map_id": "sword_coast"}'),
('ent_5e_lc3', 'ent_5e_lc2', 0, '{"x": 0, "y": 0, "map_id": "undermountain_l1"}'),

('ent_pf2e_lc1', NULL, 1, '{"x": 500, "y": 500, "map_id": "inner_sea"}'),
('ent_pf2e_lc2', NULL, 1, '{"x": 200, "y": 350, "map_id": "varisia"}'),
('ent_pf2e_lc3', 'ent_pf2e_lc1', 1, '{"x": 480, "y": 490, "map_id": "isle_of_kortos"}'),

('ent_coc_lc1', NULL, 1, '{"state": "Massachusetts", "county": "Essex"}'),
('ent_coc_lc2', 'ent_coc_lc1', 1, '{"street": "West St", "neighborhood": "Campus"}'),
('ent_coc_lc3', NULL, 0, '{"state": "Massachusetts", "region": "Miskatonic Valley"}');
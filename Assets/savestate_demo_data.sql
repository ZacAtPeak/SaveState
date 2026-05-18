-- Explicitly enable foreign keys for your session
PRAGMA foreign_keys = ON;

BEGIN TRANSACTION;

--------------------------------------------------------------------------------
-- 1. CORE ENTITIES (5 PCs, 25 Monsters, 10 NPCs)
--------------------------------------------------------------------------------

INSERT INTO entities (id, name, entity_type, size, alignment, armor_class, armor_desc, hit_points_max, hit_points_current, hit_dice_max, hit_dice_current, hit_dice_type, speed_walk, speed_fly, speed_swim) VALUES
-- PCs (5)
('pc-1', 'Tharivol', 'pc', 'Medium', 'Chaotic Good', 15, 'Studded Leather', 36, 36, 4, 4, 'd8', 30, 0, 0),
('pc-2', 'Morgran', 'pc', 'Medium', 'Lawful Good', 18, 'Chain Mail + Shield', 44, 44, 4, 4, 'd10', 25, 0, 0),
('pc-3', 'Aria', 'pc', 'Medium', 'Neutral', 12, 'No Armor', 26, 26, 4, 4, 'd6', 30, 0, 0),
('pc-4', 'Kallista', 'pc', 'Medium', 'Chaotic Neutral', 16, 'Breastplate', 35, 35, 4, 4, 'd8', 30, 0, 0),
('pc-5', 'Garrick', 'pc', 'Small', 'Neutral Good', 14, 'Leather Armor', 32, 32, 4, 4, 'd8', 25, 0, 0),

-- Monsters (25)
('mon-1', 'Goblin', 'creature', 'Small', 'Neutral Evil', 15, 'Leather Armor, Shield', 7, 7, 2, 2, 'd6', 30, 0, 0),
('mon-2', 'Orc', 'creature', 'Medium', 'Chaotic Evil', 13, 'Hide Armor', 15, 15, 2, 2, 'd8', 30, 0, 0),
('mon-3', 'Skeleton', 'creature', 'Medium', 'Lawful Evil', 13, 'Armor Scraps', 13, 13, 2, 2, 'd8', 30, 0, 0),
('mon-4', 'Zombie', 'creature', 'Medium', 'Neutral Evil', 8, 'Natural', 22, 22, 3, 3, 'd8', 20, 0, 0),
('mon-5', 'Ogre', 'creature', 'Large', 'Chaotic Evil', 11, 'Hide Armor', 59, 59, 7, 7, 'd10', 40, 0, 0),
('mon-6', 'Troll', 'creature', 'Large', 'Chaotic Evil', 15, 'Natural Armor', 84, 84, 8, 8, 'd10', 30, 0, 0),
('mon-7', 'Young Red Dragon', 'creature', 'Large', 'Chaotic Evil', 18, 'Natural Armor', 178, 178, 17, 17, 'd10', 40, 80, 0),
('mon-8', 'Gelatinous Cube', 'creature', 'Large', 'Unaligned', 6, 'Transparent', 84, 84, 8, 8, 'd10', 15, 0, 0),
('mon-9', 'Beholder', 'creature', 'Large', 'Lawful Evil', 18, 'Natural Armor', 180, 180, 19, 19, 'd10', 0, 20, 0),
('mon-10', 'Mind Flayer', 'creature', 'Medium', 'Lawful Evil', 15, 'Breastplate', 71, 71, 13, 13, 'd8', 30, 0, 0),
('mon-11', 'Mimic', 'creature', 'Medium', 'Neutral', 12, 'Natural Armor', 58, 58, 9, 9, 'd8', 15, 0, 0),
('mon-12', 'Owlbear', 'creature', 'Large', 'Unaligned', 13, 'Natural Armor', 59, 59, 7, 7, 'd10', 40, 0, 0),
('mon-13', 'Kobold', 'creature', 'Small', 'Lawful Evil', 12, 'No Armor', 5, 5, 2, 2, 'd6', 30, 0, 0),
('mon-14', 'Basilisk', 'creature', 'Medium', 'Unaligned', 15, 'Natural Armor', 52, 52, 8, 8, 'd8', 20, 0, 0),
('mon-15', 'Manticore', 'creature', 'Large', 'Lawful Evil', 14, 'Natural Armor', 68, 68, 8, 8, 'd10', 30, 50, 0),
('mon-16', 'Chimera', 'creature', 'Large', 'Chaotic Evil', 14, 'Natural Armor', 114, 114, 12, 12, 'd10', 30, 60, 0),
('mon-17', 'Harpy', 'creature', 'Medium', 'Chaotic Evil', 11, 'Natural Armor', 38, 38, 7, 7, 'd8', 20, 40, 0),
('mon-18', 'Medusa', 'creature', 'Medium', 'Lawful Evil', 15, 'Natural Armor', 127, 127, 17, 17, 'd8', 30, 0, 0),
('mon-19', 'Minotaur', 'creature', 'Large', 'Chaotic Evil', 14, 'Natural Armor', 76, 76, 9, 9, 'd10', 40, 0, 0),
('mon-20', 'Wraith', 'creature', 'Medium', 'Neutral Evil', 13, 'Incorporeal', 67, 67, 9, 9, 'd8', 0, 60, 0),
('mon-21', 'Banshee', 'creature', 'Medium', 'Chaotic Evil', 12, 'Incorporeal', 58, 58, 13, 13, 'd8', 0, 40, 0),
('mon-22', 'Lich', 'creature', 'Medium', 'Any Evil Alignment', 17, 'Natural Armor', 135, 135, 18, 18, 'd8', 30, 0, 0),
('mon-23', 'Vampire', 'creature', 'Medium', 'Lawful Evil', 16, 'Natural Armor', 144, 144, 17, 17, 'd8', 30, 0, 0),
('mon-24', 'Werewolf', 'creature', 'Medium', 'Chaotic Evil', 11, 'Natural Armor', 58, 58, 9, 9, 'd8', 30, 0, 0),
('mon-25', 'Treant', 'creature', 'Huge', 'Chaotic Good', 16, 'Natural Armor', 138, 138, 12, 12, 'd12', 30, 0, 0),

-- NPCs (10)
('npc-1', 'Town Guard', 'npc', 'Medium', 'Lawful Neutral', 16, 'Chain Shirt, Shield', 11, 11, 2, 2, 'd8', 30, 0, 0),
('npc-2', 'Bandit', 'npc', 'Medium', 'Chaotic Evil', 12, 'Leather Armor', 11, 11, 2, 2, 'd8', 30, 0, 0),
('npc-3', 'Cultist', 'npc', 'Medium', 'Lawful Evil', 12, 'Leather Armor', 9, 9, 2, 2, 'd8', 30, 0, 0),
('npc-4', 'Archmage', 'npc', 'Medium', 'Any Alignment', 12, '15 with Mage Armor', 99, 99, 18, 18, 'd8', 30, 0, 0),
('npc-5', 'Assassin', 'npc', 'Medium', 'Lawful Evil', 15, 'Studded Leather', 78, 78, 12, 12, 'd8', 30, 0, 0),
('npc-6', 'Spy', 'npc', 'Medium', 'Neutral', 12, 'No Armor', 27, 27, 6, 6, 'd8', 30, 0, 0),
('npc-7', 'Priest', 'npc', 'Medium', 'Any Alignment', 13, 'Chain Shirt', 27, 27, 5, 5, 'd8', 30, 0, 0),
('npc-8', 'Noble', 'npc', 'Medium', 'Any Alignment', 15, 'Breastplate', 9, 9, 2, 2, 'd8', 30, 0, 0),
('npc-9', 'Commoner (Barkeep)', 'npc', 'Medium', 'Neutral Good', 10, 'Clothes', 4, 4, 1, 1, 'd8', 30, 0, 0),
('npc-10', 'Blacksmith', 'npc', 'Medium', 'Lawful Good', 11, 'Leather Apron', 11, 11, 2, 2, 'd8', 30, 0, 0);


--------------------------------------------------------------------------------
-- 2. ENTITY STATS (For all 40 Entities)
--------------------------------------------------------------------------------

INSERT INTO entity_stats (entity_id, strength, dexterity, constitution, intelligence, wisdom, charisma) VALUES
-- PCs
('pc-1', 10, 18, 14, 12, 14, 10),
('pc-2', 18, 10, 16, 10, 12, 14),
('pc-3', 8, 14, 12, 18, 13, 10),
('pc-4', 12, 16, 14, 10, 18, 12),
('pc-5', 10, 16, 12, 12, 10, 18),
-- Monsters
('mon-1', 8, 14, 10, 10, 8, 8),
('mon-2', 16, 12, 16, 7, 11, 10),
('mon-3', 10, 14, 15, 6, 8, 5),
('mon-4', 13, 6, 16, 3, 6, 5),
('mon-5', 19, 8, 16, 5, 7, 7),
('mon-6', 18, 13, 20, 7, 9, 7),
('mon-7', 23, 10, 21, 14, 11, 19),
('mon-8', 14, 3, 20, 1, 6, 1),
('mon-9', 10, 14, 18, 17, 15, 17),
('mon-10', 11, 12, 12, 19, 17, 17),
('mon-11', 17, 12, 15, 5, 13, 8),
('mon-12', 20, 12, 17, 3, 12, 7),
('mon-13', 7, 15, 9, 8, 7, 8),
('mon-14', 16, 8, 15, 2, 8, 7),
('mon-15', 17, 16, 17, 7, 12, 8),
('mon-16', 19, 11, 19, 3, 14, 10),
('mon-17', 12, 13, 12, 7, 10, 13),
('mon-18', 10, 15, 16, 12, 13, 15),
('mon-19', 18, 11, 16, 6, 16, 9),
('mon-20', 6, 16, 16, 12, 14, 15),
('mon-21', 1, 14, 10, 12, 11, 17),
('mon-22', 11, 16, 16, 20, 14, 16),
('mon-23', 18, 18, 18, 17, 15, 18),
('mon-24', 15, 13, 14, 10, 11, 10),
('mon-25', 23, 8, 21, 12, 16, 12),
-- NPCs
('npc-1', 13, 12, 12, 10, 11, 10),
('npc-2', 11, 12, 12, 10, 10, 10),
('npc-3', 11, 12, 10, 10, 11, 10),
('npc-4', 9, 14, 12, 20, 15, 16),
('npc-5', 11, 16, 14, 13, 11, 10),
('npc-6', 10, 15, 10, 12, 14, 16),
('npc-7', 10, 10, 12, 13, 16, 13),
('npc-8', 11, 12, 11, 12, 14, 16),
('npc-9', 10, 10, 10, 10, 10, 10),
('npc-10', 16, 10, 14, 10, 10, 10);


--------------------------------------------------------------------------------
-- 3. TYPE-SPECIFIC PROFILES
--------------------------------------------------------------------------------

-- PC Profiles
INSERT INTO character_profiles (entity_id, player_name, class, subclass, level, xp, background, race, subrace, proficiency_bonus) VALUES
('pc-1', 'Alice', 'Rogue', 'Thief', 4, 2700, 'Urchin', 'Elf', 'Wood Elf', 2),
('pc-2', 'Bob', 'Fighter', 'Champion', 4, 2700, 'Soldier', 'Dwarf', 'Mountain Dwarf', 2),
('pc-3', 'Charlie', 'Wizard', 'School of Evocation', 4, 2700, 'Sage', 'Human', 'Variant', 2),
('pc-4', 'Diana', 'Cleric', 'Life Domain', 4, 2700, 'Acolyte', 'Tiefling', 'Bloodline of Asmodeus', 2),
('pc-5', 'Evan', 'Bard', 'College of Lore', 4, 2700, 'Entertainer', 'Halfling', 'Lightfoot', 2);

-- Creature/NPC Profiles
INSERT INTO creature_profiles (entity_id, challenge_rating, xp_value, creature_type, creature_subtype, is_legendary, legendary_resistances_max, habitat) VALUES
-- Monsters
('mon-1', 0.25, 50, 'Humanoid', 'Goblinoid', 0, 0, 'Forest'),
('mon-2', 0.5, 100, 'Humanoid', 'Orc', 0, 0, 'Mountains'),
('mon-3', 0.25, 50, 'Undead', NULL, 0, 0, 'Dungeon'),
('mon-4', 0.25, 50, 'Undead', NULL, 0, 0, 'Swamp'),
('mon-5', 2.0, 450, 'Giant', NULL, 0, 0, 'Hills'),
('mon-6', 5.0, 1800, 'Giant', NULL, 0, 0, 'Swamp'),
('mon-7', 10.0, 5900, 'Dragon', NULL, 0, 0, 'Mountains'),
('mon-8', 2.0, 450, 'Ooze', NULL, 0, 0, 'Underdark'),
('mon-9', 13.0, 10000, 'Aberration', NULL, 1, 3, 'Underdark'),
('mon-10', 7.0, 2900, 'Aberration', NULL, 0, 0, 'Underdark'),
('mon-11', 2.0, 450, 'Monstrosity', 'Shapechanger', 0, 0, 'Dungeon'),
('mon-12', 3.0, 700, 'Monstrosity', NULL, 0, 0, 'Forest'),
('mon-13', 0.125, 25, 'Humanoid', 'Kobold', 0, 0, 'Underdark'),
('mon-14', 3.0, 700, 'Monstrosity', NULL, 0, 0, 'Desert'),
('mon-15', 3.0, 700, 'Monstrosity', NULL, 0, 0, 'Mountains'),
('mon-16', 6.0, 2300, 'Monstrosity', NULL, 0, 0, 'Mountains'),
('mon-17', 1.0, 200, 'Monstrosity', NULL, 0, 0, 'Coastal'),
('mon-18', 6.0, 2300, 'Monstrosity', NULL, 0, 0, 'Dungeon'),
('mon-19', 3.0, 700, 'Monstrosity', NULL, 0, 0, 'Dungeon'),
('mon-20', 5.0, 1800, 'Undead', NULL, 0, 0, 'Dungeon'),
('mon-21', 4.0, 1100, 'Undead', NULL, 0, 0, 'Swamp'),
('mon-22', 21.0, 33000, 'Undead', NULL, 1, 3, 'Dungeon'),
('mon-23', 13.0, 10000, 'Undead', 'Shapechanger', 1, 3, 'Urban'),
('mon-24', 3.0, 700, 'Humanoid', 'Human, Shapechanger', 0, 0, 'Forest'),
('mon-25', 9.0, 5000, 'Plant', NULL, 0, 0, 'Forest'),

-- NPCs
('npc-1', 0.125, 25, 'Humanoid', 'Any Race', 0, 0, 'Urban'),
('npc-2', 0.125, 25, 'Humanoid', 'Any Race', 0, 0, 'Forest'),
('npc-3', 0.125, 25, 'Humanoid', 'Any Race', 0, 0, 'Urban'),
('npc-4', 12.0, 8400, 'Humanoid', 'Any Race', 0, 0, 'Urban'),
('npc-5', 8.0, 3900, 'Humanoid', 'Any Race', 0, 0, 'Urban'),
('npc-6', 1.0, 200, 'Humanoid', 'Any Race', 0, 0, 'Urban'),
('npc-7', 2.0, 450, 'Humanoid', 'Any Race', 0, 0, 'Urban'),
('npc-8', 0.125, 25, 'Humanoid', 'Any Race', 0, 0, 'Urban'),
('npc-9', 0.0, 10, 'Humanoid', 'Any Race', 0, 0, 'Urban'),
('npc-10', 0.125, 25, 'Humanoid', 'Any Race', 0, 0, 'Urban');


--------------------------------------------------------------------------------
-- 4. SAMPLE ACTIONS & FEATURES
--------------------------------------------------------------------------------

INSERT INTO action_library (id, name, action_type, description, is_attack, attack_bonus, damage_dice, damage_type) VALUES
('act-1', 'Scimitar', 'action', 'Melee Weapon Attack.', 1, 4, '1d6+2', 'Slashing'),
('act-2', 'Shortbow', 'action', 'Ranged Weapon Attack.', 1, 4, '1d6+2', 'Piercing'),
('act-3', 'Bite (Dragon)', 'action', 'Melee Weapon Attack.', 1, 10, '2d10+6', 'Piercing'),
('act-4', 'Fire Breath', 'action', 'The dragon exhales fire in a 30-foot cone.', 0, NULL, '16d6', 'Fire'),
('act-5', 'Multiattack', 'action', 'The creature makes multiple melee attacks.', 0, NULL, NULL, NULL);

-- Link some actions to creatures
INSERT INTO entity_actions (entity_id, action_id, uses_per_day, uses_current, recharge_formula) VALUES
('mon-1', 'act-1', NULL, NULL, NULL),
('mon-1', 'act-2', NULL, NULL, NULL),
('mon-7', 'act-3', NULL, NULL, NULL),
('mon-7', 'act-4', NULL, NULL, 'Recharge 5-6'),
('mon-7', 'act-5', NULL, NULL, NULL);


--------------------------------------------------------------------------------
-- 5. SAMPLE SPELLS & SPELLCASTING
--------------------------------------------------------------------------------

INSERT INTO spell_library (id, name, level, school, casting_time, range, components, duration, is_concentration, is_ritual, description) VALUES
('spl-1', 'Fireball', 3, 'Evocation', '1 action', '150 feet', 'V, S, M', 'Instantaneous', 0, 0, 'A bright streak flashes to a point and blossoms with a low roar into an explosion of flame.'),
('spl-2', 'Mage Armor', 1, 'Abjuration', '1 action', 'Touch', 'V, S, M', '8 hours', 0, 0, 'You touch a willing creature who isn''t wearing armor, and a protective magical force surrounds it until the spell ends.'),
('spl-3', 'Cure Wounds', 1, 'Evocation', '1 action', 'Touch', 'V, S', 'Instantaneous', 0, 0, 'A creature you touch regains a number of hit points equal to 1d8 + your spellcasting ability modifier.');

-- Add Spellcasting Stats for the Wizard PC (pc-3) and Archmage NPC (npc-4)
INSERT INTO entity_spellcasting (entity_id, spellcasting_ability, slots_lvl_1_max, slots_lvl_1_curr, slots_lvl_2_max, slots_lvl_2_curr, slots_lvl_3_max, slots_lvl_3_curr) VALUES
('pc-3', 'INT', 4, 4, 3, 3, 0, 0),
('npc-4', 'INT', 4, 4, 3, 3, 3, 3);

-- Link Known Spells
INSERT INTO entity_spells (entity_id, spell_id, is_prepared) VALUES
('pc-3', 'spl-1', 1),
('pc-3', 'spl-2', 1),
('npc-4', 'spl-1', 1),
('npc-4', 'spl-2', 1);


--------------------------------------------------------------------------------
-- 6. SAMPLE DEFENSES & CONDITIONS
--------------------------------------------------------------------------------

INSERT INTO entity_damage_modifiers (entity_id, damage_type, modifier_type) VALUES
('mon-3', 'Poison', 'immunity'),
('mon-3', 'Bludgeoning', 'vulnerability'),
('mon-7', 'Fire', 'immunity'),
('mon-8', 'Acid', 'immunity'),
('mon-10', 'Psychic', 'resistance');

INSERT INTO entity_conditions (entity_id, condition_name) VALUES
('mon-4', 'Prone');

INSERT INTO skills (id, name, associated_ability_score, description) values
('acr', 'Acrobatics', 'dexterity', 'Acrobatics is a skill used when trying to maintain balance or general nimbleness. Examples include walking across a thin or rickety bridge, running along a slippery surface, or moving out of the way of a projectile. It can also be used to break free of a grapple.'),
('ani', 'Animal Handling', 'wisdom', 'When dealing with animals, Animal Handling is called upon to determine how well that goes. Situations that might call for it range from calming a spooked horse or agitated wild animal, or petting a creature you find. It may also be used when trying to figure out an animal''s intentions and instincts.'),
('arc', 'Arcana', 'intelligence', 'Arcana is used for recalling magical lore. This can include but is not limited to deciphering spells or summoning circles, determining magic items, knowing the planes of existence and its inhabitants, reading eldritch symbols, and remembering or understanding magic rites or rituals.'),
('ath', 'Athletics', 'strength', 'Athletics checks are used when determining feats of endurance, usually when difficulty is encountered while climbing, jumping, or swimming. Examples include trying to scale a steep or slippery cliff, trying to make an unusually long jump, and resisting the pull of tides or monsters while swimming. It''s also used when grappling a creature, and can be used to break free of a grapple.'),
('dec', 'Deception', 'charisma', 'Deception is used when lying. This can be verbally or not. If you''re attempting to convince others of something untrue, Deception is called for. Using disguises, hiding the truth of situations, conning someone, and other situations of ambiguous truth all use Deception.'),
('his', 'History', 'intelligence', 'Much like the name suggests, History is used when recalling lore of the past. This can include wars big or small, legendary people, ancient kingdoms or lost civilizations, and miscellaneous historical events. It''s also occasionally used when the name of an obscure land is brought up and determining if anyone knows of it.'),
('ins', 'Insight', 'wisdom', 'Insight is a famous and frequently used skill. Primarily, it''s used to determine if someone is being truthful or not. It can also be used to glean how suspicious someone may be, if they''re hiding something even if not lying, and any other situation which calls for studying a creature''s behaviors and what can be learned from it.'),
('int', 'Intimidation', 'charisma', 'When trying to scare someone through threats, Intimidation is used. This can be through words alone, threatening to do something violent; or pulling out a dagger in a silent show. Intimidation can be applied to multiple situations, such as trying to get information out of a prisoner, convincing someone to reconsider their decisions, or showing off your lack of tolerance for nonsense.'),
('inv', 'Investigation', 'intelligence', 'Not to be confused with Perception, Investigation determines what you''re able to deduce about your surroundings or what you''re studying. You might be able to figure out what weapon killed someone, locations of hidden doors or objects, weak points in structure, or the important bit of knowledge in a large book of text.'),
('med', 'Medicine', 'wisdom', 'Medicine checks are mostly used to stabilize a dying creature. The DC to do so is 10. It can also be used to diagnose illnesses and occasionally used when determining how something died.'),
('nat', 'Nature', 'intelligence', 'Nature checks are used when remembering lore about nature. This includes terrain, plants and which might be safe to eat, animals and their behaviors, the weather, and natural cycles.'),
('prc', 'Perception', 'wisdom', 'Perception is among the most well-known skills, and is frequently mistakenly used in place of investigation. It''s used to determine how much a character notices of their surroundings. This can be intentional or not. It relies on basic senses rather than contemplative thought or deductions. Situations that might call for perception include standing guard, eavesdropping, and detecting hidden creatures or subtle sights.'),
('prf', 'Performance', 'charisma', 'Performance checks are used when entertaining audiences. This can range from playing music to telling stories. It can, on occasion, also replace Deception or Intimidation if the act is dramatic enough. It determines how well a character can exaggerate to impress others.'),
('prs', 'Persuasion', 'charisma', 'Persuasion is used when trying to convince others your way. It is distinct from Deception and Intimidation because it''s not through lies or threats, but convincing arguments, tact, social graces, and good nature. It''s used when acting in good, honest faith. Situations that call for persuasion include convincing guards to let you speak to a noble, settling disputes between warring groups, or inspiring crowds into action.'),
('rel', 'Religion', 'intelligence', 'Religion is used when remembering religious lore, such as deities of your pantheon or not, rites and prayers, holy symbols, religious hierarchies and organizations, and even the practices of cults.'),
('slh', 'Sleight of Hand', 'dexterity', 'Commonly associated with thievery, Sleight of Hand is used in situations that requires careful hand work. While attempting to pickpocket someone does require it, other examples include hiding an object on your person or planting something on someone else. It may also be called upon when doing activities that require fine movements, such as carving.'),
('ste', 'Stealth', 'dexterity', 'Stealth checks are among the most common. They are used to determine how sneaky a character is being. Situations that use Stealth include slipping past guards, escaping situations unnoticed, hiding from enemies, or sneaking up on someone for a surprise.'),
('sur', 'Survival', 'wisdom', 'Survival is a skill used for dealing with the wilds. Situations that can call for Survival include tracking footprints, foraging for food or water, navigating wilderness, identifying signs of creatures nearby or living in the area, predicting the weather, and avoiding hazards such as pits or quicksand.')

insert into abilities (id, name, description)
values
('str', 'strength', 'Physical power'),
('dex', 'Dexterity', 'Agility'),
('con', 'Constitution', 'endurance'),
('int', 'Intelligence', 'Reasoning and memory'),
('wis', 'Wisdom', 'Perception and insight'),
('cha', 'Charisma', 'Force of personality')

INSERT INTO entity_skills (entity_id, skill_id, is_proficient, is_expert)
values
('pc-1', 'slh', 1, 1),
('pc-1', 'prs', 1, 0),
('pc-2', 'arc', 1, 0)


-- ---------------------------------------------------------
-- 1. INSERT CLASSES
-- Descriptions directly referenced from dungeonsanddragonsfan.com
-- ---------------------------------------------------------

INSERT INTO classes (id, name, hit_die, primary_ability, saving_throw_1, saving_throw_2, description) VALUES
(
    'artificer',
    'Artificer',
    'd8',
    'INT',
    'CON',
    'INT',
    'DnD 5e Artificers are masters of magical invention, merging technology with arcane power. As an Artificer, you can craft magical objects and mechanical companions and provide support to your party through magical gear and enhancements.'
),
(
    'barbarian',
    'Barbarian',
    'd12',
    'STR',
    'STR',
    'CON',
    'DnD 5e Barbarians are fierce warriors who excel in combat through sheer rage and physical prowess. As a Barbarian, you can both deal and absorb an incredible amount of damage, making you a formidable tank on the battlefield.'
),
(
    'druid',
    'Druid',
    'd8',
    'WIS',
    'INT',
    'WIS',
    'DnD 5e Druids draw their power from nature and are able to harness its raw energy to command the elements, summon beasts and even change into an animal form known as a Wild Shape.'
),
(
    'fighter',
    'Fighter',
    'd10',
    'STR or DEX',
    'STR',
    'CON',
    'DnD 5e Fighters are masters of martial combat, proficient with a wide variety of weapons and armor.'
),
(
    'rogue',
    'Rogue',
    'd8',
    'DEX or INT',
    'DEX',
    'INT',
    'Rogues.'
);

-- ---------------------------------------------------------
-- 2. INSERT SUBCLASSES
-- Names and descriptions directly referenced from dungeonsanddragonsfan.com
-- ---------------------------------------------------------

-- ARTIFICER SUBCLASSES
INSERT INTO subclasses (id, class_id, name, description) VALUES
('artificer_alchemist', 'artificer', 'Alchemist', 'You specialize in experimental potion-making, using your alchemical mastery to craft powerful elixirs. These potions can heal, bolster defenses or provide various enhancements to you and your allies.'),
('artificer_armorer', 'artificer', 'Armorer', 'You channel your expertise into crafting magical armor, transforming it into a powerful exosuit. This suit enhances your combat abilities, offers exceptional protection and can be customized with various magical effects.'),
('artificer_artillerist', 'artificer', 'Artillerist', 'You focus on crafting and using magical cannons and other artillery. By summoning arcane turrets, you can deal significant damage from a distance or provide defensive support to your allies.'),
('artificer_battle_smith', 'artificer', 'Battle Smith', 'You forge a strong bond with a clockwork animal construct that you create and command in battle. Along with some minor combat abilities, you also gain the ability to repair and reinforce both your construct and other equipment.');

-- BARBARIAN SUBCLASSES (Paths)
INSERT INTO subclasses (id, class_id, name, description) VALUES
('barbarian_ancestral_guardian', 'barbarian', 'Path of the Ancestral Guardian', 'You invoke the spirits of your ancestors to protect yourself and your allies in battle. These ancestral spirits can shield your allies and deal extensive damage to your enemies.'),
('barbarian_battlerager', 'barbarian', 'Path of the Battlerager', 'Available only for dwarves, you harness your rage into a reckless and frenzied fighting style, using unique spiked armor as a weapon.'),
('barbarian_beast', 'barbarian', 'Path of the Beast', 'You channel the power of wild creatures, transforming physical aspects of your body to unleash devastating attacks. This includes sprouting claws, fangs or even a tail.'),
('barbarian_berserker', 'barbarian', 'Path of the Berserker', 'You give in to the fury of combat, allowing you to fight with a primal ferocity. While in the grips of your battle rage, you can make extra attacks and ignore effects that would otherwise cause damage or slow you down.'),
('barbarian_giant', 'barbarian', 'Path of the Giant', 'You draw on the might of legendary giants, gaining their strength and abilities. This path allows you to embody different aspects of giantkind, such as frost or fire.'),
('barbarian_storm_herald', 'barbarian', 'Path of the Storm Herald', 'You tap into the power of the storm, generating a magical aura that affects everything around you. Depending on the environment you choose—tundra, desert, or sea—your aura can chill, scorch or lash your enemies.'),
('barbarian_wild_heart', 'barbarian', 'Path of the Wild Heart', 'You forge a spiritual bond with a totem animal spirit, emulating the aspects of that being. Each animal spirit—be it bear, eagle, elk, tiger or wolf—provides unique strengths and supernatural abilities.'),
('barbarian_wild_magic', 'barbarian', 'Path of Wild Magic', 'Your rage taps into the chaotic force of wild magic, resulting in unpredictable arcane side-effects. This path is unique in that that can be both incredibly powerful but also relies heavily on random dice roles.'),
('barbarian_zealot', 'barbarian', 'Path of the Zealot', 'You are driven by a divine fury, bolstered by the power of the gods. This path not only increases your combat prowess with divine energy but also makes you nearly impossible to kill while raging.'),
('barbarian_world_tree', 'barbarian', 'Path of the World Tree', 'You draw your power from the World Tree whose vast, endless branches touch all of the realms of the multiverse. This power allows you to be more resilient in combat, heal your allies and teleport across the battlefield.');

-- DRUID SUBCLASSES (Circles)
INSERT INTO subclasses (id, class_id, name, description) VALUES
('druid_dreams', 'druid', 'Circle of Dreams', 'You are a guardian of the border between the Feywild and the mortal world, tapping into the magic of nature to heal and aid your allies.'),
('druid_land', 'druid', 'Circle of the Land', 'You have a deep connection to a specific natural terrain, such as forests, mountains or coastlines. This subclass enhances your magical abilities.'),
('druid_moon', 'druid', 'Circle of the Moon', 'You specialize in transforming into more powerful animals and even elemental forms. This subclass focuses on improving your combat effectiveness in beast form.'),
('druid_shepherd', 'druid', 'Circle of the Shepherd', 'You are a protector of nature''s creatures, communicating with and nurturing them. This subclass gives you powers to summon and strengthen spirit totems.'),
('druid_spores', 'druid', 'Circle of Spores', 'You harness the life and decay aspects of nature, using fungal spores to fuel your magic. This subclass allows you to animate dead plants and creatures, deal necrotic damage to enemies and gain temporary health boosts.'),
('druid_stars', 'druid', 'Circle of Stars', 'You draw on the mystic power of the stars and constellations, using them to guide and protect. This subclass provides abilities to transform starlight into protective and restorative magic.'),
('druid_wildfire', 'druid', 'Circle of Wildfire', 'You believe in renewal through fire, using flames to clear decay and make way for new life. This subclass lets you summon a wildfire spirit, cast fire-related spells and heal or bolster your allies.'),
('druid_sea', 'druid', 'Circle of the Sea', 'You tap into the power of the sea to unleash powerful elemental magic that can harm enemies, protect allies and allow you to traverse beneath the waves themselves for extended periods of time.');

-- FIGHTER SUBCLASSES (Martial Archetypes)
INSERT INTO subclasses (id, class_id, name, description) VALUES
('fighter_battle_master', 'fighter', 'Battle Master', 'You are a master of combat techniques and tactics, using maneuvers to outsmart and defeat your enemies. This subclass grants you abilities to enhance your attacks, control the battlefield and provide tactical advantages.'),
('fighter_cavalier', 'fighter', 'Cavalier', 'You excel in mounted combat and are dedicated to protecting others, especially when riding your steed.'),
('fighter_champion', 'fighter', 'Champion', 'You focus on refining your martial prowess, becoming a formidable warrior. This subclass enhances your ability to land critical hits more often and increases your physical capabilities.'),
('fighter_echo_knight', 'fighter', 'Echo Knight', 'You manipulate time and space to summon an echo of yourself from a parallel dimension. This subclass allows you to fight from multiple positions.'),
('fighter_eldritch_knight', 'fighter', 'Eldritch Knight', 'You blend martial prowess with magical ability, casting spells while also engaging in hand-to-hand combat.'),
('fighter_psi_warrior', 'fighter', 'Psi Warrior', 'You harness the power of your mind to augment your fighting capabilities. This subclass provides you with psionic energy that you can use to shield yourself, move objects, or strike enemies.'),
('fighter_purple_dragon_knight', 'fighter', 'Purple Dragon Knight', 'You inspire and lead others in battle, focusing on teamwork and camaraderie. This subclass allows you to extend the benefits of your fighting spirit to your allies.'),
('fighter_rune_knight', 'fighter', 'Rune Knight', 'You use mystical runes to enhance your combat skills and manipulate various magical effects. This subclass allows you to inscribe runes onto your equipment.'),
('fighter_samurai', 'fighter', 'Samurai', 'You are a warrior who combines fierce determination with meticulous skill. This subclass provides you with bonuses to accuracy, the ability to withstand damage, and a resolute will.');

INSERT INTO subclasses (id, class_id, name, description) VALUES


insert into character_classes
(entity_id, class_id, subclass_id, class_level, is_primary)
values
('pc-1', 'artificer', 'artificer_armorer', 5, 1),
('pc-2', 'fighter', 'fighter_champion', 5, 1),
('pc-3', 'druid', 'druid_spores', 3, 1),
('pc-3', 'barbarian', 'barbarian_wild_magic', 2, 0)



COMMIT;

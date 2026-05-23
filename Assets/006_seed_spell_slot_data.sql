-- Spell Slot Tracking Seed Data
-- Sets caster types and seeds class_level_progression for all 13 classes × levels 1-20

BEGIN TRANSACTION;

--------------------------------------------------------------------------------
-- 2.1 Set classes.spellcaster_type for all 13 classes
-- full: bard, cleric, druid, sorcerer, wizard
-- half: paladin, ranger
-- half_up: artificer (rounds up in multiclass formula)
-- pact: warlock
-- none: barbarian, fighter, monk, rogue
--------------------------------------------------------------------------------
UPDATE classes SET spellcaster_type = 'full'    WHERE id IN ('bard', 'cleric', 'druid', 'sorcerer', 'wizard');
UPDATE classes SET spellcaster_type = 'half'    WHERE id IN ('paladin', 'ranger');
UPDATE classes SET spellcaster_type = 'half_up' WHERE id = 'artificer';
UPDATE classes SET spellcaster_type = 'pact'    WHERE id = 'warlock';
UPDATE classes SET spellcaster_type = 'none'    WHERE id IN ('barbarian', 'fighter', 'monk', 'rogue');

-- 2.2 Set subclasses.spellcaster_type for Eldritch Knight and Arcane Trickster
UPDATE subclasses SET spellcaster_type = 'third' WHERE id = 'fighter_eldritch_knight';
UPDATE subclasses SET spellcaster_type = 'third' WHERE id = 'rogue_arcane_trickster';

--------------------------------------------------------------------------------
-- 2.3 Seed class_level_progression — all 13 classes × levels 1-20
-- Full casters use the multiclass slot table
-- Half casters use the paladin/ranger table
-- Third casters use the EK/AT table
-- Warlocks use the pact magic table
-- Non-casters get all zeros
--------------------------------------------------------------------------------

-- Full caster progression (bard, cleric, druid, sorcerer, wizard)
-- Matches the PHB multiclass spellcaster table
INSERT OR IGNORE INTO class_level_progression (class_id, level, proficiency_bonus, slots_lvl_1, slots_lvl_2, slots_lvl_3, slots_lvl_4, slots_lvl_5, slots_lvl_6, slots_lvl_7, slots_lvl_8, slots_lvl_9) VALUES
('bard', 1, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0),
('bard', 2, 2, 3, 0, 0, 0, 0, 0, 0, 0, 0),
('bard', 3, 2, 4, 2, 0, 0, 0, 0, 0, 0, 0),
('bard', 4, 2, 4, 3, 0, 0, 0, 0, 0, 0, 0),
('bard', 5, 3, 4, 3, 2, 0, 0, 0, 0, 0, 0),
('bard', 6, 3, 4, 3, 3, 0, 0, 0, 0, 0, 0),
('bard', 7, 3, 4, 3, 3, 1, 0, 0, 0, 0, 0),
('bard', 8, 3, 4, 3, 3, 2, 0, 0, 0, 0, 0),
('bard', 9, 4, 4, 3, 3, 3, 1, 0, 0, 0, 0),
('bard', 10, 4, 4, 3, 3, 3, 2, 0, 0, 0, 0),
('bard', 11, 4, 4, 3, 3, 3, 2, 1, 0, 0, 0),
('bard', 12, 4, 4, 3, 3, 3, 2, 1, 0, 0, 0),
('bard', 13, 5, 4, 3, 3, 3, 2, 1, 1, 0, 0),
('bard', 14, 5, 4, 3, 3, 3, 2, 1, 1, 0, 0),
('bard', 15, 5, 4, 3, 3, 3, 2, 1, 1, 1, 0),
('bard', 16, 5, 4, 3, 3, 3, 2, 1, 1, 1, 0),
('bard', 17, 6, 4, 3, 3, 3, 2, 1, 1, 1, 1),
('bard', 18, 6, 4, 3, 3, 3, 3, 1, 1, 1, 1),
('bard', 19, 6, 4, 3, 3, 3, 3, 2, 1, 1, 1),
('bard', 20, 6, 4, 3, 3, 3, 3, 2, 2, 1, 1);

INSERT OR IGNORE INTO class_level_progression (class_id, level, proficiency_bonus, slots_lvl_1, slots_lvl_2, slots_lvl_3, slots_lvl_4, slots_lvl_5, slots_lvl_6, slots_lvl_7, slots_lvl_8, slots_lvl_9) VALUES
('cleric', 1, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0),
('cleric', 2, 2, 3, 0, 0, 0, 0, 0, 0, 0, 0),
('cleric', 3, 2, 4, 2, 0, 0, 0, 0, 0, 0, 0),
('cleric', 4, 2, 4, 3, 0, 0, 0, 0, 0, 0, 0),
('cleric', 5, 3, 4, 3, 2, 0, 0, 0, 0, 0, 0),
('cleric', 6, 3, 4, 3, 3, 0, 0, 0, 0, 0, 0),
('cleric', 7, 3, 4, 3, 3, 1, 0, 0, 0, 0, 0),
('cleric', 8, 3, 4, 3, 3, 2, 0, 0, 0, 0, 0),
('cleric', 9, 4, 4, 3, 3, 3, 1, 0, 0, 0, 0),
('cleric', 10, 4, 4, 3, 3, 3, 2, 0, 0, 0, 0),
('cleric', 11, 4, 4, 3, 3, 3, 2, 1, 0, 0, 0),
('cleric', 12, 4, 4, 3, 3, 3, 2, 1, 0, 0, 0),
('cleric', 13, 5, 4, 3, 3, 3, 2, 1, 1, 0, 0),
('cleric', 14, 5, 4, 3, 3, 3, 2, 1, 1, 0, 0),
('cleric', 15, 5, 4, 3, 3, 3, 2, 1, 1, 1, 0),
('cleric', 16, 5, 4, 3, 3, 3, 2, 1, 1, 1, 0),
('cleric', 17, 6, 4, 3, 3, 3, 2, 1, 1, 1, 1),
('cleric', 18, 6, 4, 3, 3, 3, 3, 1, 1, 1, 1),
('cleric', 19, 6, 4, 3, 3, 3, 3, 2, 1, 1, 1),
('cleric', 20, 6, 4, 3, 3, 3, 3, 2, 2, 1, 1);

INSERT OR IGNORE INTO class_level_progression (class_id, level, proficiency_bonus, slots_lvl_1, slots_lvl_2, slots_lvl_3, slots_lvl_4, slots_lvl_5, slots_lvl_6, slots_lvl_7, slots_lvl_8, slots_lvl_9) VALUES
('druid', 1, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0),
('druid', 2, 2, 3, 0, 0, 0, 0, 0, 0, 0, 0),
('druid', 3, 2, 4, 2, 0, 0, 0, 0, 0, 0, 0),
('druid', 4, 2, 4, 3, 0, 0, 0, 0, 0, 0, 0),
('druid', 5, 3, 4, 3, 2, 0, 0, 0, 0, 0, 0),
('druid', 6, 3, 4, 3, 3, 0, 0, 0, 0, 0, 0),
('druid', 7, 3, 4, 3, 3, 1, 0, 0, 0, 0, 0),
('druid', 8, 3, 4, 3, 3, 2, 0, 0, 0, 0, 0),
('druid', 9, 4, 4, 3, 3, 3, 1, 0, 0, 0, 0),
('druid', 10, 4, 4, 3, 3, 3, 2, 0, 0, 0, 0),
('druid', 11, 4, 4, 3, 3, 3, 2, 1, 0, 0, 0),
('druid', 12, 4, 4, 3, 3, 3, 2, 1, 0, 0, 0),
('druid', 13, 5, 4, 3, 3, 3, 2, 1, 1, 0, 0),
('druid', 14, 5, 4, 3, 3, 3, 2, 1, 1, 0, 0),
('druid', 15, 5, 4, 3, 3, 3, 2, 1, 1, 1, 0),
('druid', 16, 5, 4, 3, 3, 3, 2, 1, 1, 1, 0),
('druid', 17, 6, 4, 3, 3, 3, 2, 1, 1, 1, 1),
('druid', 18, 6, 4, 3, 3, 3, 3, 1, 1, 1, 1),
('druid', 19, 6, 4, 3, 3, 3, 3, 2, 1, 1, 1),
('druid', 20, 6, 4, 3, 3, 3, 3, 2, 2, 1, 1);

INSERT OR IGNORE INTO class_level_progression (class_id, level, proficiency_bonus, slots_lvl_1, slots_lvl_2, slots_lvl_3, slots_lvl_4, slots_lvl_5, slots_lvl_6, slots_lvl_7, slots_lvl_8, slots_lvl_9) VALUES
('sorcerer', 1, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0),
('sorcerer', 2, 2, 3, 0, 0, 0, 0, 0, 0, 0, 0),
('sorcerer', 3, 2, 4, 2, 0, 0, 0, 0, 0, 0, 0),
('sorcerer', 4, 2, 4, 3, 0, 0, 0, 0, 0, 0, 0),
('sorcerer', 5, 3, 4, 3, 2, 0, 0, 0, 0, 0, 0),
('sorcerer', 6, 3, 4, 3, 3, 0, 0, 0, 0, 0, 0),
('sorcerer', 7, 3, 4, 3, 3, 1, 0, 0, 0, 0, 0),
('sorcerer', 8, 3, 4, 3, 3, 2, 0, 0, 0, 0, 0),
('sorcerer', 9, 4, 4, 3, 3, 3, 1, 0, 0, 0, 0),
('sorcerer', 10, 4, 4, 3, 3, 3, 2, 0, 0, 0, 0),
('sorcerer', 11, 4, 4, 3, 3, 3, 2, 1, 0, 0, 0),
('sorcerer', 12, 4, 4, 3, 3, 3, 2, 1, 0, 0, 0),
('sorcerer', 13, 5, 4, 3, 3, 3, 2, 1, 1, 0, 0),
('sorcerer', 14, 5, 4, 3, 3, 3, 2, 1, 1, 0, 0),
('sorcerer', 15, 5, 4, 3, 3, 3, 2, 1, 1, 1, 0),
('sorcerer', 16, 5, 4, 3, 3, 3, 2, 1, 1, 1, 0),
('sorcerer', 17, 6, 4, 3, 3, 3, 2, 1, 1, 1, 1),
('sorcerer', 18, 6, 4, 3, 3, 3, 3, 1, 1, 1, 1),
('sorcerer', 19, 6, 4, 3, 3, 3, 3, 2, 1, 1, 1),
('sorcerer', 20, 6, 4, 3, 3, 3, 3, 2, 2, 1, 1);

INSERT OR IGNORE INTO class_level_progression (class_id, level, proficiency_bonus, slots_lvl_1, slots_lvl_2, slots_lvl_3, slots_lvl_4, slots_lvl_5, slots_lvl_6, slots_lvl_7, slots_lvl_8, slots_lvl_9) VALUES
('wizard', 1, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0),
('wizard', 2, 2, 3, 0, 0, 0, 0, 0, 0, 0, 0),
('wizard', 3, 2, 4, 2, 0, 0, 0, 0, 0, 0, 0),
('wizard', 4, 2, 4, 3, 0, 0, 0, 0, 0, 0, 0),
('wizard', 5, 3, 4, 3, 2, 0, 0, 0, 0, 0, 0),
('wizard', 6, 3, 4, 3, 3, 0, 0, 0, 0, 0, 0),
('wizard', 7, 3, 4, 3, 3, 1, 0, 0, 0, 0, 0),
('wizard', 8, 3, 4, 3, 3, 2, 0, 0, 0, 0, 0),
('wizard', 9, 4, 4, 3, 3, 3, 1, 0, 0, 0, 0),
('wizard', 10, 4, 4, 3, 3, 3, 2, 0, 0, 0, 0),
('wizard', 11, 4, 4, 3, 3, 3, 2, 1, 0, 0, 0),
('wizard', 12, 4, 4, 3, 3, 3, 2, 1, 0, 0, 0),
('wizard', 13, 5, 4, 3, 3, 3, 2, 1, 1, 0, 0),
('wizard', 14, 5, 4, 3, 3, 3, 2, 1, 1, 0, 0),
('wizard', 15, 5, 4, 3, 3, 3, 2, 1, 1, 1, 0),
('wizard', 16, 5, 4, 3, 3, 3, 2, 1, 1, 1, 0),
('wizard', 17, 6, 4, 3, 3, 3, 2, 1, 1, 1, 1),
('wizard', 18, 6, 4, 3, 3, 3, 3, 1, 1, 1, 1),
('wizard', 19, 6, 4, 3, 3, 3, 3, 2, 1, 1, 1),
('wizard', 20, 6, 4, 3, 3, 3, 3, 2, 2, 1, 1);

-- Half caster progression (paladin, ranger)
INSERT OR IGNORE INTO class_level_progression (class_id, level, proficiency_bonus, slots_lvl_1, slots_lvl_2, slots_lvl_3, slots_lvl_4, slots_lvl_5) VALUES
('paladin', 1, 2, 0, 0, 0, 0, 0),
('paladin', 2, 2, 2, 0, 0, 0, 0),
('paladin', 3, 2, 3, 0, 0, 0, 0),
('paladin', 4, 2, 3, 0, 0, 0, 0),
('paladin', 5, 3, 4, 2, 0, 0, 0),
('paladin', 6, 3, 4, 2, 0, 0, 0),
('paladin', 7, 3, 4, 3, 0, 0, 0),
('paladin', 8, 3, 4, 3, 0, 0, 0),
('paladin', 9, 4, 4, 3, 2, 0, 0),
('paladin', 10, 4, 4, 3, 2, 0, 0),
('paladin', 11, 4, 4, 3, 3, 0, 0),
('paladin', 12, 4, 4, 3, 3, 0, 0),
('paladin', 13, 5, 4, 3, 3, 1, 0),
('paladin', 14, 5, 4, 3, 3, 1, 0),
('paladin', 15, 5, 4, 3, 3, 2, 0),
('paladin', 16, 5, 4, 3, 3, 2, 0),
('paladin', 17, 6, 4, 3, 3, 3, 1),
('paladin', 18, 6, 4, 3, 3, 3, 1),
('paladin', 19, 6, 4, 3, 3, 3, 2),
('paladin', 20, 6, 4, 3, 3, 3, 2);

INSERT OR IGNORE INTO class_level_progression (class_id, level, proficiency_bonus, slots_lvl_1, slots_lvl_2, slots_lvl_3, slots_lvl_4, slots_lvl_5) VALUES
('ranger', 1, 2, 0, 0, 0, 0, 0),
('ranger', 2, 2, 2, 0, 0, 0, 0),
('ranger', 3, 2, 3, 0, 0, 0, 0),
('ranger', 4, 2, 3, 0, 0, 0, 0),
('ranger', 5, 3, 4, 2, 0, 0, 0),
('ranger', 6, 3, 4, 2, 0, 0, 0),
('ranger', 7, 3, 4, 3, 0, 0, 0),
('ranger', 8, 3, 4, 3, 0, 0, 0),
('ranger', 9, 4, 4, 3, 2, 0, 0),
('ranger', 10, 4, 4, 3, 2, 0, 0),
('ranger', 11, 4, 4, 3, 3, 0, 0),
('ranger', 12, 4, 4, 3, 3, 0, 0),
('ranger', 13, 5, 4, 3, 3, 1, 0),
('ranger', 14, 5, 4, 3, 3, 1, 0),
('ranger', 15, 5, 4, 3, 3, 2, 0),
('ranger', 16, 5, 4, 3, 3, 2, 0),
('ranger', 17, 6, 4, 3, 3, 3, 1),
('ranger', 18, 6, 4, 3, 3, 3, 1),
('ranger', 19, 6, 4, 3, 3, 3, 2),
('ranger', 20, 6, 4, 3, 3, 3, 2);

-- Half_up caster progression (artificer — same slot values as half caster)
INSERT OR IGNORE INTO class_level_progression (class_id, level, proficiency_bonus, slots_lvl_1, slots_lvl_2, slots_lvl_3, slots_lvl_4, slots_lvl_5) VALUES
('artificer', 1, 2, 0, 0, 0, 0, 0),
('artificer', 2, 2, 2, 0, 0, 0, 0),
('artificer', 3, 2, 3, 0, 0, 0, 0),
('artificer', 4, 2, 3, 0, 0, 0, 0),
('artificer', 5, 3, 4, 2, 0, 0, 0),
('artificer', 6, 3, 4, 2, 0, 0, 0),
('artificer', 7, 3, 4, 3, 0, 0, 0),
('artificer', 8, 3, 4, 3, 0, 0, 0),
('artificer', 9, 4, 4, 3, 2, 0, 0),
('artificer', 10, 4, 4, 3, 2, 0, 0),
('artificer', 11, 4, 4, 3, 3, 0, 0),
('artificer', 12, 4, 4, 3, 3, 0, 0),
('artificer', 13, 5, 4, 3, 3, 1, 0),
('artificer', 14, 5, 4, 3, 3, 1, 0),
('artificer', 15, 5, 4, 3, 3, 2, 0),
('artificer', 16, 5, 4, 3, 3, 2, 0),
('artificer', 17, 6, 4, 3, 3, 3, 1),
('artificer', 18, 6, 4, 3, 3, 3, 1),
('artificer', 19, 6, 4, 3, 3, 3, 2),
('artificer', 20, 6, 4, 3, 3, 3, 2);

-- Pact magic progression (warlock)
-- For warlocks, only one non-zero level column at a time (the pact slot level)
-- Level 1: 1 slot at 1st level
-- Level 2: 2 slots at 1st level
-- Levels 3-4: 2 slots at 2nd level
-- Levels 5-6: 2 slots at 3rd level
-- Levels 7-8: 2 slots at 4th level
-- Levels 9-10: 2 slots at 5th level
-- Levels 11-16: 3 slots at 5th level
-- Levels 17-20: 4 slots at 5th level
INSERT OR IGNORE INTO class_level_progression (class_id, level, proficiency_bonus, slots_lvl_1, slots_lvl_2, slots_lvl_3, slots_lvl_4, slots_lvl_5) VALUES
('warlock', 1, 2, 1, 0, 0, 0, 0),
('warlock', 2, 2, 2, 0, 0, 0, 0),
('warlock', 3, 2, 0, 2, 0, 0, 0),
('warlock', 4, 2, 0, 2, 0, 0, 0),
('warlock', 5, 3, 0, 0, 2, 0, 0),
('warlock', 6, 3, 0, 0, 2, 0, 0),
('warlock', 7, 3, 0, 0, 0, 2, 0),
('warlock', 8, 3, 0, 0, 0, 2, 0),
('warlock', 9, 4, 0, 0, 0, 0, 2),
('warlock', 10, 4, 0, 0, 0, 0, 2),
('warlock', 11, 4, 0, 0, 0, 0, 3),
('warlock', 12, 4, 0, 0, 0, 0, 3),
('warlock', 13, 5, 0, 0, 0, 0, 3),
('warlock', 14, 5, 0, 0, 0, 0, 3),
('warlock', 15, 5, 0, 0, 0, 0, 3),
('warlock', 16, 5, 0, 0, 0, 0, 3),
('warlock', 17, 6, 0, 0, 0, 0, 4),
('warlock', 18, 6, 0, 0, 0, 0, 4),
('warlock', 19, 6, 0, 0, 0, 0, 4),
('warlock', 20, 6, 0, 0, 0, 0, 4);

-- Non-casters (barbarian, fighter, monk, rogue) — all zeros
INSERT OR IGNORE INTO class_level_progression (class_id, level, proficiency_bonus, slots_lvl_1, slots_lvl_2, slots_lvl_3, slots_lvl_4, slots_lvl_5, slots_lvl_6, slots_lvl_7, slots_lvl_8, slots_lvl_9) VALUES
('barbarian', 1, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('barbarian', 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('barbarian', 3, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('barbarian', 4, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('barbarian', 5, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('barbarian', 6, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('barbarian', 7, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('barbarian', 8, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('barbarian', 9, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('barbarian', 10, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('barbarian', 11, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('barbarian', 12, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('barbarian', 13, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('barbarian', 14, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('barbarian', 15, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('barbarian', 16, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('barbarian', 17, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('barbarian', 18, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('barbarian', 19, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('barbarian', 20, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0);

INSERT OR IGNORE INTO class_level_progression (class_id, level, proficiency_bonus, slots_lvl_1, slots_lvl_2, slots_lvl_3, slots_lvl_4, slots_lvl_5, slots_lvl_6, slots_lvl_7, slots_lvl_8, slots_lvl_9) VALUES
('fighter', 1, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('fighter', 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('fighter', 3, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('fighter', 4, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('fighter', 5, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('fighter', 6, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('fighter', 7, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('fighter', 8, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('fighter', 9, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('fighter', 10, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('fighter', 11, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('fighter', 12, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('fighter', 13, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('fighter', 14, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('fighter', 15, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('fighter', 16, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('fighter', 17, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('fighter', 18, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('fighter', 19, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('fighter', 20, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0);

INSERT OR IGNORE INTO class_level_progression (class_id, level, proficiency_bonus, slots_lvl_1, slots_lvl_2, slots_lvl_3, slots_lvl_4, slots_lvl_5, slots_lvl_6, slots_lvl_7, slots_lvl_8, slots_lvl_9) VALUES
('monk', 1, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('monk', 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('monk', 3, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('monk', 4, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('monk', 5, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('monk', 6, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('monk', 7, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('monk', 8, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('monk', 9, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('monk', 10, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('monk', 11, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('monk', 12, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('monk', 13, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('monk', 14, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('monk', 15, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('monk', 16, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('monk', 17, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('monk', 18, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('monk', 19, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('monk', 20, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0);

INSERT OR IGNORE INTO class_level_progression (class_id, level, proficiency_bonus, slots_lvl_1, slots_lvl_2, slots_lvl_3, slots_lvl_4, slots_lvl_5, slots_lvl_6, slots_lvl_7, slots_lvl_8, slots_lvl_9) VALUES
('rogue', 1, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('rogue', 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('rogue', 3, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('rogue', 4, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('rogue', 5, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('rogue', 6, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('rogue', 7, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('rogue', 8, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('rogue', 9, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('rogue', 10, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('rogue', 11, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('rogue', 12, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('rogue', 13, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('rogue', 14, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('rogue', 15, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('rogue', 16, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('rogue', 17, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('rogue', 18, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('rogue', 19, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0),
('rogue', 20, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0);

COMMIT;

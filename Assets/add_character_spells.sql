-- ============================================================================
-- Spell Assignments for SaveState Characters
-- ============================================================================
-- Adds spellcasting stats and known spells for PCs and NPCs that should have
-- them, matched to class spell lists and highest available spell slot levels.
--
-- Characters covered:
--   pc-1  Tharivol   — Artificer 5 (Armorer)           → INT, slots 4/2
--   pc-3  Aria       — Druid 3 / Barbarian 2           → WIS, slots 4/2 (fix!)
--   pc-4  Kallista   — Cleric 4 (Life Domain)          → WIS, slots 4/3
--   pc-5  Garrick    — Bard 4 (College of Lore)        → CHA, slots 4/3
--   npc-4 Archmage   — High-level wizard (expand)      → INT (exists, expand)
--   npc-7 Priest     — Cleric 5                        → WIS, slots 4/3/2
-- ============================================================================

PRAGMA foreign_keys = ON;

BEGIN TRANSACTION;

-- -------------------------------------------------------------------------
-- 1. FIX PC-3 (Aria) — was incorrectly set as INT for Wizard spells
--    Now a Druid 3 / Barbarian 2 — needs WIS and proper Druid spell slots
-- -------------------------------------------------------------------------

-- Remove the old wrong entry
DELETE FROM entity_spellcasting WHERE entity_id = 'pc-3';

-- Insert correct Druid spellcasting (caster level 3: 4 1st, 2 2nd)
INSERT INTO entity_spellcasting
    (entity_id, spellcasting_ability, slots_lvl_1_max, slots_lvl_1_curr, slots_lvl_2_max, slots_lvl_2_curr)
VALUES
    ('pc-3', 'WIS', 4, 4, 2, 2);

-- Remove old wrong spell assignments (Fireball and Mage Armor — not Druid spells)
DELETE FROM entity_spells WHERE entity_id = 'pc-3';


-- -------------------------------------------------------------------------
-- 2. ADD MISSING ENTITY_SPELLCASTING for PCs and NPCs
-- -------------------------------------------------------------------------

-- pc-1: Artificer 5 (half-caster, 4 1st, 2 2nd)
INSERT INTO entity_spellcasting
    (entity_id, spellcasting_ability, slots_lvl_1_max, slots_lvl_1_curr, slots_lvl_2_max, slots_lvl_2_curr)
VALUES
    ('pc-1', 'INT', 4, 4, 2, 2);

-- pc-4: Cleric 4 (full-caster, 4 1st, 3 2nd)
INSERT INTO entity_spellcasting
    (entity_id, spellcasting_ability, slots_lvl_1_max, slots_lvl_1_curr, slots_lvl_2_max, slots_lvl_2_curr)
VALUES
    ('pc-4', 'WIS', 4, 4, 3, 3);

-- pc-5: Bard 4 (full-caster, 4 1st, 3 2nd)
INSERT INTO entity_spellcasting
    (entity_id, spellcasting_ability, slots_lvl_1_max, slots_lvl_1_curr, slots_lvl_2_max, slots_lvl_2_curr)
VALUES
    ('pc-5', 'CHA', 4, 4, 3, 3);

-- npc-7: Priest (Cleric 5, full-caster, 4 1st, 3 2nd, 2 3rd)
INSERT INTO entity_spellcasting
    (entity_id, spellcasting_ability, slots_lvl_1_max, slots_lvl_1_curr, slots_lvl_2_max, slots_lvl_2_curr, slots_lvl_3_max, slots_lvl_3_curr)
VALUES
    ('npc-7', 'WIS', 4, 4, 3, 3, 2, 2);

-- Expand npc-4 (Archmage): add higher-level slots (18th-level wizard equivalent)
-- Currently has 4/3/3, add 4th-9th
UPDATE entity_spellcasting SET
    slots_lvl_4_max = 3, slots_lvl_4_curr = 3,
    slots_lvl_5_max = 3, slots_lvl_5_curr = 3,
    slots_lvl_6_max = 1, slots_lvl_6_curr = 1,
    slots_lvl_7_max = 1, slots_lvl_7_curr = 1,
    slots_lvl_8_max = 1, slots_lvl_8_curr = 1,
    slots_lvl_9_max = 1, slots_lvl_9_curr = 1
WHERE entity_id = 'npc-4';


-- -------------------------------------------------------------------------
-- 3. ASSIGN SPELLS
-- -------------------------------------------------------------------------

-- ============================= pc-1 Tharivol =============================
-- Artificer 5 (Armorer) | INT 12 → +1 | Prepares: 3 (INT mod + half level)
-- Max slot: 2nd | Cantrips: 3
-- Thematics: Armorer is a frontliner who uses magic to enhance defense,
-- repair gear, and provide battlefield control
--
INSERT INTO entity_spells (entity_id, spell_id, is_prepared) VALUES
    -- Cantrips (always prepared by nature)
    ('pc-1', 'spell-fire-bolt',   1),   -- Ranged attack option
    ('pc-1', 'spell-guidance',    1),   -- Party utility
    ('pc-1', 'spell-mending',     1),   -- Repair armor/gear (thematic for Armorer)

    -- 1st-Level — 3 prepared, 1 known but not prepared
    ('pc-1', 'spell-shield',      1),   -- PREPARED: Core reaction defense
    ('pc-1', 'spell-cure-wounds', 1),   -- PREPARED: Party healing
    ('pc-1', 'spell-faerie-fire', 0),   -- Known (Grant advantage to party), not currently prepared
    ('pc-1', 'spell-identify',    0),   -- Known (ritual), not currently prepared
    ('pc-1', 'spell-magic-missile', 0), -- Known, not currently prepared
    ('pc-1', 'spell-expeditious-retreat', 0), -- Known, not currently prepared

    -- 2nd-Level — 1 prepared, 1 known but not prepared
    ('pc-1', 'spell-heat-metal',  1),   -- PREPARED: Thematic — heat enemy armor!
    ('pc-1', 'spell-mirror-image', 0),  -- Known, not currently prepared
    ('pc-1', 'spell-invisibility', 0),  -- Known, not currently prepared
    ('pc-1', 'spell-lesser-restoration', 0), -- Known, not currently prepared
    ('pc-1', 'spell-web',         0);   -- Known, not currently prepared


-- =========================== pc-3 Aria (Fixed) ============================
-- Druid 3 (Spores) / Barbarian 2 | WIS 13 → +1 | Prepares: 4 (WIS + level)
-- Max slot: 2nd | Cantrips: 2
-- Thematics: Circle of Spores — decay, necrotic energy, fungal growth,
-- entangling nature
--
INSERT INTO entity_spells (entity_id, spell_id, is_prepared) VALUES
    -- Cantrips
    ('pc-3', 'spell-druidcraft',  1),   -- Nature utility
    ('pc-3', 'spell-thorn-whip',  1),   -- Pull enemies closer

    -- 1st-Level — 3 prepared, 1 known but not prepared
    ('pc-3', 'spell-entangle',      1), -- PREPARED: AoE control
    ('pc-3', 'spell-faerie-fire',   1), -- PREPARED: Reveal hidden enemies
    ('pc-3', 'spell-cure-wounds',   1), -- PREPARED: Healing
    ('pc-3', 'spell-healing-word',  0), -- Known (bonus action heal), not prepared
    ('pc-3', 'spell-thunderwave',   0), -- Known, not prepared
    ('pc-3', 'spell-goodberry',     0), -- Known, not prepared
    ('pc-3', 'spell-fog-cloud',     0), -- Known (area denial), not prepared

    -- 2nd-Level — 1 prepared, 2 known but not prepared
    ('pc-3', 'spell-moonbeam',      1), -- PREPARED: Thematic radiant/druid staple
    ('pc-3', 'spell-blindnessdeafness', 0), -- Known (thematic for Spores decay), not prepared
    ('pc-3', 'spell-gentle-repose', 0), -- Known (thematic for Spores), not prepared
    ('pc-3', 'spell-pass-without-trace', 0), -- Known, not prepared
    ('pc-3', 'spell-barkskin',      0), -- Known, not prepared
    ('pc-3', 'spell-flaming-sphere', 0); -- Known, not prepared


-- ========================= pc-4 Kallista ================================
-- Cleric 4 (Life Domain) | WIS 18 → +4 | Prepares: 8 (WIS + level)
-- Domain spells (always prepared): Bless, Cure Wounds / Lesser Restoration, Spiritual Weapon
-- Max slot: 2nd | Cantrips: 4
-- Thematics: Life Domain — healing, protection, radiant damage
--
INSERT INTO entity_spells (entity_id, spell_id, is_prepared) VALUES
    -- Cantrips
    ('pc-4', 'spell-guidance',    1),   -- Party support
    ('pc-4', 'spell-light',       1),   -- Illumination
    ('pc-4', 'spell-sacred-flame', 1),  -- Ranged radiant damage
    ('pc-4', 'spell-spare-the-dying', 1), -- Stabilize at range (Life Domain feature bonus)

    -- 1st-Level Domain Spells (always prepared)
    ('pc-4', 'spell-bless',          1), -- Domain: party buff
    ('pc-4', 'spell-cure-wounds',    1), -- Domain: healing

    -- 1st-Level Free Choices (4 slots — 2 already used by domain)
    ('pc-4', 'spell-healing-word',   1), -- PREPARED: Bonus action emergency heal
    ('pc-4', 'spell-guiding-bolt',   1), -- PREPARED: Radiant damage + give advantage
    ('pc-4', 'spell-sanctuary',      1), -- PREPARED: Protect a damaged ally
    ('pc-4', 'spell-shield-of-faith', 1),-- PREPARED: +2 AC buff

    -- 1st-Level Known, not prepared (alternatives)
    ('pc-4', 'spell-command',        0), -- Known, situational
    ('pc-4', 'spell-inflict-wounds', 0), -- Known (domain dissonance but available)
    ('pc-4', 'spell-protection-from-evil-and-good', 0), -- Known, situational

    -- 2nd-Level Domain Spells (always prepared)
    ('pc-4', 'spell-lesser-restoration', 1), -- Domain: condition removal
    ('pc-4', 'spell-spiritual-weapon',   1), -- Domain: bonus action persistent damage

    -- 2nd-Level Free Choices (3 slots — 2 already used by domain)
    ('pc-4', 'spell-hold-person',    1), -- PREPARED: Paralyze humanoid
    ('pc-4', 'spell-prayer-of-healing', 1), -- PREPARED: Out-of-combat mass heal
    ('pc-4', 'spell-aid',            1), -- PREPARED: +5 max HP buff for 3

    -- 2nd-Level Known, not prepared
    ('pc-4', 'spell-silence',        0), -- Known, situational
    ('pc-4', 'spell-zone-of-truth',  0), -- Known, situational
    ('pc-4', 'spell-calm-emotions',  0), -- Known, situational
    ('pc-4', 'spell-protection-from-poison', 0), -- Known, situational
    ('pc-4', 'spell-warding-bond',   0); -- Known, niche


-- ========================= pc-5 Garrick =================================
-- Bard 4 (College of Lore) | CHA 18 → +4 | Spells Known: 5
-- Max slot: 2nd | Cantrips: 3
-- Bards are "spells known" casters — all known spells are always available
-- Thematics: Lore Bard — charm, deception, knowledge, control
--
INSERT INTO entity_spells (entity_id, spell_id, is_prepared) VALUES
    -- Cantrips
    ('pc-5', 'spell-vicious-mockery', 1), -- Psychic damage + disadvantage
    ('pc-5', 'spell-mage-hand',       1), -- Utility telekinesis
    ('pc-5', 'spell-minor-illusion',  1), -- Creative illusion shenanigans

    -- 1st-Level (Bard knows 5 total spells at level 4)
    ('pc-5', 'spell-faerie-fire',       1), -- Give advantage to whole party
    ('pc-5', 'spell-healing-word',      1), -- Bonus action emergency heal
    ('pc-5', 'spell-dissonant-whispers', 1), -- Damage + reaction-free movement
    ('pc-5', 'spell-sleep',             1), -- AoE non-lethal control
    ('pc-5', 'spell-charm-person',      1), -- Social engineering

    -- 2nd-Level (picked at level 4)
    ('pc-5', 'spell-invisibility',      1), -- Premium party utility
    ('pc-5', 'spell-heat-metal',        0), -- Known, niche (disarm armored foes)
    ('pc-5', 'spell-suggestion',        0), -- Known, social/control
    ('pc-5', 'spell-misty-step',        0), -- Known, teleport escape
    ('pc-5', 'spell-enhance-ability',   0); -- Known, skill check buff

-- Note: Bards have spells KNOWN, not prepared. All known spells are available.
-- is_prepared=1 means always available for known casters.
-- I'm marking the core 5 as always available and a few extras as
-- "known situational" which would represent swapping via Magical Secrets
-- at higher levels. For now, these are extra known spells.


-- ========================= npc-4 Archmage ===============================
-- High-level wizard | INT 20 → +5 | Many spell slots (up to 9th)
-- Currently has: Fireball, Mage Armor
-- Expand with iconic wizard spells across all levels
--
INSERT INTO entity_spells (entity_id, spell_id, is_prepared) VALUES
    -- Cantrips (wizard staples)
    ('npc-4', 'spell-fire-bolt',        1),
    ('npc-4', 'spell-mage-hand',        1),
    ('npc-4', 'spell-prestidigitation', 1),
    ('npc-4', 'spell-light',            1),
    ('npc-4', 'spell-shocking-grasp',   1),

    -- 1st-Level (expand beyond existing Mage Armor)
    ('npc-4', 'spell-shield',           1), -- Reaction defense
    ('npc-4', 'spell-magic-missile',    1), -- Reliable damage
    ('npc-4', 'spell-detect-magic',     1), -- Utility
    ('npc-4', 'spell-disguise-self',    1), -- Utility
    ('npc-4', 'spell-find-familiar',    0), -- Ritual, not currently prepared
    ('npc-4', 'spell-feather-fall',     0), -- Situational
    ('npc-4', 'spell-comprehend-languages', 0), -- Ritual

    -- 2nd-Level
    ('npc-4', 'spell-misty-step',       1), -- Teleport escape
    ('npc-4', 'spell-mirror-image',     1), -- Defensive
    ('npc-4', 'spell-invisibility',     1), -- Utility
    ('npc-4', 'spell-hold-person',      1), -- Control
    ('npc-4', 'spell-web',              1), -- AoE control
    ('npc-4', 'spell-suggestion',       0), -- Known, not prepared
    ('npc-4', 'spell-locate-object',    0), -- Known, not prepared
    ('npc-4', 'spell-see-invisibility', 0), -- Known, not prepared

    -- 3rd-Level (already has Fireball)
    ('npc-4', 'spell-fireball',         1), -- Already assigned (via spl-1)
    ('npc-4', 'spell-counterspell',     1), -- Essential wizard reaction
    ('npc-4', 'spell-dispel-magic',     1), -- Utility
    ('npc-4', 'spell-fly',              1), -- Mobility
    ('npc-4', 'spell-haste',            1), -- Party buff
    ('npc-4', 'spell-slow',             0), -- Known, not prepared
    ('npc-4', 'spell-lightning-bolt',   0), -- Known, not prepared
    ('npc-4', 'spell-vampiric-touch',   0), -- Known, not prepared
    ('npc-4', 'spell-hypnotic-pattern', 0), -- Known, not prepared

    -- 4th-Level
    ('npc-4', 'spell-dimension-door',      1), -- Teleport +1 ally
    ('npc-4', 'spell-greater-invisibility', 1), -- Invisibility that doesn't break on attack
    ('npc-4', 'spell-polymorph',           1), -- Versatile control/utility
    ('npc-4', 'spell-banishment',          1), -- Remove one enemy from fight
    ('npc-4', 'spell-stoneskin',           0), -- Known, not prepared
    ('npc-4', 'spell-wall-of-fire',        0), -- Known, not prepared

    -- 5th-Level
    ('npc-4', 'spell-cone-of-cold',         1), -- Big AoE damage
    ('npc-4', 'spell-telekinesis',          1), -- Versatile control
    ('npc-4', 'spell-scrying',              1), -- Remote espionage
    ('npc-4', 'spell-bigbys-hand',          0), -- Known, not prepared
    ('npc-4', 'spell-wall-of-force',        0), -- Known, not prepared

    -- 6th-Level
    ('npc-4', 'spell-chain-lightning',      1), -- Iconic AoE
    ('npc-4', 'spell-globe-of-invulnerability', 0), -- Known, not prepared
    ('npc-4', 'spell-contingency',           0), -- Known, not prepared
    ('npc-4', 'spell-true-seeing',           0), -- Known, not prepared

    -- 7th-Level
    ('npc-4', 'spell-teleport',             1), -- Party travel
    ('npc-4', 'spell-forcecage',            1), -- Inescapable control
    ('npc-4', 'spell-plane-shift',          0), -- Known, not prepared

    -- 8th-Level
    ('npc-4', 'spell-mind-blank',           1), -- Psychic immunity
    ('npc-4', 'spell-antimagic-field',      0), -- Known, not prepared

    -- 9th-Level
    ('npc-4', 'spell-wish',                 1), -- The ultimate wizard spell
    ('npc-4', 'spell-time-stop',            0), -- Known, not prepared
    ('npc-4', 'spell-meteor-swarm',         0); -- Known, not prepared

-- Note: The old spl-1 (Fireball) and spl-2 (Mage Armor) entries for npc-4
-- are still there alongside the new spell-fireball and spell-mage-armor
-- entries. Let me clean up the duplicates.

-- Remove the old spl-* entries for npc-4 to avoid duplicates
DELETE FROM entity_spells WHERE entity_id = 'npc-4' AND spell_id IN ('spl-1', 'spl-2');

-- Now re-add Mage Armor using the correct spell ID
INSERT INTO entity_spells (entity_id, spell_id, is_prepared)
VALUES ('npc-4', 'spell-mage-armor', 1);


-- ========================= npc-7 Priest =================================
-- Cleric 5 | WIS 16 → +3 | Prepares: 8 (WIS + level)
-- Max slot: 3rd | Cantrips: 3
-- Thematics: Standard 5e Priest — healing, radiant damage, divine protection
--
INSERT INTO entity_spells (entity_id, spell_id, is_prepared) VALUES
    -- Cantrips
    ('npc-7', 'spell-light',          1),
    ('npc-7', 'spell-sacred-flame',   1),
    ('npc-7', 'spell-thaumaturgy',    1),

    -- 1st-Level
    ('npc-7', 'spell-cure-wounds',    1), -- PREPARED: Primary healing
    ('npc-7', 'spell-bless',          1), -- PREPARED: Party buff
    ('npc-7', 'spell-guiding-bolt',   1), -- PREPARED: Radiant damage
    ('npc-7', 'spell-sanctuary',      1), -- PREPARED: Protect ally
    ('npc-7', 'spell-healing-word',   0), -- Known, not prepared
    ('npc-7', 'spell-shield-of-faith', 0), -- Known, not prepared
    ('npc-7', 'spell-protection-from-evil-and-good', 0), -- Known, not prepared

    -- 2nd-Level
    ('npc-7', 'spell-lesser-restoration', 1), -- PREPARED: Condition removal
    ('npc-7', 'spell-spiritual-weapon',   1), -- PREPARED: Bonus action persistent damage
    ('npc-7', 'spell-prayer-of-healing',  1), -- PREPARED: Mass out-of-combat heal
    ('npc-7', 'spell-hold-person',   0), -- Known, not prepared
    ('npc-7', 'spell-silence',       0), -- Known, not prepared
    ('npc-7', 'spell-aid',           0), -- Known, not prepared

    -- 3rd-Level
    ('npc-7', 'spell-spirit-guardians', 1), -- PREPARED: Iconic cleric AoE
    ('npc-7', 'spell-speak-with-dead',  1), -- PREPARED: Investigation
    ('npc-7', 'spell-revivify',         0), -- Known (niche emergency), not prepared
    ('npc-7', 'spell-beacon-of-hope',   0), -- Known, not prepared
    ('npc-7', 'spell-dispel-magic',     0); -- Known, not prepared


COMMIT;

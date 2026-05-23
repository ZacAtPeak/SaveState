-- Spell Slot Tracking Schema Migration
-- Part of the spell-slot-tracking OpenSpec change

BEGIN TRANSACTION;

--------------------------------------------------------------------------------
-- 1.1 Add spellcaster_type to classes
--------------------------------------------------------------------------------
ALTER TABLE classes ADD COLUMN spellcaster_type TEXT NOT NULL DEFAULT 'none'
    CHECK (spellcaster_type IN ('full', 'half', 'half_up', 'third', 'pact', 'none'));

-- 1.2 Add spellcaster_type to subclasses (nullable, defaults to NULL)
ALTER TABLE subclasses ADD COLUMN spellcaster_type TEXT DEFAULT NULL
    CHECK (spellcaster_type IS NULL OR spellcaster_type IN ('third'));

-- 1.3 Create entity_spell_slot_state table
CREATE TABLE IF NOT EXISTS entity_spell_slot_state (
    entity_id   TEXT NOT NULL,
    slot_type   TEXT NOT NULL CHECK (slot_type IN ('spellcasting', 'pact_magic')),
    slot_level  INTEGER NOT NULL CHECK (slot_level BETWEEN 1 AND 9),
    slots_curr  INTEGER NOT NULL DEFAULT 0,
    PRIMARY KEY (entity_id, slot_type, slot_level),
    FOREIGN KEY (entity_id) REFERENCES entities(id) ON DELETE CASCADE
);

COMMIT;

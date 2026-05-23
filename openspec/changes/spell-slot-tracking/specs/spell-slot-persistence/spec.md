## ADDED Requirements

### Requirement: entity_spell_slot_state table

A new table SHALL exist to persist the current (remaining) count of spell slots per entity.

#### Scenario: Table schema
- **WHEN** the schema migration is applied
- **THEN** a table `entity_spell_slot_state` SHALL exist with columns: `entity_id TEXT NOT NULL`, `slot_type TEXT NOT NULL`, `slot_level INTEGER NOT NULL`, `slots_curr INTEGER NOT NULL DEFAULT 0`
- **AND** the primary key SHALL be `(entity_id, slot_type, slot_level)`
- **AND** `entity_id` SHALL reference `entities(id)` with `ON DELETE CASCADE`
- **AND** `slot_type` SHALL be constrained to `('spellcasting', 'pact_magic')`
- **AND** `slot_level` SHALL be constrained to 1-9

### Requirement: get_spell_slots command

The `get_spell_slots` Rust command SHALL return a character's current spell slot state, computed by merging derived max values with persisted current values.

#### Scenario: First load with no persisted state
- **WHEN** `get_spell_slots` is called for a character with no rows in `entity_spell_slot_state`
- **THEN** the returned slots SHALL have `current = max` for every slot level
- **AND** no rows SHALL be inserted into the database as a side effect

#### Scenario: Merge with persisted state
- **WHEN** `get_spell_slots` is called for a character with existing rows in `entity_spell_slot_state`
- **THEN** the returned slots SHALL have `current` values from the persisted state
- **AND** `max` values SHALL be computed from `class_level_progression`
- **AND** if a slot level has a persisted row but no longer has a max value (e.g., after leveling down), the persisted row SHALL be ignored

#### Scenario: Return structure
- **WHEN** `get_spell_slots` completes successfully
- **THEN** it SHALL return a `SpellSlotsResponse` containing an array of `SpellSlotGroup`
- **AND** each `SpellSlotGroup` SHALL contain `group_type`, `spellcasting_ability`, `save_dc`, `attack_bonus`, and an array of `SpellSlot` objects with `level`, `max`, and `current`

### Requirement: set_spell_slots command

The `set_spell_slots` Rust command SHALL upsert the current value for a single slot level.

#### Scenario: Upsert new value
- **WHEN** `set_spell_slots` is called with `(entity_id, slot_type, slot_level, new_curr)`
- **THEN** a row SHALL be inserted if one doesn't exist, or updated if it does
- **AND** the `slots_curr` value SHALL be clamped to `[0, computed_max]` before writing

#### Scenario: Zero out a slot
- **WHEN** `set_spell_slots` is called with `slots_curr = 0`
- **THEN** the row SHALL be written with `slots_curr = 0`
- **AND** the row SHALL NOT be deleted (zero is a valid value, not "no data")

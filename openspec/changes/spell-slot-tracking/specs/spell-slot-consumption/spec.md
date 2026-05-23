## ADDED Requirements

### Requirement: Cast button on known/prepared spells

Each spell in the Character Detail and Character Modal views SHALL have a "Cast" button that consumes a spell slot of that spell's level.

#### Scenario: Cast consumes one slot at spell's level
- **WHEN** the user clicks "Cast" on a 1st-level spell
- **AND** the character has remaining 1st-level slots
- **THEN** `current` for 1st-level slots SHALL decrement by 1
- **AND** the slot display SHALL update immediately
- **AND** the new value SHALL be persisted to the database

#### Scenario: Cantrip cast does not consume a slot
- **WHEN** the user clicks "Cast" on a cantrip (level 0)
- **THEN** no slot SHALL be consumed
- **AND** no persistence call SHALL be made

#### Scenario: Pact Magic uses its own slot group
- **WHEN** the user clicks "Cast" on a warlock spell that is cast using Pact Magic
- **THEN** the Pact Magic slot group's current value SHALL decrement
- **AND** the regular spellcasting slot group SHALL NOT be affected

### Requirement: Upcast fallback

When a spell's base level has no remaining slots, the system SHALL offer to cast it at the next available higher slot level.

#### Scenario: Upcast offered when base level depleted
- **WHEN** the user clicks "Cast" on Fireball (level 3)
- **AND** the character has 0 remaining 3rd-level slots
- **AND** the character has a 4th-level slot available
- **THEN** the system SHALL cast Fireball at 4th level (consuming a 4th-level slot)
- **AND** no level picker SHALL be shown (the system chooses the next available level)

#### Scenario: No upcast available when all higher slots depleted
- **WHEN** the user clicks "Cast" on Fireball (level 3)
- **AND** the character has 0 remaining 3rd-level slots
- **AND** the character has no 4th-level or higher slots available
- **THEN** the "Cast" button SHALL be disabled
- **AND** a tooltip or indicator SHALL explain "No available spell slots"

#### Scenario: Upcast not offered if equal-level slot exists
- **WHEN** the user clicks "Cast" on Fireball (level 3)
- **AND** the character has at least 1 remaining 3rd-level slot
- **THEN** the system SHALL consume a 3rd-level slot
- **AND** no upcast fallback SHALL be offered

### Requirement: Consume slot via Tauri command

Slot consumption SHALL call `set_spell_slots` on the Rust backend to persist the change.

#### Scenario: Debounced sync
- **WHEN** a slot is consumed
- **THEN** the frontend SHALL update immediately
- **AND** the backend sync SHALL follow the same debounced pattern as HP sync (`syncHpToDb`)

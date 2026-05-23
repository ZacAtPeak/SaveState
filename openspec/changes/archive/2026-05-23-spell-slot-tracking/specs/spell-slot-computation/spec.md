## ADDED Requirements

### Requirement: Classify spellcasting type per class/subclass

The system SHALL determine a character's spell slot progression by classifying each class into a caster type.

#### Scenario: Full caster classification
- **WHEN** a character has levels in `bard`, `cleric`, `druid`, `sorcerer`, or `wizard`
- **THEN** those classes SHALL contribute their full level to the multiclass caster level calculation

#### Scenario: Half caster classification
- **WHEN** a character has levels in `paladin` or `ranger`
- **THEN** those classes SHALL contribute `floor(level / 2)` to the multiclass caster level calculation

#### Scenario: Artificer half caster rounding up
- **WHEN** a character has levels in `artificer`
- **THEN** that class SHALL contribute `ceil(level / 2)` to the multiclass caster level calculation

#### Scenario: Third caster via subclass
- **WHEN** a character has levels in `fighter` with subclass `fighter_eldritch_knight` OR `rogue` with subclass `rogue_arcane_trickster`
- **THEN** those classes SHALL contribute `floor(level / 3)` to the multiclass caster level calculation

#### Scenario: Non-caster classes
- **WHEN** a character has levels in `barbarian`, `monk`, `fighter` (non-EK), or `rogue` (non-AT)
- **THEN** those classes SHALL contribute 0 to the multiclass caster level calculation

#### Scenario: Warlock Pact Magic classification
- **WHEN** a character has levels in `warlock`
- **THEN** those levels SHALL NOT contribute to the multiclass caster level calculation
- **AND** they SHALL be tracked separately as Pact Magic slots

### Requirement: Single-class slot lookup

For single-class characters, the system SHALL look up max spell slots directly from `class_level_progression` using the character's class and level.

#### Scenario: Direct lookup for single-class wizard
- **WHEN** a Wizard 5 calls `get_spell_slots`
- **THEN** the returned slots SHALL match the values in `class_level_progression` for `(wizard, 5)`: 4 first-level, 3 second-level, 2 third-level

#### Scenario: Direct lookup for single-class paladin
- **WHEN** a Paladin 5 calls `get_spell_slots`
- **THEN** the returned slots SHALL match the values in `class_level_progression` for `(paladin, 5)`: the paladin's actual slots, not the multiclass formula result

### Requirement: Multiclass caster level aggregation

For multi-class characters, the system SHALL compute a combined caster level using the 5e multiclass spellcaster formula.

#### Scenario: Full + half multiclass
- **WHEN** a Paladin 4 / Sorcerer 3 calls `get_spell_slots`
- **THEN** the caster level SHALL be `floor(4/2) + 3 = 5`
- **AND** the regular slots SHALL be looked up from `(wizard, 5)`: 4/3/2

#### Scenario: Full + third multiclass
- **WHEN** a Fighter EK 8 / Wizard 2 calls `get_spell_slots`
- **THEN** the caster level SHALL be `floor(8/3) + 2 = 4`
- **AND** the regular slots SHALL be looked up from `(wizard, 4)`: 4/3/2

#### Scenario: Multiple non-caster classes
- **WHEN** a Barbarian 5 / Monk 3 calls `get_spell_slots`
- **THEN** the caster level SHALL be 0
- **AND** the system SHALL return no regular slot groups

### Requirement: Pact Magic slot computation

Warlock levels SHALL produce a separate Pact Magic slot group with its own progression.

#### Scenario: Single-class warlock slots
- **WHEN** a Warlock 5 calls `get_spell_slots`
- **THEN** the system SHALL return one Pact Magic slot group with two 3rd-level slots

#### Scenario: Multiclass with warlock and regular caster
- **WHEN** a Warlock 3 / Sorcerer 5 calls `get_spell_slots`
- **THEN** the system SHALL return two slot groups: regular spellcasting (from Sorcerer 5 alone, since Warlock levels don't contribute to caster level) AND Pact Magic (from Warlock 3)

### Requirement: Caster type stored in database

The `classes` table SHALL have a `spellcaster_type` column classifying each class.

#### Scenario: Column exists with correct values
- **WHEN** the schema migration is applied
- **THEN** the `classes` table SHALL have a `spellcaster_type TEXT NOT NULL` column
- **AND** the values SHALL be one of: `full`, `half`, `half_up`, `third`, `pact`, `none`
- **AND** each class SHALL have its correct type set

### Requirement: Subclass caster type override

The `subclasses` table SHALL have a nullable `spellcaster_type` column for subclass-level overrides.

#### Scenario: Column exists with nullable default
- **WHEN** the schema migration is applied
- **THEN** the `subclasses` table SHALL have a `spellcaster_type TEXT DEFAULT NULL` column
- **AND** NULL SHALL mean "inherit from the parent class"

#### Scenario: Eldritch Knight override
- **WHEN** the `fighter_eldritch_knight` subclass is queried
- **THEN** its `spellcaster_type` SHALL be `third`

#### Scenario: Arcane Trickster override
- **WHEN** the `rogue_arcane_trickster` subclass is queried
- **THEN** its `spellcaster_type` SHALL be `third`

#### Scenario: All other subclasses inherit
- **WHEN** any subclass other than Eldritch Knight or Arcane Trickster is queried
- **THEN** its `spellcaster_type` SHALL be NULL

### Requirement: class_level_progression seeded with all classes

The `class_level_progression` table SHALL contain slot progression data for all 13 classes at levels 1-20.

#### Scenario: All rows present
- **WHEN** the database is seeded
- **THEN** `class_level_progression` SHALL have exactly 260 rows (13 classes × 20 levels)
- **AND** each row SHALL have non-negative integer values for `slots_lvl_1` through `slots_lvl_9`

#### Scenario: Full caster progression matches multiclass table
- **WHEN** querying `class_level_progression` for any full caster class at level N
- **THEN** the slot values SHALL match the standard D&D 5e full caster / multiclass spell slot table

#### Scenario: Warlock progression has single non-zero level
- **WHEN** querying `class_level_progression` for warlock at level N
- **THEN** exactly one `slots_lvl_X` column SHALL be non-zero (the pact slot level for that warlock level)

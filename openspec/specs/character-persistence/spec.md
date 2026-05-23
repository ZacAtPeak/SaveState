# character-persistence Specification

## Purpose
TBD - created by archiving change character-creation-level2. Update Purpose after archive.
## Requirements
### Requirement: Expanded CreateCharacterRequest
The `CreateCharacterRequest` struct SHALL carry all fields needed for a full character creation with validation.

#### Scenario: Request payload structure
- **WHEN** a character creation request is sent
- **THEN** the payload SHALL include: `name`, `stat_roll_method`, `raw_scores` (ability scores before racial ASI), `race_id`, `subrace_id` (optional), `class_ids_and_levels` (array of `{class_id, level}` pairs), `subclass_id` (optional), `background_id`, `alignment`, `player_name` (optional), `proficient_skill_ids`, `proficient_save_ids`
- **AND** the backend SHALL return a `PlayerCharacter` on success or a `ValidationError` on failure

### Requirement: Pre-creation validation
A `validate_character_stats` command SHALL validate character data before creation, with no side effects.

#### Scenario: Validation on existing data
- **WHEN** `validate_character_stats` is called with partial character data
- **THEN** it SHALL return a list of errors (if any) and warnings
- **AND** it SHALL NOT modify any database state

#### Scenario: Class-level consistency
- **WHEN** validation runs
- **AND** a subclass is provided
- **THEN** the backend SHALL verify the subclass belongs to one of the selected classes
- **AND** reject with an error if there's a mismatch

### Requirement: Character_classes population on creation
When a character is created, the `character_classes` join table SHALL be populated for each class the character has levels in.

#### Scenario: Single class character
- **WHEN** a character is created with one class at level 5
- **THEN** the `character_classes` table SHALL have one row: `(entity_id, class_id, class_level=5, is_primary=1)`

#### Scenario: Multiclass character
- **WHEN** a character is created with Fighter 3 / Wizard 2
- **THEN** the `character_classes` table SHALL have two rows: one for Fighter at level 3 with `is_primary=1`, one for Wizard at level 2 with `is_primary=0`

### Requirement: Entity_skills population on creation
When a character is created, the selected skill proficiencies SHALL be written to `entity_skills`.

#### Scenario: Skills persisted
- **WHEN** a character is created with skill proficiencies ["arcana", "investigation", "perception"]
- **THEN** the `entity_skills` table SHALL have three rows for that entity with `is_proficient=1`
- **AND** the `GET_CHARACTER_SKILLS` query SHALL reflect these proficiencies

### Requirement: Saving throw proficiencies on creation
When a character is created, the selected saving throw proficiencies SHALL be written to `entity_stats`.

#### Scenario: Save proficiencies persisted
- **WHEN** a character is created with Strength and Constitution saving throw proficiencies
- **THEN** the `entity_stats` row for that character SHALL have `save_prof_strength=1` and `save_prof_constitution=1`

### Requirement: GET_PLAYER_CHARACTERS query fix
The `GET_PLAYER_CHARACTERS` query SHALL handle characters without `character_classes` entries gracefully.

#### Scenario: Character without character_classes
- **WHEN** the character list is loaded
- **AND** a character exists with no `character_classes` entry (legacy or edge case)
- **THEN** the query SHALL return the character with NULL or empty class/level rather than failing
- **AND** the Rust mapping SHALL handle NULL `class_levels` and `total_level` without panicking

### Requirement: Character_profiles backward compatibility
When creating a character, the `character_profiles.class` and `character_profiles.level` fields SHALL still be populated for backward compatibility with the existing query.

#### Scenario: Dual write
- **WHEN** a character is created via the new flow
- **THEN** `character_profiles` SHALL receive the primary class name and total level (denormalized)
- **AND** `character_classes` SHALL receive the normalized rows


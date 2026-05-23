# race-data Specification

## Purpose
TBD - created by archiving change character-creation-level2. Update Purpose after archive.
## Requirements
### Requirement: Races table in SQLite
A new `races` table SHALL be added to the schema to store reference data for D&D 5e playable races.

#### Scenario: Schema definition
- **WHEN** the schema migration is applied
- **THEN** the `races` table SHALL exist with columns: `id TEXT PRIMARY KEY`, `name TEXT NOT NULL`, `description TEXT`, `size TEXT`, `speed_walk INTEGER`, `darkvision INTEGER`, `source TEXT`

#### Scenario: Subraces support
- **WHEN** the schema migration is applied
- **THEN** the `races` table MAY have a `parent_race_id TEXT` column referencing `races(id)` for subraces (e.g., High Elf → Elf)
- **OR** a separate `subraces` table SHALL exist with `id`, `name`, `race_id`, `description`
- **AND** subrace records SHALL be queryable via `get_races(include_subraces=true)` or a dedicated `get_subraces(race_id)` command

### Requirement: Racial ability score bonuses
A `race_ability_bonuses` table (or columns on `races`) SHALL track which ability scores each race improves and by how much.

#### Scenario: Race ASI applied to scores
- **WHEN** a race is selected in the creation form
- **THEN** the ability score fields SHALL display both the raw assigned score and the final score after racial bonuses
- **AND** the backend SHALL store the raw scores and apply ASIs server-side on creation

### Requirement: Races queryable via Tauri command
A `get_races` command SHALL return all races with their traits.

#### Scenario: Get all races
- **WHEN** the `get_races` command is called
- **THEN** it SHALL return a list of all races with `id`, `name`, `size`, `speed_walk`, `darkvision`, and ability score bonuses

### Requirement: Minimum race set in seed data
The seed database SHALL include the core SRD playable races.

#### Scenario: Core races present
- **WHEN** the seed database is created
- **THEN** the `races` table SHALL contain at minimum: Dwarf, Elf, Halfling, Human, Dragonborn, Gnome, Half-Elf, Half-Orc, Tiefling
- **AND** races with subraces (Dwarf, Elf, Halfling, Gnome) SHALL have at least 2 subraces each


# background-data Specification

## Purpose
TBD - created by archiving change character-creation-level2. Update Purpose after archive.
## Requirements
### Requirement: Backgrounds table in SQLite
A new `backgrounds` table SHALL be added to the schema to store D&D 5e background reference data.

#### Scenario: Schema definition
- **WHEN** the schema migration is applied
- **THEN** the `backgrounds` table SHALL exist with columns: `id TEXT PRIMARY KEY`, `name TEXT NOT NULL`, `description TEXT`, `skill_proficiencies TEXT` (JSON array of skill IDs), `tool_proficiencies TEXT`, `feature_name TEXT`, `feature_description TEXT`, `source TEXT`

### Requirement: Backgrounds queryable via Tauri command
A `get_backgrounds` command SHALL return all backgrounds.

#### Scenario: Get all backgrounds
- **WHEN** the `get_backgrounds` command is called
- **THEN** it SHALL return a list of all backgrounds with `id`, `name`, `skill_proficiencies`, `feature_name`, `feature_description`

### Requirement: Background auto-selects skills
When a background is chosen, its associated skill proficiencies SHALL be auto-selected in the skill picker.

#### Scenario: Background skills pre-filled
- **WHEN** the user selects a background in the creation form
- **THEN** the skills listed in that background's `skill_proficiencies` SHALL be toggled on in the skill picker
- **AND** the background-granted proficiency count SHALL be subtracted from the available skill picks

### Requirement: Minimum background set in seed data
The seed database SHALL include the core SRD backgrounds.

#### Scenario: Core backgrounds present
- **WHEN** the seed database is created
- **THEN** the `backgrounds` table SHALL contain at minimum: Acolyte, Criminal/Spy, Folk Hero, Noble, Sage, Soldier
- **AND** each background SHALL have at least 2 skill proficiencies defined


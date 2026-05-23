## Why

Character creation in SaveState is a bare text-input modal that captures 14 raw fields with no intelligence — no class/race validation, no auto-calculated stats, no ability score rules, no subclass or background support. For a D&D combat tracker that already has a rich schema (classes, subclasses, skills, entity relationships), this makes the first interaction with the app feel hollow and error-prone. A data-driven character creation flow with real D&D 5e rules makes SaveState viable as a standalone tabletop tool, not just a combat tracker bolted onto a spreadsheet.

## What Changes

- **Races and backgrounds become first-class data** — new `races` and `backgrounds` SQLite tables, seeded with SRD/content data, queried at runtime via new Tauri commands
- **The creation form moves from a simple modal to a richer panel** — free-text "Class" and "Race" inputs become DB-backed dropdowns; subclass, background, alignment, and subrace fields are added
- **Ability scores get real D&D 5e rules** — support for Standard Array, Point Buy (with cost table), and 4d6-drop-lowest methods; validation enforces score limits and point budgets
- **Derived stats auto-calculate** — proficiency bonus from class/level, hit points from class hit die + CON modifier, speed/size/darkvision from race selection
- **Saving throws and skills become interactive** — proficiency toggles for the 6 saving throws; a skill picker showing available proficiencies from class + background
- **The backend create flow populates the full schema** — writes to `character_classes`, `entity_stats` (save proficiencies), `entity_skills`; accepts subclass, background, and alignment; fixes the current NULL `character_classes` gap that can break the character list query
- **Validation is built into the backend** — a `validate_character` command checks ability scores, multiclass prerequisites (medium-term), and data consistency before creation

## Capabilities

### New Capabilities
- `character-creation-form`: The UI for creating a character — data-driven dropdowns, stat rolling method picker, skill/save pickers, auto-calculated readouts, inline validation feedback
- `class-data`: Classes and subclasses reference data — queryable from the seeded `classes`/`subclasses` tables, including hit die, saving throw proficiencies, and subclass options per class
- `race-data`: Races reference data — a new `races` table with ability score bonuses, speed, size, darkvision, and racial traits
- `background-data`: Backgrounds reference data — a new `backgrounds` table listing skill proficiencies, tool proficiencies, and starting feature
- `stat-generation-rules`: D&D 5e ability score generation — Standard Array, Point Buy (with PHB cost table), and 4d6-drop-lowest; validates all three methods and enforces racial ASI application
- `character-persistence`: Backend character creation with full schema support — accepts the expanded `CreateCharacterRequest`, populates `character_classes`, `entity_skills`, save proficiencies; includes pre-creation validation

### Modified Capabilities
<!-- No existing specs to modify. -->

## Impact

- **`src-tauri/src/commands/characters.rs`**: New commands (`get_classes`, `get_subclasses`, `get_races`, `get_backgrounds`, `validate_character_stats`). `create_player_character` rewritten to accept expanded request and populate `character_classes`, `entity_skills`, save proficiencies.
- **`src-tauri/src/models.rs`**: New structs (`Class`, `Race`, `Background`, `Subclass`, `ValidationResult`, `StatRollMethod`). `CreateCharacterRequest` expanded with subclass, background, alignment, subrace, skill proficiencies, save proficiencies, stat roll method and results.
- **`src-tauri/src/db.rs`**: New queries for races, backgrounds, classes, subclasses. `GET_PLAYER_CHARACTERS` fixed to handle NULL `character_classes` rows.
- **`src-tauri/src/lib.rs`**: Register new Tauri commands.
- **`Assets/savestate_schema.sql`**: New `races` and `backgrounds` tables added.
- **`Assets/5e_data.sqlite`**: Rebuilt seed with races and backgrounds populated (SRD subset).
- **`src/lib/types/index.ts`**: New TypeScript interfaces (`Race`, `Background`, `DndClass`, `StatRollMethod`, `ValidationResult`). `CreateCharacterRequest` expanded.
- **`src/lib/stores/app.svelte.ts`**: New load functions (`loadClasses`, `loadRaces`, `loadBackgrounds`). `createCharacter` expanded.
- **`src/lib/components/CreateCharacterModal.svelte`**: Major rework — replaces text inputs with DB-backed dropdowns, adds stat rolling method selector, skill/save pickers, auto-calculated readouts, validation feedback.
- **New components**: `StatRoller.svelte` (ability score generation UI), `SkillPicker.svelte` (proficiency selection), `SavePicker.svelte` (saving throw toggles).
- **No new npm or cargo dependencies.**

## 1. Data Layer: New Tables & Schema

- [x] 1.1 Add `races` table to `Assets/savestate_schema.sql` (id, name, description, size, speed_walk, darkvision, parent_race_id, source)
- [x] 1.2 Add `race_ability_bonuses` table to schema (race_id, ability, bonus)
- [x] 1.3 Add `subraces` table to schema (id, name, race_id, description) or use `parent_race_id` self-reference on races
- [x] 1.4 Add `backgrounds` table to schema (id, name, description, skill_proficiencies, tool_proficiencies, feature_name, feature_description, source)
- [x] 1.5 Add `background_skill_proficiencies` or use JSON array column for background skill picks

## 2. Backend: Class & Race & Background Queries

- [x] 2.1 Add `get_classes` Tauri command returning all classes (id, name, hit_die, saving_throw_1, saving_throw_2, primary_ability, description)
- [x] 2.2 Add `get_subclasses(class_id)` Tauri command returning subclasses for a class
- [x] 2.3 Add `get_races` Tauri command returning all races with ability score bonuses
- [x] 2.4 Add `get_subraces(race_id)` Tauri command returning subraces for a race (if using separate subraces table)
- [x] 2.5 Add `get_backgrounds` Tauri command returning all backgrounds
- [x] 2.6 Add corresponding DB queries in `db.rs::queries` for each new command
- [x] 2.7 Add Rust structs (`Class`, `Subclass`, `Race`, `Subrace`, `Background`) in `models.rs`
- [x] 2.8 Register all new commands in `lib.rs`

## 3. Backend: Stat Generation & Validation

- [x] 3.1 Create `rules.rs` module with pure functions for D&D 5e stat rules
- [x] 3.2 Implement `validate_standard_array(scores: &[i32; 6]) -> Result` function
- [x] 3.3 Implement `validate_point_buy(scores: &[i32; 6], cost_table: &HashMap) -> Result` function with PHB cost table
- [x] 3.4 Implement `validate_rolled(scores: &[i32; 6]) -> Result` function (3-18 range check)
- [x] 3.5 Implement `apply_racial_asi(raw_scores, race_id, chosen_bonuses) -> Result<[i32; 6]>` function
- [x] 3.6 Implement `validate_skill_count(class_ids, background_id, selected_skills) -> Result` function
- [x] 3.7 Implement `validate_subclass_matches_class(subclass_id, class_ids) -> Result` function
- [x] 3.8 Add `validate_character_stats` Tauri command that calls all validation functions and returns errors/warnings list
- [x] 3.9 Add `ValidationResult` struct with `errors: Vec<String>`, `warnings: Vec<String>`

## 4. Backend: Expanded Character Creation

- [x] 4.1 Expand `CreateCharacterRequest` in models.rs with: `stat_roll_method`, `raw_scores`, `race_id`, `subrace_id`, `class_ids_and_levels`, `subclass_id`, `background_id`, `alignment`, `proficient_skill_ids`, `proficient_save_ids`
- [x] 4.2 Rewrite `create_player_character` to call validation before writing
- [x] 4.3 Add `character_classes` INSERT(s) to creation flow (one row per class with level and is_primary flag)
- [x] 4.4 Add `entity_skills` batch INSERT to creation flow
- [x] 4.5 Add `entity_stats` save proficiency UPDATE to creation flow
- [x] 4.6 Keep backward-compatible write to `character_profiles.class`/`level` (denormalized)
- [x] 4.7 Fix `GET_PLAYER_CHARACTERS` query to handle NULL `character_classes` rows (COALESCE or LEFT JOIN with defaults)

## 5. Seed Data: Races, Backgrounds & Expanded Classes

- [x] 5.1 Seed races table with PHB/SRD races (Dwarf, Elf, Halfling, Human, Dragonborn, Gnome, Half-Elf, Half-Orc, Tiefling) with sizes, speeds, darkvision
- [x] 5.2 Seed race_ability_bonuses for all races (e.g., Dwarf +2 CON, Elf +2 DEX, etc.)
- [x] 5.3 Seed subraces for races that have them (Mountain/Hill Dwarf, High/Wood/Dark Elf, Lightfoot/Stout Halfling, Forest/Rock Gnome)
- [x] 5.4 Expand classes table to all 12 PHB classes (Barbarian, Bard, Cleric, Druid, Fighter, Monk, Paladin, Ranger, Rogue, Sorcerer, Warlock, Wizard) with hit dice and saves
- [x] 5.5 Ensure each class has at least 2 subclasses seeded
- [x] 5.6 Seed backgrounds table with core SRD backgrounds (Acolyte, Criminal/Spy, Folk Hero, Noble, Sage, Soldier, etc.) with skill proficiencies and feature descriptions
- [x] 5.7 Rebuild Assets/5e_data.sqlite from updated schema + seed data

## 6. Frontend: Expanded Types & Store

- [x] 6.1 Add TypeScript interfaces: `DndClass`, `Subclass`, `Race`, `Subrace`, `Background`, `ValidationResult`, `StatRollMethod`
- [x] 6.2 Expand `CreateCharacterRequest` interface with all new fields
- [x] 6.3 Add store methods: `loadClasses()`, `loadRaces()`, `loadBackgrounds()`, `validateStats()`
- [x] 6.4 Add reactive state for class/race/background dropdown options in store

## 7. Frontend: Stat Rolling UI

- [x] 7.1 Create `StatRoller.svelte` component with method selector tabs (Standard Array, Point Buy, Rolled, Manual)
- [x] 7.2 Implement Standard Array interactive picker (click to assign values to abilities)
- [x] 7.3 Implement Point Buy interactive grid with cost display and remaining budget
- [x] 7.4 Implement 4d6-drop-lowest roller with roll button and individual re-rolls
- [x] 7.5 Implement Manual entry with 1-30 range validation

## 8. Frontend: Skill & Save Pickers

- [x] 8.1 Create `SkillPicker.svelte` component showing all 18 skills with toggle checkboxes
- [x] 8.2 Implement auto-selection of class skills + background skills when class/background selected
- [x] 8.3 Display remaining skill picks available (class + background allotment minus selections)
- [x] 8.4 Create `SavePicker.svelte` component with toggle buttons for 6 saving throws
- [x] 8.5 Auto-toggle class proficiency saves when class is selected

## 9. Frontend: Character Creation Form Rework

- [x] 9.1 Enlarge `CreateCharacterModal.svelte` to ~640px width with sectioned layout
- [x] 9.2 Replace free-text Class input with `<select>` populated from loaded classes
- [x] 9.3 Add Subclass dropdown that filters based on selected class
- [x] 9.4 Replace free-text Race input with `<select>` populated from loaded races
- [x] 9.5 Add Subrace dropdown that shows when race has subraces
- [x] 9.6 Add Background dropdown populated from loaded backgrounds
- [x] 9.7 Add Alignment picker (grid or dropdown with all 9 alignments + Unaligned)
- [x] 9.8 Add auto-calculated readout fields: proficiency bonus, hit die display, speed, size
- [x] 9.9 Integrate `StatRoller`, `SkillPicker`, and `SavePicker` components into the form
- [x] 9.10 Add debounced validation call on input changes with inline error display
- [x] 9.11 Disable submit button when validation errors exist
- [x] 9.12 Wire expanded `handleCreateCharacter` to pass all new fields through the store

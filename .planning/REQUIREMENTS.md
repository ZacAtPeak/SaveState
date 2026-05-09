# Requirements — SaveState GameModel

## v1 Requirements

### Core Schema (SCHEMA)

- [ ] **SCHEMA-01**: `GameModel` data class parses a JSON file defining entity types, per-type field schemas, wiki page types (via `isWikiPageType` flag), and game rules config (dice notation, initiative config, ability score display names)
- [ ] **SCHEMA-02**: `GameEntity` is a typed Dart wrapper over `Map<String, dynamic>` with an `entityTypeKey` field — replaces `PlayerCharacter`, `Monster`, and `NPC`; serializes to/from JSON; round-trips cleanly
- [ ] **SCHEMA-03**: `GameEntity` exposes `getInt(key, {fallback})`, `getString(key, {fallback})`, and `getBool(key, {fallback})` accessor helpers — no bare `as T` dynamic casts anywhere in entity read code
- [ ] **SCHEMA-04**: Every `GameModel` JSON file carries a top-level `schemaVersion` (int); `GameModelParser` throws a readable `FormatException` if the field is absent or not an int

### Game Systems (SYSTEM)

- [ ] **SYSTEM-01**: D&D 5e `GameModel` ships as a bundled JSON asset at `packages/core/assets/game_models/dnd5e.json`; reproduces all existing field schemas — creature, spell, item, rule, location, npc, other page types; includes D&D ability score display names (Strength, Dexterity, Constitution, Intelligence, Wisdom, Charisma); initiative config uses 1d20+DEX modifier formula
- [x] **SYSTEM-02**: Call of Cthulhu 7e `GameModel` ships as a bundled JSON asset at `packages/core/assets/game_models/coc7e.json`; defines investigator entity (characteristics STR/CON/SIZ/DEX/APP/INT/POW/EDU at 15–90, derived Sanity/Luck/Magic Points/Build, percentile skill list); adversary entity (no CR/XP/class/spell slots); initiative config is DEX-rank sort (no roll)
- [x] **SYSTEM-03**: User can import an external `.json` GameModel file from disk via `file_picker`; app validates required fields (`schemaVersion`, `entityTypes`) and shows a human-readable error dialog on malformed input — never crashes silently

### Migration (MIGRATE)

- [x] **MIGRATE-01**: `PlayerCharacter`, `Monster`, and `NPC` Dart model files deleted; all demo data (`demo_player_characters.dart`, `demo_monsters.dart`, `demo_npcs.dart`) migrated to `List<GameEntity>` using D&D 5e GameModel field keys
- [x] **MIGRATE-02**: `WikiPageType` enum deleted; existing persisted wiki page JSON files (which store `"pageType": "creature"` as enum name strings) migrated by a `WikiMigrationRunner` that rewrites legacy type strings to D&D 5e GameModel entity type keys before enum removal
- [ ] **MIGRATE-03**: `enums.dart` (D&D ability score, alignment, size, damage type enums) deleted; values moved into D&D 5e GameModel JSON or replaced by `String` in affected code

### Wiki Integration (WIKI)

- [ ] **WIKI-01**: Wiki page type selector shows all entity types from the active `GameModel` where `isWikiPageType: true` — no hardcoded enum values in the type picker or create form
- [ ] **WIKI-02**: `WikiCreateForm` field list is generated from the active GameModel's `FieldSchema` list for the selected entity type — via a new `GameModelFormBuilder` widget, not `WikiPageType.fields`
- [ ] **WIKI-03**: `WikiProvider` receives the active `GameModel` via `ChangeNotifierProxyProvider.update` and re-derives available page types when the model switches

### Character Sheet (CHAR)

- [ ] **CHAR-01**: Character sheet UI in `companion_app` generates its field layout from the active GameModel's character entity type schema — no hardcoded D&D field names (e.g., `hitPoints`, `armorClass`, `proficiencyBonus`) in widget code
- [ ] **CHAR-02**: Character sheet reflects the active game system's fields immediately when the user switches GameModel — no restart required

### Encounter Tracker (ENCTR)

- [ ] **ENCTR-01**: Initiative order in the DM app encounter tracker reads the `initiativeConfig` from the active GameModel's rules block — not hardcoded `d20 + DEX modifier`; CoC 7e (DEX-rank sort, no roll) must work correctly
- [ ] **ENCTR-02**: Combatant HP display in the encounter tracker reads the HP field key from the active GameModel's adversary entity schema — not the hardcoded string `'hitPoints'`

### System Selection UX (UX)

- [ ] **UX-01**: A game system selector UI is accessible in both `companion_app` and `dm_app`; selected system persists across app restarts
- [ ] **UX-02**: Switching game systems triggers a live UI update via `GameModelService.notifyListeners()` — wiki type list, character sheet fields, and encounter initiative config all change without app restart
- [ ] **UX-03**: End-to-end agnosticism demo works: user switches to CoC 7e, creates a new wiki entry of type "investigator" with Sanity and percentile skill fields, switches back to D&D 5e and sees D&D wiki types and character fields

---

## v2 Requirements (Deferred)

- Per-campaign game system pinning (each campaign locked to its system independently)
- Third bundled system (Pathfinder 2e, FATE Core, or community-selected)
- In-app GameModel schema editor (build/edit game system definitions inside the app)
- Cross-system entity migration (auto-convert a D&D character when switching to CoC)
- Community GameModel registry / marketplace
- GameModelParser migration chain for schema v0→v1 evolution

---

## Out of Scope

- Cloud sync of GameModel files — local-only; no network fetch of model definitions
- Import from third-party VTT formats (Foundry, Roll20) — JSON-only import
- Backwards compatibility shims for old typed Dart models — clean deletion
- Networked GameModel switching via NSD — deferred to NSD milestone
- In-app GameModel schema editor — import/bundled only for v1

---

## Traceability

| REQ-ID | Phase | Status |
|--------|-------|--------|
| SCHEMA-01 | Phase 5 — Core Data Layer | Pending |
| SCHEMA-02 | Phase 5 — Core Data Layer | Pending |
| SCHEMA-03 | Phase 5 — Core Data Layer | Pending |
| SCHEMA-04 | Phase 5 — Core Data Layer | Pending |
| SYSTEM-01 | Phase 6 — Service Layer + D&D 5e Asset | Pending |
| WIKI-03 | Phase 6 — Service Layer + D&D 5e Asset | Pending |
| WIKI-01 | Phase 7 — Provider Rewiring | Pending |
| WIKI-02 | Phase 7 — Provider Rewiring | Pending |
| MIGRATE-01 | Phase 8 — Typed Model Replacement & Migration | Complete |
| MIGRATE-02 | Phase 8 — Typed Model Replacement & Migration | Complete |
| MIGRATE-03 | Phase 8 — Typed Model Replacement & Migration | Pending |
| CHAR-01 | Phase 9 — Character Sheet & Encounter Tracker Generalization | Pending |
| CHAR-02 | Phase 9 — Character Sheet & Encounter Tracker Generalization | Pending |
| ENCTR-01 | Phase 9 — Character Sheet & Encounter Tracker Generalization | Pending |
| ENCTR-02 | Phase 9 — Character Sheet & Encounter Tracker Generalization | Pending |
| SYSTEM-02 | Phase 10 — CoC 7e, System Picker & File Import | Complete |
| SYSTEM-03 | Phase 10 — CoC 7e, System Picker & File Import | Complete |
| UX-01 | Phase 10 — CoC 7e, System Picker & File Import | Pending |
| UX-02 | Phase 10 — CoC 7e, System Picker & File Import | Pending |
| UX-03 | Phase 10 — CoC 7e, System Picker & File Import | Pending |

# Roadmap: SaveState

## Milestones

- ✅ **v1.0 Wiki** - Phases 1-4 (shipped 2026-05-07)
- 🚧 **v2.0 GameModel** - Phases 5-10 (in progress)

## Phases

<details>
<summary>✅ v1.0 Wiki (Phases 1-4) - SHIPPED 2026-05-07</summary>

### Phase 1: Core Infrastructure
**Goal**: Foundation data layer — wiki pages can be modeled, persisted, and searched
**Depends on**: Nothing (first phase)
**Requirements**: CORE-01, CORE-02, CORE-03, CORE-04
**Success Criteria** (what must be TRUE):
  1. WikiPage model serializes to/from JSON with all required fields (title, tags, aliases, markdown body, stat block fields, page type, UUID)
  2. WikiPageType enum provides distinct field schemas per page type (creature, spell, item, rule, location, npc, other)
  3. Pages can be saved to disk and loaded back from file-based JSON storage
  4. Search service returns pages ranked by relevance with title matches scored higher than body matches
**Plans**: 4 plans

Plans:
- [x] 01-01-PLAN.md — WikiPage model and WikiPageType enum with per-type field schemas
- [x] 01-02-PLAN.md — File-based JSON persistence layer (WikiStorageService)
- [x] 01-03-PLAN.md — In-memory search service with title-prioritized scoring (WikiSearchService)
- [x] 01-04-PLAN.md — Core package unit tests for models and search service

### Phase 2: Modal UI Components
**Goal**: Users can browse, search, and view wiki pages through a responsive full-screen modal
**Depends on**: Phase 1
**Requirements**: MODAL-01, MODAL-02, MODAL-03, LIST-01, LIST-02, LIST-03, LIST-04, DETAIL-01, DETAIL-02, DETAIL-03, DETAIL-04
**Success Criteria** (what must be TRUE):
  1. Modal opens as full-screen slide-up overlay and displays two-panel layout (sidebar + detail) on windows >=600dp wide
  2. Modal switches to single-panel list→detail navigation on windows <600dp
  3. Sidebar shows scrollable page list with type indicators (icon or chip) and filters results as user types in search bar
  4. Search results prioritize title matches over body matches
  5. Selecting a page renders markdown content with proper formatting, tags as chips in header, and stat block as formatted card for creature-type pages
**Plans**: 7 plans

Plans:
- [x] 02-01-PLAN.md — Modal shell with responsive layout branching (two-panel >=600dp, single-panel <600dp)
- [x] 02-02-PLAN.md — WikiPageList sidebar with scrollable list, type icons, and search bar
- [x] 02-03-PLAN.md — Search integration with title-prioritized filtering and 250ms debounce
- [x] 02-04-PLAN.md — WikiPageDetail view with markdown rendering (flutter_markdown) and tag chips
- [x] 02-05-PLAN.md — Stat block widget for creature-type pages as formatted UI card
- [x] 02-06-PLAN.md — Gap closure: Wire WikiPageList and WikiPageDetail into WikiModalShell
- [x] 02-07-PLAN.md — Gap closure: Add type displayName chips to WikiPageList list items
**UI hint**: yes

### Phase 3: Create Flow & Per-App Integration
**Goal**: Users can create new wiki pages and access the modal from both apps via book icon
**Depends on**: Phase 2
**Requirements**: CREATE-01, CREATE-02, CREATE-03, CREATE-04
**Success Criteria** (what must be TRUE):
  1. Plus button in modal opens page type picker showing all available wiki page types
  2. Selecting a type displays a form with fields appropriate to that page type
  3. Submitting the form saves a new page with title, tags, aliases, markdown body, and structured fields
  4. New page appears immediately in the sidebar list after creation
**Plans**: 3 plans

Plans:
- [x] 03-01: Page type picker and dynamic create form driven by WikiPageType schemas
- [x] 03-02: Form submission with validation and persistence integration
- [x] 03-03: Book icon trigger wired into both companion_app and dm_app AppBar
**UI hint**: yes

### Phase 4: Polish & Testing
**Goal**: Modal is robust, responsive, and well-tested across both apps
**Depends on**: Phase 3
**Requirements**: MODAL-04
**Success Criteria** (what must be TRUE):
  1. Modal closes cleanly via close button and tap-outside gesture
  2. Search input has debounce (200-300ms) to prevent excessive re-filtering
  3. Layout renders correctly at phone (<600dp), tablet (600-840dp), and desktop (>840dp) breakpoints
  4. Core package unit tests pass for WikiPage model and WikiSearchService
**Plans**: 3 plans

Plans:
- [x] 04-01-PLAN.md — Modal dismissal behavior (close button + tap-outside with create-flow protection)
- [x] 04-02-PLAN.md — Debounce extraction to shared utility + unit tests with fake_async
- [x] 04-03-PLAN.md — App-level widget tests for responsive breakpoints and dismissal in both apps
**UI hint**: yes

</details>

---

### 🚧 v2.0 GameModel (In Progress)

**Milestone Goal:** Any TTRPG group can open SaveState, pick or import their game system, and immediately have a properly structured wiki, character sheet, and encounter tracker — no hardcoded D&D assumptions.

---

### Phase 5: Core Data Layer
**Goal**: Pure-Dart GameModel and GameEntity data structures exist in core — the schema foundation every other phase builds on
**Mode:** mvp
**Depends on**: Phase 4
**Requirements**: SCHEMA-01, SCHEMA-02, SCHEMA-03, SCHEMA-04
**Success Criteria** (what must be TRUE):
  1. A GameModel can be parsed from a JSON string and exposes its entityTypes, each with a list of FieldSchema definitions and an isWikiPageType flag
  2. A GameEntity wraps a Map<String, dynamic> with an entityTypeKey and round-trips cleanly through toJson/fromJson with no data loss
  3. GameEntity.getInt, getString, and getBool return typed values with fallbacks — accessing a missing key never throws a cast exception
  4. Parsing a GameModel JSON that omits schemaVersion throws a readable FormatException with a message identifying the missing field
**Plans**: 3 plans

Plans:
- [x] 05-01-PLAN.md — FieldSchema, EntityTypeSchema, and GameModel data classes (pure Dart)
- [x] 05-02-PLAN.md — GameEntity wrapper with toJson/fromJson and typed accessor helpers
- [x] 05-03-PLAN.md — GameModelParser with schemaVersion validation and unit tests

### Phase 6: Service Layer + D&D 5e Asset
**Goal**: The app can load and broadcast the active D&D 5e GameModel at startup — existing wiki and app behavior is unchanged
**Mode:** mvp
**Depends on**: Phase 5
**Requirements**: SYSTEM-01, WIKI-03
**Success Criteria** (what must be TRUE):
  1. dnd5e.json ships as a bundled asset and is parsed into a valid GameModel at startup with no console errors
  2. The D&D 5e GameModel includes all existing page types (creature, spell, item, rule, location, npc, other) with their field schemas, D&D ability score display names, and a 1d20+DEX initiative formula
  3. WikiProvider receives the active GameModel through ChangeNotifierProxyProvider and re-derives its available page types when the model changes — existing wiki pages still load and display correctly after the rewire
**Plans**: 2 plans

Plans:
- [x] 06-01-PLAN.md — dnd5e.json asset: entity types, field schemas, rulesConfig, initiative formula
- [x] 06-02-PLAN.md — GameModelService + ChangeNotifierProxyProvider wiring in both apps

### Phase 7: Provider Rewiring
**Goal**: WikiProvider is driven by the active GameModel — hardcoded WikiPageType enum references replaced with runtime GameModel lookups, with no regression to existing create flow
**Mode:** mvp
**Depends on**: Phase 6
**Requirements**: WIKI-01, WIKI-02
**Success Criteria** (what must be TRUE):
  1. The wiki type picker shows exactly the entity types from the active GameModel where isWikiPageType is true — no hardcoded enum list in the widget
  2. The WikiCreateForm field list is generated by GameModelFormBuilder from the selected entity type's FieldSchema list — WikiPageType.fields is no longer called anywhere in the create flow
  3. Creating a new wiki page with D&D 5e active produces an identical experience to before the rewire — all field types render, validation fires, and the page saves correctly
**UI hint**: yes
**Plans**: 2 plans

Plans:
- [x] 07-01-PLAN.md — GameModelFormBuilder widget + WikiTypePicker refactored for GameModel entity types
- [x] 07-02-PLAN.md — WikiCreateForm wired to GameModelFormBuilder, WikiModalProvider/Shell/SubmitFlow updated

### Phase 8: Typed Model Replacement & Migration
**Goal**: Hardcoded D&D typed Dart models are deleted and all data is migrated to GameEntity — no data loss, no broken wiki pages
**Mode:** mvp
**Depends on**: Phase 7
**Requirements**: MIGRATE-01, MIGRATE-02, MIGRATE-03
**Success Criteria** (what must be TRUE):
  1. PlayerCharacter, Monster, and NPC Dart files are deleted; all demo data is expressed as List<GameEntity> using D&D 5e GameModel field keys and loads without error
  2. Existing persisted wiki page JSON files (containing legacy "pageType" enum name strings) are rewritten by WikiMigrationRunner to D&D 5e GameModel entity type keys before the WikiPageType enum is removed
  3. enums.dart is deleted; all former enum references in app code compile cleanly using the String or GameModel-derived replacements
  4. Both apps launch, display demo data, and the wiki create flow works end-to-end after all deletions
**Plans**: TBD

Plans:
- [ ] 08-01: WikiMigrationRunner — rewrites legacy pageType enum strings to GameModel entity type keys
- [ ] 08-02: Demo data migration — demo_player_characters, demo_monsters, demo_npcs to List<GameEntity>
- [ ] 08-03: Delete PlayerCharacter, Monster, NPC, WikiPageType enum, enums.dart; fix all compile errors

### Phase 9: Character Sheet & Encounter Tracker Generalization
**Goal**: Character sheet and encounter tracker read all mechanical params from the active GameModel — no hardcoded D&D field names remain in UI or tracker logic
**Mode:** mvp
**Depends on**: Phase 8
**Requirements**: CHAR-01, CHAR-02, ENCTR-01, ENCTR-02
**Success Criteria** (what must be TRUE):
  1. The companion_app character sheet renders its fields from the active GameModel's character entity type schema — no string literals like "hitPoints" or "armorClass" appear in widget code
  2. Switching the active GameModel updates the character sheet field layout immediately without a restart
  3. The DM app encounter tracker derives its initiative order logic from the active GameModel's initiativeConfig — the hardcoded "d20 + DEX modifier" formula is removed from tracker code
  4. The HP column in the encounter tracker reads its field key from the active GameModel's adversary entity schema rather than the hardcoded string "hitPoints"
**UI hint**: yes
**Plans**: TBD

Plans:
- [ ] 09-01: Character sheet widget refactored to render from GameModel character entity FieldSchema list
- [ ] 09-02: Encounter tracker initiative logic reads initiativeConfig from active GameModel (D&D formula + CoC DEX-rank sort)
- [ ] 09-03: Encounter tracker HP field key sourced from adversary entity schema in active GameModel

### Phase 10: CoC 7e, System Picker & File Import
**Goal**: Users can pick any bundled game system or import their own — CoC 7e works end-to-end, proving true TTRPG agnosticism
**Mode:** mvp
**Depends on**: Phase 9
**Requirements**: SYSTEM-02, SYSTEM-03, UX-01, UX-02, UX-03
**Success Criteria** (what must be TRUE):
  1. A game system selector is accessible in both companion_app and dm_app; the selected system persists across app restarts
  2. Switching from D&D 5e to CoC 7e updates the wiki type list, character sheet fields, and encounter initiative config live — no restart required
  3. coc7e.json loads as a valid GameModel; CoC wiki types (investigator, adversary) appear in the type picker; the create form shows Sanity and percentile skill fields
  4. The encounter tracker correctly uses DEX-rank sort (no dice roll) for CoC initiative order
  5. A user can import an external .json file, see a human-readable error dialog for malformed input, and load a valid custom GameModel without the app crashing
**UI hint**: yes
**Plans**: TBD

Plans:
- [ ] 10-01: coc7e.json asset — investigator entity, adversary entity, DEX-rank initiativeConfig
- [ ] 10-02: System picker UI in both apps with persistence (shared_preferences or local file)
- [ ] 10-03: External .json file import via file_picker with validation and error dialog
- [ ] 10-04: End-to-end agnosticism smoke test — create CoC investigator, switch back to D&D, verify both systems

---

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3 → 4 → 5 → 6 → 7 → 8 → 9 → 10

| Phase | Milestone | Plans Complete | Status | Completed |
|-------|-----------|----------------|--------|-----------|
| 1. Core Infrastructure | v1.0 Wiki | 4/4 | Complete | 2026-05-07 |
| 2. Modal UI Components | v1.0 Wiki | 7/7 | Complete | 2026-05-07 |
| 3. Create Flow & Per-App Integration | v1.0 Wiki | 3/3 | Complete | 2026-05-07 |
| 4. Polish & Testing | v1.0 Wiki | 3/3 | Complete | 2026-05-07 |
| 5. Core Data Layer | v2.0 GameModel | 0/3 | Not started | - |
| 6. Service Layer + D&D 5e Asset | v2.0 GameModel | 0/3 | Not started | - |
| 7. Provider Rewiring | v2.0 GameModel | 0/2 | Not started | - |
| 8. Typed Model Replacement & Migration | v2.0 GameModel | 0/3 | Not started | - |
| 9. Character Sheet & Encounter Tracker Generalization | v2.0 GameModel | 0/3 | Not started | - |
| 10. CoC 7e, System Picker & File Import | v2.0 GameModel | 0/4 | Not started | - |

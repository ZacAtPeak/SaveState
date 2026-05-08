# Domain Pitfalls: GameModel Schema-Driven Migration

**Domain:** Replacing typed Dart domain models with a runtime JSON schema system in a Flutter/Dart app
**Researched:** 2026-05-07
**Confidence:** HIGH

---

## Critical Pitfalls

Mistakes that cause rewrites, data loss, or unrecoverable user-facing breakage.

---

### Pitfall 1: Runtime Null Crash From Unchecked Map Access

**What goes wrong:**
Code accesses `entity.data['hitPoints'] as int` on a `GameEntity` loaded from a file where the author used `'hp'` instead. The `[]` operator on `Map` returns `null` for missing keys, but the `as int` cast throws `Null check operator used on a null value` at runtime — a crash with no compile-time warning.

**Why it happens:**
Moving from typed Dart classes (`character.currentHP`) to `Map<String, dynamic>` lookups (`entity.data['currentHP']`) removes the compiler's ability to catch missing keys or wrong types. Every field access is now a runtime gamble. The existing codebase already uses `as String`, `as int`, `as bool` casts heavily in `fromJson` factories — that pattern is safe for structured own-data but becomes a crash vector when applied to user-imported GameModel files or GameEntity data where the author controls the keys.

**Specific triggers in SaveState:**
- `wiki_storage_service.dart` line 159 silently skips malformed wiki page files with `catch (_)` — that pattern must extend to all GameEntity loading
- `wiki_page.dart` line 51 does `WikiPageType.values.byName(json['pageType'] as String)` — after migration, `pageType` becomes a runtime string key that may not match any registered type
- `player_character.dart` performs 25+ unchecked `as Type` casts in `fromJson` — if any of those field names are renamed in the D&D 5e GameModel JSON, every existing entity crashes on load

**Consequences:**
App crashes opening any page that references a missing or renamed field. If the crash is in the encounter tracker during a live session, the DM loses all combat state. No amount of unit tests on the happy path catches this.

**Prevention:**
Define typed accessor helpers at the `GameEntity` layer that use `??` fallbacks: `int getInt(String key, {int fallback = 0}) => (data[key] as int?) ?? fallback`. Never use bare `as T` on arbitrary `Map<String, dynamic>` data. Apply `try/catch` at every deserialization boundary, the same pattern already used in `WikiStorageService.loadAllPages()`. Keep an explicit list of every key name used in GameModel JSON against a schema contract.

**Warning signs:**
- `entity.data['key'] as SomeType` without null-coalescing
- Code that casts to `List<dynamic>` and then iterates without a try/catch wrapper
- New field added to GameModel JSON but no fallback provided for entities that predate that field

**Phase to address:** GameModel data structure phase (the first implementation phase) — establish safe accessor patterns before any entity reads are written.

---

### Pitfall 2: Persisted Wiki Pages Become Unreadable After PageType Rename

**What goes wrong:**
`WikiPage.fromJson` currently does `WikiPageType.values.byName(json['pageType'] as String)` — a compile-time enum lookup. After migration, `pageType` becomes a runtime string like `"creature"`. If the D&D 5e GameModel JSON renames that type key (even to fix a typo: `"creatures"` instead of `"creature"`), every existing wiki page with `"pageType": "creature"` throws `ArgumentError` on load. The user's entire wiki corpus is unreadable until a migration is written.

**Why it happens:**
There is no schema version number in the current `WikiPage` JSON format. `wiki_storage_service.dart` serializes `pageType` as the raw enum name (line 38: `'pageType': pageType.name`). Saved files have no metadata about which GameModel version authored them. A rename in the GameModel is indistinguishable from corruption.

**Specific existing exposure:**
All 20 demo wiki pages in `demo_wiki_pages.dart` embed hardcoded type strings like `"creature"`, `"spell"`, `"item"`, `"rule"`, `"location"`, `"npc"`, `"other"`. The migration to GameModel must guarantee these exact string values map to D&D 5e GameModel type keys, or all demo data is permanently broken.

**Consequences:**
Silent data loss. `loadAllPages()` catches all errors and skips broken files (line 159). Users lose wiki pages with no error message. The DM notices half their wiki is gone after an update.

**Prevention:**
Add a `schemaVersion` field to both the GameModel JSON files and every persisted `WikiPage`/`GameEntity` file. Write a migration runner that reads the version field on load and applies transformations in sequence before returning the parsed object. The version field must be written at save time and checked at load time. Use additive-only changes for GameModel field keys in v1 — rename by adding the new key alongside the old one and mapping both during a transition period. The existing `WikiPage` JSON files on disk must be migrated (or the migration must handle the unversioned legacy format as "version 0").

**Warning signs:**
- No `version` or `schemaVersion` field in GameModel JSON files
- No migration runner between deserialization and use
- Field key renames in GameModel JSON without an explicit migration document
- `loadAllPages()` silently skipping files without logging which files failed and why

**Phase to address:** GameModel data structure phase — schema versioning strategy must be decided before the first GameModel JSON is written.

---

### Pitfall 3: CoC and D&D Use the Same Key Names for Structurally Different Concepts

**What goes wrong:**
Both systems have a concept called "HP" but they mean different things. In D&D 5e, HP is a value on a character sheet derived from class + CON modifier, tracked through combat, and can be recovered by magic. In CoC 7e, HP is `(CON + SIZ) / 10` rounded down, is never increased by "leveling," and major wounds (losing half HP in one hit) have unique mechanical effects. If both GameModels use the field key `"hp"`, the encounter tracker code written for D&D will misinterpret CoC HP values.

**Specific structural divergences:**

| Concept | D&D 5e | CoC 7e | Conflict |
|---------|--------|--------|---------|
| HP | Class-based, recoverable by magic | `(CON + SIZ) / 10`, no magic recovery | Same key, different semantics |
| Initiative | Rolled d20 + DEX modifier | DEX attribute order (high DEX goes first) | Same concept, incompatible mechanics |
| Ability scores | 6 scores (STR/DEX/CON/INT/WIS/CHA), 3–18 range, modifier = `(score-10)/2` | 8 characteristics (STR/CON/SIZ/DEX/APP/INT/POW/EDU), 15–90 range, no modifier concept | Same names, incompatible value ranges and math |
| Skills | Proficiency bonus + ability modifier | Percentile values (01–100), success = roll-under | No overlap — the entire skill resolution system differs |
| Leveling | XP → level → class features | Does not exist — investigators improve skills by practice | D&D-centric "level" field is meaningless for CoC |
| Alignment | 9-point Lawful/Chaotic/Good/Evil grid | Does not exist | D&D `alignment` enum has no CoC equivalent |
| Sanity | Does not exist | Primary resource (starts at `POW × 5`, max 99) | CoC-only field |
| Luck | Does not exist | Derived stat (`3d6 × 5`), spendable | CoC-only field |

**Why it happens:**
Developers see "both have HP" and use a shared key to avoid duplication. The encounter tracker code then assumes HP semantics (e.g., "healing by half" from a potion) from D&D and runs the same logic on CoC characters. The result is technically running but mechanically wrong.

**Consequences:**
The encounter tracker produces wrong results for CoC sessions (wrong initiative order, wrong HP thresholds for major wounds, spell healing applied to a system with no spell healing). Users can't trust the app for CoC sessions. The "agnosticism test" fails.

**Prevention:**
Treat each GameModel as a completely isolated schema with no shared field key namespace. The encounter tracker must read all its mechanical parameters (initiative formula, HP formula, heal mechanic) from the active GameModel's `rulesConfig` block rather than from hardcoded field names. Provide a `formulaEngine` in `GameModelService` that evaluates the active model's initiative formula. Test the CoC GameModel's `rulesConfig` against real CoC mechanics before declaring the migration complete — specifically: initiative as DEX-sort, HP as derived stat, no alignment, Sanity as primary resource.

**Warning signs:**
- Encounter tracker code contains `entity.data['hp']` hardcoded rather than `gameModel.rulesConfig.hpFieldKey`
- D&D-specific formula (`(score - 10) / 2`) computed in shared code rather than delegated to GameModel
- Tests only cover the D&D 5e GameModel path
- CoC character with DEX 70 shows wrong initiative relative to CoC character with DEX 40

**Phase to address:** CoC GameModel authoring phase — must produce a complete CoC 7e `rulesConfig` block before the encounter tracker is migrated. Do not defer CoC testing to a final polish phase; it will surface deep architectural issues if left late.

---

### Pitfall 4: GameModelService.notifyListeners() Rebuilds Every Consumer in Both Apps

**What goes wrong:**
`GameModelService extends ChangeNotifier`. When the user switches from D&D 5e to CoC, `notifyListeners()` is called once, which triggers rebuilds of every widget that called `context.watch<GameModelService>()` or `Consumer<GameModelService>` anywhere in either app. If the character sheet, encounter tracker, wiki modal, sidebar section labels, and app bar title all watch the same provider, a single system switch causes 5+ widgets to rebuild in the same frame. On a low-end device this is a dropped frame or animation stutter.

**Why it happens:**
`ChangeNotifier.notifyListeners()` is O(N) in listeners but triggers O(N) full widget subtree rebuilds if consumers are placed high in the widget tree. The existing codebase already uses `setState` for most UI state (e.g., `_HomeScreenState` in `dm_app/lib/main.dart` rebuilds the entire home screen with `setState`), which is a pattern that encourages coarse-grained rebuilds. When `GameModelService` is added to the same `ChangeNotifierProvider` pattern, it will compound this.

**Specific risk in SaveState:**
- DM app `HomeScreen` uses `setState` for `_entries`, `_activeIndex`, `_selectedDetail`, and `_rollHistory` — all separate concerns triggering full rebuilds
- If `GameModelService` is watched at the `MaterialApp` level (to update app title or theme), every navigation event will rebuild the entire app
- `WikiProvider` already calls `notifyListeners()` on `loadAll()`, `addPageFromSubmission()`, `selectPage()`, and `onCreateComplete()` — stacking `GameModelService` notifications on top could cascade

**Consequences:**
Frame drops during system switch (not a crash, but visible jank). The "no restart required" requirement means the switch happens live — janky transitions undermine the feature's perceived quality.

**Prevention:**
Use `Selector<GameModelService, T>` instead of `Consumer<GameModelService>` for all consumers that only need a single field from the service (e.g., `activeModelName`, `availableEntityTypes`, `initiativeConfig`). Place consumers as deep in the tree as possible. For the system switch animation, use `AnimatedSwitcher` to mask the rebuild as an intentional transition. Keep `GameModelService` scoped to the widgets that actually need it — do not place it above `MaterialApp`. Use `context.select<GameModelService, T>()` for fine-grained subscriptions.

**Warning signs:**
- `Consumer<GameModelService>` wrapping large subtrees (sidebars, full screens)
- `context.watch<GameModelService>()` in `HomeScreen.build()`
- `GameModelService` provided at `MaterialApp` level or higher
- No `Selector` usage anywhere in codebase

**Phase to address:** GameModelService + Provider wiring phase — Selector patterns must be established in the first wire-up, not retrofitted after jank complaints.

---

### Pitfall 5: WikiPageType Enum Deletion Breaks All Existing Persisted Data

**What goes wrong:**
The migration plan removes the `WikiPageType` enum and replaces it with a runtime type registry from the active GameModel. Existing wiki pages on disk have `"pageType": "creature"` (the enum name). After the migration, `WikiPage.fromJson` no longer calls `WikiPageType.values.byName(...)` — it looks up the type string in `GameModelService.activeModel.pageTypes`. If the D&D 5e GameModel uses a different string (e.g., `"monster"` instead of `"creature"`), all existing creature pages become orphans. If the app is running CoC and a D&D wiki page is loaded, the page type lookup fails entirely.

**Why it happens:**
The PROJECT.md explicitly states "Backwards compatibility shims for old typed Dart models — clean replacement, no bridge." The intent is a clean cut, but the data files on disk were written with the old type strings and cannot be rewritten automatically without a migration pass.

**Specific file impact:**
`demo_wiki_pages.dart` uses 7 type values as Dart enum references (`WikiPageType.creature`, `.spell`, `.item`, `.rule`, `.location`, `.npc`, `.other`). These will become dead references the moment the enum is deleted. More critically, any real user data saved during the wiki milestone (phases 1–4) uses those same 7 string names. All such data must be migrated or the migration will corrupt it.

**Consequences:**
Every user who ran the app before the GameModel migration loses their entire wiki on first launch after migration. No visible error — `loadAllPages()` silently skips failed files.

**Prevention:**
Before deleting `WikiPageType`, write a migration runner that scans all persisted wiki page files, detects the absence of a `schemaVersion` field (the legacy signal), and rewrites `pageType` values to their D&D 5e GameModel equivalents. Run this migration on first launch after the GameModel migration. Keep the old enum accessible as `LegacyWikiPageType` during the migration window (a single release) so the migration runner can reference the old names. After the migration runner confirms all files are updated, the legacy class can be deleted in a subsequent release.

**Warning signs:**
- No migration runner exists before `WikiPageType` enum deletion
- `demo_wiki_pages.dart` is deleted (not migrated) alongside the enum
- Launch sequence has no "first-run after migration" detection
- `loadAllPages()` error count not logged anywhere

**Phase to address:** GameEntity replacement phase — specifically, the migration runner must be written and tested before the enum is removed from any shared code that reads persisted files.

---

## Moderate Pitfalls

Mistakes that cause significant rework or degrade the feature but don't lose user data.

---

### Pitfall 6: Dynamic Form Generation Leaks TextEditingControllers on Schema Switch

**What goes wrong:**
`WikiCreateForm._WikiCreateFormState.initState()` creates one `TextEditingController` per field from `widget.selectedType.fields`. If the active GameModel switches mid-session (or the user switches type pickers), the old controllers are not disposed before new ones are created. Each leaked controller holds a `ChangeNotifier` subscription. Over multiple switches, memory pressure increases and debug mode prints "TextEditingController was used after being disposed."

**Why it happens:**
The current form (line 48–50 in `wiki_create_form.dart`) creates controllers in `initState` and disposes them in `dispose`. This lifecycle is safe for a static field list. When `selectedType` changes (or when the underlying GameModel changes the field count for a type), the widget is rebuilt but `initState` doesn't re-run — the controller map is stale. Any new fields have no controller; any removed fields leave leaked controllers.

**Prevention:**
Override `didUpdateWidget` in `_WikiCreateFormState`. When `widget.selectedType != oldWidget.selectedType`, dispose all existing controllers and recreate the map from the new type's field list. For GameModel switches that happen while a create form is open, close and reopen the form rather than trying to migrate in-flight state. Consider a `ValueKey` on `WikiCreateForm` keyed to the active GameModel ID so Flutter fully replaces the widget (and calls `dispose` + `initState`) on model switch.

**Warning signs:**
- `didUpdateWidget` not overridden in any `State` that holds a controller map
- "TextEditingController was used after being disposed" in debug console
- Controller map size differs from `widget.selectedType.fields.length`

**Phase to address:** Dynamic form generation phase.

---

### Pitfall 7: JSON Startup Parse Time Exceeds 50ms Budget on Low-End Devices

**What goes wrong:**
The D&D 5e GameModel JSON file is large (dozens of entity types, hundreds of field definitions, full rules config for initiative, HP, dice). Parsing it synchronously on the main isolate during startup exceeds the 50ms target stated in PROJECT.md, causing a white-screen flash or missed first frame.

**Why it happens:**
`rootBundle.loadString()` is async but `jsonDecode()` is synchronous and runs on the main isolate. A 50KB–150KB JSON file (realistic for a full D&D 5e schema) takes 10–60ms to decode on a mid-range device and longer on a low-end device. The project already specifies `rootBundle` for asset loading — this is the right choice, but parsing must be handled carefully.

**Critical constraint from Flutter:**
`rootBundle` cannot be accessed from a spawned isolate (Flutter GitHub issue #61480). This means the asset string must be loaded on the main isolate first, then parsing can be offloaded to `Isolate.run()` or `compute()`. Isolate spawn overhead is approximately 90–175ms — for small GameModel files, synchronous parsing on the main thread is actually faster.

**Prevention:**
Measure first. If the bundled D&D 5e GameModel JSON is under 20KB, synchronous parsing is likely under 5ms and the target is easily met. If schemas grow large (importing a full monster manual via custom GameModel), use `compute()` to offload. Cache parsed `GameModel` objects in memory — never re-parse a model that is already loaded. Load bundled models eagerly at app start on a background isolate, but do not block the first frame waiting for the result: show a splash or loading state.

**Warning signs:**
- GameModel JSON file exceeds 20KB
- No startup timing in DevTools showing model parse time
- `jsonDecode` called directly in `initState` or `runApp`
- No caching of parsed `GameModel` objects

**Phase to address:** GameModelService implementation phase — performance baseline measurement required before shipping.

---

### Pitfall 8: Schema Validation Absent on User-Imported GameModel Files

**What goes wrong:**
A user imports a custom `.json` GameModel file that is missing the `entityTypes` key. The app calls `gameModel.entityTypes` which returns null, and the character sheet rendering code crashes trying to iterate null. Or: the file has an `entityTypes` list but the `fields` array for one type is missing, causing the form generator to iterate null.

**Why it happens:**
File import is a new surface that bundled assets never exercise. Bundled assets are developer-controlled and always valid. User files are adversarial: truncated downloads, partially authored files, files from a different version of the schema spec, files with creative JSON5-ish comments (which `jsonDecode` rejects with an unhelpful error).

**Specific minimum requirements for a parseable GameModel:**
At minimum a valid GameModel file needs: `version` (string), `name` (string), `entityTypes` (non-empty list where each entry has `key` and `fields`), `pageTypes` (non-empty list with same structure), and `rulesConfig` (object with at minimum `initiativeFieldKey` or an initiative formula). Without these, no UI feature can render.

**Prevention:**
Write a `GameModelValidator` class that runs before any `GameModel` object is constructed from user input. Check for required top-level keys, that lists are non-empty, that no `fieldKey` is an empty string, and that referenced keys in `rulesConfig` exist in the relevant `entityType.fields` list. Return a `ValidationResult` with specific, user-readable error messages rather than a boolean. Show the errors in the import UI before accepting the file. Do not use `json_schema` package for this — it adds a dependency for something that can be done in 80 lines of hand-written validation code.

**Warning signs:**
- File import flow goes directly from `jsonDecode` to `GameModel.fromJson` with no intermediate validation
- `GameModel.fromJson` uses unchecked `as List` casts on optional fields
- No error message surfaced to the user when import fails

**Phase to address:** External GameModel import phase.

---

### Pitfall 9: Switching GameModel Leaves Stale References in WikiProvider

**What goes wrong:**
`WikiProvider` holds a list of `WikiPage` objects. Each `WikiPage` currently carries a `WikiPageType` reference (after migration: a string type key). When the user switches from D&D 5e to CoC, the existing wiki pages still reference D&D 5e type keys (`"creature"`, `"spell"`) that do not exist in the CoC GameModel. The wiki type picker renders an empty list. The create form offers no types. The stat block card renders nothing for D&D pages. The search service might work (it only cares about text), but everything schema-dependent is broken.

**Why it happens:**
`WikiProvider` and `GameModelService` are separate providers. `WikiProvider` is not notified when the active GameModel changes. The wiki page list is not re-evaluated against the new model's type registry. There is no concept of "pages that belong to this model" vs "pages that belong to another model."

**Prevention:**
`WikiProvider` must listen to `GameModelService` and handle model switches by either: (a) filtering the displayed pages to only those whose type key exists in the current model's type registry, showing "incompatible" pages with a warning indicator; or (b) maintaining separate wiki page stores per GameModel ID and switching the active store on model change. Option (a) is simpler for v1. Implement `WikiProvider.onModelChanged(GameModel newModel)` called by `GameModelService`. Do not silently hide pages — show a "from another game system" indicator so users don't think their data is gone.

**Warning signs:**
- `WikiProvider` has no reference to `GameModelService`
- `WikiProvider.pages` is not filtered by active model's `pageTypes`
- No "incompatible system" indicator exists for wiki pages

**Phase to address:** GameModelService + WikiProvider integration phase.

---

### Pitfall 10: Encounter Tracker Initiative Sort Breaks for CoC DEX-Order System

**What goes wrong:**
The current encounter tracker (`EncounterEntry.initiative` is a `double`) assumes initiative is a rolled value where higher numbers go first. D&D 5e: roll d20 + DEX mod. CoC 7e: simply order by DEX stat (no roll; ties broken by d100). If the encounter tracker uses `entries.sort((a, b) => b.initiative.compareTo(a.initiative))` hardcoded, CoC sessions will still ask for a rolled initiative value that doesn't exist in CoC, and the sort order will be wrong because DEX-order is not a rolled number but a stat lookup.

**Why it happens:**
`EncounterEntry` is being replaced by `GameEntity`, but the sort logic lives in the tracker UI code which will still need to sort. If the sort formula is not externalized to `GameModel.rulesConfig`, the D&D sort formula (`roll + mod`) is used for all systems.

**Prevention:**
`GameModel.rulesConfig` must include an `initiativeConfig` block that specifies: the field key to sort by, the sort direction (high-first or low-first), whether it is a rolled value or a derived stat, and a tiebreaker rule. The encounter tracker reads `initiativeConfig` from `GameModelService` rather than hardcoding `b.initiative.compareTo(a.initiative)`. For CoC, `initiativeConfig.fieldKey = "dex"` and `initiativeConfig.sortOrder = "high_first"` and `initiativeConfig.isRolled = false`.

**Warning signs:**
- `entries.sort((a, b) => b.initiative.compareTo(a.initiative))` hardcoded anywhere in encounter tracker
- No `initiativeConfig` in GameModel schema spec
- CoC test shows initiative entry UI asking for a roll value

**Phase to address:** Encounter tracker migration phase.

---

## Minor Pitfalls

Mistakes that create friction but are recoverable without data loss.

---

### Pitfall 11: Typed Test Helpers Become Invalid When Typed Classes Are Deleted

**What goes wrong:**
All existing tests in `packages/core/test/` reference `WikiPageType.creature`, `WikiPageType.spell`, etc. directly. When the enum is deleted, every test file fails to compile. The test suite goes from green to completely broken in a single commit, making CI a hard blocker before any migration work is verified.

**Prevention:**
Write `GameModel`-aware test helpers before deleting any typed classes. Create a `TestGameModels.dnd5e()` factory that returns a fully-populated `GameModel` object for D&D 5e. Replace all `WikiPageType.X` references in tests with `testDnd5e.pageTypes.byKey('creature')` equivalents. Delete typed classes only after all tests compile and pass against the new helpers.

**Phase to address:** The commit that deletes any typed model class must include test file updates in the same commit, not a follow-up PR.

---

### Pitfall 12: Demo Data Dart Files Become Dead Code That Still Compiles

**What goes wrong:**
`demo_player_characters.dart`, `demo_monsters.dart`, and `demo_npcs.dart` contain typed `PlayerCharacter`, `Monster`, and `NPC` instances. These will become invalid when those classes are deleted. However, `demo_wiki_pages.dart` uses the runtime-safe `WikiPage` type and will survive. Developers may leave the typed demo files in place (forgetting to delete or migrate them), causing confusing "import succeeds but data is never used" dead code.

**Prevention:**
Migrate demo data to `GameEntity` format against the D&D 5e `GameModel` JSON as part of the same phase that deletes the typed classes. The existing data (defined in ~1100 lines of demo files) becomes the validation corpus for confirming the D&D 5e GameModel accurately captures all the fields that were previously hardcoded.

**Phase to address:** GameEntity replacement phase.

---

### Pitfall 13: `int` vs `double` Type Coercion in Loaded JSON

**What goes wrong:**
`jsonDecode` returns `int` for whole numbers (`7`) and `double` for decimal numbers (`7.0`) in JSON. The current `EncounterEntry.fromJson` already handles this: `(json['initiative'] as num).toDouble()`. But new GameEntity access code that expects `int` will crash on values that were saved as `7.0` (e.g., if a user's text editor auto-formatted the JSON). Conversely, code expecting `double` will crash on `7` stored as `int`.

**Prevention:**
Always read numeric values from `GameEntity.data` via a helper that accepts both: `num? raw = data[key] as num?; int result = raw?.toInt() ?? fallback`. Never use bare `as int` or `as double` on values from JSON-decoded maps. This is already partially handled correctly in `EncounterEntry.fromJson` (line 46: `(json['initiative'] as num).toDouble()`) — apply this pattern universally.

**Phase to address:** GameEntity accessor utilities phase.

---

## Phase-Specific Warnings

| Phase Topic | Likely Pitfall | Mitigation |
|-------------|---------------|------------|
| GameModel JSON schema design | No version field | Add `"version": "1"` as the first required field |
| D&D 5e GameModel authoring | Using `"creatureType"` but wiki pages have `"creature"` | Audit all existing string values in demo data before finalizing GameModel type keys |
| CoC 7e GameModel authoring | Assuming D&D-style HP/initiative | Implement CoC `rulesConfig` from the Chaosium 7e rules; test with real CoC character |
| WikiPageType enum deletion | All tests break simultaneously | Write `TestGameModels` helpers before any class is deleted |
| GameEntity persistence | Existing wiki pages unreadable | Write migration runner; test with real data files from phases 1–4 |
| File import UI | Crash on malformed file | Validate before constructing `GameModel`; show user-readable errors |
| Encounter tracker migration | Hardcoded initiative sort | Read `initiativeConfig` from `GameModelService` |
| GameModelService wiring | Global provider causes 5+ rebuilds | Use `Selector` for all consumers; scope provider below `MaterialApp` |
| Dynamic form rebuild | Controller leak on schema switch | Override `didUpdateWidget`; use `ValueKey` on form widget |
| Startup perf | 50ms parse budget | Measure bundled GameModel size; use `compute()` only if > 20KB |

---

## "What Must Be True" Verification Checklist

Before any phase that touches persisted data is marked complete:

- [ ] Existing wiki pages created in phases 1–4 still load correctly after migration
- [ ] D&D 5e GameModel type keys exactly match the string values in `demo_wiki_pages.dart`
- [ ] A valid CoC 7e GameModel file exists and parses without errors
- [ ] Switching from D&D to CoC and back does not crash; wiki pages show appropriate "from another system" state
- [ ] Initiative order for CoC test encounter is correct (high DEX goes first, no roll)
- [ ] A custom malformed GameModel file shows an error in the import UI rather than crashing
- [ ] GameModelService `notifyListeners()` call triggers no rebuild of the root `MaterialApp` widget
- [ ] All `core` package tests pass with `GameModel`-aware test helpers (no `WikiPageType` enum references)

---

## Sources

- Dart official docs — Type system and null safety: https://dart.dev/null-safety/understanding-null-safety
- Flutter official docs — Concurrency and isolates (rootBundle constraint): https://docs.flutter.dev/perf/isolates
- Flutter GitHub — rootBundle unavailable in isolates (issue #61480): https://github.com/flutter/flutter/issues/61480
- provider package GitHub — ChangeNotifier O(N²) performance discussion (issue #45): https://github.com/rrousselGit/provider/issues/45
- provider package GitHub — Selector shouldRebuild (issue #333): https://github.com/rrousselGit/provider/issues/333
- Foundry VTT — System Data Models (game-agnostic schema architecture): https://foundryvtt.com/article/system-data-models/
- Couchbase — Schema versioning tutorial (field rename strategies): https://developer.couchbase.com/tutorial-schema-versioning
- Chaosium — CoC 7e character sheet (HP/Luck/Sanity/Build formulas): https://www.chaosium.com/content/FreePDFs/CoC/Character%20Sheets/Character%20Sheet%20-%20base%20-%20Call%20of%20Cthulhu%207th%20Ed.pdf
- DEV Community — Null safety crash case study: https://dev.to/alaminkarno/i-trusted-darts-null-safety-and-it-still-crashed-my-app-365a
- Flutter docs — JSON serialization (type coercion in jsonDecode): https://docs.flutter.dev/data-and-backend/serialization/json
- SaveState codebase — `wiki_storage_service.dart`, `wiki_page.dart`, `player_character.dart`, `wiki_create_form.dart`, `dm_app/lib/main.dart`

---
*Pitfalls research for: GameModel schema-driven migration in Flutter/Dart app*
*Researched: 2026-05-07*

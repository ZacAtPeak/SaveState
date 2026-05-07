# Codebase Concerns

**Analysis Date:** 2026-05-07

## Model Duplication and Data Redundancy

**Issue:** Multiple parallel model hierarchies represent the same domain concepts, creating maintenance burden and synchronization risk.

**Files:**
- `packages/core/lib/models/encounter.dart` — `EncounterEntry` (lines 3-53)
- `apps/dm_app/lib/widgets/initiative_tracker.dart` — `InitiativeEntry` (lines 71-145)
- `apps/dm_app/lib/widgets/initiative_tracker.dart` — `CombatantDragData` (lines 22-69)
- `apps/dm_app/lib/widgets/creature_detail_view.dart` — `CreatureDetail` (lines 4-93)

**Impact:** `EncounterEntry` and `InitiativeEntry` both track combatant name, HP, initiative, and conditions but are completely separate types. `CombatantDragData` duplicates fields already present on `PlayerCharacter`, `Monster`, and `NPC`. `CreatureDetail` is a presentation model defined in a widget file rather than in `core`. Any change to one model requires manual updates to all others.

**Fix approach:** Consolidate into a single `Combatant` model in `core` with factory constructors for each source type. Use `CreatureDetail` as a shared presentation model in `core` or derive it directly from domain models without a separate class.

## Mutable Fields Break Immutability Pattern

**Issue:** `EncounterEntry` and `EncounterState` contain mutable `int` and `String` fields, violating the immutable value-type pattern used consistently across all other models.

**Files:**
- `packages/core/lib/models/encounter.dart` — `EncounterEntry.currentHp` (line 7), `EncounterEntry.notes` (line 12)
- `packages/core/lib/models/encounter.dart` — `EncounterState.round` (line 58), `EncounterState.currentTurnIndex` (line 59), `EncounterState.dmNotes` (line 61)

**Impact:** All other models (`PlayerCharacter`, `Monster`, `NPC`, `Item`, `AbilityScores`, etc.) use `final` for every field. Mutable fields in `EncounterEntry`/`EncounterState` create inconsistent behavior — these models cannot be safely used with `const`, cannot be compared by value, and break expectations for immutable domain models.

**Fix approach:** Make all fields `final` and use `copyWith` pattern (as already implemented on `InitiativeEntry`) for state updates.

## Massive Monolithic Files

**Issue:** Several files exceed reasonable size limits, combining multiple responsibilities and widgets into single files.

**Files:**
- `apps/dm_app/lib/widgets/creature_detail_view.dart` — 757 lines (contains `CreatureDetail`, `CreatureDetailView`, `_StatRow`, `_AbilityScoresRow`, `_AbilityCard`, `_SpellSlotsBlock`, `_SpellSlotCell`, `_SkillsTab`, `_SkillRow`, `_ActionsTab`, `_SpellsTab`, `_LoreTab`, `_EmptyTab`, plus utility functions)
- `apps/dm_app/lib/main.dart` — 494 lines (contains `DmApp`, `HomeScreen`, `_SidebarEntry`, `_Sidebar`, `_SidebarState`, `_SidebarFab`, `_SidebarSection`, `_DraggableCombatantTile`)
- `apps/dm_app/lib/widgets/initiative_tracker.dart` — 481 lines (contains `RollHistoryEntry`, `CombatantDragData`, `InitiativeEntry`, `InitiativeTracker`, `_InitiativeTrackerState`)

**Impact:** Difficult to navigate, high merge conflict risk, multiple reasons to change per file. `creature_detail_view.dart` alone contains 14 classes and 6 utility functions.

**Fix approach:** Split each file by widget/component. Extract tab widgets (`_SkillsTab`, `_ActionsTab`, `_SpellsTab`, `_LoreTab`) into separate files. Move sidebar components (`_Sidebar`, `_SidebarFab`, `_SidebarSection`) to their own files.

## SDK Constraint Inconsistency

**Issue:** The workspace root requires SDK `^3.11.5` but both `core` and `dm_app` specify `^3.5.0`.

**Files:**
- `pubspec.yaml` (root) — line 7: `sdk: '^3.11.5'`
- `packages/core/pubspec.yaml` — line 6: `sdk: ^3.5.0`
- `apps/dm_app/pubspec.yaml` — line 6: `sdk: ^3.5.0`
- `apps/companion_app/pubspec.yaml` — line 6: `sdk: ^3.11.5` (consistent with root)

**Impact:** `core` and `dm_app` can resolve to older SDK versions than the workspace intends, potentially allowing code that uses features not available in the target deployment environment.

**Fix approach:** Align all packages to `^3.11.5` or determine the actual minimum required version and use it consistently.

## Stale Test File

**Issue:** The companion app test references a class name that no longer exists.

**Files:**
- `apps/companion_app/test/widget_test.dart` — line 16: `await tester.pumpWidget(const MyApp());`

**Impact:** Test will fail to compile. The actual app class is `CompanionApp` (`apps/companion_app/lib/main.dart`, line 8). This means tests are not running and providing false confidence.

**Fix approach:** Update test to reference `CompanionApp` instead of `MyApp`.

## No Persistence Layer

**Issue:** All application state is in-memory with no storage or persistence mechanism.

**Files:**
- `apps/dm_app/lib/main.dart` — `_entries` (line 44), `_rollHistory` (line 76), `_characters`/`_monsters`/`_npcs` (lines 49-68) — all stored as in-memory lists
- `packages/core/lib/services/` — directory does not exist

**Impact:** All data is lost on app restart. The AGENTS.md documents a `services/` directory in core for storage services, but it does not exist. No `shared_preferences`, `hive`, `sqflite`, or any storage dependency is declared.

**Fix approach:** Add a storage service to `packages/core/lib/services/` with an abstract interface and platform-specific implementations. Add appropriate dependency to `core/pubspec.yaml`.

## Unused Provider Dependency

**Issue:** Both apps declare `provider: ^6.1.2` as a dependency but neither app uses it.

**Files:**
- `apps/companion_app/pubspec.yaml` — line 12: `provider: ^6.1.2`
- `apps/dm_app/pubspec.yaml` — line 12: `provider: ^6.1.2`
- No `ChangeNotifierProvider`, `Provider`, `Consumer`, or `context.read`/`context.watch` calls found anywhere in the codebase

**Impact:** Unused dependency increases app size and creates confusion about the intended state management approach. Current state management uses `setState` directly in `StatefulWidget` classes.

**Fix approach:** Either remove `provider` from pubspec.yaml files or migrate state management to use Provider pattern consistently.

## Empty Button Handlers (Stubbed Features)

**Issue:** Multiple UI buttons have empty `onPressed` callbacks, indicating incomplete features.

**Files:**
- `apps/dm_app/lib/main.dart` — line 144: Wiki button `onPressed: () {}`
- `apps/dm_app/lib/main.dart` — line 149: Settings button `onPressed: () {}`
- `apps/dm_app/lib/main.dart` — line 154: Search button `onPressed: () {}`
- `apps/dm_app/lib/main.dart` — `_SidebarFab` actions (lines 321-326) — Add Character/Monster/NPC/Asset buttons all call `onClose` but have no creation logic

**Impact:** Users see functional-looking buttons that do nothing. This is confusing UX and indicates incomplete feature scope.

**Fix approach:** Either implement the features or remove/disable the buttons with visual indication they are not yet available.

## EncounterState Model Unused

**Issue:** `EncounterState` and `EncounterEntry` are defined in core but never used by either app. The DM app uses its own `InitiativeEntry` and `InitiativeTracker` instead.

**Files:**
- `packages/core/lib/models/encounter.dart` — `EncounterState` (lines 55-100), `EncounterEntry` (lines 3-53), `DiceRoll` (lines 102-133)
- `apps/dm_app/lib/widgets/initiative_tracker.dart` — `InitiativeEntry` (lines 71-145) — parallel implementation

**Impact:** Dead code in core that will drift from the actual implementation. `DiceRoll` in encounter.dart and `RollHistoryEntry` in initiative_tracker.dart serve the same purpose but are different types.

**Fix approach:** Either use `EncounterState`/`EncounterEntry` in the DM app and remove the duplicate types from `initiative_tracker.dart`, or move the working implementation to core and delete `encounter.dart`.

## No Error Handling in JSON Parsing

**Issue:** All `fromJson` factory constructors perform direct type casts without null checks or error handling, which will throw unhandled exceptions on malformed input.

**Files:**
- `packages/core/lib/models/player_character.dart` — lines 104-160 (direct `as String`, `as int`, `as Map` casts)
- `packages/core/lib/models/monster.dart` — lines 104-159 (same pattern)
- `packages/core/lib/models/npc.dart` — lines 95-145 (same pattern)
- `packages/core/lib/models/value_types.dart` — lines 57-64, 93-100, etc. (same pattern)

**Impact:** Any malformed JSON (missing required fields, wrong types, null where not expected) causes unhandled `TypeError` or `CastError` crashes. No try/catch or validation anywhere in the parsing layer.

**Fix approach:** Add validation with descriptive error messages, or use a serialization library like `json_serializable` with `@JsonKey` annotations for safer parsing.

## No analysis_options.yaml in Core Package

**Issue:** Only the two app packages have linting configuration. The `core` package has no `analysis_options.yaml`.

**Files:**
- `apps/dm_app/analysis_options.yaml` — present
- `apps/companion_app/analysis_options.yaml` — present
- `packages/core/analysis_options.yaml` — missing

**Impact:** The shared package (which contains all domain models and will contain services) has no lint enforcement, allowing lower code quality in the most critical shared code.

**Fix approach:** Add `analysis_options.yaml` to `packages/core/` with at least the same `flutter_lints` baseline as the apps, plus stricter rules appropriate for a library package.

## No Core Package Tests

**Issue:** The `core` package has no test directory or test files.

**Files:**
- `packages/core/test/` — does not exist
- `apps/companion_app/test/widget_test.dart` — exists but is stale
- `apps/dm_app/test/widget_test.dart` — exists (10 lines, minimal)

**Impact:** All domain model serialization/deserialization logic, value type calculations (ability modifiers, etc.), and any future service logic have zero test coverage. Changes to `toJson`/`fromJson` can break silently.

**Fix approach:** Add `packages/core/test/` directory with unit tests for all model serialization, value type computations, and enum parsing.

## Hardcoded Demo Data as Only Data Source

**Issue:** All creature data comes from hardcoded demo files. There is no mechanism to load, create, edit, or persist real user data.

**Files:**
- `packages/core/lib/data/demo_player_characters.dart` — 302 lines of hardcoded data
- `packages/core/lib/data/demo_monsters.dart` — 523 lines of hardcoded JSON
- `packages/core/lib/data/demo_npcs.dart` — 274 lines of hardcoded JSON
- `apps/dm_app/lib/main.dart` — lines 49-68: sidebar populated directly from demo data

**Impact:** The app cannot function with user-created content. The demo data approach is fine for prototyping but blocks any real usage.

**Fix approach:** Add data loading abstraction in core services with repository pattern. Keep demo data as seed/initial data option.

## Companion App is Placeholder-Only

**Issue:** The companion app has no real functionality — all three tabs show placeholder text.

**Files:**
- `apps/companion_app/lib/main.dart` — lines 33-47: tabs display `Center(child: Text('Characters Screen'))`, `Text('Inventory Screen')`, `Text('Spells Screen')`

**Impact:** The companion app is non-functional. While acceptable for early development, this should be tracked as incomplete scope.

## No Cross-App Communication Mechanism

**Issue:** The two apps (companion and DM) have no mechanism to communicate or sync state, despite being designed as a pair for D&D session management.

**Files:**
- `packages/core/pubspec.yaml` — includes `nsd: ^5.0.1` (Network Service Discovery) and `shelf: ^1.4.2` (HTTP server), suggesting planned network communication, but no services exist to use them

**Impact:** The NSD and shelf dependencies are declared but unused. Without a communication layer, the companion app cannot receive encounter state from the DM app.

**Fix approach:** Implement the network service discovery and HTTP communication layer in `core/services/` using the existing dependencies.

## Inconsistent Naming Conventions

**Issue:** Mixed naming conventions for similar concepts across files.

**Files:**
- `packages/core/lib/models/encounter.dart` — `currentHp` (camelCase `Hp`)
- `packages/core/lib/models/player_character.dart` — `currentHP` (uppercase `HP`)
- `packages/core/lib/models/monster.dart` — `currentHP` (uppercase `HP`)
- `packages/core/lib/models/npc.dart` — `currentHP` (uppercase `HP`)
- `apps/dm_app/lib/widgets/initiative_tracker.dart` — `currentHP` (uppercase `HP`)

**Impact:** Inconsistent API surface. Developers must remember which convention each model uses.

**Fix approach:** Standardize on one convention (recommend `currentHp` per Dart effective Dart guidelines) across all models.

---

*Concerns audit: 2026-05-07*

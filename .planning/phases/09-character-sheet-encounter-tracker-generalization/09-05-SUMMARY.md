---
phase: 09-character-sheet-encounter-tracker-generalization
plan: 05
subsystem: ui
tags: [formula-evaluator, initiative-tracker, schema-driven, game-model, dm-app]

# Dependency graph
requires:
  - phase: 09-character-sheet-encounter-tracker-generalization
    provides: FormulaEvaluator (from 09-01), SchemaFormBuilder (from 09-02), CreatureDetailView rewrite (from 09-04)
provides:
  - Formula-driven initiative rolls using rulesConfig.initiativeConfig.formula
  - Schema-driven HP field key resolution via resourceFields and entity type fields
  - CombatantDragData.toFormulaContext() for formula evaluation
  - 11 tests covering formula evaluation and HP resolution
affects:
  - Future phases adding new game systems (CoC 7e) — initiative formula and HP keys will adapt automatically

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "FormulaEvaluator.evaluate for schema-driven dice rolls instead of hardcoded Random().nextInt"
    - "_resolveHPFieldKey fallback chain: resourceFields → entity type fields → hardcoded 'hitPoints'"
    - "toFormulaContext() builds ability score map from entity data for formula evaluation"
    - "gameModel passed through widget tree via InitiativeTracker parameter"

key-files:
  created:
    - apps/dm_app/test/initiative_tracker_formula_test.dart
  modified:
    - apps/dm_app/lib/widgets/initiative_tracker.dart
    - apps/dm_app/lib/main.dart

key-decisions:
  - "Moved sidebar list initialization from field declarations to initState to access GameModelService via context"
  - "Removed const from CombatantDragData constructor due to non-const _entityData default initialization"
  - "_resolveHPFieldKey is private top-level function — tested indirectly through public API (fromGameEntity factories)"

patterns-established:
  - "Initiative formula read from rulesConfig.initiativeConfig.formula, evaluated via FormulaEvaluator"
  - "HP field key resolved from schema, not hardcoded — supports any game system's HP field naming"

requirements-completed:
  - ENCTR-01
  - ENCTR-02

# Metrics
duration: 12min
completed: 2026-05-08
---

# Phase 09 Plan 05: Initiative Tracker Formula Integration Summary

**Replaced hardcoded d20+DEX initiative roll with FormulaEvaluator-driven formula from GameModel rulesConfig, and schema-driven HP field key resolution**

## Performance

- **Duration:** 12 min
- **Started:** 2026-05-08T23:00:00Z
- **Completed:** 2026-05-08T23:12:00Z
- **Tasks:** 2
- **Files modified:** 3

## Accomplishments

- Replaced hardcoded `_rng.nextInt(20) + 1 + dexMod` initiative roll with `FormulaEvaluator.evaluate(formula, context)` using formula from `rulesConfig.initiativeConfig.formula`
- Added `toFormulaContext()` method to CombatantDragData that builds ability score map (STR, DEX, CON, INT, WIS, CHA + modifiers) from entity data
- Added `_resolveHPFieldKey` helper with fallback chain: resourceFields → entity type fields → 'hitPoints'
- Updated both `CombatantDragData.fromGameEntity` and `InitiativeEntry.fromGameEntity` to use schema-resolved HP keys
- Roll history now shows formula-based result format (e.g., "Goblin: 1d20+DEX = 18")
- 11 tests covering formula context, HP resolution, and FormulaEvaluator behavior

## Task Commits

Each task was committed atomically:

1. **Task 1: Update InitiativeTracker to use FormulaEvaluator and schema-driven HP** - `4f00ec1` (feat)
   - Added gameModel parameter to InitiativeTracker widget
   - Replaced hardcoded dice roll with FormulaEvaluator.evaluate
   - Added toFormulaContext() method and _entityData field to CombatantDragData
   - Added _resolveHPFieldKey helper function
   - Updated both fromGameEntity factories to use resolved HP keys
   - Removed _rng field from _InitiativeTrackerState
   - Updated dm_app main.dart to pass gameModel through widget tree

2. **Task 2: Create tests for formula-driven initiative and schema-driven HP** - `021078a` (test)
   - 11 tests covering toFormulaContext, FormulaEvaluator, HP resolution, and fallback behavior

## Files Created/Modified

- `apps/dm_app/lib/widgets/initiative_tracker.dart` - Formula-driven initiative, schema-driven HP, toFormulaContext(), _resolveHPFieldKey
- `apps/dm_app/lib/main.dart` - Pass gameModel to InitiativeTracker and sidebar entries, moved initialization to initState
- `apps/dm_app/test/initiative_tracker_formula_test.dart` - NEW: 11 tests for formula and HP resolution

## Decisions Made

- Moved sidebar list initialization (`_characters`, `_monsters`, `_npcs`) from field declarations to `initState` to access `GameModelService` via `context.read()` — `_gameModelService` is defined in parent `_DmAppState`, not accessible from `_HomeScreenState`
- Removed `const` from `CombatantDragData` constructor because `_entityData = entityData ?? {}` is not a const expression
- `_resolveHPFieldKey` is a private top-level function (Dart convention) — cannot be directly exported for testing. Tests verify behavior indirectly through `CombatantDragData.fromGameEntity` and `InitiativeEntry.fromGameEntity` public APIs

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Fixed sidebar initialization scope**
- **Found during:** Task 1
- **Issue:** Plan specified using `_gameModelService.activeModel` in `_HomeScreenState` field declarations, but `_gameModelService` is defined in parent `_DmAppState`, not accessible from `_HomeScreenState`
- **Fix:** Moved `_characters`, `_monsters`, `_npcs` initialization from field declarations to `initState()`, using `context.read<GameModelService>().activeModel` to access the service
- **Files modified:** apps/dm_app/lib/main.dart
- **Verification:** flutter analyze passes, no undefined_identifier errors
- **Committed in:** 4f00ec1 (Task 1 commit)

---

**Total deviations:** 1 auto-fixed (1 blocking)
**Impact on plan:** Fix required for code to compile. No scope creep — same functionality, different initialization approach.

## Issues Encountered

- None

## Known Stubs

None — InitiativeTracker fully uses formula-driven initiative and schema-driven HP resolution.

## Threat Surface Scan

| Flag | File | Description |
|------|------|-------------|
| threat_flag:tampering | initiative_tracker.dart | Formula from rulesConfig JSON evaluated via FormulaEvaluator — only accepts defined grammar (no eval/arbitrary code), consistent with T-09-01 mitigation |
| threat_flag:input-validation | initiative_tracker.dart | _resolveHPFieldKey has explicit fallback chain (resourceFields → entity fields → 'hitPoints'), never returns null — mitigates T-09-13 |
| threat_flag:dos | initiative_tracker.dart | try/catch around FormulaEvaluator.evaluate with fallback to modifier+1 on error — mitigates T-09-14 |

## Verification Results

- `flutter analyze apps/dm_app/lib/widgets/initiative_tracker.dart` — No issues found
- `flutter analyze apps/dm_app/lib/main.dart` — No issues found
- `flutter test apps/dm_app/test/initiative_tracker_formula_test.dart` — 11/11 tests passed
- No hardcoded `_rng.nextInt(20) + 1` or `1d20` string in initiative roll code (only as fallback formula string)
- `_onCombatantDropped` reads formula from `rulesConfig.initiativeConfig.formula`
- `FormulaEvaluator.evaluate` computes initiative from formula + entity data
- HP field key resolved from resourceFields or entity schema, not hardcoded

## Next Phase Readiness

- Initiative tracker fully formula-driven — CoC 7e (Phase 10) can define different initiative formula without code changes
- HP field key schema-driven — supports any game system's HP field naming convention
- Roll history shows formula-based results for transparency

---
*Phase: 09-character-sheet-encounter-tracker-generalization*
*Completed: 2026-05-08*

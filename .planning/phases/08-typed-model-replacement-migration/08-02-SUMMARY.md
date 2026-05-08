---
phase: 08-typed-model-replacement-migration
plan: 02
subsystem: data
tags: [gameentity, migration, demo-data, wiki]
requires:
  - phase: 08-01
    provides: strict WikiPage entityTypeKey migration baseline
provides:
  - Unified `demoEntities` GameEntity source with pre-split helpers
  - Contract tests for strict wiki key serialization and helper invariants
affects: [dm-app, phase-08-03, migrate-01]
tech-stack:
  added: []
  patterns: ["Bridge pattern: keep legacy typed exports while introducing unified GameEntity source"]
key-files:
  created:
    - packages/core/lib/data/demo_entities.dart
    - packages/core/test/wiki_page_string_type_test.dart
    - .planning/phases/08-typed-model-replacement-migration/deferred-items.md
  modified:
    - packages/core/lib/data/data.dart
    - packages/core/lib/data/demo_player_characters.dart
    - packages/core/lib/data/demo_monsters.dart
    - packages/core/lib/data/demo_npcs.dart
key-decisions:
  - "Keep typed demo exports intact for DM compatibility while layering unified demoEntities for migration path."
  - "Use schema-contract tests to lock entityTypeKey serialization and nested mechanics payload shape."
patterns-established:
  - "Unified-source with compatibility bridge: introduce GameEntity aggregate first, remove typed callsites later."
requirements-completed: [MIGRATE-01]
duration: 43min
completed: 2026-05-08
---

# Phase 8 Plan 02: Unified demoEntities migration + core schema contract tests Summary

**Unified GameEntity demo aggregation now powers shared migration contracts while preserving DM typed-callsite compatibility via a bridge layer.**

## Performance

- **Duration:** 43 min
- **Started:** 2026-05-08T18:38:00Z
- **Completed:** 2026-05-08T19:21:35Z
- **Tasks:** 2
- **Files modified:** 8

## Accomplishments
- Added `wiki_page_string_type_test.dart` to enforce strict `entityTypeKey` serialization and legacy `pageType` exclusion.
- Added `demo_entities.dart` with unified `demoEntities` plus `demoCharacterEntities`, `demoMonsterEntities`, `demoNpcEntities` helper splits.
- Updated data barrel export to expose unified source while retaining compatibility for existing DM typed consumers.

## Task Commits

1. **Task 1: Add tests for strict wiki key serialization and GameEntity demo contracts** - `42cac5e` (test)
2. **Task 2: Implement unified demoEntities and pre-split section helpers** - `2eb6b66` (feat)
3. **Task 2 follow-up (Rule 1 bugfix): restore DM compatibility after type break** - `be4b519` (fix)

## Files Created/Modified
- `packages/core/test/wiki_page_string_type_test.dart` - Contract tests for key serialization and helper invariants.
- `packages/core/lib/data/demo_entities.dart` - Unified `GameEntity` source and helper splits.
- `packages/core/lib/data/data.dart` - Exports unified source.
- `packages/core/lib/data/demo_player_characters.dart` - Compatibility-preserving bridge adjustments.
- `packages/core/lib/data/demo_monsters.dart` - Compatibility-preserving bridge adjustments.
- `packages/core/lib/data/demo_npcs.dart` - Compatibility-preserving bridge adjustments.

## Decisions Made
- Kept typed demo exports in place to avoid breaking dm_app callsites before Phase 08-03 bridge rewiring.
- Used helper-level filtering over flattening to preserve nested mechanics data structures (D-12).

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Restored dm_app compile compatibility after initial type replacement**
- **Found during:** Task 2 verification
- **Issue:** Replacing typed demo exports with `List<GameEntity>` broke dm_app callsites expecting `PlayerCharacter`/`Monster`/`NPC`.
- **Fix:** Restored typed exports and kept unified `demoEntities` as additive bridge source.
- **Files modified:** `demo_entities.dart`, `demo_player_characters.dart`, `demo_monsters.dart`, `demo_npcs.dart`
- **Verification:** `dart test test/wiki_page_string_type_test.dart` passed; dm_app compile type errors resolved.
- **Committed in:** `be4b519`

---

**Total deviations:** 1 auto-fixed (Rule 1)
**Impact on plan:** Preserved plan intent and avoided downstream breakage while keeping migration path moving.

## Issues Encountered
- `apps/dm_app` full test suite still has pre-existing widget lifecycle/integration failures (`WikiProvider used after disposed`, provider lookup mismatch). Logged to `deferred-items.md` as out-of-scope for this plan.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- `demoEntities` and helper splits are available for DM bridge rewiring in 08-03.
- Strict serialization and unified-source contracts are now pinned by tests.

## Known Stubs
None.

## Self-Check: PASSED
- Found file: `packages/core/lib/data/demo_entities.dart`
- Found file: `packages/core/test/wiki_page_string_type_test.dart`
- Found commit: `42cac5e`
- Found commit: `2eb6b66`
- Found commit: `be4b519`

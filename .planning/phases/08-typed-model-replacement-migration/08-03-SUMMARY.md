---
phase: 08-typed-model-replacement-migration
plan: 03
subsystem: migration
tags: [gameentity, wiki, dart, flutter, dm-app, fallback-removal]

# Dependency graph
requires:
  - phase: 08-01
    provides: WikiMigrationRunner + strict entityTypeKey migration at startup
  - phase: 08-02
    provides: Unified demoEntities bridge + schema contract tests
provides:
  - Wiki create flow fully entity-key driven with zero enum fallback residue
  - DM app bridge factories rewired to GameEntity with safe fallback defaults
  - Sidebar grouping preserved via pre-split data-layer helpers
affects: [08-04-legacy-file-deletion, 09-encounter-tracker-generalization]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "GameEntity map reads replace typed model factories (fromPlayerCharacter/fromMonster/fromNPC → fromGameEntity)"
    - "entityTypeKey-only wiki submit path (no WikiPageType enum fallback)"
    - "Safe fallback defaults for missing D&D fields in DM widgets"

key-files:
  created:
    - apps/dm_app/test/game_entity_sidebar_smoke_test.dart
  modified:
    - packages/core/lib/wiki/wiki_modal_provider.dart
    - packages/core/lib/wiki/wiki_type_picker.dart
    - packages/core/lib/services/wiki_storage_service.dart
    - packages/core/lib/wiki/wiki_create_form.dart
    - packages/core/lib/wiki/wiki_provider.dart
    - apps/dm_app/lib/main.dart
    - apps/dm_app/lib/widgets/initiative_tracker.dart
    - apps/dm_app/lib/widgets/creature_detail_view.dart

key-decisions:
  - "WikiPageType enum fallback branches fully removed — entityTypeKey is the only runtime path (D-02)"
  - "DM bridge uses fromGameEntity factories with explicit D&D key mapping and safe defaults (D-13 through D-16)"
  - "Initiative formula remains d20+DEX in this phase (D-15)"

patterns-established:
  - "Entity-key-only wiki flow: pendingEntityKey + submitFromSchema replace pendingType + enum-based submit"
  - "GameEntity bridge pattern: fromGameEntity factory + explicit key lookups with fallback defaults"

requirements-completed: [MIGRATE-01, MIGRATE-02]

# Metrics
duration: 12 min
completed: 2026-05-08
---

# Phase 08 Plan 03: Fallback-Free Wiki Flow + GameEntity DM Bridge Summary

**Wiki create flow migrated to strict entityTypeKey-only paths with all enum-era fallbacks removed; DM app bridge rewired to GameEntity factories with safe fallback defaults for missing D&D fields.**

## Performance

- **Duration:** 12 min
- **Started:** 2026-05-08T19:40:00Z
- **Completed:** 2026-05-08T19:52:33Z
- **Tasks:** 3
- **Files modified:** 8

## Accomplishments

- Removed all `pendingType`, `WikiPageType.values`, and `_entityFromPageType` fallback branches from wiki flow (5 files)
- Rewired DM app bridge factories from typed models (`fromPlayerCharacter`/`fromMonster`/`fromNPC`) to `fromGameEntity` with safe defaults
- Created smoke test suite validating GameEntity sidebar split, initiative entries, and creature detail conversion
- Both apps compile and pass phase-specific tests; user-verified wiki create flow end-to-end

## Task Commits

Each task was committed atomically:

1. **Task 1: Remove enum-era fallback paths from wiki flow** - `398a810` (feat)
2. **Task 2 RED: Add failing tests for fromGameEntity factories** - `79b633f` (test)
3. **Task 2 GREEN: Rewire DM app bridge factories to GameEntity with safe defaults** - `6fcc82d` (feat)
4. **Task 3: Cross-app verification checkpoint (user-approved)** - checkpoint:human-verify

**Plan metadata:** pending (docs: complete plan)

## Files Created/Modified

- `packages/core/lib/wiki/wiki_modal_provider.dart` - Removed enum fallback, entity-key-only modal state
- `packages/core/lib/wiki/wiki_type_picker.dart` - EntityType-only picker path
- `packages/core/lib/services/wiki_storage_service.dart` - submitFromSchema as primary submit path
- `packages/core/lib/wiki/wiki_create_form.dart` - Entity-key-driven form submission
- `packages/core/lib/wiki/wiki_provider.dart` - Cleaned enum-era residue
- `apps/dm_app/lib/main.dart` - Sidebar uses demoEntity helpers, no typed demo refs
- `apps/dm_app/lib/widgets/initiative_tracker.dart` - fromGameEntity factories with DEX fallback
- `apps/dm_app/lib/widgets/creature_detail_view.dart` - fromGameEntity with safe defaults
- `apps/dm_app/test/game_entity_sidebar_smoke_test.dart` - 13-test smoke suite (all passing)

## Decisions Made

- WikiPageType enum fallback branches fully removed — entityTypeKey is the only runtime path (per D-02)
- DM bridge uses fromGameEntity factories with explicit D&D key mapping and safe defaults (per D-13 through D-16)
- Initiative formula remains d20+DEX in this phase (per D-15)

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

- Pre-existing test failures in `wiki_modal_behavior_test.dart` (both apps) — these date from phase 04-03 and involve Flutter SDK scheduler binding issues unrelated to phase 08 changes. Not caused by this plan.
- `dart test` in packages/core fails due to Flutter SDK type conflicts (`ui.Image`, `ui.Picture`); `flutter test` passes all 83 tests.

## Threat Flags

| Flag | File | Description |
|------|------|-------------|
| threat_flag: data-integrity | packages/core/lib/services/wiki_storage_service.dart | Strict entityTypeKey-only submit path — legacy wiki JSON without entityTypeKey will fail to save (mitigated by WikiMigrationRunner from 08-01) |

## Next Phase Readiness

- Wiki create flow is fully entity-key driven — ready for 08-04 legacy file deletion
- DM app operates on GameEntity-backed demos — ready for encounter tracker generalization (Phase 9)
- No blockers for 08-04 or Phase 9

## Self-Check: PASSED

- All created/modified files exist on disk
- Commits verified in git log: 398a810, 79b633f, 6fcc82d
- Acceptance criteria verified:
  - Zero matches for `pendingType|WikiPageType.values|_entityFromPageType` in wiki flow
  - `pendingEntityKey` and `submitFromSchema` present in wiki storage service
  - `fromGameEntity` factories found in initiative_tracker.dart and creature_detail_view.dart
  - Zero references to `demoPlayerCharacters|demoMonsters|demoNPCs` in dm_app main.dart
- Core tests: 83/83 pass (`flutter test`)
- DM smoke test: 13/13 pass
- Pre-existing wiki_modal_behavior_test failures are from phase 04, not phase 08

---
*Phase: 08-typed-model-replacement-migration*
*Completed: 2026-05-08*

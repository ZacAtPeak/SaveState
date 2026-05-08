---
phase: 08-typed-model-replacement-migration
plan: 01
subsystem: data-migration
tags: [wiki, migration, json, startup]
requires:
  - phase: 07-provider-rewiring
    provides: GameModel-wired wiki flow before enum deletion
provides:
  - In-place wiki JSON migration from pageType to entityTypeKey
  - Strict WikiPage deserialization requiring entityTypeKey
  - Startup migration wiring before first wiki load in both apps
affects: [phase-08-plan-03, wiki-storage, app-startup]
tech-stack:
  added: []
  patterns: [idempotent startup migration, non-blocking migration warnings]
key-files:
  created: [.planning/phases/08-typed-model-replacement-migration/08-01-SUMMARY.md]
  modified:
    - packages/core/lib/migrations/wiki_migration_runner.dart
    - packages/core/lib/models/wiki_page.dart
    - packages/core/lib/services/wiki_storage_service.dart
    - packages/core/lib/wiki/wiki_provider.dart
    - apps/dm_app/lib/main.dart
    - apps/companion_app/lib/main.dart
    - packages/core/test/wiki_migration_runner_test.dart
    - packages/core/test/wiki_page_test.dart
key-decisions:
  - "Keep WikiPage runtime type as WikiPageType for now, but make persisted JSON entityTypeKey-only"
  - "Run migration each startup and treat migration errors as warnings, never startup blockers"
patterns-established:
  - "Startup migration precedes WikiProvider.loadAll in both apps"
requirements-completed: [MIGRATE-02]
duration: 75min
completed: 2026-05-08
---

# Phase 08 Plan 01: WikiMigrationRunner + strict entityTypeKey migration at startup Summary

**Persisted wiki files are now migrated in place at startup and read through an entityTypeKey-only JSON schema, preventing enum-era pageType JSON from breaking runtime loads.**

## Performance

- **Duration:** 75 min
- **Started:** 2026-05-08T19:06:39Z
- **Completed:** 2026-05-08T20:21:00Z
- **Tasks:** 3
- **Files modified:** 8

## Accomplishments
- Added migration tests covering known-type rewrite, unknown-type skip/warning, malformed JSON skip, and idempotency behavior.
- Enforced strict `entityTypeKey` JSON parsing and serialization in `WikiPage` (legacy `pageType` key removed from model JSON contract).
- Wired startup migration before first `loadAll()` call in both apps with non-blocking warning behavior.

## Task Commits

1. **Task 1: Add failing migration tests for legacy wiki JSON rewrite** - `150e89a` (test)
2. **Task 2: Implement WikiMigrationRunner + strict WikiPage key schema** - `c616a41` (feat), `7467485` (feat)
3. **Task 3: Run migration at startup before first wiki load in both apps** - `6fa6ba4` (feat)

## Files Created/Modified
- `packages/core/lib/migrations/wiki_migration_runner.dart` - In-place wiki/pages JSON migration runner.
- `packages/core/lib/models/wiki_page.dart` - `entityTypeKey`-only JSON schema with strict missing-key `FormatException`.
- `packages/core/lib/services/wiki_storage_service.dart` - Startup migration entry point.
- `packages/core/lib/wiki/wiki_provider.dart` - Migration invocation + non-blocking warning path.
- `apps/dm_app/lib/main.dart` - Startup ordering: migration before first wiki load.
- `apps/companion_app/lib/main.dart` - Startup ordering: migration before first wiki load.
- `packages/core/test/wiki_migration_runner_test.dart` - Migration behavior coverage.
- `packages/core/test/wiki_page_test.dart` - JSON schema assertion updates.

## Decisions Made
- Kept migration scope constrained to `wiki/pages/*.json` and avoided marker files so migration remains idempotent per launch.
- Chose startup non-blocking behavior for migration warnings/errors to preserve app availability.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Prevent notify-after-dispose during async startup migration**
- **Found during:** Task 3
- **Issue:** Async startup migration/load could notify listeners after provider disposal in widget tests.
- **Fix:** Added provider disposal guard and conditional `notifyListeners()` checks.
- **Files modified:** `packages/core/lib/wiki/wiki_provider.dart`
- **Verification:** Re-ran DM integration test; dispose assertion no longer reproduced.
- **Committed in:** `6fa6ba4`

---

**Total deviations:** 1 auto-fixed (1 bug)
**Impact on plan:** Increased startup safety without changing intended behavior.

## Issues Encountered
- `apps/dm_app/test/game_entity_sidebar_smoke_test.dart` is referenced by plan verification but file is missing in repository.
- Full app test suites include pre-existing failures (`companion_app/test/widget_test.dart` expects `MyApp`, integration expectations around provider widget shape).

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- MIGRATE-02 gate is now in place for startup wiki migration + strict runtime key usage.
- Ready for follow-up plans that remove enum-era fallbacks and typed-model dependencies.

## Self-Check: PASSED
- Summary file exists at `.planning/phases/08-typed-model-replacement-migration/08-01-SUMMARY.md`.
- Task commits found: `150e89a`, `c616a41`, `7467485`, `6fa6ba4`.

---
*Phase: 08-typed-model-replacement-migration*
*Completed: 2026-05-08*

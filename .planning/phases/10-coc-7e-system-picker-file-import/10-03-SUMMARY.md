---
phase: 10-coc-7e-system-picker-file-import
plan: 03
subsystem: ui
tags: [flutter, file-picker, game-model, import, settings]

# Dependency graph
requires:
  - phase: 10-coc-7e-system-picker-file-import
    provides: GameModelValidator validates imported files before parsing
provides:
  - GameModelValidator class with sealed GameModelValidationResult
  - loadFromDocumentsDirectory() method on GameModelService
  - importExternalFile() method on GameModelService
  - Settings screen with import functionality in both apps
affects: [companion_app, dm_app, core]

# Tech tracking
tech-stack:
  added: [file_picker ^8.0.0]
  patterns: [sealed class for validation results, documents directory persistence]

key-files:
  created:
    - packages/core/lib/services/game_model_validator.dart
    - apps/companion_app/lib/screens/settings_screen.dart
    - apps/dm_app/lib/screens/settings_screen.dart
  modified:
    - packages/core/lib/services/game_model_service.dart
    - packages/core/lib/services/services.dart
    - apps/companion_app/pubspec.yaml
    - apps/dm_app/pubspec.yaml
    - apps/companion_app/lib/main.dart
    - apps/dm_app/lib/main.dart

key-decisions:
  - "GameModelValidator uses sealed class pattern for validation results (success/failure)"
  - "Imported files stored with timestamp-based filenames to avoid collisions"
  - "file_picker restricted to .json extension only"
  - "Validation failures show AlertDialog with specific error message (D-40)"

patterns-established:
  - "Sealed class for validation results enables exhaustive checking at call sites"

requirements-completed: [SYSTEM-03]

# Metrics
duration: 6 min
completed: 2026-05-09
---

# Phase 10 Plan 03: File Import with GameModelValidator Summary

**GameModelValidator with sealed validation results, loadFromDocumentsDirectory and importExternalFile methods, and settings screens in both apps with file_picker integration**

## Performance

- **Duration:** 6 min
- **Started:** 2026-05-09T01:05:41Z
- **Completed:** 2026-05-09T01:11:13Z
- **Tasks:** 4
- **Files modified:** 8

## Accomplishments

- Created GameModelValidator with sealed GameModelValidationResult (success/failure variants)
- Added loadFromDocumentsDirectory() and importExternalFile() to GameModelService
- Built settings screen with import tile and bundled system radio selector in companion_app
- Mirrored settings screen in dm_app with same import functionality

## Task Commits

Each task was committed atomically:

1. **Task 1: Create GameModelValidator in core** - `f743433` (feat)
2. **Task 2: Update GameModelService with loadFromDocumentsDirectory and import methods** - `1a01cd4` (feat)
3. **Task 3: Update companion_app settings screen with Import Custom option** - `2fdd769` (feat)
4. **Task 4: Update dm_app settings screen with Import Custom option** - `b15474b` (feat)

**Plan metadata:** `9454e67` (chore: export GameModelValidator from services)

## Files Created/Modified

- `packages/core/lib/services/game_model_validator.dart` - Validates GameModel JSON before parsing
- `packages/core/lib/services/game_model_service.dart` - Added import/persistence methods
- `packages/core/lib/services/services.dart` - Added GameModelValidator export
- `apps/companion_app/lib/screens/settings_screen.dart` - Settings with import
- `apps/companion_app/lib/main.dart` - Wired settings button
- `apps/companion_app/pubspec.yaml` - Added file_picker
- `apps/dm_app/lib/screens/settings_screen.dart` - Settings with import
- `apps/dm_app/lib/main.dart` - Already had settings button wired
- `apps/dm_app/pubspec.yaml` - Added file_picker

## Decisions Made

- GameModelValidator uses sealed class pattern for validation results (success/failure)
- Imported files stored with timestamp-based filenames to avoid collisions
- file_picker restricted to .json extension only
- Validation failures show AlertDialog with specific error message (D-40)

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None

## Next Phase Readiness

- file_picker integrated in both apps
- GameModelValidator available for pre-validation
- loadFromDocumentsDirectory ready for loading persisted files
- Ready for next plan in phase 10

---
*Phase: 10-coc-7e-system-picker-file-import*
*Completed: 2026-05-09*
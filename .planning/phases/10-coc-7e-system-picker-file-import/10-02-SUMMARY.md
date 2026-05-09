---
phase: 10-coc-7e-system-picker-file-import
plan: 02
subsystem: settings
tags: [flutter, provider, sharedpreferences, settings, system-picker]

# Dependency graph
requires:
  - phase: 10-01
    provides: CoC 7e game model JSON asset
provides:
  - Settings screen with system picker in both apps
  - GameModelService.switchToSystem() for switching bundled systems
  - SharedPreferences-based activeGameSystem persistence
affects: [10-03, 10-04]

# Tech tracking
tech-stack:
  added: [shared_preferences, path_provider]
  patterns: [ChangeNotifierProvider for settings, RadioListTile for system selection]

key-files:
  created:
    - apps/companion_app/lib/screens/settings_screen.dart
    - apps/dm_app/lib/screens/settings_screen.dart
  modified:
    - packages/core/lib/services/game_model_service.dart
    - apps/companion_app/pubspec.yaml
    - apps/dm_app/pubspec.yaml
    - apps/companion_app/lib/main.dart
    - apps/dm_app/lib/main.dart

key-decisions:
  - "Settings screen uses RadioListTile for system selection from bundledSystems list"
  - "switchToSystem() called from SettingsScreen triggers loadFromAsset + SharedPreferences persist"
  - "Migration dialog shown before system switch to warn about wiki display changes"
  - "GameModelService constructor loads persisted system via _loadPersistedSystem()"

patterns-established:
  - "GameModelService as single source of truth for activeSystemKey"
  - "Migration dialog pattern for system switching"

requirements-completed: [UX-01, UX-02]

# Metrics
duration: 6 min
completed: 2026-05-09
---

# Phase 10 Plan 02: Settings Screen with Game System Picker Summary

**Settings screen with system picker wired to GameModelService persistence, enabling live game system switching in both apps**

## Performance

- **Duration:** 6 min
- **Started:** 2026-05-09T01:04:45Z
- **Completed:** 2026-05-09T01:10:42Z
- **Tasks:** 4
- **Files modified:** 6

## Accomplishments
- Added SharedPreferences and path_provider dependencies to both companion_app and dm_app
- Extended GameModelService with persistence layer (activeSystemKey, bundledSystems, switchToSystem, _loadPersistedSystem)
- Created SettingsScreen for companion_app with RadioListTile system picker and migration dialog
- Created SettingsScreen for dm_app with identical implementation

## Task Commits

Each task was committed atomically:

1. **Task 1+2: SharedPreferences and GameModelService extension** - `0ab95c0` (feat)
2. **Task 3: companion_app settings screen** - `eb3113b` (feat)
3. **Task 4: dm_app settings screen** - `6faa665` (feat)
4. **Fix: restore persistence methods** - `1be2d71` (fix)

**Plan metadata:** `1be2d71` (docs: complete plan)

## Files Created/Modified
- `packages/core/lib/services/game_model_service.dart` - Added persistence layer (switchToSystem, bundledSystems, _loadPersistedSystem)
- `apps/companion_app/lib/screens/settings_screen.dart` - Settings screen with system picker
- `apps/dm_app/lib/screens/settings_screen.dart` - Settings screen with system picker
- `apps/companion_app/lib/main.dart` - Wired settings icon to SettingsScreen
- `apps/dm_app/lib/main.dart` - Wired settings icon to SettingsScreen
- `apps/companion_app/pubspec.yaml` - Added shared_preferences, path_provider
- `apps/dm_app/pubspec.yaml` - Added shared_preferences, path_provider

## Decisions Made

- Settings screen uses RadioListTile for system selection from bundledSystems list
- switchToSystem() called from SettingsScreen triggers loadFromAsset + SharedPreferences persist
- Migration dialog shown before system switch to warn about wiki display changes
- GameModelService constructor loads persisted system via _loadPersistedSystem()

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] GameModelService missing persistence methods**
- **Found during:** Task 2 (GameModelService extension)
- **Issue:** Previous plan (10-01) had overwritten GameModelService with import functionality, losing the SharedPreferences persistence methods that 10-02 was designed to add
- **Fix:** Re-added activeSystemKey, bundledSystems, _loadPersistedSystem(), _assetPathForSystem(), and switchToSystem() while preserving existing import functionality (loadFromDocumentsDirectory, importExternalFile, availableSystems)
- **Files modified:** packages/core/lib/services/game_model_service.dart
- **Verification:** grep 'switchToSystem' found the method; grep 'bundledSystems' found the static list
- **Committed in:** `1be2d71` (fix commit)

---

**Total deviations:** 1 auto-fixed (blocking issue - pre-existing code overwritten by 10-01)
**Impact on plan:** Fix restored critical persistence functionality without removing import capability added in 10-01. No scope creep.

## Issues Encountered
None - plan executed successfully after fix.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Both apps have SettingsScreen wired to AppBar with system picker
- GameModelService has switchToSystem() that persists selection and triggers UI update
- Ready for plan 10-03 (if applicable) or next phase

---
*Phase: 10-coc-7e-system-picker-file-import*
*Completed: 2026-05-09*
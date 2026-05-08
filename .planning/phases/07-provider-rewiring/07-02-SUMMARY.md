---
phase: 07-provider-rewiring
plan: 02
subsystem: wiki-ui
tags: [flutter, widget, game-model, entity-type, wiki-create, form-builder, submit-flow]

# Dependency graph
requires:
  - phase: 07-provider-rewiring
    provides: GameModelFormBuilder widget, WikiTypePicker with EntityTypeSchema support
  - phase: 06-service-layer-d-d-5e-asset
    provides: GameModelService, dnd5e.json asset, WikiProvider.updateGameModel
provides:
  - WikiModalProvider stores pendingEntityKey as String instead of WikiPageType enum
  - WikiCreateForm uses GameModelFormBuilder with EntityTypeSchema.fields
  - WikiModalShell passes GameModel entity types to WikiTypePicker
  - WikiCreateSubmitFlow.submitFromSchema accepts EntityTypeSchema with WikiPageType conversion
  - Both app callers updated to pass gameModel to WikiModalShell.show()
affects: [08-migration]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "EntityTypeSchema-driven create flow replacing WikiPageType.fields"
    - "submitFromSchema with backward-compat WikiPageType conversion via byName"
    - "Deprecated interface getter with default null for gradual migration"

key-files:
  created: []
  modified:
    - packages/core/lib/wiki/wiki_modal_provider.dart
    - packages/core/lib/wiki/wiki_create_form.dart
    - packages/core/lib/wiki/wiki_modal_shell.dart
    - packages/core/lib/services/wiki_storage_service.dart
    - packages/core/lib/wiki/wiki_provider.dart
    - packages/core/test/wiki_modal_provider_test.dart
    - apps/dm_app/lib/main.dart
    - apps/companion_app/lib/main.dart

key-decisions:
  - "Kept original submit() method unchanged for backward compatibility — submitFromSchema is the new preferred path"
  - "WikiCreateTarget.pendingType deprecated with default null return — avoids breaking any external implementers"
  - "WikiModalShell.gameModel parameter is nullable — allows gradual adoption across callers"

requirements-completed: [WIKI-01, WIKI-02]

# Metrics
duration: 6 min
completed: 2026-05-08
---

# Phase 07 Plan 02: WikiCreateForm + Provider Rewiring Summary

**WikiCreateForm wired to GameModelFormBuilder, WikiModalProvider/Shell/SubmitFlow updated for GameModel-driven create flow with backward-compatible WikiPageType conversion**

## Performance

- **Duration:** 6 min
- **Started:** 2026-05-08T15:03:35Z
- **Completed:** 2026-05-08T15:10:03Z
- **Tasks:** 3
- **Files modified:** 8

## Accomplishments

- WikiModalProvider stores pendingEntityKey as String, WikiCreateTarget interface updated with deprecated pendingType
- WikiCreateForm refactored to use EntityTypeSchema + GameModelFormBuilder, removing _buildStructuredField method entirely
- WikiModalShell passes gameModel entity types to WikiTypePicker, looks up EntityTypeSchema by key for form rendering
- WikiCreateSubmitFlow.submitFromSchema added with WikiPageType.values.byName conversion for backward compat
- Both app callers (dm_app, companion_app) updated to pass gameModel to WikiModalShell.show()
- dart analyze passes with zero errors across entire core package

## Task Commits

Each task was committed atomically:

1. **Task 1: Update WikiModalProvider for entity type key storage** - `42a5fec` (feat)
2. **Task 2: Refactor WikiCreateForm to use GameModelFormBuilder** - `a66c33c` (feat)
3. **Task 3: Wire WikiModalShell and update WikiCreateSubmitFlow** - `f09b60e` (feat)

**Note:** submitFromSchema was included in Task 1 commit because all edits were in working tree before first commit. Code is correct.

## Files Created/Modified

- `packages/core/lib/wiki/wiki_modal_provider.dart` — _pendingEntityKey (String) replaces _pendingType, selectCreateType accepts EntityTypeSchema
- `packages/core/lib/wiki/wiki_create_form.dart` — entitySchema parameter replaces selectedType, GameModelFormBuilder replaces _buildStructuredField
- `packages/core/lib/wiki/wiki_modal_shell.dart` — gameModel parameter added, entityTypes passed to WikiTypePicker, EntityTypeSchema lookup by pendingEntityKey
- `packages/core/lib/services/wiki_storage_service.dart` — WikiCreateTarget interface updated, submitFromSchema method added with WikiPageType conversion
- `packages/core/lib/wiki/wiki_provider.dart` — Implements new WikiCreateTarget interface with pendingEntityKey
- `packages/core/test/wiki_modal_provider_test.dart` — Test updated to use EntityTypeSchema
- `apps/dm_app/lib/main.dart` — Passes gameModel to WikiModalShell.show()
- `apps/companion_app/lib/main.dart` — Passes gameModel to WikiModalShell.show()

## Decisions Made

- Kept original `submit()` method unchanged for backward compatibility — `submitFromSchema` is the new preferred path, old method will be removed in Phase 8
- `WikiCreateTarget.pendingType` deprecated with default `null` return — avoids breaking any external implementers of the interface
- `WikiModalShell.gameModel` parameter is nullable — allows gradual adoption across callers that may not yet have GameModel available

## Deviations from Plan

None - plan executed exactly as written. All three tasks completed with dart analyze passing.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Entire wiki create flow (type picker → form → submit) is now driven by GameModel entity types
- No WikiPageType.fields calls remain in create flow files
- Phase 8 can proceed with WikiPageType enum deletion and typed model replacement
- submitFromSchema is the new preferred submission path; old submit() method is backward-compat only

## Self-Check: PASSED

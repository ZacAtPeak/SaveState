---
phase: 07-provider-rewiring
plan: 01
subsystem: wiki-ui
tags: [flutter, widget, game-model, entity-type, form-builder, type-picker]

# Dependency graph
requires:
  - phase: 06-service-layer-d-d-5e-asset
    provides: GameModelService, dnd5e.json asset, WikiProvider.updateGameModel
  - phase: 05-core-data-layer
    provides: FieldSchema, EntityTypeSchema, GameModel data classes
provides:
  - GameModelFormBuilder widget rendering form inputs from List<FieldSchema>
  - WikiTypePicker refactored to consume List<EntityTypeSchema> filtered by isWikiPageType
  - Backward-compat adapter layer for existing WikiModalShell callers
affects: [07-02, 08-migration]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Schema-driven form widget using switch on FieldInputType"
    - "Optional entityTypes parameter with enum fallback for gradual migration"
    - "Adapter callback pattern bridging EntityTypeSchema to WikiPageType"

key-files:
  created:
    - packages/core/lib/wiki/game_model_form_builder.dart
  modified:
    - packages/core/lib/wiki/wiki_type_picker.dart
    - packages/core/lib/wiki/wiki.dart
    - packages/core/lib/wiki/wiki_modal_shell.dart

key-decisions:
  - "Used field.enumOptions (not field.options) for select dropdown items per JSON schema"
  - "Made entityTypes optional on WikiTypePicker with WikiPageType fallback to avoid breaking 07-02 scope"
  - "Added adapter callbacks in wiki_modal_shell.dart converting EntityTypeSchema to WikiPageType via byName"

requirements-completed: [WIKI-01, WIKI-02]

# Metrics
duration: 8 min
completed: 2026-05-08
---

# Phase 07 Plan 01: GameModelFormBuilder + WikiTypePicker Refactor Summary

**GameModelFormBuilder widget renders schema-driven forms from FieldSchema; WikiTypePicker consumes GameModel entity types with backward-compat adapter for existing callers**

## Performance

- **Duration:** 8 min
- **Started:** 2026-05-08T15:00:00Z
- **Completed:** 2026-05-08T15:08:00Z
- **Tasks:** 3
- **Files modified:** 4

## Accomplishments

- Created GameModelFormBuilder StatefulWidget rendering text/number/multiline/select inputs from FieldSchema list
- Refactored WikiTypePicker to accept List<EntityTypeSchema>, filter by isWikiPageType, sort by sortOrder
- Added backward-compat layer: optional entityTypes with WikiPageType enum fallback, adapter callbacks in wiki_modal_shell.dart
- All files pass dart analyze with zero errors on core package

## Task Commits

Each task was committed atomically:

1. **Task 1: Create GameModelFormBuilder widget** - `ed4f4c5` (feat)
2. **Task 2: Refactor WikiTypePicker to consume GameModel entity types** - `2b0f4db` (feat)
3. **Task 3: Export GameModelFormBuilder in wiki barrel** - `0798d46` (feat)
4. **Deviation fix: Backward compat for WikiTypePicker callers** - `efaf120` (fix)

**Plan metadata:** pending (docs: complete plan)

## Files Created/Modified

- `packages/core/lib/wiki/game_model_form_builder.dart` - New StatefulWidget rendering form inputs from List<FieldSchema> via switch on inputType
- `packages/core/lib/wiki/wiki_type_picker.dart` - Refactored to accept optional List<EntityTypeSchema>, filter by isWikiPageType, sort by sortOrder; backward-compat fallback to WikiPageType enum
- `packages/core/lib/wiki/wiki.dart` - Added export for game_model_form_builder.dart
- `packages/core/lib/wiki/wiki_modal_shell.dart` - Added adapter callbacks converting EntityTypeSchema to WikiPageType via WikiPageType.values.byName

## Decisions Made

- Used `field.enumOptions` (not `field.options`) for select dropdown items — the JSON schema uses enumOptions
- Made `entityTypes` optional on WikiTypePicker with WikiPageType enum fallback — avoids breaking callers that will be fully rewired in plan 07-02
- Added adapter callbacks in wiki_modal_shell.dart that convert EntityTypeSchema to WikiPageType via `WikiPageType.values.byName(entity.key)` — temporary bridge until WikiModalProvider.pendingType is changed from WikiPageType to EntityTypeSchema

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Fixed compilation break from WikiTypePicker API change**
- **Found during:** Task 3 (full dart analyze verification)
- **Issue:** WikiTypePicker constructor signature changed from `ValueChanged<WikiPageType>` to `ValueChanged<EntityTypeSchema>` with required `entityTypes` parameter — wiki_modal_shell.dart had 4 compilation errors (missing required argument + type mismatch)
- **Fix:** Made `entityTypes` optional on WikiTypePicker with WikiPageType enum fallback; added adapter callbacks in wiki_modal_shell.dart converting EntityTypeSchema to WikiPageType
- **Files modified:** packages/core/lib/wiki/wiki_type_picker.dart, packages/core/lib/wiki/wiki_modal_shell.dart
- **Verification:** dart analyze passes with zero errors on core package
- **Committed in:** efaf120 (fix commit)

**2. [Rule 1 - Bug] Fixed DropdownButtonFormField deprecated `value` parameter**
- **Found during:** Task 1 (dart analyze)
- **Issue:** `value` parameter on DropdownButtonFormField deprecated after v3.33.0 — should use `initialValue`
- **Fix:** Changed `value:` to `initialValue:` in GameModelFormBuilder select field
- **Files modified:** packages/core/lib/wiki/game_model_form_builder.dart
- **Verification:** dart analyze reports no issues
- **Committed in:** ed4f4c5 (Task 1 commit)

**3. [Rule 1 - Bug] Fixed type mismatch in backward-compat fallback**
- **Found during:** Deviation fix #1
- **Issue:** WikiPageType.fields returns List<WikiPageFieldDefinition> but EntityTypeSchema expects List<FieldSchema> — incompatible types
- **Fix:** Pass empty list `const []` for fields in _entityFromPageType fallback (picker doesn't use fields)
- **Files modified:** packages/core/lib/wiki/wiki_type_picker.dart
- **Verification:** dart analyze passes
- **Committed in:** efaf120 (fix commit)

---

**Total deviations:** 3 auto-fixed (2 bug fixes, 1 blocking)
**Impact on plan:** All auto-fixes necessary for compilation. No scope creep. Backward-compat layer is temporary bridge for plan 07-02.

## Issues Encountered

None beyond the auto-fixed issues above.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- GameModelFormBuilder ready for wiring into WikiCreateForm (plan 07-02)
- WikiTypePicker backward-compat layer allows existing create flow to work unchanged
- Plan 07-02 will remove backward-compat layer when WikiModalProvider is fully rewired to use EntityTypeSchema

## Known Stubs

- `checkbox`, `list`, `dice` input types render as disabled TextFormField with "TODO: {type} input" label — these exist in FieldInputType enum but are not used by D&D 5e wiki types yet

## Self-Check: PASSED

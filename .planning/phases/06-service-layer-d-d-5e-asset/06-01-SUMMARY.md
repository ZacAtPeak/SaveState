---
phase: 06-service-layer-d-d-5e-asset
plan: 01
subsystem: data-layer
tags: [json-asset, game-model, dnd-5e, flutter-assets]

# Dependency graph
requires: []
provides:
  - D&D 5e GameModel JSON asset with all 7 entity types and field schemas
  - Asset registration in core pubspec.yaml for Flutter bundling
  - Ability score display names and initiative formula in rulesConfig
affects: [game-model-service, wiki-page-type-migration, encounter-tracker]

# Tech tracking
tech-stack:
  added: []
  patterns: [bundled JSON asset for game system definition, schema-driven entity types]

key-files:
  created:
    - packages/core/assets/game_models/dnd5e.json
  modified:
    - packages/core/pubspec.yaml

key-decisions:
  - "Used enumOptions for select fields (matching FieldSchema.fromJson expectations)"
  - "sortOrder assigned sequentially 0-6 matching WikiPageType enum order"

requirements-completed: [SYSTEM-01]

# Metrics
duration: 3 min
completed: 2026-05-08
---

# Phase 06 Plan 01: D&D 5e Asset Summary

**D&D 5e GameModel JSON asset with 7 entity types (Creature, Spell, Item, Rule, Location, NPC, Other), field schemas matching existing WikiPageTypeExtension.fields, ability scores, and 1d20+DEX initiative formula registered as Flutter bundled asset**

## Performance

- **Duration:** 3 min
- **Started:** 2026-05-08T14:41:00Z
- **Completed:** 2026-05-08T14:41:28Z
- **Tasks:** 2
- **Files modified:** 2

## Accomplishments
- Created dnd5e.json with schemaVersion 1, 7 entity types all with isWikiPageType:true
- All field schemas match WikiPageTypeExtension.fields exactly (keys, labels, inputTypes, enumOptions, hints, required flags)
- rulesConfig includes 6 ability scores with display names and initiative formula (1d20+DEX)
- Registered assets/game_models/ directory in core pubspec.yaml flutter.assets

## Task Commits

Each task was committed atomically:

1. **Task 1: Create dnd5e.json asset with all 7 entity types** - `1d8a812` (feat)
2. **Task 2: Register dnd5e.json asset in core pubspec.yaml** - `c63521c` (feat)

**Plan metadata:** `pending` (docs: complete plan)

## Files Created/Modified
- `packages/core/assets/game_models/dnd5e.json` - D&D 5e GameModel JSON asset with all entity types, field schemas, ability scores, initiative config
- `packages/core/pubspec.yaml` - Added flutter.assets declaration for assets/game_models/

## Decisions Made
- Used `enumOptions` in JSON for select-type fields (matches FieldSchema.fromJson which reads `enumOptions` from JSON)
- Assigned `sortOrder` 0-6 sequentially matching WikiPageType enum order (creature=0 through other=6)
- Followed FieldSchema.toJson pattern: only include non-null optional fields in JSON

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
None

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- D&D 5e GameModel asset ready for GameModelService to load via rootBundle
- Ready for CoC 7e GameModel asset (next plan in phase)
- WikiPageType migration can proceed once GameModelService loads this asset

---
*Phase: 06-service-layer-d-d-5e-asset*
*Completed: 2026-05-08*

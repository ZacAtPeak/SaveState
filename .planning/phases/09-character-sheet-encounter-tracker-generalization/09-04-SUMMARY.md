---
phase: 09-character-sheet-encounter-tracker-generalization
plan: 04
subsystem: ui
tags: [schema-driven-form, flutter-widgets, creature-detail, game-entity, dm-app]

# Dependency graph
requires:
  - phase: 09-character-sheet-encounter-tracker-generalization
    provides: Extended FieldSchema, FormulaEvaluator, comprehensive dnd5e.json (from 09-01), SchemaFormBuilder widget tree (from 09-02)
provides:
  - Schema-driven CreatureDetailView replacing 784-line hardcoded D&D rendering
  - GameEntity wired through DM app sidebar to CreatureDetailView
  - CreatureDetail class preserved but @Deprecated for backwards compatibility
  - 5 widget tests for schema-driven creature detail rendering
affects:
  - 09-05 (companion app character sheet — already built, uses same SchemaFormBuilder pattern)

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "SchemaFormBuilder as drop-in replacement for hardcoded widget trees"
    - "Selector<GameModelService, GameModel?> for reactive GameModel access in detail views"
    - "GameEntity as data carrier through sidebar instead of CreatureDetail DTO"
    - "Backwards-compatible deprecation pattern: keep old class, mark @Deprecated"

key-files:
  created:
    - apps/dm_app/test/creature_detail_schema_test.dart
  modified:
    - apps/dm_app/lib/widgets/creature_detail_view.dart
    - apps/dm_app/lib/main.dart

key-decisions:
  - "Used e.drag.id as map key for _detailById since GameEntity has no direct id getter (ID stored in data map)"
  - "Used _selectedDetail?.getString('id') for sidebar selectedId since GameEntity lacks id property"
  - "CreatureDetail.fromGameEntity factory retained with hardcoded field keys — acceptable since it's a data class, not a widget, and marked @Deprecated"

patterns-established:
  - "Detail view pattern: null entity → placeholder, non-null entity → Selector<GameModelService> → SchemaFormBuilder"
  - "Sidebar entry carries both CreatureDetail (for drag data) and GameEntity (for schema rendering) during migration period"

requirements-completed:
  - CHAR-01
  - ENCTR-02

# Metrics
duration: 8min
completed: 2026-05-08
---

# Phase 09 Plan 04: CreatureDetailView Schema-Driven Rewrite Summary

**Rewrote DM app CreatureDetailView from 784-line hardcoded D&D rendering to ~196-line schema-driven view using SchemaFormBuilder, with GameEntity wired through sidebar**

## Performance

- **Duration:** 8 min
- **Started:** 2026-05-08T22:48:00Z
- **Completed:** 2026-05-08T22:56:15Z
- **Tasks:** 2
- **Files modified:** 3

## Accomplishments

- Replaced 784-line hardcoded CreatureDetailView (15 widget classes, 5 tabs, ability cards, spell slots, skills grid) with 196-line schema-driven view using SchemaFormBuilder
- Wired GameEntity through DM app sidebar (_SidebarEntry, _detailById, _selectedDetail) enabling schema-driven rendering
- CreatureDetail class preserved with @Deprecated annotation for backwards compatibility with CombatantDragData
- 5 widget tests covering null placeholder, loading state, unknown entity type error, SchemaFormBuilder rendering, and absence of hardcoded field strings

## Task Commits

Each task was committed atomically:

1. **Task 1: Rewrite CreatureDetailView to use SchemaFormBuilder** - `76caca7` (feat)
   - Replaced hardcoded rendering with SchemaFormBuilder + Selector<GameModelService>
   - Removed 15 hardcoded widget classes (_StatRow, _AbilityCard, _SkillsTab, etc.)
   - File reduced from 784 to 196 lines
   - CreatureDetail class kept with @Deprecated for sidebar compat

2. **Task 2: Wire GameEntity through DM app main.dart** - `efa42f9` (feat)
   - Added entity field to _SidebarEntry
   - Changed _selectedDetail from CreatureDetail? to GameEntity?
   - Changed _detailById from Map<String, CreatureDetail> to Map<String, GameEntity>
   - Created 5 widget tests for schema-driven creature detail

## Files Created/Modified

- `apps/dm_app/lib/widgets/creature_detail_view.dart` - Rewritten: schema-driven view using SchemaFormBuilder (784 → 196 lines)
- `apps/dm_app/lib/main.dart` - Updated: _SidebarEntry with entity field, _selectedDetail as GameEntity?, _detailById as Map<String, GameEntity>
- `apps/dm_app/test/creature_detail_schema_test.dart` - NEW: 5 widget tests for schema-driven creature detail

## Decisions Made

- Used `e.drag.id` as map key for `_detailById` since `GameEntity` has no direct `id` getter (ID stored in data map via `getString('id')`)
- Used `_selectedDetail?.getString('id')` for sidebar `selectedId` parameter since `GameEntity` lacks `id` property
- `CreatureDetail.fromGameEntity` factory retained with hardcoded field key strings — acceptable since it's a data class (not a widget) and marked `@Deprecated`

## Deviations from Plan

None - plan executed exactly as written.

## Known Stubs

None — CreatureDetailView fully renders from schema via SchemaFormBuilder. The `onDataChanged: (_) {}` callback is intentionally empty because the DM app detail view is read-only (not a stub — by design).

## Threat Surface Scan

| Flag | File | Description |
|------|------|-------------|
| threat_flag:tampering | creature_detail_view.dart | onDataChanged is empty function `{}` — no data mutation possible from detail view (T-09-10 mitigated) |
| threat_flag:code-quality | creature_detail_view.dart | CreatureDetail class marked @Deprecated, retained only for sidebar drag compat until Plan 05 (T-09-11 accepted) |

## Issues Encountered

- GameEntity has no `id` getter — ID is stored in the data map. Fixed by using `e.drag.id` (from CombatantDragData) as the map key for `_detailById`, and `_selectedDetail?.getString('id')` for sidebar selection tracking.

## Verification Results

- `flutter analyze apps/dm_app/lib/` — No issues found
- `flutter test apps/dm_app/test/creature_detail_schema_test.dart` — 5/5 tests passed

## Next Phase Readiness

- CreatureDetailView fully schema-driven, ready for initiative tracker formula integration (09-05)
- Sidebar carries GameEntity alongside CreatureDetail for gradual migration
- SchemaFormBuilder proven in both DM app and companion app character sheet

---
*Phase: 09-character-sheet-encounter-tracker-generalization*
*Completed: 2026-05-08*

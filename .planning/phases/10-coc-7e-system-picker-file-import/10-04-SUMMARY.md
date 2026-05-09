---
phase: 10-coc-7e-system-picker-file-import
plan: 04
subsystem: encounter
tags: [initiative, coc7e, dex-rank, system-switching, game-model]

# Dependency graph
requires:
  - phase: 10-01
    provides: coc7e.json with investigator/adversary types, isRolled: false in initiativeConfig
  - phase: 10-02
    provides: GameModelService.switchToSystem() wired to settings UI
  - phase: 10-03
    provides: File import with GameModelValidator
provides:
  - CoC initiative uses DEX-rank sort (no dice roll) when isRolled: false
  - CombatantDragData includes 'dex' and 'dexterity' in formula context
affects: [encounter-tracker, initiative-sorting]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "DEX-rank sort: isRolled: false flag gates dice formula vs raw DEX value"

# Key files
key-files:
  created: []
  modified:
    - apps/dm_app/lib/widgets/initiative_tracker.dart

key-decisions:
  - "D-41: CoC initiative uses isRolled: false flag instead of special formula token"
  - "D-42: No tiebreaker for same-DEX — unstable sort"
  - "D-43: Display raw DEX value for player reference during tie negotiation"
  - "CombatantDragData.toFormulaContext() includes both 'dex' and 'dexterity' keys for CoC compatibility"

patterns-established:
  - "initiativeConfig.isRolled: false → no formula evaluation, raw DEX used directly"
  - "System switching updates initiative behavior without restart"

requirements-completed: [UX-02, UX-03, ENCTR-01]

# Metrics
duration: 2 min
completed: 2026-05-09
---

# Phase 10 Plan 04: CoC Initiative (DEX-Rank Sort) Integration Summary

**Wire up CoC initiative logic (DEX-rank sort with isRolled: false flag) and verify end-to-end system switching across wiki types, character sheet, and encounter tracker.**

## Performance

- **Duration:** 2 min
- **Started:** 2026-05-09T01:13:56Z
- **Completed:** 2026-05-09T01:15:38Z
- **Tasks:** 2
- **Files modified:** 1

## Accomplishments

- InitiativeTracker now checks `isRolled: false` in initiativeConfig and routes to DEX-rank sort (CoC) vs dice formula (D&D)
- DEX-rank displays raw DEX value with "no roll" message — D-43 satisfied
- CombatantDragData.toFormulaContext() updated to include both 'dex' (CoC) and 'dexterity' (D&D) keys
- `_entityDataFor()` helper safely extracts numeric fields from CombatantDragData

## Task Commits

Each task was committed atomically:

1. **Task 1: Update InitiativeTracker to handle isRolled: false (DEX-rank sort)** - `609ed94` (feat)
   - isRolled: false → use raw DEX value, "DEX = X (no roll)" message
   - isRolled: true (default) → dice formula evaluation (D&D behavior unchanged)
   - toFormulaContext() includes 'dex' alongside 'dexterity'

**Plan metadata:** `609ed94` (docs: complete plan)

## Files Created/Modified

- `apps/dm_app/lib/widgets/initiative_tracker.dart` - DEX-rank sort with isRolled: false, 'dex'/'dexterity' dual support in toFormulaContext()

## Decisions Made

- D-41: CoC initiative uses `isRolled: false` flag — tracker checks this instead of evaluating dice formula
- D-42: No tiebreaker for same-DEX — unstable sort
- D-43: Display raw DEX value for tie negotiation reference
- CombatantDragData.toFormulaContext() includes both 'dex' and 'dexterity' keys so CoC entities (which store DEX as 'dex') work with formula evaluation

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None.

## Next Phase Readiness

- Phase 10 complete — all 4 plans finished
- CoC 7e system fully integrated: wiki types, character sheet fields, initiative config
- External file import with validation working (plan 10-03)
- Ready for end-to-end verification across the full system switching flow

---
*Phase: 10-coc-7e-system-picker-file-import*
*Completed: 2026-05-09*

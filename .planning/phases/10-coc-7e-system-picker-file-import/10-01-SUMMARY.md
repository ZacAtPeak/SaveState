---
phase: 10-coc-7e-system-picker-file-import
plan: 01
subsystem: game-model
tags: [coc7e, gamemodel, json, call-of-cthulhu, asset]

# Dependency graph
requires:
  - phase: 09-character-sheet-encounter-tracker-generalization
    provides: FieldSchema pattern (section, subFields, itemSchema, attributeRef), GameModel structure, rulesConfig schema
provides:
  - packages/core/assets/game_models/coc7e.json — CoC 7e game system definition
affects:
  - Phase 10-02 (system picker UI)
  - Phase 10-03 (file import)

# Tech tracking
tech-stack:
  added: [coc7e.json]
  patterns: [FieldSchema pattern mirroring dnd5e.json, 8-attribute system, percentile skills, DEX-rank initiative]

key-files:
  created:
    - packages/core/assets/game_models/coc7e.json
  modified: []

key-decisions:
  - "D-28: Keep same FieldSchema pattern as D&D 5e"
  - "D-29: CoC attribute fields store values directly, no derivedFrom formulas"
  - "D-30: CoC entity types: investigator + creature + location + item + rule"
  - "D-31: CoC investigator has 8 characteristics with min:15, max:90"
  - "D-32: CoC creature has hp/armor/attacks/specialAbilities/sanityEffects, no CR/XP"
  - "D-41: initiativeConfig uses isRolled: false for DEX-rank sort"

patterns-established:
  - "GameModel JSON follows FieldSchema pattern with inputType/section/subFields/itemSchema"
  - "Attribute fields use attributeRef to link to rulesConfig.attributes"
  - "initiativeConfig.isRolled flag drives initiative behavior"

requirements-completed: [SYSTEM-02]

# Metrics
duration: 3min
completed: 2026-05-09
---

# Phase 10 Plan 01: CoC 7e GameModel Summary

**Call of Cthulhu 7e GameModel JSON asset with investigator/creature/location/item/rule entities, 8 characteristics, percentile skills, and DEX-rank initiative**

## Performance

- **Duration:** 3 min
- **Started:** 2026-05-09T00:59:28Z
- **Completed:** 2026-05-09T01:02:14Z
- **Tasks:** 1 completed
- **Files modified:** 1 created

## Accomplishments
- Created coc7e.json GameModel with 5 entity types (investigator, creature, location, item, rule)
- Investigator entity has 8 characteristics (STR/CON/SIZ/DEX/APP/INT/POW/EDU) each with min:15, max:90
- Investigator has 8 derived fields (Sanity, Luck, Magic Points, Build, HP + current variants)
- Investigator has skills list with percentile values (name + value subFields)
- Creature entity has hp, armor, attacks, specialAbilities, sanityEffects — no CR/XP/class/spellSlots
- InitiativeConfig uses isRolled: false flag for DEX-rank sort (per D-41)
- Valid JSON, 181 lines, follows dnd5e.json FieldSchema pattern

## Task Commits

Each task was committed atomically:

1. **Task 1: Create coc7e.json with investigator entity** - `b91ed0c` (feat)

**Plan metadata:** (pending final commit)

## Files Created/Modified
- `packages/core/assets/game_models/coc7e.json` - CoC 7e game system definition with 5 entity types, 8-attribute system, percentile skills, and DEX-rank initiative config

## Decisions Made
- D-28: Keep same FieldSchema pattern as D&D 5e — CoC uses the same inputType/section/subFields/itemSchema structure
- D-29: CoC doesn't use `derivedFrom` for modifiers — attribute fields store values directly, no formula evaluation needed
- D-30: CoC entity types: investigator + creature + location + item + rule
- D-31: CoC investigator fields: 8 characteristics (STR/CON/SIZ/DEX/APP/INT/POW/EDU), derived Sanity/Luck/MP/Build, percentile skills
- D-32: CoC creature fields: hp, armor, attacks, specialAbilities, sanityEffects — no CR/XP/legendary actions
- D-41: CoC initiative uses `isRolled: false` flag — DEX-rank sort (no dice)

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
None

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness
- coc7e.json created and committed (181 lines)
- Ready for Phase 10-02: system picker UI with settings screen
- Both companion_app and dm_app will need settings screen with RadioListTile for game system selection
- SYSTEM-02 requirement fulfilled

---
*Phase: 10-coc-7e-system-picker-file-import*
*Completed: 2026-05-09*
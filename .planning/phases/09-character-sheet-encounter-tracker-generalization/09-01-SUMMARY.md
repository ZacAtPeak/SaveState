---
phase: 09-character-sheet-encounter-tracker-generalization
plan: 01
subsystem: models
tags: [field-schema, formula-evaluator, dart, tdd, recursive-descent-parser, dice-notation, game-model]

# Dependency graph
requires:
  - phase: 08-typed-model-replacement-migration
    provides: GameEntity replacing typed models, GameModelParser validation
provides:
  - Extended FieldSchema with section, subFields, itemSchema, attributeRef properties
  - FieldInputType.group enum value for nested field containers
  - FormulaEvaluator with recursive descent parser supporting arithmetic, dice notation, field refs, floor/ceil
  - Circular dependency detection via DFS on formula dependency graph
  - Comprehensive dnd5e.json with 33 creature fields organized by sections
  - Extended rulesConfig with attributes, skills, resourceFields, statusConditions
affects:
  - 09-02 (schema-driven form builder)
  - 09-03 (CreatureDetailView schema-driven rewrite)
  - 09-04 (initiative tracker formula integration)
  - 09-05 (companion app character sheet)

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "TDD RED-GREEN-REFACTOR for model extensions"
    - "Recursive descent parser for formula grammar"
    - "Sealed class AST node hierarchy"
    - "Conditional JSON serialization for optional fields"

key-files:
  created:
    - packages/core/lib/models/formula_evaluator.dart
    - packages/core/test/field_schema_extension_test.dart
    - packages/core/test/formula_evaluator_test.dart
  modified:
    - packages/core/lib/models/field_schema.dart
    - packages/core/assets/game_models/dnd5e.json

key-decisions:
  - "Hand-rolled recursive descent parser instead of math_expressions package (simpler for limited grammar)"
  - "Sealed class AST hierarchy for type-safe node evaluation"
  - "DFS-based circular dependency detection before formula evaluation"
  - "Conditional JSON serialization (if field != null) to maintain backward compatibility"

patterns-established:
  - "TDD pattern: failing tests committed first, then minimal implementation"
  - "FormulaError exception class for all formula-related errors"
  - "getDependencies() extracts field refs for dependency graph construction"

requirements-completed:
  - CHAR-01
  - CHAR-02
  - ENCTR-01
  - ENCTR-02

# Metrics
duration: 15min
completed: 2026-05-08
---

# Phase 09 Plan 01: FieldSchema Extension, FormulaEvaluator, Comprehensive dnd5e.json

**Extended FieldSchema with section grouping and nested structures, built FormulaEvaluator with recursive descent parser for arithmetic + dice notation, and rewrote dnd5e.json as comprehensive 33-field creature schema with extended rulesConfig**

## Performance

- **Duration:** 15 min
- **Started:** 2026-05-08T22:11:00Z
- **Completed:** 2026-05-08T22:26:28Z
- **Tasks:** 3
- **Files modified:** 5

## Accomplishments

- Extended FieldSchema with 4 new properties (section, subFields, itemSchema, attributeRef) and FieldInputType.group with full JSON round-trip serialization
- Built FormulaEvaluator as pure-Dart recursive descent parser supporting arithmetic (+, -, *, /), parentheses, dice notation (NdM, NdM+k), field references, floor/ceil functions, and circular dependency detection
- Rewrote dnd5e.json creature entity from 6 fields to 33 fields organized by 5 sections (Vitals, Abilities, Combat, Spells, Lore) with extended rulesConfig (attributes, 18 skills, resourceFields, 15 statusConditions, initiativeConfig)

## Task Commits

Each task was committed atomically:

1. **Task 1: Extend FieldSchema with section, subFields, itemSchema, attributeRef + group inputType** - `750f244` (feat)
   - TDD: 12 tests committed first (RED), then implementation (GREEN)
2. **Task 2: Build FormulaEvaluator with recursive descent parser** - `310dc9a` (feat)
   - TDD: 27 tests committed first (RED), then implementation (GREEN)
3. **Task 3: Extend dnd5e.json with comprehensive creature fields** - `5ffbbf0` (feat)
   - Non-TDD: JSON rewrite with acceptance criteria verification

## Files Created/Modified

- `packages/core/lib/models/field_schema.dart` - Extended with section, subFields, itemSchema, attributeRef + group inputType
- `packages/core/lib/models/formula_evaluator.dart` - NEW: Pure-Dart formula parser/evaluator with AST, recursive descent parser, circular dependency detection
- `packages/core/assets/game_models/dnd5e.json` - Comprehensive creature schema (33 fields) + extended rulesConfig
- `packages/core/test/field_schema_extension_test.dart` - NEW: 12 tests for FieldSchema extensions
- `packages/core/test/formula_evaluator_test.dart` - NEW: 27 tests for formula parsing, evaluation, dice, circular detection

## Decisions Made

- Used hand-rolled recursive descent parser instead of math_expressions package — the grammar (arithmetic + dice + field refs + floor/ceil) is simple enough that a third-party dependency would add unnecessary complexity
- Sealed class AST hierarchy (NumberNode, FieldRefNode, DiceNode, BinaryOpNode, FunctionNode) for type-safe evaluation
- DFS-based circular dependency detection runs before evaluation, not during — prevents infinite recursion entirely
- Conditional JSON serialization (`if (field != null)`) maintains backward compatibility with existing schemas that don't use new properties

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed test typo in floor formula**
- **Found during:** Task 2 (FormulaEvaluator GREEN phase)
- **Issue:** Test had `floor((12 - 10) / 2` missing closing parenthesis, causing parse failure
- **Fix:** Added missing `)` to test formula string
- **Files modified:** packages/core/test/formula_evaluator_test.dart
- **Verification:** All 27 tests pass after fix
- **Committed in:** 310dc9a (part of task commit)

---

**Total deviations:** 1 auto-fixed (1 test typo)
**Impact on plan:** Trivial test fix, no scope creep.

## TDD Gate Compliance

| Plan | RED | GREEN | REFACTOR | Status |
|------|-----|-------|----------|--------|
| Task 1 (FieldSchema) | ✓ test commit | ✓ feat commit | — | Pass |
| Task 2 (FormulaEvaluator) | ✓ test commit | ✓ feat commit | — | Pass |

Both TDD tasks have proper RED → GREEN commit sequence.

## Threat Surface Scan

| Flag | File | Description |
|------|------|-------------|
| threat_flag:tampering | formula_evaluator.dart | Recursive descent parser only accepts defined grammar — no eval(), no function injection, no string interpolation. AST evaluation is sandboxed (T-09-01 mitigated) |
| threat_flag:dos | formula_evaluator.dart | Circular dependency detection via DFS prevents infinite recursion from derivedFrom formula cycles (T-09-03 mitigated) |

## Issues Encountered

None beyond the test typo fixed during GREEN phase.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- Foundation complete for schema-driven form builder (09-02) — FieldSchema has all required properties
- FormulaEvaluator ready for initiative tracker integration (09-04) — supports 1d20+DEX formula
- dnd5e.json comprehensive enough for CreatureDetailView rewrite (09-03) — all 33 fields with sections
- All core tests pass (57 tests)

---
*Phase: 09-character-sheet-encounter-tracker-generalization*
*Completed: 2026-05-08*

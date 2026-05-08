---
phase: 09-character-sheet-encounter-tracker-generalization
plan: 02
subsystem: ui
tags: [schema-driven-form, flutter-widgets, field-renderer, section-renderer, list-field-renderer, widget-tests]

# Dependency graph
requires:
  - phase: 09-character-sheet-encounter-tracker-generalization
    provides: Extended FieldSchema, FormulaEvaluator, comprehensive dnd5e.json (from 09-01)
provides:
  - SchemaFormBuilder widget — main form orchestrator grouping fields by section
  - SectionRenderer widget — renders section Card with header and field children
  - FieldRenderer widget — maps 8 inputTypes to Flutter input widgets
  - ListFieldRenderer widget — renders list fields with add/remove using itemSchema
  - derivedFrom formula evaluation context via data map parameter
  - 10 widget tests covering section grouping, subFields, lists, derivedFrom, pre-fill
affects:
  - 09-03 (CreatureDetailView schema-driven rewrite — will consume SchemaFormBuilder)
  - 09-05 (companion app character sheet — will consume SchemaFormBuilder)

# Tech tracking
tech-stack:
  added: [flutter_test (SDK)]
  patterns:
    - "Composable widget tree: SchemaFormBuilder → SectionRenderer → FieldRenderer → input widgets"
    - "Data-map approach (Map<String, dynamic>) instead of TextEditingController per field"
    - "Section ordering with known D&D sections first, unknown sections appended"
    - "derivedFrom evaluation with full data context passed down widget tree"

key-files:
  created:
    - packages/core/lib/widgets/schema_form_builder.dart
    - packages/core/lib/widgets/section_renderer.dart
    - packages/core/lib/widgets/field_renderer.dart
    - packages/core/lib/widgets/list_field_renderer.dart
    - packages/core/test/schema_form_builder_test.dart
  modified:
    - packages/core/lib/models/models.dart
    - packages/core/pubspec.yaml

key-decisions:
  - "Added data parameter to FieldRenderer for derivedFrom evaluation context (plan code assumed value was full data map, but value is per-field — Rule 1 auto-fix)"
  - "Removed gameModel null check from derivedFrom rendering — formula evaluation works standalone with data context"
  - "Used flutter_test SDK for widget tests in core package (previously only test package for pure Dart tests)"

patterns-established:
  - "Data-map pattern: each field reads/writes its key in shared Map<String, dynamic>"
  - "SectionRenderer passes full data map to FieldRenderer for derivedFrom context"
  - "ListFieldRenderer uses UUID for item IDs to enable stable list item keys"

requirements-completed:
  - CHAR-01
  - CHAR-02

# Metrics
duration: 12min
completed: 2026-05-08
---

# Phase 09 Plan 02: SchemaFormBuilder, SectionRenderer, FieldRenderer, ListFieldRenderer

**Built composable schema-driven form widget tree in core: SchemaFormBuilder orchestrates section grouping, SectionRenderer renders Cards, FieldRenderer maps 8 inputTypes to Flutter widgets, ListFieldRenderer handles add/remove with itemSchema — all backed by 10 passing widget tests**

## Performance

- **Duration:** 12 min
- **Started:** 2026-05-08T22:24:00Z
- **Completed:** 2026-05-08T22:36:01Z
- **Tasks:** 2
- **Files modified:** 7

## Accomplishments

- FieldRenderer maps all 8 inputTypes (text, number, multiline, select, checkbox, dice, group, list) to appropriate Flutter widgets with validation and required-field asterisks
- SchemaFormBuilder groups fields by section property with ordered rendering (Vitals → Abilities → Combat → Skills → Spells → Lore → General)
- SectionRenderer renders Card containers with section headers and field children; group fields with subFields render as nested blocks
- ListFieldRenderer renders add/remove controls with itemSchema-based subField rendering per item
- derivedFrom fields display computed values via FormulaEvaluator with full data context
- 10 widget tests covering section grouping, subFields, list add/remove, derivedFrom computation, empty/populated data, required asterisk, checkbox, select

## Task Commits

Each task was committed atomically:

1. **Task 1: Build FieldRenderer** - `fac8472` (feat)
   - FieldRenderer widget mapping inputType to Flutter inputs
   - derivedFrom read-only computed value display
   - ListFieldRenderer stub created alongside (needed for compilation)
   - Added formula_evaluator.dart export to models.dart barrel

2. **Task 2: Build SectionRenderer, SchemaFormBuilder, and tests** - `87f155a` (feat)
   - SectionRenderer with Card + section header + field children
   - SchemaFormBuilder with section grouping and ordered rendering
   - ListFieldRenderer full implementation with add/remove/itemSchema
   - 10 widget tests all passing
   - Added flutter_test SDK dependency to core pubspec.yaml

## Files Created/Modified

- `packages/core/lib/widgets/field_renderer.dart` - Maps 8 inputTypes to Flutter widgets, derivedFrom evaluation, validation
- `packages/core/lib/widgets/section_renderer.dart` - Section Card renderer with group field support
- `packages/core/lib/widgets/schema_form_builder.dart` - Main form orchestrator with section grouping
- `packages/core/lib/widgets/list_field_renderer.dart` - List field with add/remove, itemSchema subFields
- `packages/core/test/schema_form_builder_test.dart` - 10 widget tests
- `packages/core/lib/models/models.dart` - Added formula_evaluator.dart export
- `packages/core/pubspec.yaml` - Added flutter_test SDK dev_dependency

## Decisions Made

- Added `data` parameter to FieldRenderer (Map<String, dynamic>?) for derivedFrom formula evaluation context — the plan's code assumed `value` was the full data map, but `value` is the individual field's value. The full data map must come from the parent (SchemaFormBuilder → SectionRenderer → FieldRenderer) for formulas like `floor((strength - 10) / 2)` to resolve `strength` correctly.
- Removed `gameModel != null` guard from derivedFrom rendering — formula evaluation only needs the data context, not the GameModel. This simplifies the widget API and allows derivedFrom fields to work in isolation.
- Used `flutter_test` SDK for widget tests in core package — the core package previously only used `test` for pure Dart unit tests. Widget tests require the Flutter test framework.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed derivedFrom data context in FieldRenderer**
- **Found during:** Task 1 (FieldRenderer implementation)
- **Issue:** Plan's `_extractDataFromValue()` assumed `value` parameter is `Map<String, dynamic>` (full data context), but `value` is the individual field's value (string, number, bool, etc.). derivedFrom formulas like `floor((strength - 10) / 2)` need access to ALL field values, not just the current field's value.
- **Fix:** Added `data` parameter (Map<String, dynamic>?) to FieldRenderer. SectionRenderer passes the full data map. `_buildDerivedField` uses `data ?? _extractDataFromValue()` as fallback.
- **Files modified:** packages/core/lib/widgets/field_renderer.dart
- **Verification:** derivedFrom test passes — `floor((strength - 10) / 2)` with `{'strength': 15}` correctly displays "2"
- **Committed in:** 87f155a (part of Task 2 commit)

---

**Total deviations:** 1 auto-fixed (1 data context bug)
**Impact on plan:** Essential fix — without it, derivedFrom formulas would never resolve field references correctly. No scope creep.

## Known Stubs

None — all widgets are fully implemented with data wiring. ListFieldRenderer delegates to FieldRenderer for subFields, which is the intended design (not a stub).

## Threat Surface Scan

| Flag | File | Description |
|------|------|-------------|
| threat_flag:tampering | field_renderer.dart | derivedFrom formulas evaluated via FormulaEvaluator (sandboxed AST, no eval()) — FormulaError caught and displays "Error" text (T-09-05 mitigated) |
| threat_flag:input-validation | field_renderer.dart | Flutter Form/FormField validators enforce required/min/max constraints at field level before onChanged fires (T-09-06 mitigated) |

## Issues Encountered

- Test "renders null section fields as General": "Lore" text appeared twice (section header + field label) — fixed by using `findsWidgets` instead of `findsOneWidget`
- Test "populated data map pre-fills field values": TextFormField order depends on section ordering (Vitals before General) — fixed by using `any()` matcher instead of positional access
- Test "derivedFrom fields show computed values": Was failing because `gameModel != null` check prevented derivedFrom rendering — fixed by removing the unnecessary guard

## Self-Check: PASSED

- All created files verified on disk
- `dart analyze packages/core/lib/widgets/` — No issues found
- `flutter test packages/core/test/schema_form_builder_test.dart` — 10 tests passed
- Both commits present: `fac8472` (Task 1), `87f155a` (Task 2)

## Next Phase Readiness

- SchemaFormBuilder ready for CreatureDetailView rewrite (09-03) — both apps can consume this widget
- FieldRenderer handles all 8 inputTypes with validation
- ListFieldRenderer supports nested itemSchema with add/remove
- derivedFrom formula evaluation works with full data context
- All widget tests pass (10/10)

---
*Phase: 09-character-sheet-encounter-tracker-generalization*
*Completed: 2026-05-08*

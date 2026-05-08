---
phase: 05-core-data-layer
plan: 01
subsystem: data-models
tags: [schema, json, dart, field-validation, game-model]

# Dependency graph
requires:
  - phase: 04-research
    provides: schema design decisions (D-01 through D-07)
provides:
  - FieldSchema class with 7 input types and 8 validation constraint fields
  - EntityTypeSchema class with nested FieldSchema list and isWikiPageType flag
  - GameModel class as top-level schema container with entityTypes and rulesConfig
  - Barrel export updated in models.dart
affects: [05-02, 05-03, 06-game-model-service, 07-dnd5e-bundle, 08-wiki-migration]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - Pure-Dart immutable data classes with const constructors
    - Manual toJson/fromJson serialization (no codegen)
    - Enum serialization via .name and .values.byName()
    - Optional fields use `as Type?` casts with null-coalescing defaults
    - Nested list deserialization via .map().toList() with Map.from()

key-files:
  created:
    - packages/core/lib/models/field_schema.dart
    - packages/core/lib/models/entity_type_schema.dart
    - packages/core/lib/models/game_model.dart
  modified:
    - packages/core/lib/models/models.dart

key-decisions:
  - "FieldInputType has exactly 7 values — percentile and derived expressed through validation constraints, not separate types"
  - "schemaVersion is int not String for numeric comparison"
  - "rulesConfig is Map<String, dynamic> — free-form, validated at higher layer"

patterns-established:
  - "Schema classes: const constructor, all fields final, manual toJson/fromJson"
  - "Enum serialization: inputType.name for toJson, EnumType.values.byName() for fromJson"
  - "Nested object lists: .map((e) => Type.fromJson(Map<String, dynamic>.from(e as Map))).toList()"

requirements-completed: [SCHEMA-01]

# Metrics
duration: 2min
completed: 2026-05-08
---

# Phase 05 Plan 01: Core Data Layer Summary

**FieldSchema, EntityTypeSchema, and GameModel pure-Dart data classes with JSON serialization — the schema foundation that replaces hardcoded WikiPageType.fields with runtime-configurable JSON-driven schemas**

## Performance

- **Duration:** 2 min
- **Started:** 2026-05-08T14:09:00Z
- **Completed:** 2026-05-08T14:11:35Z
- **Tasks:** 3
- **Files modified:** 4 (3 created, 1 modified)

## Accomplishments

- Created FieldInputType enum with 7 values (text, number, multiline, select, checkbox, list, dice)
- Created FieldSchema class with 13 fields including validation constraints (min, max, pattern, enumOptions, derivedFrom, defaultValue)
- Created EntityTypeSchema class with key, displayName, isWikiPageType, fields (List<FieldSchema>), description, iconKey, sortOrder
- Created GameModel class with schemaVersion (int), name, entityTypes (List<EntityTypeSchema>), rulesConfig (Map<String, dynamic>)
- Updated models.dart barrel export with all three new files
- All classes pass dart analyze with no errors

## Task Commits

Each task was committed atomically:

1. **Task 1: Create FieldSchema class and FieldInputType enum** - `b111185` (feat)
2. **Task 2: Create EntityTypeSchema and GameModel classes** - `60456b0` (feat)
3. **Task 3: Update models.dart barrel export** - `bc7c256` (feat)

## Files Created/Modified

- `packages/core/lib/models/field_schema.dart` - FieldInputType enum + FieldSchema class with validation constraints
- `packages/core/lib/models/entity_type_schema.dart` - EntityTypeSchema class with nested FieldSchema list
- `packages/core/lib/models/game_model.dart` - GameModel top-level schema container
- `packages/core/lib/models/models.dart` - Added 3 new export lines

## Decisions Made

None - followed plan as specified.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

Schema foundation complete. GameModel, EntityTypeSchema, and FieldSchema classes are ready for:
- GameEntity wrapper (05-02)
- D&D 5e GameModel JSON bundle (05-03)
- GameModelService provider (Phase 6)

## Self-Check: PASSED

---
*Phase: 05-core-data-layer*
*Completed: 2026-05-08*

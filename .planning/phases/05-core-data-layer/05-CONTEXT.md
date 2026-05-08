# Phase 5: Core Data Layer - Context

**Gathered:** 2026-05-08
**Status:** Ready for planning

<domain>
## Phase Boundary

Pure-Dart GameModel and GameEntity data structures exist in core — the schema foundation every other phase builds on. Three plans: (1) GameModel, EntityTypeSchema, FieldSchema data classes, (2) GameEntity wrapper with accessors, (3) GameModelParser with schemaVersion validation. No Flutter dependencies.

</domain>

<decisions>
## Implementation Decisions

### FieldSchema Type System
- **D-01:** Input types are: `text`, `number`, `multiline`, `select`, `checkbox`, `list`, `dice`. No `percentile` or `derived` as separate types — those are expressed through validation rules on `number` fields.
- **D-02:** Validation constraints on FieldSchema: `min`, `max`, `pattern` (regex), `enumOptions`, `derivedFrom` (formula string), `defaultValue`, `required`. This allows CoC percentile skills (number, min: 0, max: 100), characteristics (number, min: 15, max: 90), and Sanity (number, derivedFrom: "POW * 5") without special-case types.
- **D-03:** `derivedFrom` is a string formula (e.g., `"POW * 5"`) — parsing and evaluation is deferred to Phase 9 (encounter tracker / character sheet). Phase 5 only stores the string.

### GameModel JSON Structure
- **D-04:** Flat top-level keys: `schemaVersion` (int), `name` (String), `entityTypes` (List), `rulesConfig` (Map). No nested grouping sections.
- **D-05:** Each entity type in `entityTypes[]` carries: `key` (String, unique), `displayName` (String), `isWikiPageType` (bool), `fields` (List of FieldSchema), `description` (String, optional), `iconKey` (String, optional), `sortOrder` (int, optional).
- **D-06:** `rulesConfig` is a free-form Map at minimum — must contain `initiative` key with initiative formula/config. D&D 5e: `"1d20 + {dexMod}"`. CoC 7e: `"dexRank"` (special token, not a dice formula). Exact structure of rulesConfig beyond initiative is flexible.
- **D-07:** `schemaVersion` is a top-level int (not string). Current value: 1.

### GameEntity Accessor Depth
- **D-08:** GameEntity exposes six explicit typed accessors: `getInt`, `getString`, `getBool`, `getDouble`, `getList`, `getMap`. No generic `get<T>`.
- **D-09:** Each accessor takes `(String key, {dynamic fallback})` and returns the typed value or fallback. Never throws on missing key — returns fallback. Never throws on type mismatch — returns fallback.
- **D-10:** Accessors do NOT validate against FieldSchema. They return raw typed values from the underlying `Map<String, dynamic>`. Validation happens at the form/UI layer (Phase 7+).
- **D-11:** GameEntity has `entityTypeKey` (String) pointing into the active GameModel's entityTypes, and `toJson()` / `fromJson()` that round-trip cleanly with no data loss.

### Parsing Strictness
- **D-12:** GameModelParser throws `FormatException` for: missing `schemaVersion`, `schemaVersion` not an int, missing `entityTypes`, `entityTypes` not a list, empty `entityTypes` list, duplicate entity type `key` values, type mismatches on required fields.
- **D-13:** Unknown extra fields in GameModel JSON are silently ignored (forward-compatibility tolerance).
- **D-14:** Missing optional fields on entity types (description, iconKey, sortOrder) default to null/0.
- **D-15:** FormatException messages must identify the missing or invalid field (e.g., `"GameModel JSON missing required field: schemaVersion"`).

### the agent's Discretion
- Exact naming of data class files (e.g., `game_model.dart` vs `gamemodel.dart`) — follow existing `snake_case.dart` convention.
- Internal structure of `rulesConfig` beyond the `initiative` key — downstream phases will define what they need.
- Whether `FieldSchema` uses `const` constructors — depends on whether all fields can be compile-time constants.
- Error message wording for FormatException — as long as it identifies the problematic field.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Phase Scope and Requirements
- `.planning/ROADMAP.md` — Phase 5 goal, success criteria (SCHEMA-01 through SCHEMA-04), and plan placeholders (05-01 to 05-03)
- `.planning/REQUIREMENTS.md` — SCHEMA-01, SCHEMA-02, SCHEMA-03, SCHEMA-04 requirement definitions
- `.planning/PROJECT.md` — models being replaced, tech stack constraints, Call of Cthulhu agnosticism test rationale

### Prior Phase Decisions to Carry Forward
- `.planning/phases/01-core-infrastructure/01-CONTEXT.md` — WikiPage model and WikiPageType field schema pattern (blueprint for FieldSchema)
- `.planning/phases/04-polish-testing/04-CONTEXT.md` — established patterns and conventions

### Existing Code to Replace/Extend
- `packages/core/lib/models/wiki_page_type.dart` — `WikiPageFieldDefinition` pattern is the blueprint for `FieldSchema`; `WikiPageType` enum is what gets replaced
- `packages/core/lib/models/value_types.dart` — existing `toJson`/`fromJson` pattern, `const` constructor usage, `final` fields
- `packages/core/lib/models/models.dart` — barrel file that will need new exports (GameModel, GameEntity, FieldSchema, etc.)
- `packages/core/lib/models/player_character.dart` — ~200 hardcoded D&D5e fields, target for GameEntity replacement
- `packages/core/lib/models/monster.dart` — CR, XP, legendary actions, target for GameEntity replacement
- `packages/core/lib/models/npc.dart` — role, biography, target for GameEntity replacement
- `packages/core/lib/models/enums.dart` — D&D ability score, alignment, size, damage type enums — deleted in Phase 8

### Codebase Conventions
- `.planning/codebase/CONVENTIONS.md` — naming patterns, serialization patterns, model design patterns
- `.planning/codebase/STRUCTURE.md` — where to add new code (packages/core/lib/models/)

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `WikiPageFieldDefinition` (`wiki_page_type.dart:18-34`) — the exact blueprint for `FieldSchema`. Has `key`, `label`, `inputType`, `required`, `hint`, `options`. FieldSchema extends this pattern with richer validation.
- Existing model serialization pattern (`value_types.dart`) — every model has `toJson()` returning `Map<String, dynamic>` and `factory Model.fromJson(Map<String, dynamic>)`. Manual serialization, no codegen.
- `const` constructor pattern — used on value types where all fields are final and compile-time constants.
- Barrel export pattern — `models.dart` re-exports all sibling model files.

### Established Patterns
- `snake_case.dart` file naming for all Dart files
- `PascalCase` class names
- Named `required` parameters for mandatory fields
- Default values for optional fields (`= const []`, `= false`, `= 0`)
- Nullable fields use `as Type?` casts with `?? default` fallbacks
- No dartdoc comments in current codebase
- Core package has NO `analysis_options.yaml` — no linting enforced

### Integration Points
- Phase 5 classes live in `packages/core/lib/models/` — pure Dart, no Flutter imports
- Phase 6 will load GameModel JSON assets via `rootBundle` and parse with GameModelParser
- Phase 8 will delete `player_character.dart`, `monster.dart`, `npc.dart`, `enums.dart` after migration
- `models.dart` barrel file must be updated to export new classes

</code_context>

<specifics>
## Specific Ideas

- "WikiPageType.fields pattern is the blueprint — GameModel externalizes that into JSON so it's runtime-configurable rather than compile-time Dart" (from PROJECT.md)
- CoC characteristics range 15-90, percentile skills 0-100, Sanity = POW × 5 — these drive the validation constraint decisions
- Initiative formula: D&D uses `"1d20 + {dexMod}"`, CoC uses `"dexRank"` (special token for DEX-rank sort, no dice roll)
- schemaVersion must be int 1 from the first commit — cannot be retrofitted later

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 05-core-data-layer*
*Context gathered: 2026-05-08*

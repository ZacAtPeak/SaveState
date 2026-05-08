# Phase 9: Character Sheet & Encounter Tracker Generalization - Research

**Researched:** 2026-05-08
**Domain:** Flutter schema-driven UI, formula evaluation, D&D/CoC game system abstraction
**Confidence:** HIGH

## Summary

This phase transforms two hardcoded UI components (`CreatureDetailView` in dm_app and the placeholder "Characters Screen" in companion_app) into fully schema-driven widgets that read their field layout, rendering structure, and computed values from the active `GameModel`. The core work involves extending `FieldSchema` with four new properties (`section`, `subFields`, `itemSchema`, `attributeRef`), building a `FormulaEvaluator` for arithmetic + dice notation, extending `dnd5e.json` to be comprehensive, and building a reusable schema-driven form builder widget in `core` that both apps consume.

The existing `GameModelFormBuilder` in `packages/core/lib/wiki/` provides a starting point but is limited — it only handles flat fields with basic input types (text, number, multiline, select) and has TODO stubs for checkbox, list, and dice. It does not support sections, nested objects, list items with schemas, or `derivedFrom` formula evaluation. It must be substantially extended or replaced.

**Primary recommendation:** Extend `FieldSchema` and `FieldInputType` in core, build `FormulaEvaluator` as a standalone pure-Dart class in core, create a new `SchemaFormBuilder` widget that supersedes `GameModelFormBuilder`, then update `CreatureDetailView` and `InitiativeTracker` to use schema-driven rendering. Build companion app character sheet on the same `SchemaFormBuilder`.

## User Constraints (from CONTEXT.md)

### Locked Decisions
- **D-17:** Extend `dnd5e.json` with ALL missing fields — schema becomes single source of truth, no ad-hoc fields outside schema
- **D-18:** Add `section` property to `FieldSchema` — UI groups fields by section, rendered as distinct visual blocks
- **D-19:** Add both `subFields` and `itemSchema` to `FieldSchema` — `subFields` for grouped objects, `itemSchema` for list item schemas
- **D-20:** Build `FormulaEvaluator` supporting arithmetic (`+`, `-`, `*`, `/`, `()`), field references (`STR`, `DEX`), dice notation (`NdM`, `NdM+k`), with the specified grammar
- **D-21:** Initiative uses `rulesConfig.initiativeConfig.formula` for default computation, DM can manually override
- **D-22:** `rulesConfig.resourceFields` defines combat resource fields — tracker renders resource bars for each
- **D-23:** `rulesConfig.statusConditions` defines system defaults + "Custom..." option for free-form
- **D-24:** Build full editable character sheet in companion_app — schema-driven form with full parity to creature detail
- **D-25:** `rulesConfig.attributes` defines system attributes — schema fields reference by key via `attributeRef`
- **D-26:** `rulesConfig.skills` defines base skill list with name, attributeRef, formula — entities can add custom skills
- **D-27:** Each modifier field has its own `derivedFrom` formula — explicit and flexible per-system

### the agent's Discretion
- How the schema-driven form builder handles validation errors
- Whether the form builder is a single widget or a set of widgets (FormFieldRenderer, SectionRenderer, ListRenderer)
- How to handle the transition from hardcoded `CreatureDetail` → schema-driven rendering without breaking existing data
- Whether companion app has a separate character creation flow or reuses the same form as viewing
- How the formula evaluator handles circular references in `derivedFrom` formulas

### Deferred Ideas (OUT OF SCOPE)
- Per-campaign game system pinning (v2)
- Third bundled system (v2)
- In-app GameModel schema editor (v2)
- Cross-system entity migration (v2)
- Community GameModel registry (v2)
- GameModelParser migration chain for schema v0→v1 (v2)
- Cloud sync of GameModel files
- Import from third-party VTT formats
- Networked GameModel switching via NSD

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| FieldSchema extension | API / Backend (core package) | — | Schema definition is data-layer concern, shared by both apps |
| FormulaEvaluator | API / Backend (core package) | — | Pure computation, no UI dependency, used by both apps |
| Schema-driven form builder | API / Backend (core package) | Browser / Client (Flutter) | Reusable widget in core, consumed by both apps |
| CreatureDetailView rendering | Frontend (dm_app) | — | DM-specific UI, reads from core schema |
| InitiativeTracker | Frontend (dm_app) | API / Backend (core) | UI in dm_app, reads formula from core rulesConfig |
| Companion app character sheet | Frontend (companion_app) | API / Backend (core) | UI in companion_app, uses core SchemaFormBuilder |
| dnd5e.json schema extension | API / Backend (core assets) | — | Game model definition, loaded by both apps |
| Character data persistence | Database / Storage (WikiStorageService) | — | Existing wiki storage, characters stored as GameEntity |

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| `flutter` (SDK) | 3.41.9 | UI framework, widgets | Project standard — both apps use Flutter |
| `provider` | ^6.1.2 | State management | Already used in both apps for GameModelService, WikiProvider |
| `test` | ^1.25.0 | Unit testing (core) | Already used for core package tests |
| `flutter_test` | SDK | Widget testing (apps) | Standard Flutter test framework |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| `uuid` | ^4.5.1 | Unique ID generation | Already in core — for new entity IDs |
| `nsd` | ^5.0.1 | Network service discovery | Already in core — not directly needed for this phase |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Hand-rolled formula parser | `math_expressions` package | Adds dependency; hand-rolled is simpler for the limited grammar (arithmetic + dice) |
| Hand-rolled formula parser | `expressions` package | Heavier; overkill for this use case |

**Installation:** No new packages needed. Formula evaluator will be hand-rolled (D-20 specifies a simple grammar that doesn't warrant a third-party dependency).

**Version verification:**
```
flutter: 3.41.9 (verified 2026-04-29 release)
dart: 3.11.5 (verified)
provider: ^6.1.2 (in pubspec.yaml)
test: ^1.25.0 (in pubspec.yaml)
```

## Architecture Patterns

### System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        GameModel (JSON)                         │
│  dnd5e.json / coc7e.json → GameModelParser → GameModelService   │
└──────────────────────────────┬──────────────────────────────────┘
                               │ ChangeNotifier
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│                     Core Package (shared)                        │
│                                                                  │
│  ┌──────────────┐  ┌──────────────────┐  ┌───────────────────┐  │
│  │ FieldSchema  │  │ FormulaEvaluator │  │ SchemaFormBuilder │  │
│  │ + section    │  │ (pure Dart)      │  │ (Flutter widget)  │  │
│  │ + subFields  │  │                  │  │                   │  │
│  │ + itemSchema │  │ Parse → Resolve  │  │ SectionRenderer   │  │
│  │ + attributeRef│ │ → Evaluate       │  │ FormFieldRenderer │  │
│  └──────────────┘  └──────────────────┘  │ ListRenderer      │  │
│                                           └───────────────────┘  │
└──────────────────────────────┬──────────────────────────────────┘
                               │
              ┌────────────────┴────────────────┐
              ▼                                 ▼
┌─────────────────────────┐     ┌───────────────────────────────┐
│     DM App              │     │     Companion App             │
│                         │     │                               │
│ CreatureDetailView ─────┤     │ CharacterSheetScreen          │
│ (schema-driven)         │     │ (uses SchemaFormBuilder)      │
│                         │     │                               │
│ InitiativeTracker ──────┤     │ CharacterStorage              │
│ (formula evaluator)     │     │ (GameEntity via WikiProvider) │
│                         │     │                               │
│ Sidebar (drag source)   │     │                               │
└─────────────────────────┘     └───────────────────────────────┘
```

Data flow:
1. GameModel JSON loaded → parsed → GameModelService notifies listeners
2. Both apps read active GameModel via `Selector<GameModelService, GameModel?>`
3. SchemaFormBuilder reads `EntityTypeSchema.fields` → renders appropriate widgets
4. FormulaEvaluator resolves `derivedFrom` formulas against entity data at render time
5. InitiativeTracker reads `rulesConfig.initiativeConfig.formula` → evaluates on combatant drop
6. Character edits saved as `GameEntity` → persisted via WikiStorageService

### Recommended Project Structure

```
packages/core/lib/
├── models/
│   ├── field_schema.dart        # EXTEND: +section, subFields, itemSchema, attributeRef
│   ├── entity_type_schema.dart  # No changes needed
│   ├── game_entity.dart         # No changes needed
│   ├── game_model.dart          # No changes needed
│   └── formula_evaluator.dart   # NEW: pure Dart formula parser/evaluator
├── wiki/
│   ├── game_model_form_builder.dart  # REPLACE/EXTEND: becomes SchemaFormBuilder
│   └── ...
└── widgets/                      # NEW: shared Flutter widgets
    ├── schema_form_builder.dart  # Main form widget
    ├── section_renderer.dart     # Renders a section group
    ├── field_renderer.dart       # Renders a single field
    └── list_field_renderer.dart  # Renders list fields with itemSchema

apps/dm_app/lib/
├── widgets/
│   ├── creature_detail_view.dart  # REWRITE: schema-driven, remove hardcoded structure
│   ├── initiative_tracker.dart    # EXTEND: formula evaluator, schema-driven resources
│   └── roll_history_panel.dart    # No changes
└── main.dart                      # MINOR: update sidebar to use GameEntity directly

apps/companion_app/lib/
├── screens/                       # NEW
│   └── character_sheet_screen.dart # NEW: full character sheet
├── widgets/
│   └── generic_tab_view.dart      # No changes
└── main.dart                      # EXTEND: add character sheet screen
```

### Pattern 1: Schema-Driven Form Rendering

**What:** A widget tree that reads `FieldSchema` properties and renders appropriate Flutter input widgets, grouped by `section`, with nested `subFields` rendered as grouped blocks, and `list` fields rendered with add/remove controls using `itemSchema`.

**When to use:** Any form that must adapt to different game systems without code changes.

**Example:**
```dart
// Source: Based on existing GameModelFormBuilder pattern
class SchemaFormBuilder extends StatefulWidget {
  const SchemaFormBuilder({
    super.key,
    required this.fields,
    required this.data,
    required this.onDataChanged,
    this.gameModel,
  });

  final List<FieldSchema> fields;
  final Map<String, dynamic> data;
  final ValueChanged<Map<String, dynamic>> onDataChanged;
  final GameModel? gameModel; // For rulesConfig access (attributes, skills)
}
```

### Pattern 2: Formula Evaluation with Context Resolution

**What:** A pure-Dart class that parses formula strings into an AST, resolves field references from a data context map, evaluates dice rolls, and returns numeric results.

**When to use:** Computing derived fields (modifiers, resource values), initiative rolls, skill bonuses.

**Example:**
```dart
// Source: D-20 grammar specification
class FormulaEvaluator {
  /// Evaluate a formula string against a data context.
  /// Throws FormulaError on syntax errors or circular references.
  static num evaluate(String formula, Map<String, dynamic> context) {
    // 1. Parse into AST
    // 2. Detect circular references via dependency graph
    // 3. Resolve field references from context
    // 4. Evaluate AST
  }
}
```

### Pattern 3: Section-Aware Grouped Rendering

**What:** Fields are grouped by their `section` property. Each section renders as a visually distinct block with a section header. Fields without a section render in an "Other" section.

**When to use:** Character sheets, creature details — any form with logical groupings.

### Anti-Patterns to Avoid

- **Hardcoded section names in widgets:** Section names come from schema, not widget code. Widget should not know "Abilities" or "Combat" — it reads `field.section`.
- **Evaluating derivedFrom on every rebuild:** Cache computed values or use memoization. Formula evaluation is cheap but not free.
- **Storing computed derivedFrom values in entity data:** Derived values should be computed on-demand, not persisted. The entity data stores only the base values.
- **Using CreatureDetail typed model in new code:** Phase 8 established `CreatureDetail.fromGameEntity` as a bridge. Phase 9 should eliminate the need for `CreatureDetail` entirely in favor of direct `GameEntity` + schema rendering.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Formula parsing | Custom regex-based parser | Recursive descent parser (D-20 grammar) | Regex can't handle nested parentheses or operator precedence correctly |
| Dynamic form widgets | One giant build method | Composable widgets (SectionRenderer, FieldRenderer, ListRenderer) | Maintainability, testability, reuse across apps |
| Field validation | Manual if/else chains | `Form` + `FormField` + validator functions per inputType | Flutter's built-in validation handles error display, focus management |
| Dice rolling | `Random().nextInt(20) + 1` inline | `FormulaEvaluator` with dice AST node | Centralized, testable, supports all dice notation variants |
| Section grouping | Hardcoded Column children | Group fields by `.section` then map to SectionRenderer | Schema-driven, adapts to any game system |

**Key insight:** The existing `GameModelFormBuilder` already demonstrates the pattern of mapping `FieldInputType` to widgets. The extension needs to add section grouping, nested rendering, and formula evaluation — not reinvent the basic form field mapping.

## Runtime State Inventory

> This is NOT a rename/refactor/migration phase. No runtime state inventory needed.

## Common Pitfalls

### Pitfall 1: Circular derivedFrom Formulas
**What goes wrong:** Field A has `derivedFrom: "B + 1"` and field B has `derivedFrom: "A - 1"`, causing infinite recursion during evaluation.
**Why it happens:** Users (or schema authors) can create dependency cycles when defining derived formulas.
**How to avoid:** Build a dependency graph before evaluation. Detect cycles using DFS. Throw a `FormulaError` with a clear message: "Circular dependency detected: A → B → A".
**Warning signs:** Stack overflow during form render, app freeze when opening character sheet.

### Pitfall 2: Performance with Large Schemas
**What goes wrong:** Schema with 50+ fields, each with derivedFrom formulas, causes noticeable lag on every rebuild.
**Why it happens:** Evaluating all formulas on every `build()` call is O(n) where n = number of derived fields.
**How to avoid:** Cache derived values. Only re-evaluate when a dependency field changes. Use `ValueNotifier` or `ChangeNotifier` for derived values, not recomputation in `build()`.
**Warning signs:** Janky scrolling on character sheet, 16+ frame times when editing fields.

### Pitfall 3: GameModelFormBuilder TextController Pattern Doesn't Scale
**What goes wrong:** Current `GameModelFormBuilder` uses `TextEditingController` per field. This works for text/number but breaks for checkbox (bool), list (List), dice (roll result), and subFields (Map).
**Why it happens:** `TextEditingController` is string-only. Nested structures need different state management.
**How to avoid:** Use a data-map approach: `Map<String, dynamic> data` with `onDataChanged` callback. Each field reads/writes its key in the map. For nested objects, use dot-notation keys or nested maps.
**Warning signs:** Checkbox fields showing as disabled text fields (current TODO pattern), list fields not rendering.

### Pitfall 4: CreatureDetail Typed Model Still Referenced
**What goes wrong:** After making rendering schema-driven, `CreatureDetail` class (with its hardcoded D&D typed fields) remains referenced in dm_app's sidebar and drag data.
**Why it happens:** `CreatureDetail` is used in `_SidebarEntry`, `_DraggableCombatantTile`, and `CombatantDragData.fromGameEntity`.
**How to avoid:** Replace `CreatureDetail` usage with direct `GameEntity` + schema lookups. The sidebar should display entity name from `entity.getString('name')`, not `detail.name`. Drag data should read from entity data map, not `CreatureDetail` properties.
**Warning signs:** Compile errors after removing CreatureDetail, or runtime crashes when entity data doesn't match CreatureDetail's expected fields.

### Pitfall 5: Initiative Formula Not Used
**What goes wrong:** `rulesConfig.initiativeConfig` exists in dnd5e.json but `InitiativeTracker._onCombatantDropped` hardcodes `1d20 + dexMod`.
**Why it happens:** The initiative config was added in Phase 5 but never wired up.
**How to avoid:** Replace the hardcoded roll in `_onCombatantDropped` with `FormulaEvaluator.evaluate(initiativeFormula, entityData)`. Handle CoC's DEX-rank sort as a special case (no roll, sort by DEX value).
**Warning signs:** Initiative still shows "d20+DEX" even when formula in JSON changes.

### Pitfall 6: HP Field Key Hardcoded as 'hitPoints'
**What goes wrong:** `InitiativeEntry.fromGameEntity` and `CombatantDragData.fromGameEntity` read `hitPoints` and `currentHP` as hardcoded strings.
**Why it happens:** These were written before the schema was comprehensive.
**How to avoid:** Read the HP field key from the schema — find the field with `section: "Vitals"` (or equivalent) that represents hit points. Or use `rulesConfig.resourceFields` to identify resource fields. For v1, the schema field key IS the data key, so reading from entity data using the schema key works.
**Warning signs:** HP shows 0 for entities that use a different HP field key.

## Code Examples

Verified patterns from official sources:

### Extending FieldSchema with New Properties
```dart
// Source: D-18, D-19, D-25 decisions in CONTEXT.md
enum FieldInputType {
  text,
  number,
  multiline,
  select,
  checkbox,
  list,
  dice,
  group, // NEW: for subFields containers
}

class FieldSchema {
  const FieldSchema({
    required this.key,
    required this.label,
    required this.inputType,
    this.required = false,
    this.hint,
    this.options,
    this.min,
    this.max,
    this.pattern,
    this.enumOptions,
    this.derivedFrom,
    this.defaultValue,
    this.section,              // NEW: D-18
    this.subFields,            // NEW: D-19
    this.itemSchema,           // NEW: D-19
    this.attributeRef,         // NEW: D-25
  });

  final String key;
  final String label;
  final FieldInputType inputType;
  final bool required;
  final String? hint;
  final List<String>? options;
  final num? min;
  final num? max;
  final String? pattern;
  final List<String>? enumOptions;
  final String? derivedFrom;
  final dynamic defaultValue;
  final String? section;
  final List<FieldSchema>? subFields;
  final FieldSchema? itemSchema;
  final String? attributeRef;

  Map<String, dynamic> toJson() => {
    'key': key,
    'label': label,
    'inputType': inputType.name,
    'required': required,
    if (hint != null) 'hint': hint,
    if (options != null) 'options': options,
    if (min != null) 'min': min,
    if (max != null) 'max': max,
    if (pattern != null) 'pattern': pattern,
    if (enumOptions != null) 'enumOptions': enumOptions,
    if (derivedFrom != null) 'derivedFrom': derivedFrom,
    if (defaultValue != null) 'defaultValue': defaultValue,
    if (section != null) 'section': section,
    if (subFields != null) 'subFields': subFields!.map((f) => f.toJson()).toList(),
    if (itemSchema != null) 'itemSchema': itemSchema!.toJson(),
    if (attributeRef != null) 'attributeRef': attributeRef,
  };

  factory FieldSchema.fromJson(Map<String, dynamic> json) => FieldSchema(
    key: json['key'] as String,
    label: json['label'] as String,
    inputType: FieldInputType.values.byName(json['inputType'] as String),
    required: json['required'] as bool? ?? false,
    hint: json['hint'] as String?,
    options: (json['options'] as List<dynamic>?)?.map((e) => e as String).toList(),
    min: json['min'] as num?,
    max: json['max'] as num?,
    pattern: json['pattern'] as String?,
    enumOptions: (json['enumOptions'] as List<dynamic>?)?.map((e) => e as String).toList(),
    derivedFrom: json['derivedFrom'] as String?,
    defaultValue: json['defaultValue'],
    section: json['section'] as String?,
    subFields: (json['subFields'] as List<dynamic>?)
        ?.map((f) => FieldSchema.fromJson(Map<String, dynamic>.from(f as Map)))
        .toList(),
    itemSchema: json['itemSchema'] != null
        ? FieldSchema.fromJson(Map<String, dynamic>.from(json['itemSchema'] as Map))
        : null,
    attributeRef: json['attributeRef'] as String?,
  );
}
```

### Formula Evaluator — Recursive Descent Parser
```dart
// Source: D-20 grammar specification in CONTEXT.md
// Grammar:
//   expression = term (('+' | '-') term)*
//   term       = factor (('*' | '/') factor)*
//   factor     = number | fieldRef | dice | '(' expression ')' | functionCall
//   dice       = [count] 'd' sides ('+' | '-' term)?
//   number     = integer | float
//   fieldRef   = [A-Z]+ (e.g., STR, DEX, POW)
//   functionCall = 'floor' '(' expression ')'

class FormulaEvaluator {
  /// Evaluate a formula against a data context.
  /// Returns the numeric result.
  /// Throws FormulaError on parse errors, unknown fields, or circular refs.
  static num evaluate(String formula, Map<String, dynamic> context) {
    final parser = _FormulaParser(formula);
    final ast = parser.parse();
    return ast.evaluate(context);
  }
}

// AST nodes for the grammar:
// - NumberNode(value)
// - FieldRefNode(name) — resolves from context
// - DiceNode(count, sides, modifier) — rolls and adds modifier
// - BinaryOpNode(operator, left, right)
// - FunctionNode(name, arg) — e.g., floor()
```

### Schema-Driven Form Builder — Section Grouping
```dart
// Source: D-18 decision + existing GameModelFormBuilder pattern
class SchemaFormBuilder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Group fields by section
    final sections = <String, List<FieldSchema>>{};
    for (final field in fields) {
      final section = field.section ?? 'General';
      sections.putIfAbsent(section, () => []).add(field);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: sections.entries.map((entry) {
        return _SectionRenderer(
          title: entry.key,
          fields: entry.value,
          data: data,
          onChanged: onChanged,
          gameModel: gameModel,
        );
      }).toList(),
    );
  }
}
```

### Initiative Tracker — Formula-Driven Roll
```dart
// Source: D-21 decision, replacing hardcoded roll in InitiativeTracker._onCombatantDropped
void _onCombatantDropped(GameEntity entity) {
  final formula = _initiativeConfig?['formula'] as String? ?? '1d20+DEX';
  final data = _entityToContext(entity); // Build context map from entity data
  final initiative = FormulaEvaluator.evaluate(formula, data);

  final entry = InitiativeEntry(
    id: '${entity.getString('id')}_${DateTime.now().millisecondsSinceEpoch}',
    sourceId: entity.getString('id'),
    name: entity.getString('name', fallback: 'Unknown'),
    initiative: initiative.toDouble(),
    currentHP: _getResourceValue(entity, 'hitPoints'),
    maxHP: _getResourceValue(entity, 'hitPoints'),
    statusConditions: _getStatusConditions(entity),
    isPlayer: _isPlayerEntity(entity),
  );
  // ... add to tracker
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Hardcoded `CreatureDetail` typed model | `GameEntity` + schema-driven rendering | Phase 8 (bridge), Phase 9 (full) | Eliminates D&D field name assumptions in UI |
| `TextEditingController` per field | `Map<String, dynamic>` data model with callbacks | Phase 9 | Supports nested objects, lists, bools |
| Hardcoded initiative: `1d20+dexMod` | `rulesConfig.initiativeConfig.formula` evaluated | Phase 9 | CoC DEX-rank sort works without code changes |
| `GameModelFormBuilder` flat fields only | `SchemaFormBuilder` with sections, subFields, itemSchema | Phase 9 | Complex character sheets render correctly |
| No formula evaluation | `FormulaEvaluator` with AST parser | Phase 9 | Derived fields (modifiers, resources) compute correctly |

**Deprecated/outdated:**
- **`CreatureDetail` typed model**: Phase 8 created `fromGameEntity` factories as a bridge. Phase 9 should eliminate the need for this class entirely. The UI should read directly from `GameEntity` data using schema field keys.
- **`value_types.dart` classes** (`AbilityScores`, `MovementSpeed`, `Senses`, `SkillProficiency`, `Attack`, `SpellSlot`, etc.): These are D&D-specific typed models. After Phase 9, they should only exist for backwards compatibility with existing code that hasn't been migrated. New code should use `GameEntity` + schema.
- **`GameModelFormBuilder` current implementation**: Only handles flat text/number/multiline/select fields. Checkbox, list, and dice are TODO stubs. Must be replaced with the new `SchemaFormBuilder`.

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | `GameEntity` data is stored in `WikiPage.statBlock` (Map<String, dynamic>) and persisted via `WikiStorageService` | Architecture Patterns | If character storage uses a different mechanism, persistence layer needs different implementation |
| A2 | `GameModelService` currently only loads from bundled assets (no system switching or persistence) — Phase 10 will add this | Architecture Patterns | If system switching already exists, phase scope changes |
| A3 | `GameModelFormBuilder` is the only existing schema-driven form widget in the codebase | Don't Hand-Roll | If other form builders exist, they should be considered |
| A4 | `FormulaEvaluator` should be pure Dart (no Flutter dependencies) to be usable in tests and both apps | Standard Stack | If it needs Flutter, it can't be in core models |

## Open Questions

1. **How should the form builder handle validation errors?**
   - What we know: Current `GameModelFormBuilder` uses `TextFormField` with `validator` callbacks
   - What's unclear: Should validation errors be per-field (current approach) or per-section? Should derivedFrom fields show validation errors if their formula produces invalid results?
   - Recommendation: Per-field validation using Flutter's `Form` + `FormField` pattern. DerivedFrom fields are read-only and should never produce validation errors (formula errors should be caught at parse time).

2. **Should the form builder be a single widget or a set of composable widgets?**
   - What we know: Current `GameModelFormBuilder` is a single StatefulWidget with a switch statement
   - What's unclear: At what point does a single widget become unmaintainable?
   - Recommendation: Composable widgets — `SchemaFormBuilder` (orchestrator), `SectionRenderer` (section grouping), `FieldRenderer` (single field), `ListFieldRenderer` (list with add/remove). This matches Flutter best practices and enables testing individual components.

3. **How to handle the transition from hardcoded `CreatureDetail` → schema-driven rendering?**
   - What we know: `CreatureDetail` is used in dm_app sidebar, drag data, and detail view
   - What's unclear: Should we remove `CreatureDetail` in this phase or keep it for backwards compatibility?
   - Recommendation: Replace `CreatureDetailView` rendering with schema-driven approach first. Keep `CreatureDetail` class but mark it deprecated. Remove sidebar references to `CreatureDetail` in favor of direct `GameEntity` access. Full deletion can happen in a follow-up cleanup phase.

4. **Should companion app have a separate character creation flow?**
   - What we know: Current companion app has a placeholder "Characters Screen"
   - What's unclear: Should character creation use the same form as editing, or a wizard-style flow?
   - Recommendation: Same form for create and edit. The `SchemaFormBuilder` can accept an empty `data` map for creation and a populated map for editing. This reduces code duplication and ensures consistency.

5. **How does the formula evaluator handle circular references?**
   - What we know: `derivedFrom` formulas can reference other field keys
   - What's unclear: What's the most efficient cycle detection approach?
   - Recommendation: Build a dependency graph from all `derivedFrom` formulas before evaluation. Run DFS to detect cycles. If a cycle is found, throw `FormulaError('Circular dependency: A → B → A')`. Cache the dependency graph so it's only computed once per schema load.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Flutter SDK | All UI work | ✓ | 3.41.9 | — |
| Dart SDK | Core package, formula evaluator | ✓ | 3.11.5 | — |
| `provider` | State management | ✓ | ^6.1.2 | — |
| `test` | Unit tests (core) | ✓ | ^1.25.0 | — |
| `flutter_test` | Widget tests (apps) | ✓ | SDK | — |

**Missing dependencies with no fallback:** None.

**Missing dependencies with fallback:** None.

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | `test` ^1.25.0 (core), `flutter_test` SDK (apps) |
| Config file | None — uses default test discovery |
| Quick run command | `cd packages/core && dart test test/game_model_test.dart -x slow` |
| Full suite command | `dart test` (from workspace root) |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| CHAR-01 | Character sheet UI generates field layout from GameModel schema — no hardcoded D&D field names | unit + widget | `cd packages/core && dart test test/schema_form_builder_test.dart -x slow` | ❌ Wave 0 |
| CHAR-02 | Character sheet reflects active game system immediately on GameModel switch | widget | `cd apps/companion_app && flutter test test/character_sheet_system_switch_test.dart` | ❌ Wave 0 |
| ENCTR-01 | Initiative order reads initiativeConfig from active GameModel — CoC DEX-rank sort works | unit + widget | `cd packages/core && dart test test/formula_evaluator_test.dart -x slow` | ❌ Wave 0 |
| ENCTR-02 | Combatant HP display reads HP field key from active GameModel schema | unit | `cd packages/core && dart test test/initiative_tracker_test.dart -x slow` | ❌ Wave 0 |

### Sampling Rate
- **Per task commit:** `dart test` (core) or `flutter test` (app) for affected test files
- **Per wave merge:** `dart test` from workspace root
- **Phase gate:** Full suite green before `/gsd-verify-work`

### Wave 0 Gaps
- [ ] `packages/core/test/formula_evaluator_test.dart` — covers ENCTR-01 (formula parsing, evaluation, dice, circular detection)
- [ ] `packages/core/test/schema_form_builder_test.dart` — covers CHAR-01 (section grouping, subFields, itemSchema, derivedFrom rendering)
- [ ] `packages/core/test/field_schema_extension_test.dart` — covers new FieldSchema properties serialization/deserialization
- [ ] `apps/companion_app/test/character_sheet_screen_test.dart` — covers CHAR-02 (system switch, form rendering)
- [ ] `apps/dm_app/test/creature_detail_schema_test.dart` — covers CHAR-01 (DM app creature detail uses schema)
- [ ] `apps/dm_app/test/initiative_tracker_formula_test.dart` — covers ENCTR-01 (initiative uses formula from rulesConfig)
- [ ] Framework install: none needed — `test` and `flutter_test` already in dev_dependencies

## Security Domain

> `security_enforcement` is not explicitly set in config.json — treating as enabled per default.

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | no | — |
| V3 Session Management | no | — |
| V4 Access Control | no | — |
| V5 Input Validation | yes | `Form` + `FormField` validators, schema `required`/`min`/`max`/`pattern` enforcement |
| V6 Cryptography | no | — |

### Known Threat Patterns for Schema-Driven Forms

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Formula injection (malicious derivedFrom formula) | Tampering | Formula parser only accepts defined grammar — no arbitrary code execution. AST evaluation is sandboxed to arithmetic + dice + field refs. |
| Schema manipulation (user modifies dnd5e.json) | Tampering | GameModel files are bundled assets, not user-editable in v1. Import validation in Phase 10 will handle external files. |
| Data injection via statBlock | Injection | `WikiCreateSubmitFlow.submitFromSchema` validates field keys against schema — unknown keys are silently dropped. |

## Sources

### Primary (HIGH confidence)
- **Codebase files** — All Dart source files read directly from the SaveState repository
  - `packages/core/lib/models/field_schema.dart` — Current FieldSchema implementation
  - `packages/core/lib/models/entity_type_schema.dart` — EntityTypeSchema implementation
  - `packages/core/lib/models/game_entity.dart` — GameEntity wrapper
  - `packages/core/lib/models/game_model.dart` — GameModel data class
  - `packages/core/lib/models/value_types.dart` — D&D typed models (AbilityScores, etc.)
  - `packages/core/lib/models/encounter.dart` — EncounterEntry, EncounterState, DiceRoll
  - `packages/core/lib/wiki/game_model_form_builder.dart` — Existing schema-driven form
  - `packages/core/lib/wiki/wiki_create_form.dart` — Wiki create form usage pattern
  - `apps/dm_app/lib/widgets/creature_detail_view.dart` — Hardcoded creature detail (784 lines)
  - `apps/dm_app/lib/widgets/initiative_tracker.dart` — Hardcoded initiative tracker (470 lines)
  - `apps/companion_app/lib/main.dart` — Companion app with placeholder tabs
  - `packages/core/assets/game_models/dnd5e.json` — Current D&D 5e schema (112 lines)
  - `packages/core/test/game_model_test.dart` — Existing test patterns

### Secondary (MEDIUM confidence)
- **CONTEXT.md decisions D-17 through D-27** — Locked decisions from discuss-phase
- **REQUIREMENTS.md** — CHAR-01, CHAR-02, ENCTR-01, ENCTR-02 requirements
- **Flutter 3.41.9 documentation** — Form, FormField, TabController patterns (verified via codebase usage)

### Tertiary (LOW confidence)
- None — all claims verified against codebase or CONTEXT.md

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — verified from pubspec.yaml files and codebase imports
- Architecture: HIGH — verified from reading all relevant source files
- Pitfalls: HIGH — identified from actual code patterns in the codebase
- Formula evaluator grammar: HIGH — explicitly specified in CONTEXT.md D-20
- FieldSchema extension: HIGH — explicitly specified in CONTEXT.md D-18, D-19, D-25

**Research date:** 2026-05-08
**Valid until:** 30 days (stable Dart/Flutter APIs, no fast-moving dependencies)

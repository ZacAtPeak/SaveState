# Phase 9: Character Sheet & Encounter Tracker Generalization — Context

## Scope
Generalize character sheet (companion app) and encounter tracker (DM app) to be fully schema-driven via GameModel. Remove all hardcoded D&D 5e field assumptions from UI layers.

## Prior Context
- **Phase 5 (D-01–D-10):** FieldSchema input types (`text`, `number`, `multiline`, `select`, `checkbox`, `list`, `dice`). Validation constraints: `min`, `max`, `pattern`, `enumOptions`, `derivedFrom`, `defaultValue`, `required`. `derivedFrom` is a string formula — parsing/evaluation deferred to Phase 9.
- **Phase 5 (D-04/D-05):** GameModel JSON has flat top-level keys; entity types carry `key`, `displayName`, `isWikiPageType`, `fields`, etc.
- **Phase 8 (D-16):** `CreatureDetail.fromGameEntity` and `CombatantDragData.fromGameEntity` use safe fallback defaults when fields are missing from GameEntity maps.
- **Phase 8 completed:** Hardcoded typed models removed, wiki JSON migrated, demo data migrated to `GameEntity` structures.

---

## Decisions

### D-17: Extend dnd5e.json with all missing fields
The current `dnd5e.json` schema only defines basic wiki fields (size, creatureType, AC, HP, speed text, CR). `CreatureDetail` reads fields that don't exist in the schema: `strength`, `dexterity`, `constitution`, `intelligence`, `wisdom`, `charisma`, `speedWalk`, `speedFly`, `speedSwim`, `speedClimb`, `speedBurrow`, `hover`, `darkvision`, `blindsight`, `tremorsense`, `truesight`, `passivePerception`, `playerClass`, `race`, `level`, `alignment`, `armorSource`, `id`, `body`, `status`, `currentHP`.

**Decision:** Extend `dnd5e.json` to define ALL fields that entities use. The schema becomes the single source of truth. No ad-hoc fields outside the schema.

**Rationale:** Phase 10 (system picker, CoC 7e) requires the schema to be comprehensive. Having the schema be the source of truth eliminates dual-maintenance of schema + hardcoded UI field lists.

### D-18: Section-aware rendering
`CreatureDetailView` hardcodes visual structure: 6 ability score cards in a row, stat rows for AC/Speed/Senses, 5 tabs (Skills, Actions, Spells, Inventory, Lore), 18 skills in a grid, spell slots with Roman numerals.

**Decision:** Add a `section` property to `FieldSchema`. UI groups fields by section. Sections are rendered as distinct visual blocks.

**Implementation:**
```dart
class FieldSchema {
  final String? section; // e.g., "Vitals", "Abilities", "Combat", "Skills", "Spells", "Lore"
  // ... existing fields
}
```

Sections in `dnd5e.json` creature type:
- `Vitals` — size, creatureType, armorClass, hitPoints, speed (group), senses (group)
- `Abilities` — strength, dexterity, constitution, intelligence, wisdom, charisma + their modifiers
- `Combat` — attacks (list), specialAbilities (list)
- `Skills` — skill proficiencies (from rulesConfig)
- `Spells` — spellSlots (list), knownSpells (list)
- `Lore` — loreText, traits

### D-19: `subFields` for nested objects + `itemSchema` for lists
Current `FieldSchema` is flat. `CreatureDetail` has nested structures: `AbilityScores` (6 scores), `MovementSpeed` (walk/fly/swim/climb/burrow/hover), `Senses` (darkvision/blindsight/tremorsense/truesight/passivePerception), `List<Attack>`, `List<SpellSlot>`, `List<SkillProficiency>`.

**Decision:** Add both `subFields` and `itemSchema` to `FieldSchema`.

**Implementation:**
```dart
class FieldSchema {
  final List<FieldSchema>? subFields; // Nested object fields
  final FieldSchema? itemSchema;      // Schema for list items
  // ... existing fields
}
```

**subFields** — for grouped objects rendered as a unit:
```json
{
  "key": "speed",
  "label": "Movement Speed",
  "inputType": "group",
  "section": "Vitals",
  "subFields": [
    {"key": "walk", "label": "Walk", "inputType": "number"},
    {"key": "fly", "label": "Fly", "inputType": "number"},
    {"key": "swim", "label": "Swim", "inputType": "number"},
    {"key": "climb", "label": "Climb", "inputType": "number"}
  ]
}
```

**itemSchema** — for lists where each item has a defined structure:
```json
{
  "key": "attacks",
  "label": "Attacks",
  "inputType": "list",
  "section": "Combat",
  "itemSchema": {
    "subFields": [
      {"key": "name", "label": "Name", "inputType": "text"},
      {"key": "hitBonus", "label": "To Hit", "inputType": "number"},
      {"key": "damageRoll", "label": "Damage", "inputType": "text"},
      {"key": "damageType", "label": "Damage Type", "inputType": "text"}
    ]
  }
}
```

### D-20: Formula evaluator — arithmetic + dice notation
`derivedFrom` formulas need evaluation. Examples: `"POW * 5"` (CoC FP), `"1d20+DEX"` (initiative), `"(STR-10)/2"` (D&D modifier).

**Decision:** Build a formula evaluator supporting:
- Arithmetic: `+`, `-`, `*`, `/`, `()`
- Field references: `STR`, `DEX`, `POW`, etc. (resolved from entity data)
- Dice notation: `NdM` (e.g., `1d20`, `2d6`), `NdM+k` (e.g., `1d20+3`, `2d6+DEX`)

**Implementation:** A `FormulaEvaluator` class in `core` that:
1. Parses the formula string into an AST
2. Resolves field references from a `Map<String, dynamic>` data context
3. Evaluates dice rolls using `Random`
4. Returns a numeric result

**Grammar:**
```
expression = term (('+' | '-') term)*
term       = factor (('*' | '/') factor)*
factor     = number | fieldRef | dice | '(' expression ')'
dice       = [count] 'd' sides ('+' | '-' term)?
number     = integer | float
fieldRef   = [A-Z]+ (e.g., STR, DEX, POW)
```

### D-21: Initiative — formula-driven + manual override
Initiative is hardcoded as `1d20 + dexMod`. `rulesConfig` already has `initiativeConfig: { formula: "1d20+DEX", label: "Initiative" }` but it's unused.

**Decision:** Use `rulesConfig.initiativeConfig.formula` to compute initiative default. The formula evaluator (D-20) handles `"1d20+DEX"`. DM can always manually override the computed value.

**Implementation:**
- When a combatant is dropped into the initiative tracker, evaluate the formula against their entity data
- Display the computed value as the default
- Allow DM to tap/edit the initiative number to set any value
- Store the override in the `InitiativeEntry`

### D-22: Resources — schema-driven via `rulesConfig.resourceFields`
D&D has single HP. CoC has HP, FP, MP. Other systems vary.

**Decision:** `rulesConfig.resourceFields` defines which numeric fields are combat resources. The encounter tracker reads this config to know which fields to show and manage (with +/- buttons and progress bars).

**Implementation:**
```json
"rulesConfig": {
  "resourceFields": [
    {"key": "hitPoints", "label": "HP", "color": "red"},
    {"key": "magicPoints", "label": "MP", "color": "blue"}
  ]
}
```

The tracker renders a resource bar for each configured resource field.

### D-23: Status conditions — hybrid (system defaults + custom)
Currently free-form strings. Different systems have different condition sets.

**Decision:** `rulesConfig.statusConditions` defines system-specific defaults. UI shows them as chips/toggles. DM can also add custom conditions not in the list.

**Implementation:**
```json
"rulesConfig": {
  "statusConditions": [
    "Blinded", "Charmed", "Deafened", "Frightened", "Grappled",
    "Incapacitated", "Invisible", "Paralyzed", "Petrified", "Poisoned",
    "Prone", "Restrained", "Stunned", "Unconscious", "Exhaustion"
  ]
}
```

UI shows a "Add Condition" button that opens a picker with system defaults + "Custom..." option for free-form input.

### D-24: Companion app — full editable character sheet
Current companion app is minimal (wiki browsing). Phase 9 should build a full character sheet.

**Decision:** Build a full editable character sheet in the companion app — schema-driven form, player can create/edit character, full parity with creature detail view.

**Implementation:**
- Schema-driven form that reads entity type fields and renders appropriate input widgets
- Uses `FieldSchema.inputType` to determine widget (TextField, NumberField, Dropdown, Checkbox, etc.)
- Groups fields by `section` property
- Evaluates `derivedFrom` formulas for read-only computed fields
- Saves characters as `GameEntity` instances

### D-25: Attributes defined in `rulesConfig.attributes`
D&D has STR/DEX/CON/INT/WIS/CHA. CoC has STR/CON/SIZ/DEX/APP/INT/POW/EDU. Other systems vary.

**Decision:** `rulesConfig.attributes` defines the system's attributes (name, label, abbreviation). Schema fields on entity types reference these attributes. Modifier formulas are `derivedFrom` on separate modifier fields.

**Implementation:**
```json
"rulesConfig": {
  "attributes": {
    "STR": {"label": "Strength", "abbreviation": "STR"},
    "DEX": {"label": "Dexterity", "abbreviation": "DEX"},
    "CON": {"label": "Constitution", "abbreviation": "CON"},
    "INT": {"label": "Intelligence", "abbreviation": "INT"},
    "WIS": {"label": "Wisdom", "abbreviation": "WIS"},
    "CHA": {"label": "Charisma", "abbreviation": "CHA"}
  }
}
```

Entity type schema references attributes by key:
```json
{"key": "strength", "label": "Strength", "inputType": "number", "attributeRef": "STR"}
```

### D-26: Skills in `rulesConfig.skills` + custom additions per entity
D&D has 18 fixed skills tied to ability scores. CoC has percentage skills. Other systems allow custom skills.

**Decision:** `rulesConfig.skills` defines the base skill list. Each skill has a name, linked attribute, and formula. Entities can also have custom skills appended that aren't in the system list.

**Implementation:**
```json
"rulesConfig": {
  "skills": [
    {"name": "Acrobatics", "attributeRef": "DEX", "formula": "floor((DEX - 10) / 2)"},
    {"name": "Athletics", "attributeRef": "STR", "formula": "floor((STR - 10) / 2)"},
    {"name": "Arcana", "attributeRef": "INT", "formula": "floor((INT - 10) / 2)"}
  ]
}
```

Entity data stores skill proficiencies:
```json
"skillProficiencies": [
  {"name": "Acrobatics", "proficient": true, "bonus": 5},
  {"name": "My Custom Skill", "proficient": false, "bonus": 0}
]
```

### D-27: Modifier calculation via `derivedFrom` per field
D&D: `(score - 10) / 2` floored. CoC: percentage-based (no modifier). Other systems vary.

**Decision:** Each modifier field on the entity has its own `derivedFrom` formula. This is explicit and flexible per-system.

**Implementation:**
```json
{"key": "strengthModifier", "label": "STR Mod", "inputType": "number", "derivedFrom": "floor((strength - 10) / 2)", "section": "Abilities"}
```

The formula evaluator resolves `strength` from the entity's data map, computes the result, and displays it as a read-only value.

---

## Schema Changes Required

### New FieldSchema properties
```dart
class FieldSchema {
  // Existing: key, label, inputType, required, hint, options, min, max, pattern, enumOptions, derivedFrom, defaultValue
  
  String? section;              // D-18: Section grouping
  List<FieldSchema>? subFields; // D-19: Nested object fields
  FieldSchema? itemSchema;      // D-19: List item schema
  String? attributeRef;         // D-25: Reference to rulesConfig attribute
}
```

### New rulesConfig sections
```json
{
  "rulesConfig": {
    "attributes": { ... },           // D-25
    "skills": [ ... ],               // D-26
    "resourceFields": [ ... ],       // D-22
    "statusConditions": [ ... ],     // D-23
    "initiativeConfig": {
      "formula": "1d20+DEX",
      "label": "Initiative"
    }
  }
}
```

### New inputType: `group`
For fields with `subFields`, the `inputType` should be `group` to indicate it's a container, not a direct input.

## Implementation Order

1. **Extend FieldSchema** — Add `section`, `subFields`, `itemSchema`, `attributeRef` properties
2. **Build FormulaEvaluator** — Arithmetic + dice notation parser and evaluator
3. **Extend dnd5e.json** — Add all missing fields with sections, groups, lists, derivedFrom formulas
4. **Extend rulesConfig** — Add attributes, skills, resourceFields, statusConditions
5. **Build schema-driven form builder** — Core package widget that renders fields based on schema
6. **Update CreatureDetailView** — Replace hardcoded rendering with schema-driven form builder
7. **Update InitiativeTracker** — Use formula evaluator for initiative, schema-driven resources, hybrid conditions
8. **Build companion app character sheet** — Full editable form using schema-driven form builder
9. **Migrate existing data** — Ensure existing GameEntity instances work with new schema

## Open Questions for Planning
- How does the schema-driven form builder handle validation errors?
- Should the form builder be a single widget or a set of widgets (FormFieldRenderer, SectionRenderer, ListRenderer)?
- How do we handle the transition from hardcoded `CreatureDetail` → schema-driven rendering without breaking existing data?
- Should the companion app have a separate character creation flow, or reuse the same form as viewing?
- How does the formula evaluator handle circular references in `derivedFrom` formulas?

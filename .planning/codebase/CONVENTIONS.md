# Coding Conventions

**Analysis Date:** 2026-05-07

## Naming Patterns

**Files:**
- `snake_case` for all Dart file names (e.g., `player_character.dart`, `creature_detail_view.dart`)
- Barrel files match directory name: `models.dart`, `data.dart`

**Classes:**
- `PascalCase` for all classes (e.g., `PlayerCharacter`, `CreatureDetail`, `InitiativeTracker`)
- Private classes prefixed with `_` (e.g., `_SidebarEntry`, `_SidebarState`, `_SpellSlotCell`)
- Widget classes end with `Widget` or describe their purpose (e.g., `CreatureDetailView`, `RollHistoryPanel`)
- Data classes use domain names (e.g., `Monster`, `NPC`, `EncounterState`, `DiceRoll`)

**Functions/Methods:**
- `camelCase` for all methods (e.g., `modifierFor`, `_formatCR`, `_toggleSection`)
- Private methods prefixed with `_` (e.g., `_titleCase`, `_formatSpeed`, `_handleTabChange`)
- Factory constructors use `from<SourceType>` pattern (e.g., `fromJson`, `fromPlayerCharacter`, `fromMonster`, `fromNPC`)

**Variables:**
- `camelCase` for instance variables (e.g., `currentHP`, `armorClass`, `initiativeModifier`)
- `camelCase` for local variables (e.g., `sortedEntries`, `rollMessage`)
- Private instance variables prefixed with `_` (e.g., `_entries`, `_activeIndex`, `_tabController`)
- Constants use `lowerCamelCase` (e.g., `_allSkills`, `_romanNumerals`, `_actions`)

**Enums:**
- `PascalCase` for enum types (e.g., `CreatureSize`, `DamageType`, `Alignment`)
- `camelCase` for enum values (e.g., `lawfulGood`, `chaoticEvil`, `bludgeoning`)

## Code Style

**Formatting:**
- No explicit formatter config detected (uses Flutter default `dart format`)
- 2-space indentation throughout
- Trailing commas used in multi-line constructor calls
- Line length follows Flutter default (80 chars soft limit)

**Linting:**
- Both apps use `package:flutter_lints/flutter.yaml` as base lint rules
- `apps/dm_app/analysis_options.yaml` — default Flutter lints, no custom rules enabled
- `apps/companion_app/analysis_options.yaml` — default Flutter lints, no custom rules enabled
- **Core package has NO `analysis_options.yaml`** — no linting enforced on shared code
- No `// ignore:` directives used in Dart source files

## Import Organization

**Order:**
1. `dart:` imports (e.g., `dart:math`)
2. `package:` imports (e.g., `package:flutter/material.dart`, `package:core/models/models.dart`)
3. Relative imports (e.g., `'enums.dart'`, `'../models/models.dart'`)

**Path Aliases:**
- No path aliases configured
- Core package imported via `package:core/...` (e.g., `package:core/models/models.dart`, `package:core/data/data.dart`)
- Apps import each other's widgets via relative paths within their own `lib/` directory

**Import Style:**
- Barrel files used for grouped exports:
  - `packages/core/lib/models/models.dart` — exports all model files
  - `packages/core/lib/data/data.dart` — exports all demo data files
- Prefer barrel imports in apps: `package:core/models/models.dart`

## Model Design Patterns

**Immutability:**
- All model fields are `final` (immutable after construction)
- Exception: `EncounterEntry` and `EncounterState` have mutable fields (`currentHp`, `round`, `currentTurnIndex`, `dmNotes`, `isActive`, `notes`) for runtime state tracking

**Constructors:**
- Named parameters with `required` keyword for mandatory fields
- Default values for optional fields using `= const []` for empty lists, `= false` for bools, `= 0` for numbers
- Auto-generated IDs via initializer list: `id = id ?? const Uuid().v4()`
- `const` constructors used where all fields are final and compile-time constants (e.g., `AbilityScores`, `MovementSpeed`, `SpecialAbility`)

**Serialization:**
- Every model has `Map<String, dynamic> toJson()` method
- Every model has `factory Model.fromJson(Map<String, dynamic> json)` constructor
- Enum serialization uses `.name` for output and `EnumType.values.byName()` for input
- Nested objects call their own `toJson()`/`fromJson()` recursively
- Nullable fields use `as Type?` casts with `?? default` fallbacks
- List deserialization pattern:
  ```dart
  (json['skills'] as List<dynamic>)
      .map((s) => SkillProficiency.fromJson(Map<String, dynamic>.from(s as Map)))
      .toList()
  ```

**Factory Methods:**
- Domain conversion factories follow `from<SourceType>` pattern:
  - `CreatureDetail.fromPlayerCharacter(PlayerCharacter pc)`
  - `CreatureDetail.fromMonster(Monster m)`
  - `CreatureDetail.fromNPC(NPC npc)`
  - `CombatantDragData.fromPlayerCharacter(PlayerCharacter pc)`
  - `InitiativeEntry.fromMonster(Monster m)`

## Widget Design Patterns

**Widget Structure:**
- `StatelessWidget` for simple display widgets (e.g., `CreatureDetail`, `RollHistoryPanel`, `TabData`)
- `StatefulWidget` for interactive widgets (e.g., `InitiativeTracker`, `GenericTabView`, `_Sidebar`)
- Private state classes named `_WidgetNameState` (e.g., `_InitiativeTrackerState`, `_GenericTabViewState`)

**State Management:**
- Uses `provider: ^6.1.2` as dependency (declared in both app pubspecs)
- No `Provider` or `ChangeNotifier` usage observed in current code
- State managed via `setState()` in `StatefulWidget`s
- Parent-to-child communication via callbacks (`ValueChanged<T>`, `VoidCallback`)

**Widget Composition:**
- Small private widgets for UI sections (e.g., `_StatRow`, `_AbilityCard`, `_SkillRow`, `_EmptyTab`)
- Theme accessed via `Theme.of(context)` in `build()` methods
- Local `final theme = Theme.of(context)` pattern used consistently
- `const` constructors used for all widgets where possible

**Helper Functions:**
- Private formatting functions at file level (e.g., `_titleCase`, `_formatCR`, `_formatSpeed`, `_formatSenses`, `_modifierLabel`, `_abbrev`, `_toRoman`)
- Static constants for reference data (e.g., `_allSkills`, `_romanNumerals`)

## Comments

**Dartdoc:**
- No `///` dartdoc comments in any Dart source files
- Only dartdoc comments found are in auto-generated Windows platform files

**Inline Comments:**
- No inline comments in Dart source files
- Demo data files have no comments

## Function Design

**Size:**
- Widget `build()` methods range from ~20 lines (`RollHistoryPanel`) to ~75 lines (`HomeScreen`)
- Helper functions are short (1-10 lines)
- `toJson()`/`fromJson()` methods are verbose but mechanical (20-60 lines for complex models)

**Parameters:**
- Named parameters exclusively used for constructors with 2+ parameters
- Positional parameters not used in constructors
- Callbacks typed as `ValueChanged<T>` or `VoidCallback`

**Return Values:**
- Single return type per function
- Nullable return types used where appropriate (e.g., `EncounterEntry? get currentTurnEntry`)

## Module Design

**Exports:**
- Barrel files re-export all sibling files:
  - `packages/core/lib/models/models.dart`: exports `enums.dart`, `value_types.dart`, `player_character.dart`, `npc.dart`, `monster.dart`, `item.dart`
  - `packages/core/lib/data/data.dart`: exports `demo_player_characters.dart`, `demo_monsters.dart`, `demo_npcs.dart`, `demo_items.dart`

**Package Dependencies:**
- Apps depend on `core` via path dependency: `path: ../../packages/core`
- Apps depend on `provider: ^6.1.2`
- Core depends on `nsd`, `uuid`, `shelf`, `http`

---

*Convention analysis: 2026-05-07*

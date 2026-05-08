# Phase 6: Service Layer + D&D 5e Asset - Context

**Gathered:** 2026-05-08
**Status:** Ready for planning
**Source:** Orchestrator analysis + ROADMAP.md + REQUIREMENTS.md

<domain>
## Phase Boundary

Phase 6 delivers the D&D 5e GameModel as a bundled JSON asset and a ChangeNotifier service that loads and broadcasts it at app startup. Existing wiki behavior must remain unchanged — this phase adds the service layer without modifying wiki page rendering, storage, or search.

**What this phase delivers:**
1. `dnd5e.json` — bundled asset defining all 7 existing wiki page types as EntityTypeSchema entries
2. `GameModelService` — ChangeNotifier in core that parses JSON and broadcasts the active model
3. Provider wiring in both apps — ChangeNotifierProxyProvider connects GameModelService to WikiProvider

**What this phase does NOT deliver:**
- WikiProvider refactoring to use GameModel (Phase 7)
- Hardcoded enum removal (Phase 8)
- Character sheet / encounter tracker changes (Phase 9)
- System picker UI (Phase 10)
</domain>

<decisions>
## Implementation Decisions

### Asset Location (SYSTEM-01)
- dnd5e.json MUST be placed at `packages/core/assets/game_models/dnd5e.json`
- core/pubspec.yaml MUST declare the asset in the `flutter.assets` section
- The JSON must have schemaVersion: 1 (int, not string) per SCHEMA-04

### Entity Types (SYSTEM-01)
- dnd5e.json MUST include entity types matching all 7 existing WikiPageType enum values: creature, spell, item, rule, location, npc, other
- Each entity type's `key` MUST match the WikiPageType enum name (e.g., `"creature"`, `"spell"`)
- Each entity type's `displayName` MUST match the existing `WikiPageTypeExtension.displayName` values
- Each entity type's `isWikiPageType` MUST be `true` for all 7 types
- Each entity type's `fields` MUST reproduce the existing `WikiPageTypeExtension.fields` definitions using FieldSchema format

### Field Schema Mapping (SYSTEM-01)
- FieldSchema `key` MUST match existing WikiPageFieldDefinition `key` exactly
- FieldSchema `label` MUST match existing WikiPageFieldDefinition `label` exactly
- FieldSchema `inputType` maps: text→text, number→number, multiline→multiline, select→select
- FieldSchema `validation.enumOptions` MUST contain the same options list as WikiPageFieldDefinition `options`
- FieldSchema `validation.required` MUST match WikiPageFieldDefinition `required`
- FieldSchema `validation.hint` MUST match WikiPageFieldDefinition `hint`

### Ability Scores (SYSTEM-01)
- rulesConfig MUST include `abilityScores` with display names: Strength, Dexterity, Constitution, Intelligence, Wisdom, Charisma

### Initiative Formula (SYSTEM-01)
- rulesConfig MUST include `initiativeConfig` with formula `"1d20+DEX"` (or equivalent structure)

### GameModelService Architecture
- GameModelService MUST be a ChangeNotifier in `packages/core/lib/services/game_model_service.dart`
- GameModelService MUST use `GameModelParser.parse()` (from Phase 5) to validate and parse the JSON
- GameModelService MUST expose `GameModel? activeModel` getter
- GameModelService MUST have `Future<void> loadFromAsset(String assetPath)` method
- GameModelService MUST call `notifyListeners()` after successful load
- GameModelService MUST be placed in core (not in apps) — both apps consume it

### Provider Wiring (WIKI-03)
- Both apps' main.dart MUST use `ChangeNotifierProxyProvider<GameModelService, WikiProvider>`
- WikiProvider MUST gain an `updateGameModel(GameModel? model)` method
- WikiProvider MUST NOT lose its existing `loadAll()` behavior
- The proxy provider's `update` callback MUST call `wikiProvider.updateGameModel(gameModelService.activeModel)`

### the agent's Discretion
- JSON structure for abilityScores and initiativeConfig within rulesConfig (exact key names, nesting)
- Whether GameModelService loads via rootBundle string passed from app or has its own Flutter dependency
- Exact error handling strategy for asset load failures (log + null model vs. throw)
- Whether to add a `loading` state to GameModelService
</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Phase 5 Output (models)
- `packages/core/lib/models/game_model.dart` — GameModel class (schemaVersion, name, entityTypes, rulesConfig)
- `packages/core/lib/models/entity_type_schema.dart` — EntityTypeSchema (key, displayName, isWikiPageType, fields)
- `packages/core/lib/models/field_schema.dart` — FieldSchema + FieldInputType enum
- `packages/core/lib/models/game_model_parser.dart` — GameModelParser.parse() static method
- `packages/core/lib/models/models.dart` — Barrel export

### Phase 5 Output (patterns)
- `packages/core/lib/models/game_entity.dart` — GameEntity wrapper (typed accessors pattern)

### Existing Code (must not break)
- `packages/core/lib/wiki/wiki_provider.dart` — WikiProvider (needs updateGameModel method added)
- `packages/core/lib/models/wiki_page_type.dart` — WikiPageType enum (source of truth for field definitions to replicate)
- `apps/companion_app/lib/main.dart` — CompanionApp entry (needs provider wiring)
- `apps/dm_app/lib/main.dart` — DmApp entry (needs provider wiring)
- `packages/core/lib/services/services.dart` — Services barrel (needs GameModelService export)
- `packages/core/pubspec.yaml` — Core pubspec (needs flutter.assets declaration)
</canonical_refs>

<specifics>
## Specific References

### Existing WikiPageType fields (must replicate in dnd5e.json):

**creature**: size (select), creatureType (text), armorClass (number), hitPoints (number), speed (text), challengeRating (text)
**spell**: level (number), school (select), castingTime (text), range (text), duration (text), components (text)
**item**: rarity (select), itemType (text), attunement (select), weight (number), value (text), properties (multiline)
**rule**: ruleCategory (select), appliesTo (text), sourcebook (text), pageNumber (number), summary (multiline)
**location**: region (text), locationType (select), population (number), factionControl (text), notableFeatures (multiline)
**npc**: race (text), classOrRole (text), alignment (select), goals (multiline), secrets (multiline)
**other**: category (text), reference (text), notes (multiline)

### Existing WikiPageType displayNames:
Creature, Spell, Item, Rule, Location, NPC, Other

### Phase 5 patterns to follow:
- Pure-Dart immutable data classes with const constructors
- Manual toJson/fromJson serialization (no codegen)
- Enum serialization via .name and .values.byName()
- Static parser class pattern (GameModelParser.parse())
- Barrel export updates for all new files
</specifics>

<deferred>
## Deferred Ideas

None — Phase 6 scope is fully defined by SYSTEM-01 and WIKI-03.
</deferred>

---

*Phase: 06-service-layer-d-d-5e-asset*
*Context gathered: 2026-05-08 via orchestrator analysis*

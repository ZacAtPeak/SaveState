# Architecture Patterns: GameModel Schema System

**Domain:** TTRPG-agnostic schema-driven Flutter app (GameModel migration)
**Researched:** 2026-05-07
**Confidence:** HIGH (codebase analysis) / MEDIUM (external patterns cross-verified)

---

## Recommended Architecture

### Component Map

```
packages/core/lib/
├── game_model/
│   ├── game_model.dart            # GameModel, EntityTypeSchema, FieldSchema
│   ├── game_entity.dart           # GameEntity (typed wrapper over Map<String,dynamic>)
│   ├── game_model_service.dart    # ChangeNotifier — active model + switch
│   └── game_model.g.dart          # (optional) generated fromJson via json_serializable
│
├── wiki/
│   └── wiki_provider.dart         # CHANGE: WikiPageType? → String? (type key into GameModel)
│
├── models/
│   ├── wiki_page.dart             # CHANGE: pageType String (not enum)
│   └── [delete] player_character.dart, monster.dart, npc.dart, enums.dart
│
└── assets/
    ├── game_models/dnd5e.json     # Bundled D&D 5e GameModel
    └── game_models/coc7e.json     # Bundled Call of Cthulhu 7e GameModel

apps/dm_app/lib/
└── main.dart                      # Add GameModelService to Provider tree

apps/companion_app/lib/
└── main.dart                      # Add GameModelService to Provider tree
```

### Component Boundaries

| Component | Responsibility | Communicates With |
|-----------|---------------|-------------------|
| `GameModel` | Immutable data class: parsed JSON schema, list of entity type schemas, rules config | Deserialized from JSON assets or file import; consumed by `GameModelService` |
| `EntityTypeSchema` | Immutable schema for one entity type: key, display name, list of `FieldSchema`, flags (isCharacter, isAdversary, isWikiPageType) | Owned by `GameModel`; consumed by `GameModelFormBuilder`, `WikiProvider` |
| `FieldSchema` | Immutable definition of one field: key, label, inputType, required, hint, options | Owned by `EntityTypeSchema`; replaces `WikiPageFieldDefinition` |
| `GameEntity` | Runtime entity instance: `entityTypeKey` + `Map<String,dynamic> fields` | Created by forms/import; persisted to JSON; consumed by encounter tracker, wiki, character sheet |
| `GameModelService` | `ChangeNotifier` — holds `activeModel`, loads bundled/imported models, broadcasts switches | Consumed by `WikiProvider`, `EncounterProvider`, `CharacterProvider` via `ChangeNotifierProxyProvider` |
| `GameModelFormBuilder` | Stateless widget — builds `Form` children from `List<FieldSchema>` at runtime | Replaces `_buildStructuredField` in `WikiCreateForm`; consumed by create flows |
| `WikiProvider` | `ChangeNotifier` — wiki page CRUD, now carries `GameModel` reference for type lookups | Receives `GameModel` from `GameModelService` via proxy; exposes `availablePageTypes` |

---

## Decision 1: GameEntity Design — Typed Wrapper, Not Raw Map

**Recommendation:** Use `class GameEntity { String entityTypeKey; Map<String, dynamic> fields; }` — the typed wrapper.

**Rationale:**

Raw `Map<String, dynamic>` throughout would mean every caller must independently know the `entityTypeKey` convention and cast fields manually. The typed wrapper:

- Makes the type explicit (`entity.entityTypeKey`) so no key-by-convention
- Allows `copyWith` for immutable updates (same pattern as `InitiativeEntry` already in the codebase)
- Provides a single `toJson`/`fromJson` on `GameEntity` rather than scattered map manipulation
- Allows type-level validation: `entity.validate(schema)` can check required fields exist

**What the class should look like:**

```dart
class GameEntity {
  const GameEntity({
    String? id,
    required this.entityTypeKey,
    required this.fields,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  final String id;
  final String entityTypeKey;         // e.g. "creature", "spell", "character"
  final Map<String, dynamic> fields;  // all typed field values
  final DateTime createdAt;
  final DateTime updatedAt;

  GameEntity copyWith({String? entityTypeKey, Map<String, dynamic>? fields}) => ...;

  Map<String, dynamic> toJson() => {
    'id': id,
    'entityTypeKey': entityTypeKey,
    'fields': fields,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory GameEntity.fromJson(Map<String, dynamic> json) => ...;
}
```

**Serialization tradeoffs:**

- `fields` is `Map<String, dynamic>` — `jsonEncode`/`jsonDecode` handles it natively since all values must be JSON-safe primitives (strings, numbers, booleans, null, lists of those). No nested objects in field values.
- Unknown keys in `fields` are preserved on round-trip. If the schema adds a new required field later, existing entities simply lack it — callers use `fields['key'] ?? defaultValue`.
- Type coercion on load: the `FieldSchema.inputType` tells you whether `fields['hp']` should be coerced to `int`. Do this coercion in `GameEntity.fromJson`, not at use sites.

---

## Decision 2: GameModel JSON Format

**Recommendation:** A single flat JSON object with `schemaVersion`, `system` metadata block, `entityTypes` array, and `rules` config block.

**Rationale from reference systems:**

Foundry VTT's `template.json` uses a two-level structure (document type → sub-types with shared templates). Open5e's API schema uses a flat key namespace per entity. For SaveState's use case, a flat entity-types array with per-type field lists maps directly onto `List<EntityTypeSchema>` in Dart without requiring template inheritance resolution — which adds complexity for no local benefit.

**Canonical format:**

```json
{
  "schemaVersion": 1,
  "system": {
    "key": "dnd5e",
    "name": "Dungeons & Dragons 5th Edition",
    "version": "1.0.0",
    "description": "Official D&D 5e rules"
  },
  "rules": {
    "initiativeFormula": "1d20 + dex_modifier",
    "abilityScoreNames": ["Strength", "Dexterity", "Constitution", "Intelligence", "Wisdom", "Charisma"],
    "defaultDiceNotation": "XdY+Z"
  },
  "entityTypes": [
    {
      "key": "creature",
      "displayName": "Creature",
      "isCharacterType": false,
      "isAdversaryType": true,
      "isWikiPageType": true,
      "fields": [
        { "key": "size", "label": "Size", "inputType": "select", "required": true,
          "options": ["Tiny", "Small", "Medium", "Large", "Huge", "Gargantuan"] },
        { "key": "armorClass", "label": "Armor Class", "inputType": "number", "required": true },
        { "key": "hitPoints", "label": "Hit Points", "inputType": "number", "required": true },
        { "key": "challengeRating", "label": "Challenge Rating", "inputType": "text" }
      ]
    },
    {
      "key": "character",
      "displayName": "Character",
      "isCharacterType": true,
      "isAdversaryType": false,
      "isWikiPageType": false,
      "fields": [
        { "key": "race", "label": "Race", "inputType": "text", "required": true },
        { "key": "class", "label": "Class", "inputType": "text", "required": true },
        { "key": "level", "label": "Level", "inputType": "number", "required": true },
        { "key": "armorClass", "label": "Armor Class", "inputType": "number", "required": true },
        { "key": "hitPoints", "label": "Hit Points", "inputType": "number", "required": true },
        { "key": "maxHitPoints", "label": "Max HP", "inputType": "number", "required": true },
        { "key": "initiative", "label": "Initiative", "inputType": "number" }
      ]
    }
  ]
}
```

**Essential top-level keys:**

| Key | Type | Purpose |
|-----|------|---------|
| `schemaVersion` | `int` | Migration branching — increment on breaking changes |
| `system.key` | `String` | Unique identifier for system switching (e.g., `"dnd5e"`, `"coc7e"`) |
| `system.name` | `String` | Display name in the system picker |
| `system.version` | `String` | Semver for the bundled model file itself |
| `rules` | `Object` | Game-specific rule config (initiative formula, ability score names) |
| `entityTypes` | `Array` | The schema definitions for all entity types |

**FieldSchema inputType values** (mirrors existing `WikiFieldInputType`):

`"text"`, `"number"`, `"multiline"`, `"select"`, `"boolean"`, `"list"` (comma-separated strings)

**Flags on EntityTypeSchema** (`isCharacterType`, `isAdversaryType`, `isWikiPageType`) let the UI filter: the encounter tracker shows only adversary types in the "Add Monster" flow; the wiki type picker shows only wiki page types; the character sheet renders only character types.

---

## Decision 3: Provider Architecture — ChangeNotifierProxyProvider Cascade

**Recommendation:** Use `ChangeNotifierProxyProvider` so `WikiProvider` (and future `EncounterProvider`, `CharacterProvider`) automatically receive the new `GameModel` when `GameModelService` switches models.

**Why not "all UI listens directly to GameModelService":**

Having every individual form widget call `context.watch<GameModelService>().activeModel.entityTypes` spreads the coupling everywhere. The provider that owns wiki page logic (`WikiProvider`) is the right place to re-derive `availablePageTypes` — not dozens of individual UI widgets.

**Why not a manual cascade (WikiProvider calls GameModelService.addListener):**

Manually wiring `addListener`/`removeListener` is brittle and produces memory leaks if dispose is missed. `ChangeNotifierProxyProvider` does this correctly and is already a supported pattern in the `provider ^6.1.2` package already declared in the codebase.

**How the tree is structured:**

```dart
// apps/dm_app/lib/main.dart (and companion_app identically)
MultiProvider(
  providers: [
    ChangeNotifierProvider<GameModelService>(
      create: (_) => GameModelService()..loadBundled(),
    ),
    ChangeNotifierProxyProvider<GameModelService, WikiProvider>(
      create: (ctx) => WikiProvider(
        storage: WikiStorageService(baseDirectory: Directory.current),
        gameModel: ctx.read<GameModelService>().activeModel,
      ),
      update: (_, gameModelService, wikiProvider) {
        wikiProvider!.updateGameModel(gameModelService.activeModel);
        return wikiProvider;
      },
    ),
    // Future providers follow the same proxy pattern:
    // ChangeNotifierProxyProvider<GameModelService, EncounterProvider>(...),
    // ChangeNotifierProxyProvider<GameModelService, CharacterProvider>(...),
  ],
  child: MaterialApp(...),
)
```

**What `WikiProvider.updateGameModel` does:**

```dart
void updateGameModel(GameModel model) {
  _gameModel = model;
  // If selected page type no longer exists in the new model, clear it
  if (_pendingTypeKey != null &&
      !model.entityTypes.any((e) => e.key == _pendingTypeKey)) {
    _pendingTypeKey = null;
  }
  notifyListeners();
}

List<EntityTypeSchema> get availablePageTypes =>
    _gameModel.entityTypes.where((e) => e.isWikiPageType).toList();
```

**Data flow on model switch:**

```
User selects "Call of Cthulhu" in system picker
    ↓
GameModelService.switchModel("coc7e") → loads JSON asset → sets _activeModel → notifyListeners()
    ↓
ChangeNotifierProxyProvider calls update() on WikiProvider
    ↓
WikiProvider.updateGameModel(cocModel) → re-derives availablePageTypes → notifyListeners()
    ↓
WikiTypePicker rebuilds showing CoC page types (Investigator, Tome, Location, etc.)
WikiCreateForm rebuilds showing CoC fields if a type was selected
```

**One constraint:** `ChangeNotifierProxyProvider.update` must not replace the `WikiProvider` instance — it must call a mutating method and return the same instance (`wikiProvider!`). This preserves the existing page list and selection state during a model switch.

---

## Decision 4: Schema Versioning

**Recommendation:** Embed `schemaVersion: int` in every GameModel JSON. Parse version first; run migration functions before constructing the full model.

**Migration pattern in Dart:**

```dart
class GameModelParser {
  static GameModel parse(Map<String, dynamic> json) {
    final version = json['schemaVersion'] as int? ?? 1;
    final migrated = _migrate(json, fromVersion: version);
    return GameModel.fromJson(migrated);
  }

  static Map<String, dynamic> _migrate(Map<String, dynamic> json, {required int fromVersion}) {
    var data = json;
    if (fromVersion < 2) data = _migrateV1toV2(data);
    if (fromVersion < 3) data = _migrateV2toV3(data);
    return data;
  }

  static Map<String, dynamic> _migrateV1toV2(Map<String, dynamic> json) {
    // Example: v1 used "pageTypes" key, v2 uses "entityTypes"
    final result = Map<String, dynamic>.from(json);
    if (result.containsKey('pageTypes') && !result.containsKey('entityTypes')) {
      result['entityTypes'] = result.remove('pageTypes');
    }
    result['schemaVersion'] = 2;
    return result;
  }
}
```

**Rules for backward compatibility:**

- Adding a new optional field to `entityTypes[*].fields`: backward compatible, no version bump needed (old parsers skip unknown field keys)
- Renaming a key in the GameModel JSON structure: requires `schemaVersion` increment + migration function
- The bundled `dnd5e.json` file ships at the current `schemaVersion` — no migration needed at runtime for bundled files
- User-imported files may be older versions — the migration chain handles them silently

**Versioning is for the GameModel JSON file format, not for the user's entity data.** `GameEntity` instances stored to disk carry `entityTypeKey` as a string; if the schema renames `"creature"` to `"monster"`, that is a data migration problem (out of scope per PROJECT.md). Keep entity type keys stable.

---

## Decision 5: Dynamic Form Generation

**Recommendation:** Extract `GameModelFormBuilder` as a stateless widget that takes `List<FieldSchema>` and `Map<String, TextEditingController>`. This is a direct generalization of the existing `_buildStructuredField` method in `WikiCreateForm`.

**Current pattern in WikiCreateForm (lines 106-136):**

The form initializes one `TextEditingController` per field key in `initState`, iterates `widget.selectedType.fields` to build widgets, and collects values on submit. This exact pattern works with runtime `List<FieldSchema>` — the only change is the source of the field list.

**Recommended widget signature:**

```dart
class GameModelFormBuilder extends StatelessWidget {
  const GameModelFormBuilder({
    super.key,
    required this.fields,
    required this.controllers,
  });

  final List<FieldSchema> fields;
  final Map<String, TextEditingController> controllers;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: fields.map(_buildField).toList(),
    );
  }

  Widget _buildField(FieldSchema field) {
    // Same logic as existing _buildStructuredField in WikiCreateForm
    // Handles: select → DropdownButtonFormField
    //          number → TextFormField(keyboardType: TextInputType.number)
    //          multiline → TextFormField(minLines: 3, maxLines: 5)
    //          text → TextFormField (default)
    //          boolean → CheckboxFormField (new inputType)
  }
}
```

**Controller lifecycle — critical detail:**

`initState` must build controllers from the current schema. When the active `GameModel` switches mid-session and the form is still open, `didUpdateWidget` must diff the old and new field lists, dispose controllers for removed fields, and create controllers for added fields. Failure to do this causes memory leaks (controllers never disposed) or crashes (controller accessed after dispose).

```dart
@override
void didUpdateWidget(WikiCreateForm old) {
  super.didUpdateWidget(old);
  if (old.fields != widget.fields) {
    final oldKeys = old.fields.map((f) => f.key).toSet();
    final newKeys = widget.fields.map((f) => f.key).toSet();
    for (final removed in oldKeys.difference(newKeys)) {
      _structured[removed]?.dispose();
      _structured.remove(removed);
    }
    for (final added in newKeys.difference(oldKeys)) {
      _structured[added] = TextEditingController();
    }
  }
}
```

**Select fields with runtime options:**

The existing `DropdownButtonFormField` pattern works unchanged — `field.options` comes from the JSON schema instead of a hardcoded Dart list.

---

## Decision 6: Build Order

Build order is determined by the dependency graph. Nothing should be built that depends on something not yet stable.

### Dependency Graph

```
GameModel (data class, no deps)
    ↓
GameModelParser (parses JSON → GameModel, no Flutter deps)
    ↓
EntityTypeSchema, FieldSchema (owned by GameModel)
    ↓
GameEntity (entityTypeKey + fields, no Flutter deps)
    ↓
GameModelService (ChangeNotifier — wraps GameModel + file loading)
    ↓
WikiProvider (proxy to GameModelService — must receive GameModel on update)
WikiPage (model change: pageType String replaces WikiPageType enum)
    ↓
GameModelFormBuilder (widget — depends on FieldSchema, replaces static WikiCreateForm)
WikiTypePicker (widget — reads GameModelService.activeModel.entityTypes filtered by isWikiPageType)
    ↓
WikiCreateForm (updated to use GameModelFormBuilder)
WikiModalProvider (type changed: pendingTypeKey String not WikiPageType enum)
    ↓
Provider tree wiring (MultiProvider in both app main.dart)
    ↓
System picker UI (settings screen for switching active GameModel)
    ↓
Demo data migration (convert demoPlayerCharacters/demoMonsters/demoNPCs → GameEntity)
    ↓
D&D 5e GameModel JSON asset (replaces demo data typed fields)
Call of Cthulhu 7e GameModel JSON asset (agnosticism proof)
```

### Recommended Phase Sequence

**Phase A — Core data layer (no UI, pure Dart):**

1. `FieldSchema` + `EntityTypeSchema` + `GameModel` data classes with `toJson`/`fromJson`
2. `GameModelParser` with `schemaVersion` migration chain
3. `GameEntity` with `toJson`/`fromJson` and `copyWith`
4. Unit tests: round-trip JSON for all three classes

Rationale: Everything depends on these. Build and test them before touching any UI or Provider. They have zero Flutter dependencies — can be tested with `dart test`, no `flutter test` needed.

**Phase B — Service layer:**

5. `GameModelService` as `ChangeNotifier` (loads bundled assets via `rootBundle`, holds `activeModel`, exposes `switchModel`)
6. Bundled `dnd5e.json` asset (JSON-ification of current `WikiPageType.fields` — the exact same data, just externalized)
7. `GameModelService` unit tests with mock `AssetBundle`

Rationale: Until `GameModelService` exists and can load a model, nothing downstream can be wired. The D&D 5e JSON must exist before any other phase can produce visible output.

**Phase C — Provider rewiring (no new UI):**

8. Change `WikiPage.pageType` from `WikiPageType` enum to `String` (type key)
9. Update `WikiPage.fromJson`/`toJson` accordingly
10. Update `WikiProvider` to accept `GameModel` via constructor + `updateGameModel` mutator
11. Wire `ChangeNotifierProxyProvider<GameModelService, WikiProvider>` in both app `main.dart` files
12. Update `WikiCreateSubmitFlow` to use `EntityTypeSchema` instead of `WikiPageType`
13. Update `WikiStorageService.loadAllPages` — `WikiPage.fromJson` handles the string type key
14. Update `WikiModalProvider.pendingType` from `WikiPageType?` to `String?`

Rationale: This is the riskiest phase for breaking existing functionality. Completing it with no new features (only the existing D&D 5e model loaded) lets you verify the existing wiki still works before removing the typed models.

**Phase D — UI generalization:**

15. `GameModelFormBuilder` widget (replaces `_buildStructuredField`)
16. Update `WikiCreateForm` to use `GameModelFormBuilder` and receive `List<FieldSchema>` instead of `WikiPageType`
17. Update `WikiTypePicker` to read `GameModelService.activeModel.entityTypes` filtered by `isWikiPageType`
18. Delete `packages/core/lib/models/wiki_page_type.dart` once zero references remain

Rationale: The static `WikiPageType` enum can be deleted only after the form and type picker are both driven by runtime schemas.

**Phase E — Typed model replacement:**

19. `GameEntity` storage service (parallel to `WikiStorageService` but for entities)
20. Migrate `demoPlayerCharacters`, `demoMonsters`, `demoNPCs` to `List<GameEntity>` using D&D 5e model keys
21. Update `CreatureDetail.from*` factory constructors to accept `GameEntity`
22. Update `CombatantDragData.from*` factory constructors to accept `GameEntity`
23. Delete `player_character.dart`, `monster.dart`, `npc.dart`, `enums.dart`

Rationale: These deletions are last because `CreatureDetail` and `CombatantDragData` are adapters that depend on the typed models. They can only be updated after `GameEntity` is stable and the encounter tracker logic is validated.

**Phase F — Agnosticism proof:**

24. Bundled `coc7e.json` asset
25. System picker UI (selector in settings showing bundled + imported models)
26. File import via `file_picker` for external `.json` model files
27. Full end-to-end test: switch D&D 5e → CoC 7e, create CoC entities, switch back

Rationale: The CoC model is the litmus test. If it works without code changes, only JSON, then the architecture is genuinely agnostic. Build it last so all the machinery is proven on D&D first.

---

## Architectural Patterns to Follow

### Pattern 1: FieldSchema Mirrors WikiPageFieldDefinition

`FieldSchema` is a direct generalization of the existing `WikiPageFieldDefinition`. Use identical field names (`key`, `label`, `inputType`, `required`, `hint`, `options`) so the diff from `WikiPageFieldDefinition` to `FieldSchema` is minimal — only the source (JSON parse vs Dart constructor) changes.

### Pattern 2: String Type Keys, Not Enums

Everywhere `WikiPageType` (an enum) is used, replace with `String` (a type key). The GameModel is the registry that says which keys are valid. This is the same pattern `WikiPage.statBlock` already uses: `Map<String, dynamic>` with string keys, not typed structs.

### Pattern 3: Flags Over Separate Lists

Use `isCharacterType`, `isAdversaryType`, `isWikiPageType` boolean flags on `EntityTypeSchema` rather than maintaining separate lists of character types vs wiki page types. A single entity type can be multiple things (a PC is both a character type and potentially a wiki page type). Flags compose; parallel lists diverge.

### Pattern 4: GameModelService as the Single Source of Truth

No component except `GameModelService` should hold a reference to the loaded GameModel JSON or parse it. All other providers receive the model object via `ChangeNotifierProxyProvider`. If a widget needs the active model directly, it reads `context.watch<GameModelService>().activeModel` — it never loads or parses JSON itself.

### Pattern 5: GameEntity is Opaque Storage

`GameEntity.fields` is treated as opaque `Map<String, dynamic>` by the storage layer. Only UI components and domain logic that know the active `GameModelService` should interpret field values. The storage service reads/writes the map without schema knowledge — the same way `WikiPage.statBlock` works today.

---

## Anti-Patterns to Avoid

### Anti-Pattern 1: Putting Schema Logic in GameEntity

**What goes wrong:** Adding methods like `entity.armorClass` or `entity.initiativeModifier` to `GameEntity` — these are D&D concepts baked into a generic type.

**Instead:** Domain logic that interprets fields lives in game-system-aware services or UI components that have access to the `GameModelService`. `GameEntity` carries data; it does not know what the data means.

### Anti-Pattern 2: Replacing Enum with int Index

**What goes wrong:** Storing the entity type as an integer index into `gameModel.entityTypes` instead of a string key. Saves a byte; breaks every saved `GameEntity` if the type list is reordered.

**Instead:** Always use the string `key` field as the persistent identifier. Indices are UI concerns only.

### Anti-Pattern 3: WikiProvider Listening to GameModelService Directly

**What goes wrong:** `WikiProvider` calls `gameModelService.addListener(() { updateGameModel(gameModelService.activeModel); })` in its constructor. If the listener is not removed in `dispose`, or if `WikiProvider` is recreated while the listener is still attached, memory leaks and double-notification bugs follow.

**Instead:** `ChangeNotifierProxyProvider` handles the subscription lifecycle correctly. Let the Provider framework manage the wiring.

### Anti-Pattern 4: Lazy Schema Loading

**What goes wrong:** Loading the GameModel JSON on first use (when the wiki opens) instead of at app startup. Creates visible delay + race conditions (what happens if two widgets request entity types simultaneously before the model loads?).

**Instead:** `GameModelService.loadBundled()` is called in `initState` of the root widget, before `MaterialApp` renders. Assets loaded via `rootBundle` are synchronous after the first load; the startup parse is under 50ms for a well-formed JSON file.

### Anti-Pattern 5: Preserving WikiPageType Enum as Intermediate Layer

**What goes wrong:** Adding a `toEntityTypeSchema()` method to `WikiPageType` as a bridge during migration. Creates two parallel systems that must stay in sync.

**Instead:** Phase C (Provider rewiring) does the migration in one pass. The enum is deleted when the last reference is removed. No bridge; clean cut.

---

## Scalability Considerations

| Concern | Current Scale | At 10 Entity Types | At 50+ Entity Types |
|---------|--------------|--------------------|--------------------|
| Model parse time | <10ms | <20ms | <50ms (still well under target) |
| `availablePageTypes` filter | Negligible | Negligible | Still O(n), fine |
| Form field controllers | 5-10 fields | 10-20 fields | Consider lazy initialization |
| `WikiProvider.availablePageTypes` rebuild | One list copy | One list copy | One list copy — no scaling issue |

**Memory:** A parsed `GameModel` with 20 entity types and 10 fields each is approximately 50KB of Dart objects. No scaling concern for the foreseeable lifetime of this app.

---

## Sources

- Codebase analysis: `wiki_page_type.dart`, `wiki_create_form.dart`, `wiki_provider.dart`, `wiki_storage_service.dart`, `player_character.dart`, `encounter.dart`, `dm_app/main.dart` — HIGH confidence (direct observation)
- Foundry VTT template.json structure (https://www.makeyourownrpg.com/my-rpg-blog/creating-a-new-system-for-foundry-vtt-the-data-template) — MEDIUM confidence (cross-checked with official Foundry docs)
- Foundry VTT DataModel fields and migration: https://foundryvtt.com/article/system-data-models/ — MEDIUM confidence
- Open5e V2 API creature schema: https://api.open5e.com/v2/creatures/srd_aboleth/ — HIGH confidence (live API response)
- Flutter `ChangeNotifierProxyProvider` pattern: https://pub.dev/packages/provider — HIGH confidence (official package docs)
- JSON schema versioning best practices: https://developer.couchbase.com/tutorial-schema-versioning — MEDIUM confidence (multiple sources agree on schemaVersion + migration chain pattern)

---

*Architecture research for: GameModel schema-driven Flutter app*
*Researched: 2026-05-07*

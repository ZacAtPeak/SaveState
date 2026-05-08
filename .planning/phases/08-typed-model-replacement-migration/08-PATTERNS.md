# Phase 8: Typed Model Replacement & Migration - Pattern Map

**Mapped:** 2026-05-08  
**Files analyzed:** 20  
**Analogs found:** 20 / 20

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|---|---|---|---|---|
| `packages/core/lib/migrations/wiki_migration_runner.dart` (new) | service | file-I/O, batch | `packages/core/lib/services/wiki_storage_service.dart` | exact |
| `packages/core/lib/models/wiki_page.dart` | model | transform, request-response | `packages/core/lib/models/game_entity.dart` | role-match |
| `packages/core/lib/services/wiki_storage_service.dart` | service | file-I/O | `packages/core/lib/services/wiki_storage_service.dart` | exact |
| `packages/core/lib/wiki/wiki_provider.dart` | provider | request-response | `packages/core/lib/wiki/wiki_provider.dart` | exact |
| `packages/core/lib/wiki/wiki_modal_provider.dart` | provider | request-response | `packages/core/lib/wiki/wiki_modal_provider.dart` | exact |
| `packages/core/lib/wiki/wiki_type_picker.dart` | component | request-response | `packages/core/lib/wiki/wiki_type_picker.dart` | exact |
| `packages/core/lib/data/demo_entities.dart` (new) | data/utility | transform | `packages/core/lib/data/demo_items.dart` | role-match |
| `packages/core/lib/data/demo_player_characters.dart` | data/model | transform | `packages/core/lib/data/demo_monsters.dart` | role-match |
| `packages/core/lib/data/demo_monsters.dart` | data/model | transform | `packages/core/lib/data/demo_monsters.dart` | exact |
| `packages/core/lib/data/demo_npcs.dart` | data/model | transform | `packages/core/lib/data/demo_npcs.dart` | exact |
| `packages/core/lib/data/data.dart` | config/barrel | request-response | `packages/core/lib/data/data.dart` | exact |
| `packages/core/lib/models/models.dart` | config/barrel | request-response | `packages/core/lib/models/models.dart` | exact |
| `packages/core/lib/models/item.dart` | model | CRUD/transform | `packages/core/lib/models/item.dart` | exact |
| `packages/core/lib/models/value_types.dart` | model | transform | `packages/core/lib/models/value_types.dart` | exact |
| `apps/dm_app/lib/main.dart` | component | request-response | `apps/dm_app/lib/main.dart` | exact |
| `apps/dm_app/lib/widgets/initiative_tracker.dart` | component | event-driven | `apps/dm_app/lib/widgets/initiative_tracker.dart` | exact |
| `apps/dm_app/lib/widgets/creature_detail_view.dart` | component | transform | `apps/dm_app/lib/widgets/creature_detail_view.dart` | exact |
| `packages/core/test/wiki_migration_runner_test.dart` (new) | test | file-I/O, batch | `packages/core/test/wiki_storage_service_test.dart` | role-match |
| `packages/core/test/wiki_page_string_type_test.dart` (new) | test | transform | `packages/core/test/wiki_page_test.dart` | role-match |
| `apps/dm_app/test/game_entity_sidebar_smoke_test.dart` (new) | test | request-response | `packages/core/test/wiki_create_submit_test.dart` | partial |

## Pattern Assignments

### `packages/core/lib/migrations/wiki_migration_runner.dart` (service, file-I/O + batch)

**Analog:** `packages/core/lib/services/wiki_storage_service.dart`

**Imports pattern** (`wiki_storage_service.dart:1-6`):
```dart
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:core/models/models.dart';
```

**Directory + path scope pattern** (`wiki_storage_service.dart:167-172`):
```dart
Directory get _pagesDir =>
    Directory(path.join(_baseDirectory.path, 'wiki', 'pages'));

void _ensureDirectory() {
  _pagesDir.createSync(recursive: true);
}
```

**Per-file read/parse with skip-on-error pattern** (`wiki_storage_service.dart:192-204`):
```dart
final entities = await _pagesDir.list().toList();
for (final entity in entities) {
  if (entity is File && entity.path.endsWith('.json')) {
    try {
      final content = await entity.readAsString();
      final jsonMap = jsonDecode(content) as Map<String, dynamic>;
      pages.add(WikiPage.fromJson(jsonMap));
    } catch (_) {
      // Skip malformed files
    }
  }
}
```

---

### `packages/core/lib/models/wiki_page.dart` (model, transform)

**Analog:** `packages/core/lib/models/game_entity.dart` + current `wiki_page.dart`

**String-key JSON schema pattern** (`game_entity.dart:10-20`):
```dart
Map<String, dynamic> toJson() => {
      'entityTypeKey': entityTypeKey,
      'data': Map<String, dynamic>.from(_data),
    };

factory GameEntity.fromJson(Map<String, dynamic> json) => GameEntity(
      entityTypeKey: json['entityTypeKey'] as String,
      data: json['data'] != null
          ? Map<String, dynamic>.from(json['data'] as Map)
          : {},
    );
```

**Current field mapping style to preserve** (`wiki_page.dart:32-44`, `47-67`):
```dart
Map<String, dynamic> toJson() {
  return {
    'id': id,
    'title': title,
    'pageType': pageType.name,
    'body': body,
    'tags': tags,
    'aliases': aliases,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'referenceId': referenceId,
    'statBlock': statBlock,
  };
}
```

Use this same explicit mapping shape when renaming `pageType` -> `entityTypeKey`.

---

### `packages/core/lib/wiki/wiki_provider.dart` (provider, request-response)

**Analog:** `packages/core/lib/wiki/wiki_provider.dart`

**Load-once + seed fallback pattern** (`wiki_provider.dart:45-58`):
```dart
Future<void> loadAll() async {
  if (_isLoaded) return;
  final loaded = await _storage.loadAllPages();
  if (loaded.isEmpty) {
    for (final page in demoWikiPages) {
      await _storage.savePage(page);
    }
    _pages.addAll(demoWikiPages);
  } else {
    _pages.addAll(loaded);
  }
  _isLoaded = true;
  notifyListeners();
}
```

**Submit-flow delegation pattern** (`wiki_provider.dart:60-66`):
```dart
final flow = WikiCreateSubmitFlow(storage: _storage, target: this);
return flow.submit(selectedType: selectedType, draft: draft);
```

Use same call site for startup migration runner before `loadAllPages()`.

---

### `packages/core/lib/wiki/wiki_modal_provider.dart` + `wiki_type_picker.dart` (provider/component)

**Analogs:** `wiki_modal_provider.dart`, `wiki_type_picker.dart`

**Transitional compatibility marker pattern** (`wiki_modal_provider.dart:18-22`):
```dart
/// Deprecated: returns null. The interface is transitioning to entity keys.
/// Will be removed in Phase 8 when WikiPageType enum is deleted.
@Deprecated('Use pendingEntityKey instead')
WikiPageType? get pendingType => null;
```

**Entity-key-first picker pattern** (`wiki_type_picker.dart:18-27`):
```dart
if (entityTypes != null) {
  wikiTypes = entityTypes!
      .where((e) => e.isWikiPageType)
      .toList()
    ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
} else {
  // Fallback: derive from WikiPageType enum for backward compatibility
  wikiTypes = WikiPageType.values.map(_entityFromPageType).toList();
}
```

Phase 8 should remove fallback branch and keep first branch semantics.

---

### `packages/core/lib/data/demo_entities.dart` (new), `demo_player_characters.dart`, `demo_monsters.dart`, `demo_npcs.dart` (data transform)

**Analogs:** `demo_monsters.dart`, `demo_npcs.dart`, `game_entity.dart`, `demo_items.dart`

**Raw map dataset pattern** (`demo_monsters.dart:3-16`, `demo_npcs.dart:3-17`):
```dart
final List<Map<String, dynamic>> _monsterJsonData = [ ... ];
final List<Map<String, dynamic>> _npcJsonData = [ ... ];
```

**Entity wrapper JSON pattern** (`game_entity.dart:15-20`):
```dart
factory GameEntity.fromJson(Map<String, dynamic> json) => GameEntity(
      entityTypeKey: json['entityTypeKey'] as String,
      data: json['data'] != null
          ? Map<String, dynamic>.from(json['data'] as Map)
          : {},
    );
```

**Flat top-level export constant pattern** (`demo_items.dart:1-4`):
```dart
import '../models/models.dart';

final demoAssets = <Item>[
```

Use same style for unified `demoEntities` list and update `data.dart` exports (`data.dart:1-5`).

---

### `packages/core/lib/models/models.dart` + `data/data.dart` (barrel/config)

**Analogs:** `models.dart`, `data.dart`, `services.dart`

**One-export-per-line barrel pattern** (`models.dart:1-13`, `data.dart:1-5`, `services.dart:1-3`):
```dart
export 'enums.dart';
export 'value_types.dart';
...
export 'game_model_parser.dart';
```

Follow this when deleting old exports and adding `demo_entities.dart` / migration exports.

---

### `packages/core/lib/models/item.dart` + `value_types.dart` (enum removal targets)

**Analogs:** `item.dart`, `value_types.dart`

**Enum string serialization pattern to replace** (`item.dart:31-47`, `value_types.dart:252-266`):
```dart
'type': type.name,
'bonusType': bonusType.name,
'bonusAbility': bonusAbility?.name,
...
type: ItemType.values.byName(json['type'] as String? ?? 'other'),
...
damageType: DamageType.values.byName(json['damageType'] as String),
```

**Manual field-by-field constructor mapping pattern** (`value_types.dart:246-270`):
```dart
factory Attack.fromJson(Map<String, dynamic> json) => Attack(
      id: json['id'] as String,
      name: json['name'] as String,
      ...
    );
```

Keep explicit mapping, but replace enum parsing with string-safe mapping aligned to GameModel keys.

---

### `apps/dm_app/lib/main.dart` (component, request-response)

**Analog:** `apps/dm_app/lib/main.dart`

**Startup service/provider wiring pattern** (`main.dart:27-35`, `46-55`):
```dart
_gameModelService = GameModelService();
_gameModelService.loadFromAsset('packages/core/assets/game_models/dnd5e.json');
_wikiProvider = WikiProvider(
  storage: WikiStorageService(baseDirectory: Directory.current),
);
_wikiProvider.loadAll();
...
ChangeNotifierProxyProvider<GameModelService, WikiProvider>(
  create: (_) => _wikiProvider,
  update: (_, gameModelService, wikiProvider) {
    wikiProvider!.updateGameModel(gameModelService.activeModel);
    return wikiProvider;
  },
),
```

**Sidebar pre-split list pattern** (`main.dart:91-110`):
```dart
late final List<_SidebarEntry> _characters = demoPlayerCharacters.map(...).toList();
late final List<_SidebarEntry> _monsters = demoMonsters.map(...).toList();
late final List<_SidebarEntry> _npcs = demoNPCs.map(...).toList();
```

Replace source lists with `demoEntities` + helper pre-splits (D-14), keep this structure.

---

### `apps/dm_app/lib/widgets/initiative_tracker.dart` (component, event-driven)

**Analog:** `initiative_tracker.dart`

**Drag-drop + initiative roll pattern** (`initiative_tracker.dart:224-255`):
```dart
final roll = _rng.nextInt(20) + 1;
final initiative = (roll + data.initiativeModifier).toDouble();
...
final entry = InitiativeEntry(
  id: instanceId,
  sourceId: data.id,
  name: data.name,
  initiative: initiative,
  currentHP: data.currentHP,
  maxHP: data.maxHP,
  statusConditions: data.statusConditions,
  isPlayer: data.isPlayer,
);
```

**Factory conversion seam to replace typed models** (`initiative_tracker.dart:41-68`, `92-121`):
```dart
factory CombatantDragData.fromPlayerCharacter(PlayerCharacter pc) => ...
factory CombatantDragData.fromMonster(Monster m) => ...
factory CombatantDragData.fromNPC(NPC npc) => ...
...
factory InitiativeEntry.fromPlayerCharacter(PlayerCharacter pc) => ...
```

Add equivalent `fromGameEntity(...)` constructors and preserve fallback-safe reads.

---

### `apps/dm_app/lib/widgets/creature_detail_view.dart` (component, transform)

**Analog:** `creature_detail_view.dart`

**DTO bridge pattern** (`creature_detail_view.dart:4-37`):
```dart
class CreatureDetail {
  final String id;
  final String name;
  ...
  const CreatureDetail({ ... });
}
```

**Factory conversion seam** (`creature_detail_view.dart:39-92`):
```dart
factory CreatureDetail.fromPlayerCharacter(PlayerCharacter pc) => ...
factory CreatureDetail.fromMonster(Monster m) => ...
factory CreatureDetail.fromNPC(NPC npc) => ...
```

Keep DTO + factory style; switch factories to `GameEntity` inputs with safe defaults for missing D&D fields (D-16).

---

### Tests to create

#### `packages/core/test/wiki_migration_runner_test.dart`
**Analog:** `packages/core/test/wiki_storage_service_test.dart`

**Temp dir setup/teardown pattern** (`wiki_storage_service_test.dart:12-19`):
```dart
setUp(() {
  tempDir = Directory.systemTemp.createTempSync('wiki_test_');
  service = WikiStorageService(baseDirectory: tempDir);
});

tearDown(() {
  tempDir.deleteSync(recursive: true);
});
```

**Group/test organization pattern** (`wiki_storage_service_test.dart:37-129`):
```dart
group('loadAllPages', () {
  test('returns all saved pages', () async { ... });
});
```

#### `packages/core/test/wiki_page_string_type_test.dart`
**Analog:** `packages/core/test/wiki_page_test.dart`

**Serialization assertion style** (`wiki_page_test.dart:80-91`, `139-154`):
```dart
final json = page.toJson();
expect(json['pageType'], equals('spell'));
...
final page = WikiPage.fromJson(json);
expect(page.pageType, equals(WikiPageType.spell));
```

Reuse this exact style with `entityTypeKey` assertions.

#### `apps/dm_app/test/game_entity_sidebar_smoke_test.dart`
**Analog:** `packages/core/test/wiki_create_submit_test.dart`

**Small focused behavior test style** (`wiki_create_submit_test.dart:22-94`):
```dart
group('WikiCreateSubmitFlow', () {
  test('persists a created page with expected common fields', () async { ... });
});
```

Use concise smoke expectations for sidebar splits and null-safe fallbacks.

## Shared Patterns

### File I/O + parse-failure tolerance
**Source:** `packages/core/lib/services/wiki_storage_service.dart:192-204`  
**Apply to:** `wiki_migration_runner.dart`, storage migration hooks
```dart
try {
  final content = await entity.readAsString();
  final jsonMap = jsonDecode(content) as Map<String, dynamic>;
  pages.add(WikiPage.fromJson(jsonMap));
} catch (_) {
  // Skip malformed files
}
```

### Explicit manual JSON mapping
**Source:** `packages/core/lib/models/wiki_page.dart:32-44`, `packages/core/lib/models/value_types.dart:246-270`  
**Apply to:** wiki page schema rename + demo entity conversion code
```dart
Map<String, dynamic> toJson() => { ... };
factory X.fromJson(Map<String, dynamic> json) => X(...);
```

### Provider notification lifecycle
**Source:** `packages/core/lib/wiki/wiki_provider.dart:68-85`, `packages/core/lib/wiki/wiki_modal_provider.dart:47-73`  
**Apply to:** wiki create/migration UI integration
```dart
void onCreateComplete() {
  _isCreating = false;
  _pendingEntityKey = null;
  notifyListeners();
}
```

### DM bridge via conversion DTOs/factories
**Source:** `apps/dm_app/lib/widgets/initiative_tracker.dart:41-68`, `apps/dm_app/lib/widgets/creature_detail_view.dart:39-92`  
**Apply to:** `GameEntity` migration without widget rewrite
```dart
factory CombatantDragData.fromX(...) => ...;
factory CreatureDetail.fromX(...) => ...;
```

## No Analog Found

| File | Role | Data Flow | Reason |
|---|---|---|---|
| None | — | — | Existing storage/model/provider/test patterns cover all Phase 8 files. |

## Metadata

**Analog search scope:**
- `packages/core/lib/models/`
- `packages/core/lib/services/`
- `packages/core/lib/wiki/`
- `packages/core/lib/data/`
- `apps/dm_app/lib/`
- `packages/core/test/`

**Files scanned:** 19  
**Pattern extraction date:** 2026-05-08

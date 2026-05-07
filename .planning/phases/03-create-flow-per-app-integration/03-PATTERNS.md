# Phase 3: Create Flow & Per-App Integration - Pattern Map

**Mapped:** 2026-05-07
**Files analyzed:** 11
**Analogs found:** 9 / 11

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|---|---|---|---|---|
| `packages/core/lib/models/wiki_page_type.dart` (modify) | model | transform | `packages/core/lib/models/wiki_page_type.dart` | exact |
| `packages/core/lib/wiki/wiki_modal_provider.dart` (modify) | provider | event-driven | `packages/core/lib/wiki/wiki_modal_provider.dart` | exact |
| `packages/core/lib/wiki/wiki_modal_shell.dart` (modify) | component | request-response | `packages/core/lib/wiki/wiki_modal_shell.dart` | exact |
| `packages/core/lib/wiki/wiki_type_picker.dart` (new) | component | event-driven | `packages/core/lib/wiki/wiki_page_list.dart` | role-match |
| `packages/core/lib/wiki/wiki_create_form.dart` (new) | component | CRUD | `packages/core/lib/wiki/wiki_page_detail.dart` + `packages/core/lib/services/wiki_storage_service.dart` | partial |
| `packages/core/lib/wiki/wiki_provider.dart` (new) | provider | CRUD | `packages/core/lib/wiki/wiki_modal_provider.dart` + `packages/core/lib/services/wiki_storage_service.dart` | role-match |
| `packages/core/lib/wiki/wiki.dart` (modify exports) | config | transform | `packages/core/lib/wiki/wiki.dart` | exact |
| `apps/companion_app/lib/main.dart` (modify) | component | request-response | `apps/dm_app/lib/main.dart` | role-match |
| `apps/dm_app/lib/main.dart` (modify) | component | request-response | `apps/dm_app/lib/main.dart` | exact |
| `packages/core/test/wiki_create_flow_test.dart` (new) | test | event-driven | `packages/core/test/wiki_page_test.dart` | role-match |
| `packages/core/test/wiki_create_submit_test.dart` / `wiki_create_form_test.dart` (new) | test | CRUD | `packages/core/test/wiki_storage_service_test.dart` | role-match |

## Pattern Assignments

### `packages/core/lib/models/wiki_page_type.dart` (model, transform)

**Analog:** `packages/core/lib/models/wiki_page_type.dart`

**Enum + extension pattern** (lines 1-34):
```dart
enum WikiPageType {
  creature,
  spell,
  item,
  rule,
  location,
  npc,
  other,
}

extension WikiPageTypeExtension on WikiPageType {
  bool get isReferenceType { ... }
  String get displayName { ... }
}
```

**Apply:** add a `fields` getter to this existing extension (do not create a separate schema file), matching current extension-based metadata style.

---

### `packages/core/lib/wiki/wiki_modal_provider.dart` (provider, event-driven)

**Analog:** `packages/core/lib/wiki/wiki_modal_provider.dart`

**ChangeNotifier state + getters** (lines 4-10):
```dart
class WikiModalProvider extends ChangeNotifier {
  WikiPage? _selectedPage;
  bool _isTwoPanel = false;

  WikiPage? get selectedPage => _selectedPage;
  bool get isTwoPanel => _isTwoPanel;
}
```

**Mutation methods notify listeners** (lines 11-24):
```dart
void selectPage(WikiPage? page) {
  _selectedPage = page;
  notifyListeners();
}

void reset() {
  _selectedPage = null;
  notifyListeners();
}
```

**Apply:** implement `isCreating`, `pendingType`, and page list mutation methods with the same private-field + getter + `notifyListeners()` pattern.

---

### `packages/core/lib/wiki/wiki_modal_shell.dart` (component, request-response)

**Analog:** `packages/core/lib/wiki/wiki_modal_shell.dart`

**Imports + provider wiring** (lines 1-7, 38-41):
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'wiki_modal_provider.dart';
...
return ChangeNotifierProvider.value(
  value: widget.provider,
  child: Consumer<WikiModalProvider>(
```

**Modal launcher factory** (lines 14-25):
```dart
static Future<void> show(
  BuildContext context, {
  VoidCallback? onClose,
  required WikiModalProvider provider,
  required List<WikiPage> pages,
}) {
  return showModalBottomSheet(...);
}
```

**Responsive split pattern** (lines 35-37, 53-73):
```dart
final width = MediaQuery.sizeOf(context).width;
final isTwoPanel = width >= 600;

body: isTwoPanel ? Row(...) : _buildSinglePanel(modal),
```

**Apply:** keep this structure and branch body by modal state (`list`/`picker`/`form`/`detail`) while preserving two-panel and single-panel behavior.

---

### `packages/core/lib/wiki/wiki_type_picker.dart` (component, event-driven)

**Analog:** `packages/core/lib/wiki/wiki_page_list.dart`

**Enum-driven icon mapping pattern** (lines 94-111):
```dart
IconData _iconForType(WikiPageType type) {
  switch (type) {
    case WikiPageType.creature: return Icons.pets;
    ...
  }
}
```

**Tap callback pattern** (line 85):
```dart
onTap: () => widget.onPageSelected?.call(page),
```

**Apply:** build 2x4 cards from `WikiPageType.values`; each card invokes `onTypeSelected(type)` callback. Reuse icon-per-type switch style from list.

---

### `packages/core/lib/wiki/wiki_create_form.dart` (component, CRUD)

**Analogs:**
- `packages/core/lib/wiki/wiki_page_detail.dart`
- `packages/core/lib/services/wiki_storage_service.dart`
- `packages/core/lib/models/wiki_page.dart`

**Layout conventions** from detail widget (lines 14-19, 33-36):
```dart
return Padding(
  padding: const EdgeInsets.all(16),
  child: SingleChildScrollView(
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [...]),
  ),
);
```

**Persistence call shape** from storage service (lines 22-27):
```dart
Future<void> savePage(WikiPage page) async {
  ...
  await file.writeAsString(jsonString);
}
```

**Model construction contract** from WikiPage (lines 17-30):
```dart
WikiPage({
  required this.title,
  required this.pageType,
  this.body = '',
  this.tags = const [],
  this.aliases = const [],
  this.statBlock = const {},
})
```

**Apply:** create form should gather title/body/tags/aliases + dynamic `statBlock` and instantiate `WikiPage` directly, then call provider/service async save path.

---

### `packages/core/lib/wiki/wiki_provider.dart` (provider, CRUD)

**Analogs:**
- `packages/core/lib/wiki/wiki_modal_provider.dart`
- `packages/core/lib/services/wiki_storage_service.dart`

**Notifier API pattern** (modal provider lines 4-24):
```dart
class ... extends ChangeNotifier {
  // private state, public getters
  // mutators call notifyListeners()
}
```

**Async load/save pattern** (storage lines 40-55, 22-27):
```dart
Future<List<WikiPage>> loadAllPages() async { ... }
Future<void> savePage(WikiPage page) async { ... }
```

**Apply:** top-level provider should own `List<WikiPage>`, expose `loadAll()`, `addPage()`, maybe `saveAndAddPage()` and notify listeners after mutation.

---

### `apps/dm_app/lib/main.dart` + `apps/companion_app/lib/main.dart` (component, request-response)

**Analogs:**
- `apps/dm_app/lib/main.dart`
- `apps/companion_app/lib/main.dart`
- `packages/core/lib/wiki/wiki_modal_shell.dart`

**MaterialApp root pattern** (companion lines 13-20, dm lines 16-23):
```dart
return MaterialApp(
  title: '...',
  theme: ThemeData(...),
  home: const HomeScreen(),
);
```

**AppBar action pattern** (dm lines 128-146):
```dart
actions: [
  IconButton(
    icon: const Icon(Icons.menu_book),
    tooltip: 'Wiki',
    onPressed: () {},
  ),
]
```

**Modal invocation contract** (shell lines 14-25):
```dart
WikiModalShell.show(context, provider: ..., pages: ...)
```

**Apply:** wrap app root with top-level `ChangeNotifierProvider<WikiProvider>` and wire the existing book icon to call `WikiModalShell.show(...)` using provider-managed pages.

---

### New tests in `packages/core/test/` (test, event-driven/CRUD)

**Analogs:**
- `packages/core/test/wiki_page_test.dart`
- `packages/core/test/wiki_storage_service_test.dart`

**Group/test structure** (wiki_page_test lines 4-8):
```dart
void main() {
  group('...', () {
    test('...', () { ... });
  });
}
```

**Fixture lifecycle + async assertions** (wiki_storage_service_test lines 9-19, 37-55):
```dart
late Directory tempDir;
setUp(() { ... });
tearDown(() { ... });

test('...', () async {
  await service.savePage(page);
  expect(...);
});
```

**Apply:** follow same `group` segmentation and temp-directory fixture style for create-flow submit tests.

## Shared Patterns

### Provider state management
**Source:** `packages/core/lib/wiki/wiki_modal_provider.dart` lines 4-24 and `packages/core/lib/wiki/wiki_modal_shell.dart` lines 38-41
**Apply to:** `wiki_provider.dart`, `wiki_modal_provider.dart`, app roots
```dart
class WikiModalProvider extends ChangeNotifier { ... }

return ChangeNotifierProvider.value(
  value: widget.provider,
  child: Consumer<WikiModalProvider>(...)
)
```

### Persistence boundary in service layer
**Source:** `packages/core/lib/services/wiki_storage_service.dart` lines 22-27, 40-55
**Apply to:** create-submit path + app startup load
```dart
await storage.savePage(page);
final pages = await storage.loadAllPages();
```

### Enum/extension-driven UI metadata
**Source:** `packages/core/lib/models/wiki_page_type.dart` lines 11-34 and `packages/core/lib/wiki/wiki_page_list.dart` lines 94-111
**Apply to:** type picker + dynamic field rendering
```dart
extension WikiPageTypeExtension on WikiPageType { ... }
switch (type) { ... }
```

### Reusable shared wiki exports
**Source:** `packages/core/lib/wiki/wiki.dart` lines 1-6
**Apply to:** adding new shared widgets/providers
```dart
export 'wiki_modal_shell.dart';
export 'wiki_modal_provider.dart';
...
```

## No Analog Found

| File | Role | Data Flow | Reason |
|---|---|---|---|
| `packages/core/lib/wiki/wiki_type_picker.dart` | component | event-driven | No existing grid-card selector in `core/wiki`; closest is list-based selector (`wiki_page_list.dart`). |
| `packages/core/test/wiki_create_flow_test.dart` (widget-level modal flow) | test | event-driven | No existing widget tests in `packages/core/test`; current tests are model/service unit tests only. |

## Metadata

**Analog search scope:**
- `packages/core/lib/wiki/`
- `packages/core/lib/models/`
- `packages/core/lib/services/`
- `apps/companion_app/lib/`
- `apps/dm_app/lib/`
- `packages/core/test/`

**Files scanned:** 14
**Pattern extraction date:** 2026-05-07

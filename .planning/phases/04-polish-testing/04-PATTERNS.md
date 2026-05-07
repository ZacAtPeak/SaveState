# Phase 4: Polish & Testing - Pattern Map

**Mapped:** 2026-05-07
**Files analyzed:** 10
**Analogs found:** 10 / 10

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|-------------------|------|-----------|----------------|---------------|
| `packages/core/lib/utils/debounce.dart` (new) | utility | transform | `packages/core/lib/wiki/wiki_page_list.dart` (lines 25-47) | pattern-extract |
| `packages/core/lib/wiki/wiki_modal_shell.dart` (modified) | component | request-response | itself — existing file | exact |
| `packages/core/lib/wiki/wiki_modal_provider.dart` (modified) | provider | event-driven | `packages/core/lib/wiki/wiki_provider.dart` | role-match |
| `packages/core/lib/wiki/wiki_page_list.dart` (modified) | component | event-driven | itself — existing file | exact |
| `packages/core/lib/wiki/wiki.dart` (modified) | barrel | N/A | itself — existing barrel | exact |
| `packages/core/lib/services/services.dart` (modified) | barrel | N/A | itself — existing barrel | exact |
| `packages/core/test/wiki_modal_provider_test.dart` (new) | test | request-response | `packages/core/test/wiki_search_service_test.dart` | role-match |
| `packages/core/test/wiki_debounce_test.dart` (new) | test | request-response | `packages/core/test/wiki_search_service_test.dart` | role-match |
| `packages/core/test/wiki_modal_dismissal_test.dart` (new) | test | request-response | `packages/core/test/wiki_create_submit_test.dart` | role-match |
| `apps/companion_app/test/wiki_modal_behavior_test.dart` (new) | test (widget) | request-response | `apps/companion_app/test/wiki_entry_integration_test.dart` | exact |
| `apps/dm_app/test/wiki_modal_behavior_test.dart` (new) | test (widget) | request-response | `apps/dm_app/test/wiki_entry_integration_test.dart` | exact |

## Pattern Assignments

### `packages/core/lib/utils/debounce.dart` (utility, transform) — NEW

**Analog pattern extracted from:** `packages/core/lib/wiki/wiki_page_list.dart` (lines 1-47)

The debounce logic currently lives inline in `WikiPageList`. Decision D-09 requires extracting it to a shared utility.

**Current inline pattern** (wiki_page_list.dart lines 1-47):
```dart
import 'dart:async';

// ... inside _WikiPageListState:
Timer? _debounceTimer;
String _currentQuery = '';

void _onQueryChanged(String query) {
  widget.onQueryChanged?.call(query);
  _debounceTimer?.cancel();
  _debounceTimer = Timer(const Duration(milliseconds: 250), () {
    setState(() => _currentQuery = query);
  });
}
```

**Target pattern:** A reusable `DebounceUtil` class with:
- Constructor accepting `Duration` (canonical: 250ms per D-10)
- `run(VoidCallback callback)` method that cancels prior timer and schedules new one
- `cancel()` method for cleanup
- `dispose()` method matching Dart lifecycle conventions

**Imports pattern** (follow core utility conventions):
```dart
import 'dart:async';
```

---

### `packages/core/lib/wiki/wiki_modal_shell.dart` (component, request-response) — MODIFIED

**Analog:** itself (existing file, 199 lines)

**Close button pattern** (lines 67-73) — will need modification per D-03:
```dart
leading: IconButton(
  icon: const Icon(Icons.close),
  onPressed: () {
    Navigator.of(context).pop();
    widget.onClose?.call();
  },
),
```

**Two-panel breakpoint pattern** (lines 48-49) — locked at 600dp per D-05:
```dart
final width = MediaQuery.sizeOf(context).width;
final isTwoPanel = width >= 600;
```

**Create flow routing** (lines 79-86) — relates to D-02 (tap-outside disabled during create):
```dart
onPressed: () {
  if (isTwoPanel) {
    widget.provider.startCreate();
  } else {
    _openSinglePanelCreateFlow(context);
  }
},
```

**Modal entry point** (lines 19-31) — hook for dismissal hardening per D-01/D-04:
```dart
static Future<void> show(
  BuildContext context, {
  VoidCallback? onClose,
  required WikiModalProvider provider,
  required List<WikiPage> pages,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => WikiModalShell(onClose: onClose, provider: provider, pages: pages),
  );
}
```

---

### `packages/core/lib/wiki/wiki_modal_provider.dart` (provider, event-driven) — MODIFIED

**Analog:** `packages/core/lib/wiki/wiki_provider.dart` (65 lines)

**ChangeNotifier pattern** (wiki_modal_provider.dart lines 1-16):
```dart
import 'package:flutter/foundation.dart';
import 'package:core/models/models.dart';
import 'package:core/services/services.dart';

class WikiModalProvider extends ChangeNotifier implements WikiCreateTarget {
  WikiPage? _selectedPage;
  bool _isTwoPanel = false;
  bool _isCreating = false;
  WikiPageType? _pendingType;
  final List<WikiPage> _pages = [];
```

**Existing reset pattern** (lines 69-74) — relates to D-01 (reset on reopen):
```dart
void reset() {
  _selectedPage = null;
  _isCreating = false;
  _pendingType = null;
  notifyListeners();
}
```

**Select page pattern** (lines 41-44) — relates to D-04 (restore last selected page):
```dart
void selectPage(WikiPage? page) {
  _selectedPage = page;
  notifyListeners();
}
```

**Create flow pattern** (lines 52-67):
```dart
void startCreate() {
  _isCreating = true;
  _pendingType = null;
  notifyListeners();
}

void cancelCreate() {
  _isCreating = false;
  _pendingType = null;
  notifyListeners();
}
```

---

### `packages/core/lib/wiki/wiki_page_list.dart` (component, event-driven) — MODIFIED

**Analog:** itself (existing file, 112 lines)

**Debounce to extract** (lines 25-47) — will be replaced by shared utility per D-09:
```dart
Timer? _debounceTimer;
String _currentQuery = '';

void _onQueryChanged(String query) {
  widget.onQueryChanged?.call(query);
  _debounceTimer?.cancel();
  _debounceTimer = Timer(const Duration(milliseconds: 250), () {
    setState(() => _currentQuery = query);
  });
}
```

**Search service usage** (lines 24, 31-32, 49-52):
```dart
late final WikiSearchService _searchService;

// initState:
_searchService = WikiSearchService();
_searchService.index(widget.pages);

// getter:
List<WikiPage> get _displayedPages {
  if (_currentQuery.isEmpty) return widget.pages;
  return _searchService.search(_currentQuery).map((r) => r.page).toList();
}
```

**Imports pattern** (lines 1-6):
```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:core/models/models.dart';
import 'package:core/services/services.dart';
```

---

### `packages/core/lib/wiki/wiki.dart` (barrel) — MODIFIED

**Analog:** itself (9 lines)

**Current exports:**
```dart
export 'wiki_modal_shell.dart';
export 'wiki_modal_provider.dart';
export 'wiki_page_list.dart';
export 'wiki_page_detail.dart';
export 'wiki_stat_block.dart';
export 'wiki_type_picker.dart';
export 'wiki_create_form.dart';
export 'wiki_provider.dart';
```

**Add export for new debounce utility if placed in wiki/ directory, or update services.dart if placed in services/.**

---

### `packages/core/lib/services/services.dart` (barrel) — MODIFIED

**Analog:** itself (2 lines)

**Current exports:**
```dart
export 'wiki_storage_service.dart';
export 'wiki_search_service.dart';
```

**Add export for debounce utility if placed in services/ directory per D-09 ("shared service").**

---

### `packages/core/test/wiki_modal_provider_test.dart` (test) — NEW

**Analog:** `packages/core/test/wiki_search_service_test.dart` (167 lines)

**Test structure pattern** (lines 1-27):
```dart
import 'package:test/test.dart';
import 'package:core/models/models.dart';
import 'package:core/services/services.dart';

// Helper function for test fixtures
WikiPage _page({
  String? id,
  required String title,
  String body = '',
  List<String> tags = const [],
  WikiPageType pageType = WikiPageType.spell,
}) {
  return WikiPage(
    id: id,
    title: title,
    pageType: pageType,
    body: body,
    tags: tags,
  );
}

void main() {
  late WikiSearchService service;

  setUp(() {
    service = WikiSearchService();
  });
```

**Group + test pattern** (lines 28-39):
```dart
  group('indexing', () {
    test('index replaces existing pages', () {
      final pageA = _page(id: 'a', title: 'Page A');
      final pageB = _page(id: 'b', title: 'Page B');

      service.addPage(pageA);
      service.index([pageB]);

      final results = service.search('');
      expect(results.length, equals(1));
      expect(results.first.page.title, equals('Page B'));
    });
```

**Key scenarios per D-13/D-14:**
- Dismissal resets create state (D-01)
- Restore last selected page on reopen (D-04)
- Create flow state transitions

---

### `packages/core/test/wiki_debounce_test.dart` (test) — NEW

**Analog:** `packages/core/test/wiki_search_service_test.dart` (167 lines)

**Same test structure pattern** as above.

**Key scenarios per D-15:**
- Deterministic timer pumping with explicit pre/post 250ms assertions
- Trailing-edge only behavior (D-11)
- Callback fires only when debounce settles (D-12)

**Timer pumping pattern** (use `FakeAsync` from `fake_async` package or `tester.pump` in widget tests):
```dart
import 'package:test/test.dart';
import 'package:fake_async/fake_async.dart';

void main() {
  group('DebounceUtil', () {
    test('callback fires after 250ms debounce', () {
      fakeAsync((async) {
        var called = false;
        final debounce = DebounceUtil(const Duration(milliseconds: 250));

        debounce.run(() => called = true);
        expect(called, isFalse); // pre-250ms assertion

        async.elapse(const Duration(milliseconds: 250));
        expect(called, isTrue); // post-250ms assertion
      });
    });
```

---

### `packages/core/test/wiki_modal_dismissal_test.dart` (test) — NEW

**Analog:** `packages/core/test/wiki_create_submit_test.dart` (95 lines)

**Test structure with setUp/tearDown** (lines 1-21):
```dart
import 'dart:io';

import 'package:core/models/models.dart';
import 'package:core/services/services.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;
  late WikiStorageService storage;
  late InMemoryWikiCreateTarget target;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('wiki_create_submit_');
    storage = WikiStorageService(baseDirectory: tempDir);
    target = InMemoryWikiCreateTarget();
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });
```

---

### `apps/companion_app/test/wiki_modal_behavior_test.dart` (widget test) — NEW

**Analog:** `apps/companion_app/test/wiki_entry_integration_test.dart` (27 lines)

**Widget test structure pattern** (lines 1-27):
```dart
import 'package:companion_app/main.dart';
import 'package:core/wiki/wiki.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  group('Companion wiki entry integration', () {
    testWidgets('exposes top-level WikiProvider and opens wiki modal from AppBar', (tester) async {
      await tester.pumpWidget(const CompanionApp());

      expect(
        find.byWidgetPredicate((widget) => widget is ChangeNotifierProvider<WikiProvider>),
        findsOneWidget,
      );

      final wikiButton = find.byIcon(Icons.menu_book);
      expect(wikiButton, findsOneWidget);
      expect(find.byTooltip('Wiki'), findsOneWidget);

      await tester.tap(wikiButton);
      await tester.pumpAndSettle();

      expect(find.text('Wiki'), findsOneWidget);
    });
  });
}
```

**Key patterns to apply:**
- `tester.pumpWidget(...)` for app-level widget pumping
- `tester.pumpAndSettle()` after async interactions
- `find.byIcon(...)`, `find.byTooltip(...)`, `find.text(...)` for widget finding
- `find.byWidgetPredicate(...)` for provider verification

**Responsive breakpoint testing** (per D-07/D-08):
```dart
testWidgets('modal shows single panel at 599dp', (tester) async {
  tester.view.physicalSize = const Size(599, 800);
  tester.view.devicePixelRatio = 1.0;
  // ... pump modal, assert single-panel structure
});

testWidgets('modal shows two-panel at 600dp', (tester) async {
  tester.view.physicalSize = const Size(600, 800);
  tester.view.devicePixelRatio = 1.0;
  // ... pump modal, assert two-panel structure
});
```

---

### `apps/dm_app/test/wiki_modal_behavior_test.dart` (widget test) — NEW

**Analog:** `apps/dm_app/test/wiki_entry_integration_test.dart` (27 lines)

**Same widget test structure** as companion_app, substituting `DmApp` for `CompanionApp`:
```dart
import 'package:core/wiki/wiki.dart';
import 'package:dm_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  group('DM wiki modal behavior', () {
    testWidgets('opens wiki modal from AppBar', (tester) async {
      await tester.pumpWidget(const DmApp());
      // ... same pattern as companion_app
    });
  });
}
```

## Shared Patterns

### Barrel Export Pattern
**Source:** `packages/core/lib/wiki/wiki.dart`, `packages/core/lib/services/services.dart`
**Apply to:** Any new file in core package

All new core files must be exported from their directory's barrel file:
```dart
// wiki.dart
export 'wiki_modal_shell.dart';
export 'wiki_modal_provider.dart';
// ... add new exports here
```

### ChangeNotifier Provider Pattern
**Source:** `packages/core/lib/wiki/wiki_modal_provider.dart` (lines 1-75)
**Apply to:** All provider/state files

```dart
import 'package:flutter/foundation.dart';
import 'package:core/models/models.dart';

class WikiModalProvider extends ChangeNotifier implements WikiCreateTarget {
  // Private state fields
  WikiPage? _selectedPage;
  
  // Public getters
  WikiPage? get selectedPage => _selectedPage;
  
  // Mutators with notifyListeners()
  void selectPage(WikiPage? page) {
    _selectedPage = page;
    notifyListeners();
  }
}
```

### Core Test Structure Pattern
**Source:** `packages/core/test/wiki_search_service_test.dart`
**Apply to:** All `packages/core/test/` files

```dart
import 'package:test/test.dart';
import 'package:core/models/models.dart';
import 'package:core/services/services.dart';

// Helper fixture functions at top level
WikiPage _page({...}) { ... }

void main() {
  late SomeService service;

  setUp(() {
    service = SomeService();
  });

  group('feature area', () {
    test('descriptive assertion', () {
      // arrange
      // act
      // assert with expect(...)
    });
  });
}
```

### Widget Test Structure Pattern
**Source:** `apps/companion_app/test/wiki_entry_integration_test.dart`
**Apply to:** All `apps/*/test/` widget behavior tests

```dart
import 'package:<app_name>/main.dart';
import 'package:core/wiki/wiki.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  group('<App> wiki behavior', () {
    testWidgets('descriptive scenario', (tester) async {
      await tester.pumpWidget(const <App>());
      // ... interactions and assertions
    });
  });
}
```

### Responsive Breakpoint Testing Pattern
**Source:** D-07, D-08 in CONTEXT.md (boundary widths: 599, 600, 840, 841)
**Apply to:** Both app-level widget test files

```dart
// Set physical size before pumping widget
tester.view.physicalSize = const Size(width, height);
tester.view.devicePixelRatio = 1.0;
addTearDown(tester.view.resetPhysicalSize);

// Assert panel structure at each boundary
```

## No Analog Found

Files with no close match in the codebase (planner should use RESEARCH.md patterns instead):

| File | Role | Data Flow | Reason |
|------|------|-----------|--------|
| `packages/core/lib/utils/debounce.dart` | utility | transform | No standalone debounce utility exists; pattern extracted from inline usage in `wiki_page_list.dart` |
| `packages/core/test/wiki_modal_dismissal_test.dart` | test | request-response | No dedicated dismissal behavior tests exist yet; structure follows `wiki_create_submit_test.dart` pattern |

## Metadata

**Analog search scope:** `packages/core/lib/`, `packages/core/test/`, `apps/companion_app/test/`, `apps/dm_app/test/`
**Files scanned:** 18
**Pattern extraction date:** 2026-05-07

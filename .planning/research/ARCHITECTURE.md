# Architecture Research: Wiki Popup UI

**Domain:** Flutter wiki popup with responsive layouts in existing D&D companion/DM apps
**Researched:** 2026-05-07
**Confidence:** HIGH

## System Overview

The wiki popup integrates as a full-screen modal overlay accessible from both apps via a book icon in the AppBar. It uses a shared core package for models and services, with app-specific UI layers that share a responsive layout component.

```
┌─────────────────────────────────────────────────────────────────┐
│                        App Layer (each app)                      │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────────┐    ┌──────────────────────────────┐    │
│  │ companion_app/lib/  │    │ dm_app/lib/                  │    │
│  │  wiki/              │    │  wiki/                       │    │
│  │   wiki_modal.dart   │    │   wiki_modal.dart            │    │
│  │   wiki_trigger.dart │    │   wiki_trigger.dart          │    │
│  └────────┬────────────┘    └────────────┬─────────────────┘    │
│           │                              │                      │
│           └──────────────┬───────────────┘                      │
├──────────────────────────┼──────────────────────────────────────┤
│                    Shared UI Layer                               │
├──────────────────────────┼──────────────────────────────────────┤
│  ┌───────────────────────┴──────────────────────────────────┐   │
│  │  packages/core/lib/wiki/ (or apps shared via composition) │   │
│  │  ┌──────────────────┐ ┌────────────────┐ ┌────────────┐  │   │
│  │  │ WikiPageList     │ │ WikiPageDetail │ │ WikiCreate │  │   │
│  │  │ (searchable list)│ │ (markdown +    │ │ (form for  │  │   │
│  │  │                  │ │  stat blocks)  │ │  new pages)│  │   │
│  │  └────────┬─────────┘ └───────┬────────┘ └─────┬──────┘  │   │
│  │           │                   │                │         │   │
│  │  ┌────────┴───────────────────┴────────────────┴──────┐  │   │
│  │  │              WikiResponsiveLayout                  │  │   │
│  │  │  (MediaQuery.sizeOf branching: 1-panel vs 2-panel) │  │   │
│  │  └────────────────────────────────────────────────────┘  │   │
│  └──────────────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────────────┤
│                        Core Package                              │
├─────────────────────────────────────────────────────────────────┤
│  ┌──────────────┐ ┌─────────────────┐ ┌──────────────────────┐  │
│  │ WikiPage     │ │ WikiPageType    │ │ WikiStorageService   │  │
│  │ (model)      │ │ (enum)          │ │ (file-based JSON)    │  │
│  └──────────────┘ └─────────────────┘ └──────────────────────┘  │
│  ┌──────────────┐ ┌─────────────────┐                            │
│  │ StatBlock    │ │ WikiSearchService│                            │
│  │ (value type) │ │ (in-memory text) │                            │
│  └──────────────┘ └─────────────────┘                            │
└─────────────────────────────────────────────────────────────────┘
```

### Component Responsibilities

| Component | Responsibility | Typical Implementation |
|-----------|----------------|------------------------|
| `WikiPage` (core model) | Immutable domain model for wiki pages | Class with `toJson`/`fromJson`, UUID id, title, tags, aliases, markdown body, stat block fields, page type |
| `WikiPageType` (core enum) | Typed page system (rule, item, spell, creature, location, etc.) | Enum with associated field schema metadata |
| `WikiStorageService` (core) | Persist wiki pages to local filesystem | File-based JSON storage using `path_provider` + `dart:io` |
| `WikiSearchService` (core) | In-memory full-text search with title prioritization | Simple string matching over loaded pages, no external dependency |
| `WikiResponsiveLayout` (shared UI) | Branches between 1-panel and 2-panel layouts | `MediaQuery.sizeOf(context)` with 600px breakpoint |
| `WikiPageList` (shared UI) | Searchable sidebar/list of wiki pages | `TextField` + `ListView.builder` with filtered results |
| `WikiPageDetail` (shared UI) | Renders page content (markdown + stat blocks) | `flutter_markdown_plus` for markdown, custom stat block widgets |
| `WikiCreateForm` (shared UI) | Form for creating new wiki pages | `Form` with dynamic fields based on `WikiPageType` |
| `WikiModal` (per-app) | Full-screen modal wrapper with slide-up animation | `showGeneralDialog` with `PageRouteBuilder` |
| `WikiTrigger` (per-app) | Book icon button in each app's AppBar | `IconButton(Icons.menu_book)` wired to modal open |

## Recommended Project Structure

```
SaveState/
├── packages/core/
│   └── lib/
│       ├── models/
│       │   ├── wiki_page.dart           # WikiPage model + toJson/fromJson
│       │   ├── wiki_page_type.dart      # WikiPageType enum
│       │   └── wiki_stat_block.dart     # StatBlock value type for structured data
│       ├── services/
│       │   ├── wiki_storage_service.dart  # File-based JSON persistence
│       │   └── wiki_search_service.dart   # In-memory full-text search
│       └── wiki/                          # NEW: shared wiki UI components
│           ├── wiki_responsive_layout.dart  # Adaptive 1/2-panel layout
│           ├── wiki_page_list.dart          # Searchable page list sidebar
│           ├── wiki_page_detail.dart        # Markdown + stat block renderer
│           ├── wiki_create_form.dart        # New page creation form
│           └── wiki_widgets.dart            # Shared small widgets (tag chips, etc.)
│
├── apps/companion_app/
│   └── lib/
│       ├── main.dart                      # Add wiki trigger to AppBar
│       └── wiki/
│           ├── wiki_modal.dart              # Full-screen modal wrapper
│           └── wiki_trigger.dart            # Book icon button
│
└── apps/dm_app/
    └── lib/
        ├── main.dart                      # Wire existing wiki icon (line 142)
        └── wiki/
            ├── wiki_modal.dart              # Full-screen modal wrapper
            └── wiki_trigger.dart            # Book icon button
```

### Structure Rationale

- **`packages/core/lib/models/`** — Wiki domain models follow the existing pattern (immutable classes with `toJson`/`fromJson` alongside `monster.dart`, `item.dart`, etc.)
- **`packages/core/lib/services/`** — Storage and search services follow the existing service pattern (alongside NSD discovery service)
- **`packages/core/lib/wiki/`** — NEW directory for shared UI components. Both apps render wiki pages identically, so the list, detail, and form widgets belong in core to avoid duplication. This is the same rationale that puts `CreatureDetail` in `creature_detail_view.dart` — but unlike that 757-line monolith, these will be small, focused widgets.
- **`apps/*/lib/wiki/`** — Per-app modal wrappers and trigger buttons. The modal presentation (slide-up animation) is the same, but each app needs its own entry point wired into its existing AppBar.

### Why shared UI in core (not duplicated per app)?

The existing codebase already shares `CreatureDetailView` between apps via the core package. The wiki detail view has the same requirement: identical rendering of markdown, stat blocks, tags, and metadata in both apps. Duplicating this would repeat the monolithic-view anti-pattern.

## Architectural Patterns

### Pattern 1: Responsive Layout via MediaQuery.sizeOf

**What:** Use `MediaQuery.sizeOf(context)` to branch between single-panel (phone) and two-panel (tablet/desktop) layouts based on window width, not device type.

**When to use:** Any widget that needs to adapt its layout to available space — especially full-screen modals.

**Trade-offs:**
- Pro: Works in split-screen, floating windows, and desktop resizing
- Pro: Single codebase, no device-type detection
- Con: Requires a breakpoint decision (600px is Material 3's compact/medium boundary)

**Example:**
```dart
class WikiResponsiveLayout extends StatelessWidget {
  final List<WikiPage> pages;
  final WikiPage? selectedPage;
  final ValueChanged<WikiPage?> onSelectPage;
  final VoidCallback onCreatePage;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 600; // Material 3 compact breakpoint

    if (isWide) {
      return Row(
        children: [
          SizedBox(width: 320, child: WikiPageList(pages: pages, onSelect: onSelectPage)),
          Expanded(child: WikiPageDetail(page: selectedPage)),
        ],
      );
    } else {
      // Single panel: show list if no selection, detail if selected
      return selectedPage != null
          ? WikiPageDetail(page: selectedPage, onBack: () => onSelectPage(null))
          : WikiPageList(pages: pages, onSelect: onSelectPage);
    }
  }
}
```

### Pattern 2: Full-Screen Modal via showGeneralDialog

**What:** Use `showGeneralDialog` with a custom `PageRouteBuilder` for a slide-up full-screen modal with backdrop.

**When to use:** Modal overlays that should feel like a temporary full-screen view (not a new route in the navigator stack).

**Trade-offs:**
- Pro: Slide-up animation, backdrop dimming, back-button dismissal
- Pro: Doesn't interfere with app's existing navigation
- Con: More boilerplate than `Navigator.push`

**Example:**
```dart
void openWikiModal(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close wiki',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return const WikiModalContent();
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
        child: child,
      );
    },
  );
}
```

### Pattern 3: Provider-Based Wiki State

**What:** Use `ChangeNotifierProvider` (already a dependency in companion_app) to manage wiki state (pages, selection, search query, loading).

**When to use:** App-level state that multiple wiki widgets need to read and react to.

**Trade-offs:**
- Pro: Already used in the project, no new dependencies
- Pro: Simple, declarative state management
- Con: Can become unwieldy if state grows complex (mitigated by keeping wiki state focused)

**Example:**
```dart
class WikiState extends ChangeNotifier {
  List<WikiPage> _pages = [];
  WikiPage? _selectedPage;
  String _searchQuery = '';

  List<WikiPage> get pages => _pages;
  WikiPage? get selectedPage => _selectedPage;
  String get searchQuery => _searchQuery;

  List<WikiPage> get filteredPages {
    if (_searchQuery.isEmpty) return _pages;
    final query = _searchQuery.toLowerCase();
    // Title matches first, then body matches
    final titleMatches = _pages.where((p) => p.title.toLowerCase().contains(query)).toList();
    final bodyMatches = _pages.where(
      (p) => !titleMatches.contains(p) && p.body.toLowerCase().contains(query)
    ).toList();
    return [...titleMatches, ...bodyMatches];
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void selectPage(WikiPage? page) {
    _selectedPage = page;
    notifyListeners();
  }

  Future<void> loadPages() async {
    _pages = await WikiStorageService().loadAll();
    notifyListeners();
  }

  Future<void> createPage(WikiPage page) async {
    await WikiStorageService().save(page);
    _pages = [..._pages, page];
    notifyListeners();
  }
}
```

### Pattern 4: Typed Page Schema with Dynamic Forms

**What:** `WikiPageType` enum drives which fields appear in the create form. Each type has a different stat block schema.

**When to use:** When different content types need different structured data but share a common page model.

**Trade-offs:**
- Pro: Single model class, type-specific behavior via enum
- Con: Form logic gets conditional (mitigated by type-specific field builders)

**Example:**
```dart
enum WikiPageType {
  rule,
  item,
  spell,
  creature,
  location,
  npc,
  other;

  List<StatBlockField> get statBlockFields => switch (this) {
    WikiPageType.creature => [
      StatBlockField(name: 'Armor Class', type: StatBlockFieldType.number),
      StatBlockField(name: 'Hit Points', type: StatBlockFieldType.number),
      StatBlockField(name: 'Speed', type: StatBlockFieldType.text),
      StatBlockField(name: 'Challenge Rating', type: StatBlockFieldType.text),
    ],
    WikiPageType.spell => [
      StatBlockField(name: 'Level', type: StatBlockFieldType.number),
      StatBlockField(name: 'Casting Time', type: StatBlockFieldType.text),
      StatBlockField(name: 'Range', type: StatBlockFieldType.text),
      StatBlockField(name: 'Components', type: StatBlockFieldType.text),
      StatBlockField(name: 'Duration', type: StatBlockFieldType.text),
    ],
    WikiPageType.item => [
      StatBlockField(name: 'Type', type: StatBlockFieldType.text),
      StatBlockField(name: 'Rarity', type: StatBlockFieldType.text),
      StatBlockField(name: 'Weight', type: StatBlockFieldType.number),
    ],
    _ => const [],
  };
}
```

## Data Flow

### Opening the Wiki Modal

```
User taps book icon (AppBar)
    ↓
WikiTrigger calls openWikiModal(context)
    ↓
showGeneralDialog presents WikiModalContent
    ↓
WikiModalContent wraps WikiState (ChangeNotifierProvider)
    ↓
WikiState.loadPages() reads from WikiStorageService
    ↓
WikiResponsiveLayout renders (1-panel or 2-panel based on width)
```

### Searching and Selecting Pages

```
User types in search bar (WikiPageList)
    ↓
WikiState.setSearchQuery(query)
    ↓
WikiState.filteredPages recomputes (title matches → body matches)
    ↓
WikiPageList rebuilds with filtered results
    ↓
User taps a page
    ↓
WikiState.selectPage(page)
    ↓
WikiPageDetail rebuilds with selected page content
```

### Creating a New Page

```
User taps + button
    ↓
WikiCreateForm shows (inline in 2-panel, full-screen in 1-panel)
    ↓
User selects WikiPageType → dynamic stat block fields render
    ↓
User fills title, tags, aliases, markdown body, stat block fields
    ↓
User submits
    ↓
WikiState.createPage(newPage) → WikiStorageService.save(page)
    ↓
WikiState reloads pages, list updates
```

### State Management

```
WikiState (ChangeNotifier)
    ↓ (notifyListeners)
WikiPageList ←→ search query
WikiPageDetail ←→ selected page
WikiCreateForm ←→ page type, form fields
WikiResponsiveLayout ←→ layout mode
```

### Key Data Flows

1. **Page load:** Storage service reads JSON files → parses to `List<WikiPage>` → WikiState holds in memory → widgets react
2. **Search:** In-memory filter over loaded pages, no I/O. Title matches prioritized over body matches.
3. **Page creation:** Form → new `WikiPage` → storage service writes JSON file → state updates → list refreshes
4. **Responsive branching:** `MediaQuery.sizeOf` at layout root → single widget tree decides 1-panel vs 2-panel

## Scaling Considerations

| Scale | Architecture Adjustments |
|-------|--------------------------|
| 0-100 pages (current milestone) | In-memory search, file-based JSON storage — no changes needed |
| 100-1000 pages | Consider lazy-loading pages, indexed search (still no DB needed) |
| 1000+ pages | SQLite via `sqflite`/`drift` for indexed search, pagination in list |

### Scaling Priorities

1. **First bottleneck:** Search performance over large page sets. Mitigation: switch from `String.contains` to indexed search when pages exceed ~500.
2. **Second bottleneck:** File I/O latency on page load. Mitigation: cache parsed pages in memory, only re-read on changes.

**Realistic note:** D&D wikis rarely exceed a few hundred pages. File-based JSON with in-memory search is sufficient for this project's lifetime.

## Anti-Patterns

### Anti-Pattern 1: Monolithic Wiki View (757-line creature_detail_view.dart repeat)

**What people do:** Put all wiki UI (list, detail, form, search, stat blocks) in one giant widget file.

**Why it's wrong:** The existing `creature_detail_view.dart` is 757 lines and mixes layout, formatting helpers, tab content, and state. It's hard to navigate, hard to test, and hard to modify without breaking unrelated parts.

**Do this instead:** Split into focused widgets: `WikiPageList` (~80 lines), `WikiPageDetail` (~120 lines), `WikiCreateForm` (~150 lines), `WikiResponsiveLayout` (~40 lines). Each file has a single responsibility.

### Anti-Pattern 2: Duplicating Wiki UI Between Apps

**What people do:** Copy the wiki list/detail/form widgets into both `companion_app` and `dm_app`.

**Why it's wrong:** Both apps must render wiki pages identically. Duplicating means bugs fixed in one app won't be fixed in the other. The existing codebase already shares `CreatureDetailView` via core — follow that pattern.

**Do this instead:** Put shared wiki UI widgets in `packages/core/lib/wiki/`. Each app only owns its modal wrapper and trigger button.

### Anti-Pattern 3: Device-Type Detection Instead of Size-Based Branching

**What people do:** Use `Platform.isIOS` or `MediaQuery.platformBrightness` to decide layout.

**Why it's wrong:** The app may run in a small window on a large desktop, or in split-screen on a tablet. Device type doesn't correlate with available space.

**Do this instead:** Use `MediaQuery.sizeOf(context).width` with Material 3 breakpoints (600px compact/medium boundary). Branch on size, not device.

### Anti-Pattern 4: Navigator.push for Modal Presentation

**What people do:** Use `Navigator.push` to navigate to a wiki screen.

**Why it's wrong:** The wiki is a popup overlay, not a navigation destination. `Navigator.push` adds to the route stack, changes the URL (on web), and doesn't provide the slide-up modal feel specified in requirements.

**Do this instead:** Use `showGeneralDialog` with a custom `PageRouteBuilder` for slide-up animation and backdrop dismissal.

### Anti-Pattern 5: Coupling Wiki State to App-Specific Providers

**What people do:** Put wiki state in the companion app's or DM app's provider tree.

**Why it's wrong:** Wiki state is shared between both apps. App-specific providers create coupling and prevent the core package from owning wiki behavior.

**Do this instead:** `WikiState` is a standalone `ChangeNotifier` instantiated at the modal level. It's self-contained and doesn't depend on app-level state.

## Integration Points

### External Services

| Service | Integration Pattern | Notes |
|---------|---------------------|-------|
| `flutter_markdown_plus` | Dependency in both app pubspec.yaml | `flutter_markdown` is discontinued; use `flutter_markdown_plus: ^1.0.7` (the official successor) |
| `path_provider` | Dependency in core pubspec.yaml | Needed for file-based storage path resolution |
| `provider` | Already in companion_app; add to dm_app | Used for `WikiState` ChangeNotifier |

### Internal Boundaries

| Boundary | Communication | Notes |
|----------|---------------|-------|
| `WikiTrigger` → `WikiModal` | Function call (`openWikiModal(context)`) | Simple, no state crossing |
| `WikiModal` → `WikiResponsiveLayout` | Widget composition | Modal provides the state provider, layout consumes it |
| `WikiResponsiveLayout` → `WikiPageList` / `WikiPageDetail` | Widget composition with callbacks | Layout passes filtered pages and selection state down |
| `WikiPageList` → `WikiSearchService` | Direct method call | Search service is stateless, called from WikiState |
| `WikiState` → `WikiStorageService` | Async method calls | Storage service is the I/O boundary |
| `WikiCreateForm` → `WikiState` | Callback (`onCreatePage`) | Form emits new page, state persists it |

### Existing Code Integration

| Location | Change | Details |
|----------|--------|---------|
| `apps/dm_app/lib/main.dart` line 142-145 | Wire existing wiki icon | Replace empty `onPressed: () {}` with `onPressed: () => openWikiModal(context)` |
| `apps/companion_app/lib/main.dart` | Add wiki icon to AppBar | Add `IconButton(Icons.menu_book)` to HomeScreen's Scaffold appBar actions |
| `packages/core/pubspec.yaml` | Add `path_provider` dependency | Required for file storage |
| `apps/companion_app/pubspec.yaml` | Already has `provider` | No change needed |
| `apps/dm_app/pubspec.yaml` | Add `provider` dependency | Needed for WikiState |

## Suggested Build Order

```
Phase 1: Core Models + Services
├── 1.1 WikiPageType enum (core/models/wiki_page_type.dart)
├── 1.2 WikiPage model (core/models/wiki_page.dart)
├── 1.3 StatBlock value type (core/models/wiki_stat_block.dart)
├── 1.4 WikiStorageService (core/services/wiki_storage_service.dart)
└── 1.5 WikiSearchService (core/services/wiki_search_service.dart)

Phase 2: Shared UI Components (in core)
├── 2.1 WikiPageList (core/wiki/wiki_page_list.dart) — search bar + list
├── 2.2 WikiPageDetail (core/wiki/wiki_page_detail.dart) — markdown + stat blocks
├── 2.3 WikiCreateForm (core/wiki/wiki_create_form.dart) — dynamic form
├── 2.4 WikiResponsiveLayout (core/wiki/wiki_responsive_layout.dart) — adaptive branching
└── 2.5 WikiState (core/wiki/wiki_state.dart) — ChangeNotifier provider

Phase 3: Per-App Integration
├── 3.1 WikiModal (companion_app) — full-screen modal wrapper
├── 3.2 WikiTrigger (companion_app) — book icon in HomeScreen AppBar
├── 3.3 WikiModal (dm_app) — full-screen modal wrapper
├── 3.4 Wire existing wiki icon (dm_app/main.dart line 142)
└── 3.5 Add provider dependency to dm_app pubspec.yaml

Phase 4: Polish + Testing
├── 4.1 Slide-up animation tuning
├── 4.2 Responsive breakpoint testing (phone, tablet, desktop)
├── 4.3 Core package tests for WikiPage model + search service
└── 4.4 Widget tests for WikiPageList filtering
```

### Build Order Rationale

1. **Models first** — Everything depends on `WikiPage`. Can't build UI without the data shape.
2. **Services second** — Storage and search are needed before the UI can display real data. Can use demo data for UI development, but services should exist.
3. **Shared UI third** — Core UI components are the bulk of the work. Building them in core means both apps get them simultaneously.
4. **Per-app integration last** — Wiring the modal and trigger is trivial once the shared UI exists. The DM app's wiki icon already exists (line 142 of main.dart) — just needs to be connected.
5. **Polish final** — Animation tuning and responsive testing require the full stack to be functional.

### Dependency Graph

```
WikiPage ← WikiStorageService ← WikiState ← WikiResponsiveLayout
         ← WikiSearchService  ← WikiPageList
                              ← WikiPageDetail
                              ← WikiCreateForm
```

## Sources

- [Flutter Adaptive/Responsive Design — General Approach](https://docs.flutter.dev/ui/adaptive-responsive/general) — Official Flutter docs, HIGH confidence
- [Material 3 Layout Breakpoints](https://m3.material.io/foundations/layout/applying-layout/window-size-classes) — Material guidelines, HIGH confidence
- [flutter_markdown_plus package](https://pub.dev/packages/flutter_markdown_plus) — Official pub.dev page (successor to discontinued flutter_markdown), HIGH confidence
- [Flutter showGeneralDialog API](https://api.flutter.dev/flutter/material/showGeneralDialog.html) — Official Flutter API, HIGH confidence
- [Flutter MediaQuery.sizeOf](https://api.flutter.dev/flutter/widgets/MediaQuery/sizeOf.html) — Official Flutter API, HIGH confidence
- Existing codebase analysis (monster.dart, creature_detail_view.dart, main.dart files) — Direct observation, HIGH confidence

---
*Architecture research for: Flutter wiki popup UI with responsive layouts*
*Researched: 2026-05-07*

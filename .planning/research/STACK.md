# Technology Stack

**Project:** SaveState Wiki Popup UI
**Researched:** 2026-05-07

## Recommended Stack

### Markdown Rendering
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| `flutter_markdown_plus` | ^1.0.7 | Render markdown wiki content | Official successor to discontinued `flutter_markdown` (0.7.7+1). Maintained by Foresight Mobile, drop-in API compatible. Supports GFM, tables, code blocks, checkboxes, footnotes, LaTeX (via separate package). 259k downloads. |
| `markdown` | ^7.3.1 | Markdown parsing (transitive) | Underlying parser used by flutter_markdown_plus. Actively maintained by dart.dev (published 50 days ago). 1.83M downloads. Provides extension sets for GFM, CommonMark, emoji. |

### Responsive Layout
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| Flutter `LayoutBuilder` + `MediaQuery` | Built-in (SDK) | Two-panel vs single-panel switching | No external package needed. `MediaQuery.sizeOf(context).width` gives screen width, `LayoutBuilder` gives available space. Single breakpoint (~600-800px) toggles between sidebar+detail (Row) and list-then-detail (stacked). Simpler, zero-dependency, no learning curve. |

### Full-Text Search
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| Custom Dart implementation | N/A | In-memory wiki page search | For v1 (title prioritized + body text matching), a custom service using Dart's built-in `String.contains()` with case-insensitive comparison is sufficient. No external package needed. If fuzzy matching becomes necessary later, `fuzzywuzzy` (^1.2.0, 85.6k downloads) provides Levenshtein-based scoring. |

### Modal / Popup
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| Flutter `showModalBottomSheet` | Built-in (SDK) | Full-screen slide-up modal | `isScrollControlled: true` + `useSafeArea: false` creates a full-screen modal. Built into Flutter, no dependency. The `modal_bottom_sheet` package (3.0.0, 268k downloads) offers more customization but hasn't been updated in 2 years and requires route-level changes (`MaterialWithModalsPageRoute`) — overkill for this use case. |

### State Management
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| `provider` | ^6.1.2 | Wiki page state, search state | Already used in both apps. Consistent with existing architecture. `ChangeNotifier` for wiki page list, search query, and selected page. |

### Persistence (for wiki content)
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| `path_provider` | ^2.1.4 (latest) | Get app documents directory | Standard Flutter package for file paths. Needed to locate where wiki JSON files are stored. |
| `dart:io` File I/O | Built-in (SDK) | Read/write wiki JSON files | No external package needed. JSON serialization with `dart:convert`. Sufficient for v1 single-device storage. |

## Alternatives Considered

| Category | Recommended | Alternative | Why Not |
|----------|-------------|-------------|---------|
| Markdown renderer | `flutter_markdown_plus` | `flutter_markdown` | **Discontinued** by flutter.dev. Won't receive updates. Official migration path points to flutter_markdown_plus. |
| Markdown renderer | `flutter_markdown_plus` | `markdown_widget` | Community package, smaller ecosystem (392 likes vs 116 but less actively maintained). flutter_markdown_plus has official lineage from Google's original package. |
| Markdown renderer | `flutter_markdown_plus` | `flutter_quill` | Rich text editor, not a markdown renderer. Overkill for read-only wiki display. |
| Responsive layout | `LayoutBuilder` + `MediaQuery` | `responsive_framework` | 129k downloads, but designed for app-wide breakpoint management with auto-scaling. Overkill for a single two-panel toggle. Adds MaterialApp.builder wrapping. |
| Responsive layout | `LayoutBuilder` + `MediaQuery` | `flutter_layout_grid` | CSS Grid-inspired layout system. Powerful but unnecessary complexity for a simple sidebar+detail split. |
| Full-text search | Custom implementation | `fuzzywuzzy` | Levenshtein-based fuzzy matching is valuable for typo tolerance but adds a dependency. Defer to v2 if users report search friction. |
| Full-text search | Custom implementation | `searchfield` | Autocomplete widget, not a search engine. Useful for search UI but not for the search logic itself. |
| Modal | `showModalBottomSheet` | `modal_bottom_sheet` | Requires replacing route builders (`MaterialWithModalsPageRoute`) for animated transitions. Adds complexity for minimal gain on a full-screen modal. |

## Installation

Add to **both** `apps/companion_app/pubspec.yaml` and `apps/dm_app/pubspec.yaml`:

```yaml
dependencies:
  flutter_markdown_plus: ^1.0.7
  path_provider: ^2.1.4
```

No changes needed to `packages/core/pubspec.yaml` — markdown rendering is UI-layer only. Wiki models and search service belong in core.

Add to **`packages/core/pubspec.yaml`** (for JSON serialization utilities):

```yaml
dependencies:
  # Already present: nsd, uuid, shelf, http
```

No additional core dependencies needed. `dart:convert` (built-in) handles JSON serialization for wiki page storage.

## Integration Points

### Where each package lives

| Package | Location | Reason |
|---------|----------|--------|
| Wiki models (`WikiPage`, `WikiPageType`, etc.) | `packages/core/lib/models/` | Shared between both apps per workspace conventions |
| Wiki search service | `packages/core/lib/services/` | In-memory search logic is app-agnostic |
| Wiki storage service | `packages/core/lib/services/` | File I/O abstraction shared between apps |
| Wiki modal UI | `apps/companion_app/lib/screens/` and `apps/dm_app/lib/screens/` | App-specific UI, same widget reused |
| Wiki detail widgets | `apps/companion_app/lib/widgets/` and `apps/dm_app/lib/widgets/` | App-specific rendering (stat block cards, etc.) |
| Wiki providers | `apps/companion_app/lib/providers/` and `apps/dm_app/lib/providers/` | App-specific state management |

### What NOT to add

| Package | Why Avoid |
|---------|-----------|
| `flutter_markdown` | **Discontinued.** Will not receive bug fixes or Flutter compatibility updates. |
| `responsive_framework` | Overkill for a single responsive toggle. Adds app-wide breakpoint infrastructure you don't need. |
| `modal_bottom_sheet` | Requires route-level changes. Built-in `showModalBottomSheet` with `isScrollControlled: true` covers the full-screen requirement. |
| `searchfield` | Autocomplete dropdown widget, not a search engine. The wiki needs a search bar + filtered list, which is trivial with a `TextField` + `ListView.builder`. |
| `flutter_layout_grid` | CSS Grid is powerful but adds complexity for a simple two-panel layout that `Row`/`Column` handles natively. |
| `provider` (new) | Already in both apps. Don't add again. |
| `hive` / `isar` / `sqflite` | Overkill for v1 wiki storage. JSON files are sufficient. Add a database only when sync or query complexity demands it. |

## Sources

- [flutter_markdown_plus 1.0.7 on pub.dev](https://pub.dev/packages/flutter_markdown_plus) — HIGH confidence (official pub.dev)
- [flutter_markdown 0.7.7+1 discontinued notice](https://pub.dev/packages/flutter_markdown) — HIGH confidence (official pub.dev, links to flutter_markdown_plus as replacement)
- [markdown 7.3.1 on pub.dev](https://pub.dev/packages/markdown) — HIGH confidence (dart.dev publisher, published 50 days ago)
- [responsive_framework 1.5.1 on pub.dev](https://pub.dev/packages/responsive_framework) — HIGH confidence (official pub.dev)
- [fuzzywuzzy 1.2.0 on pub.dev](https://pub.dev/packages/fuzzywuzzy) — HIGH confidence (official pub.dev)
- [modal_bottom_sheet 3.0.0 on pub.dev](https://pub.dev/packages/modal_bottom_sheet) — HIGH confidence (official pub.dev, last published 2 years ago)
- [flutter_layout_grid 2.0.8 on pub.dev](https://pub.dev/packages/flutter_layout_grid) — HIGH confidence (official pub.dev)
- [searchfield 2.0.0 on pub.dev](https://pub.dev/packages/searchfield) — HIGH confidence (official pub.dev)
- Existing project pubspec.yaml files — HIGH confidence (local filesystem)

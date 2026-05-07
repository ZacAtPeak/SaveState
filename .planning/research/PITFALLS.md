# Pitfalls Research

**Domain:** Flutter wiki/knowledge-base popup UI with responsive layouts, added to existing D&D companion + DM apps
**Researched:** 2026-05-07
**Confidence:** HIGH

## Critical Pitfalls

### Pitfall 1: Device-Type Checking Instead of Window-Size Branching

**What goes wrong:**
Layout decisions switch on "is phone" vs "is tablet" rather than actual available window space. The wiki modal renders a cramped single-panel layout on a tablet running in split-screen mode, or stretches a two-panel layout across a full-width phone in landscape.

**Why it happens:**
Developers naturally think in terms of device categories ("phones get list, tablets get sidebar"). Flutter's `Platform` class and `dart:io` make device-type checks trivial. It feels correct until the app runs in a resizeable window on desktop, ChromeOS multi-window, or iPad split-view.

**How to avoid:**
Use `MediaQuery.sizeOf(context)` to get the current app window dimensions and branch on width breakpoints. Follow Material 3 window size classes: < 600dp = compact (single panel), 600-840dp = medium (consider two-panel), > 840dp = expanded (two-panel). Never use `Platform.isIOS` or `Platform.isAndroid` for layout decisions.

**Warning signs:**
- Code contains `if (Platform.isTablet)` or similar device checks in layout logic
- Layout looks wrong when resizing the desktop window
- Single-panel layout appears on a tablet in split-screen mode

**Phase to address:**
Wiki Modal UI phase — enforce window-size branching from the first commit.

---

### Pitfall 2: Using MaterialPageRoute for Full-Screen Modal Instead of Custom Slide-Up Route

**What goes wrong:**
The wiki modal uses `Navigator.push(MaterialPageRoute(...))` which gives a platform-specific transition (slide-right on Android, slide-left on iOS) instead of the required slide-up-from-bottom animation. On desktop, the route fills the entire window with no visual distinction from normal navigation, making it unclear how to return.

**Why it happens:**
`MaterialPageRoute` is the default Flutter navigation pattern. It's well-documented and works out of the box. Developers reach for it because it's the first navigation pattern they learn.

**How to avoid:**
Use `showModalBottomSheet` with `isScrollControlled: true` and `useSafeArea: true` for a slide-up modal that fills the screen. Alternatively, create a custom `PageRouteBuilder` with a slide-up transition animation. For the full-screen modal requirement, `showModalBottomSheet` with `constraints: BoxConstraints.expand()` is the simplest correct approach. On desktop, consider adding a visible close button and semi-transparent backdrop.

**Warning signs:**
- Modal uses platform slide-left/right transition instead of slide-up
- No visual distinction between wiki modal and regular screen navigation
- Desktop users can't tell how to dismiss the modal

**Phase to address:**
Wiki Modal UI phase — define the modal entry mechanism before building internal layout.

---

### Pitfall 3: State Loss on Modal Dismiss (Selected Page, Search Query, Scroll Position)

**What goes wrong:**
User searches for "fireball", finds it, taps to view, closes the modal, reopens it — and everything resets. Search query is empty, list is at the top, previously viewed page is not highlighted. Every modal open feels like the first open.

**Why it happens:**
`showModalBottomSheet` and `Navigator.push` create new widget trees each time. Ephemeral state (search text, scroll offset, selected item) lives in the modal's widget tree and is destroyed on dismiss. Developers assume users won't notice because the modal is "just a popup."

**How to avoid:**
Lift wiki state (search query, selected page ID, scroll position) to a provider or state management solution that survives modal dismissal. Use `PageStorageKey` on the page list `ListView` to preserve scroll position. Store the last-selected page ID and search query in a `ChangeNotifier` or similar provider scoped above the modal. When the modal reopens, restore from this persisted state.

**Warning signs:**
- Search field is TextEditingController created inside the modal's build method
- No provider or state holder exists for wiki navigation state
- `ListView` has no `PageStorageKey`

**Phase to address:**
Wiki Modal UI phase — state management design before UI construction.

---

### Pitfall 4: Using Discontinued flutter_markdown Instead of flutter_markdown_plus

**What goes wrong:**
The project adds `flutter_markdown` as a dependency, which is officially discontinued by Google (per pub.dev). It will not receive updates, bug fixes, or compatibility patches for future Flutter versions. The community-maintained `flutter_markdown_plus` is the active successor.

**Why it happens:**
`flutter_markdown` appears first in search results, has more downloads (1.4k likes vs 116), and is the "official" Flutter package. The discontinuation notice on pub.dev is easy to miss. Many tutorials and Stack Overflow answers still recommend the old package.

**How to avoid:**
Use `flutter_markdown_plus: ^1.0.7` instead. It is the direct continuation maintained by Foresight Mobile, with the same API surface. Both packages share the same underlying `markdown` parser, so migration is a simple dependency swap. Note: neither package supports inline HTML — Flutter is not an HTML renderer.

**Warning signs:**
- `pubspec.yaml` lists `flutter_markdown` (not `flutter_markdown_plus`)
- pub.dev shows "discontinued" badge on the package

**Phase to address:**
Wiki Modal UI phase — dependency selection before markdown rendering implementation.

---

### Pitfall 5: Markdown Rendering Performance on the Main Isolate

**What goes wrong:**
Long wiki pages with extensive markdown content (stat blocks, tables, code blocks) cause frame drops and jank when the detail view renders. The markdown parser runs synchronously on the main isolate, blocking the UI thread during AST parsing and widget tree construction.

**Why it happens:**
`flutter_markdown_plus` parses markdown synchronously in the widget's build method. For short content this is invisible. For D&D wiki pages with multi-paragraph rules text, stat block tables, and formatted spell descriptions, the parse time becomes noticeable.

**How to avoid:**
Pre-parse markdown content into the AST or cached widget representation before it reaches the UI layer. Use `compute()` to run markdown parsing in a background isolate for pages exceeding a size threshold (e.g., > 2KB). Cache parsed results so re-visiting a page is instant. For the initial milestone with create-only pages, pre-parsing at save time is sufficient.

**Warning signs:**
- `MarkdownBody(data: page.body)` called directly in build method with no caching
- Frame drops visible in DevTools when opening pages with long markdown content
- No `compute()` or isolate usage for markdown parsing

**Phase to address:**
Wiki Modal UI phase — performance consideration for markdown rendering. Defer isolate optimization if page content is small at launch.

---

### Pitfall 6: Full-Text Search Running Synchronously on Every Keystroke

**What goes wrong:**
User types "drag" in the search bar and the UI freezes for 200-500ms on each keystroke as the app scans every wiki page's title, body, tags, and aliases. On a wiki with hundreds of pages, this creates noticeable input lag.

**Why it happens:**
Developers implement search as a simple `where()` filter over the full page list, triggered by `onChanged` on the search TextField. No debouncing, no indexing, no incremental filtering. Every keystroke re-scans the entire corpus.

**How to avoid:**
Debounce search input (200-300ms delay) using `Timer` or `debounce` from `async` package. Filter only on titles initially, with full-text body search as a secondary pass. For larger wikis, build a simple inverted index at load time mapping words to page IDs. The requirement states "title matches prioritized" — implement title-first filtering, then body search only if title results are insufficient.

**Warning signs:**
- Search filter runs in `TextField onChanged` callback with no debounce
- Every page's full markdown body is scanned on each keystroke
- No search index or pre-computed lookup structure

**Phase to address:**
Wiki Modal UI phase — search implementation. Debounce is mandatory; indexing is optional for v1.

---

### Pitfall 7: Duplicating Wiki UI Code Across Companion and DM Apps

**What goes wrong:**
The wiki modal widget, search logic, markdown rendering, and responsive layout code are copy-pasted into both `companion_app` and `dm_app`. A bug fix in one app is forgotten in the other. The two wiki implementations drift apart over time.

**Why it happens:**
The project convention places UI in each app's `lib/` directory. Developers interpret this as "all wiki code goes in each app." The shared `core` package is reserved for models and services, so UI components naturally get duplicated.

**How to avoid:**
Create a shared `wiki` sub-package or place wiki UI widgets in a shared location that both apps import. At minimum, extract the wiki modal widget, search component, and page detail renderer into `packages/core/lib/widgets/` (extending core beyond just models/services). The models stay in `core/lib/models/`, the UI widgets go in `core/lib/widgets/wiki/`, and each app only provides the book-icon trigger and theme context. This follows the existing pattern of keeping shared code in core.

**Warning signs:**
- `WikiModal` or similar widget exists in both `apps/companion_app/lib/` and `apps/dm_app/lib/`
- Same search logic implemented twice with minor differences
- Bug fix applied to one app's wiki but not the other's

**Phase to address:**
Wiki Modal UI phase — architecture decision before any UI code is written.

---

### Pitfall 8: Exacerbating the Monolithic View File Problem

**What goes wrong:**
The wiki modal is implemented as a single 500+ line file (joining the existing 757-line `creature_detail_view.dart`). All layout logic, search, markdown rendering, responsive branching, and state management live in one widget class. Future modifications become impossible without introducing regressions.

**Why it happens:**
The existing codebase already has this pattern (`creature_detail_view.dart` at 757 lines). Developers follow the established convention. It's faster to write one big file than to design component boundaries upfront.

**How to avoid:**
Break the wiki modal into small, focused widgets following Flutter's best practices for adaptive design:
- `WikiModal` — modal shell with slide-up animation
- `WikiSearchBar` — search input with debounce
- `WikiPageList` — filtered list of pages with selection
- `WikiPageDetail` — renders a single page (markdown, stat blocks, tags)
- `WikiResponsiveLayout` — branches between single-panel and two-panel based on `MediaQuery.sizeOf`

Each widget should be < 150 lines. Use `const` constructors throughout for rebuild performance.

**Warning signs:**
- Single file exceeds 200 lines for the wiki feature
- `build()` method contains nested ternary operators for responsive branching
- Search, list, and detail logic all in one State class

**Phase to address:**
Wiki Modal UI phase — enforce component decomposition from the start.

---

### Pitfall 9: Not Handling Keyboard Navigation and Mouse Input on Desktop/Tablet

**What goes wrong:**
The wiki modal works with touch but is unusable with keyboard on desktop. Tab navigation skips the search bar, arrow keys don't navigate the page list, Enter doesn't select a page, and Escape doesn't dismiss the modal. Desktop users are forced to use the mouse for everything.

**Why it happens:**
Flutter's Material widgets have good default touch behavior but keyboard/mouse support requires explicit configuration. Developers test primarily on mobile emulators where touch is the only input. Desktop testing is an afterthought.

**How to avoid:**
Wrap the page list in a `FocusableActionDetector` or use `Shortcuts`/`Actions` for keyboard navigation. Ensure Escape dismisses the modal (built into `showModalBottomSheet` but verify). Add `FocusNode` management for the search bar to auto-focus on modal open. Use `SelectableRegion` around markdown content for text selection with mouse. Test on desktop target regularly, not just mobile emulators.

**Warning signs:**
- No `FocusNode` or `Shortcuts` in wiki modal code
- Search bar doesn't auto-focus when modal opens
- Tab key doesn't move focus between search bar and page list

**Phase to address:**
Wiki Modal UI phase — input handling alongside layout implementation.

---

## Moderate Pitfalls

### Pitfall 10: Hardcoded Breakpoint Values Without Documentation

**What goes wrong:**
The responsive layout switches at `width > 600` but no one remembers why 600 was chosen. Later, someone changes it to 500 to "fix" a layout issue on a specific device, breaking the layout on other devices.

**Prevention:**
Define breakpoints as named constants with comments referencing Material 3 window size classes. Use `const double kCompactWidth = 600.0;` and `const double kMediumWidth = 840.0;` with documentation links.

### Pitfall 11: Sidebar List State Not Restored After Orientation/Resize Change

**What goes wrong:**
User scrolls to page 50 in the sidebar, resizes the window (or rotates a tablet), and the list jumps back to the top. The selected page in the detail panel is also lost.

**Prevention:**
Use `PageStorageKey` on the sidebar `ListView` to persist scroll position. Store the selected page ID in a provider that survives rebuilds. Per Flutter best practices: "To maintain the scroll position in a list that doesn't change its layout when the device's orientation changes, use the `PageStorageKey` class."

### Pitfall 12: Not Using MediaQuery.sizeOf (Using MediaQuery.of Instead)

**What goes wrong:**
Using `MediaQuery.of(context).size` causes unnecessary rebuilds because `MediaQuery` contains much more data than just size (padding, view insets, platform brightness, etc.). Every time any MediaQuery property changes, the entire widget rebuilds.

**Prevention:**
Use `MediaQuery.sizeOf(context)` instead of `MediaQuery.of(context).size`. This is the current Flutter recommendation for performance reasons — it only rebuilds when size changes, not when other MediaQuery properties change.

### Pitfall 13: Typed Page Schema Complexity Without Abstraction

**What goes wrong:**
Each page type (spell, item, creature, rule) has different structured fields. The detail view contains a massive switch statement rendering different field combinations for each type. Adding a new page type requires modifying the detail view, the create form, and the search indexing logic.

**Prevention:**
Define a `WikiPageType` enum with a schema descriptor interface. Each type provides its own field definitions, validators, and renderers through a polymorphic interface. The detail view delegates to type-specific renderers rather than containing all rendering logic inline.

---

## Technical Debt Patterns

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|----------------|-----------------|
| Inline all wiki UI in each app | No shared package setup | Duplicate code, divergent behavior, double bug fixes | Never — use core package for shared widgets |
| Synchronous markdown parsing | Simpler code | Jank on long pages, poor UX | Only if wiki pages are guaranteed < 1KB at launch |
| No search debounce | Faster to implement | Input lag on every keystroke | Never — debounce is trivial and essential |
| Hardcoded breakpoints | Works now | Unmaintainable, device-specific bugs | Never — use named constants with M3 references |
| Single monolithic widget file | Fewer files to manage | Unmaintainable, impossible to test in isolation | Never — the codebase already suffers from this |
| flutter_markdown over flutter_markdown_plus | More tutorials available | Discontinued package, no future updates | Never — flutter_markdown_plus is a drop-in replacement |

## Integration Gotchas

| Integration | Common Mistake | Correct Approach |
|-------------|----------------|------------------|
| Wiki models in core | Putting UI logic in core models | Models stay in `core/lib/models/`, UI widgets in `core/lib/widgets/` or app-specific |
| Modal state management | Ephemeral state inside modal widget | Lift state to provider scoped above modal for persistence across open/close |
| Markdown + stat blocks | Rendering stat blocks as markdown tables | Stat blocks are structured data — render as custom widgets, not markdown |
| Search across both apps | Separate search indices per app | Single shared search index from core, both apps query the same data |
| Theme consistency | Each app themes wiki differently | Use `Theme.of(context)` for all styling, wiki inherits app theme automatically |
| NSD sync (future) | Building wiki UI assuming local-only data | Design data layer with abstraction so NSD sync can be plugged in later |

## Performance Traps

| Trap | Symptoms | Prevention | When It Breaks |
|------|----------|------------|----------------|
| Markdown parsed on every build | Frame drops opening long pages | Pre-parse at save time, cache parsed result | Pages > 2KB of markdown |
| Full-text search on every keystroke | Input lag in search bar | Debounce (200-300ms), title-first filtering | > 50 wiki pages |
| Rebuilding entire page list on search change | List flickers during filtering | Use `ValueListenableBuilder` or selective rebuild | > 100 wiki pages |
| No const constructors on wiki widgets | Excessive rebuilds on modal resize | Use `const` everywhere possible | Any responsive resize event |
| Loading all wiki pages into memory at once | Slow modal open, high memory | Lazy-load page bodies, load titles eagerly | > 200 wiki pages with long content |

## Security Mistakes

| Mistake | Risk | Prevention |
|---------|------|------------|
| Storing wiki content in SharedPreferences | Data loss on app reinstall, size limits (4-10KB on some platforms) | Use file-based storage (JSON files) or SQLite via `drift`/`sqflite` |
| No input validation on wiki page creation | Malformed markdown, broken stat blocks | Validate title (non-empty), body (valid markdown), tags (non-empty strings) |
| Markdown injection via user content | If wiki content is ever shared/synced, malicious markdown could crash the renderer | Sanitize markdown input, limit allowed syntax extensions |

## UX Pitfalls

| Pitfall | User Impact | Better Approach |
|---------|-------------|-----------------|
| No empty state when wiki has no pages | User sees blank screen, doesn't know to tap + | Show "No pages yet — tap + to create one" with illustration |
| Search returns no results with no feedback | User thinks search is broken | Show "No results for 'xyz'" with suggestion to try different terms |
| Page list doesn't show page type | User can't distinguish spells from items at a glance | Show type badge/icon next to each page title |
| Detail view scrolls to top on page switch | User loses their place when browsing | Preserve scroll position per-page with PageStorageKey |
| Modal dismisses on tap outside (on desktop) | User accidentally closes wiki while reading | Disable tap-outside-dismiss on desktop, keep it on mobile |

## "Looks Done But Isn't" Checklist

- [ ] **Wiki Modal:** Often missing keyboard navigation (Escape to dismiss, Tab through elements, arrow keys in list) — verify desktop target testing
- [ ] **Search:** Often missing debounce — verify no lag when typing quickly
- [ ] **Responsive Layout:** Often missing testing at exact breakpoint widths (599dp, 600dp, 839dp, 840dp) — verify both sides of each breakpoint
- [ ] **Markdown:** Often missing handling of edge cases (empty body, malformed markdown, very long single-line content) — verify with edge-case test data
- [ ] **State Persistence:** Often missing scroll position and selected page restoration — verify by opening modal, navigating, closing, reopening
- [ ] **Two-Panel Layout:** Often missing sidebar width constraint on very wide screens — verify sidebar doesn't exceed 400dp on ultrawide displays
- [ ] **Both Apps:** Often missing testing in both companion_app and dm_app — verify identical behavior in both
- [ ] **Core Package:** Often missing tests for wiki models — verify core package has unit tests for WikiPage, WikiPageType, and serialization

## Recovery Strategies

| Pitfall | Recovery Cost | Recovery Steps |
|---------|---------------|----------------|
| Device-type checks everywhere | MEDIUM | Replace all `Platform.isX` checks with `MediaQuery.sizeOf` branching; define breakpoint constants |
| flutter_markdown dependency | LOW | Swap to `flutter_markdown_plus` — API is identical, just change pubspec |
| Monolithic wiki widget file | HIGH | Extract components incrementally: search bar first, then page list, then detail view, then responsive wrapper |
| No state persistence across modal dismiss | MEDIUM | Introduce a ChangeNotifier provider, move search query and selected page ID into it |
| Duplicated wiki UI in both apps | HIGH | Extract shared widgets to core package, update both apps to import from core |
| Synchronous search on main thread | LOW | Add debounce timer, refactor search to title-first filtering |

## Pitfall-to-Phase Mapping

| Pitfall | Prevention Phase | Verification |
|---------|------------------|--------------|
| Device-type checking | Wiki Modal UI | Review all layout branching code for Platform.isX usage |
| Wrong modal transition | Wiki Modal UI | Verify slide-up animation on both platforms and desktop |
| State loss on dismiss | Wiki Modal UI | Test open→navigate→close→reopen cycle, verify state preserved |
| Discontinued markdown package | Wiki Modal UI | Check pubspec.yaml for flutter_markdown_plus |
| Markdown performance | Wiki Modal UI (defer optimization) | DevTools frame check with long wiki pages |
| Search without debounce | Wiki Modal UI | Type quickly in search bar, verify no input lag |
| Duplicated UI code | Wiki Modal UI | Grep for wiki widgets in both apps — should only exist in core |
| Monolithic view files | Wiki Modal UI | Count lines per wiki file — none should exceed 200 |
| No keyboard navigation | Wiki Modal UI | Test wiki modal on desktop with keyboard only |
| Hardcoded breakpoints | Wiki Modal UI | Search for numeric width comparisons — should use named constants |
| No empty state | Wiki Modal UI | Open wiki with zero pages, verify helpful empty state |
| Missing core tests | Wiki Models (core) | Run `dart test` in packages/core, verify wiki model tests pass |

## Sources

- Flutter Official Docs — Adaptive and responsive design: https://docs.flutter.dev/ui/adaptive-responsive
- Flutter Official Docs — General approach to adaptive apps: https://docs.flutter.dev/ui/adaptive-responsive/general
- Flutter Official Docs — Best practices for adaptive design: https://docs.flutter.dev/ui/adaptive-responsive/best-practices
- Flutter Official Docs — Large screen devices: https://docs.flutter.dev/ui/adaptive-responsive/large-screens
- Flutter Official Docs — Display a Cupertino sheet: https://docs.flutter.dev/cookbook/design/cupertino-sheets
- Flutter Official Docs — Navigate to a new screen and back: https://docs.flutter.dev/cookbook/navigation/navigation-basics
- pub.dev — flutter_markdown (discontinued): https://pub.dev/packages/flutter_markdown
- pub.dev — flutter_markdown_plus (active): https://pub.dev/packages/flutter_markdown_plus
- Material 3 — Applying layout window size classes: https://m3.material.io/foundations/layout/applying-layout/window-size-classes
- SaveState PROJECT.md — Existing concerns (monolithic views, model duplication, missing tests)

---
*Pitfalls research for: Flutter wiki/knowledge-base popup UI with responsive layouts*
*Researched: 2026-05-07*

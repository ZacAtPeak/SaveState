---
phase: 03-create-flow-per-app-integration
created: "2026-05-07T00:00:00Z"
source: discuss-phase
---

# Phase 3: Create Flow & Per-App Integration - Context

**Gathered:** 2026-05-07
**Status:** Ready for planning

<domain>
## Phase Boundary

Users can create new wiki pages from within the modal and open the wiki from both apps via a book icon in the AppBar. This phase adds: (1) a "+" button in the modal that launches a type picker then a per-type create form, (2) persistence of the new page via WikiStorageService, (3) auto-selection of the new page after save, and (4) a top-level WikiProvider in each app that loads pages at startup.

</domain>

<decisions>
## Implementation Decisions

### Create Form Navigation
- **D-01:** The create form replaces the detail panel — in two-panel mode it occupies the right panel; in single-panel mode it pushes via Navigator (same routing already used for detail view).
- **D-02:** After successful save, the new page is auto-selected and shown in the detail view (not the create form, not an empty state).

### Type Picker Design
- **D-03:** The type picker is a 2×4 grid of icon cards, one per `WikiPageType` (7 types). Each card shows an icon and the type's `displayName`.
- **D-04:** The picker is cancellable — a back arrow (or Cancel button) returns to the previous state without creating a page.

### Form Field Depth
- **D-05:** Full per-type structured fields — each type shows its own set of labeled fields beyond the common title/body/tags/aliases.
- **D-06:** Field schemas are defined via a `fields` getter on `WikiPageTypeExtension` in `core` — returns a list of field definitions (label + key + input type) per type. This keeps schema knowledge centralized in the model layer, not scattered in the UI.
- **D-07:** Structured field values are stored in the existing `statBlock: Map<String, dynamic>` on `WikiPage`. No model changes needed — form writes field values as map entries keyed by the field definition's key string.

### Book Icon & App Integration
- **D-08:** The book icon (`Icons.menu_book`) lives as an `AppBar` action in both `companion_app` and `dm_app`.
- **D-09:** Each app wraps its `MaterialApp` in a top-level `WikiProvider` (a `ChangeNotifier`) that loads all pages from `WikiStorageService` at startup. The provider holds the live pages list so new pages created in the modal appear in the sidebar immediately.

### Claude's Discretion
- Specific per-type field definitions (which fields belong to creature, spell, item, etc.) — Claude should derive sensible D&D-relevant fields from the type's domain.
- Icon choices for each type in the type picker grid — use Material icons appropriate to each type's domain.
- Exact widget layout of the create form (spacing, padding, field ordering within each type).

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Phase Requirements
- `.planning/ROADMAP.md` — Phase 3 goal, success criteria (CREATE-01 through CREATE-04), and plan breakdown
- `.planning/REQUIREMENTS.md` — Full CREATE-01–04 requirement definitions

### Core Models
- `packages/core/lib/models/wiki_page.dart` — WikiPage model fields (`title`, `body`, `tags`, `aliases`, `statBlock`, `pageType`)
- `packages/core/lib/models/wiki_page_type.dart` — WikiPageType enum + extension (will gain `fields` getter in this phase)

### Existing Wiki UI (integration points)
- `packages/core/lib/wiki/wiki_modal_shell.dart` — Modal shell to extend with "+" button and create-flow routing
- `packages/core/lib/wiki/wiki_modal_provider.dart` — Provider to extend with `isCreating`, `pendingType`, and pages-list state
- `packages/core/lib/wiki/wiki_page_list.dart` — Sidebar list (reads from provider's pages list)
- `packages/core/lib/wiki/wiki_page_detail.dart` — Detail panel (create form replaces this in the same slot)

### Persistence
- `packages/core/lib/services/wiki_storage_service.dart` — WikiStorageService (savePage, loadAll — integration point for form submission)

### App Entry Points
- `apps/dm_app/lib/main.dart` — DmApp + HomeScreen (add top-level WikiProvider + AppBar book icon)
- `apps/companion_app/lib/main.dart` — CompanionApp + HomeScreen (add top-level WikiProvider + AppBar book icon)

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `WikiModalShell.show()` — static factory already handles bottom sheet display; extend with provider that now owns pages list
- `WikiModalProvider` — lightweight `ChangeNotifier`; extend with `isCreating` bool, `pendingType`, and `pages` list (moved from call-site parameter)
- `WikiStorageService` — already implements `saveToFile`/`loadAll`; create form calls `save()` on submit
- `GenericTabView` (companion_app) — wraps tabs in a Scaffold; AppBar actions slot available via existing `Scaffold` structure

### Established Patterns
- Widget size limit <150 lines — type picker widget and create form widget each stay under limit; form is split per-type or uses a shared scaffold with type-specific fields injected
- Shared UI in `packages/core/lib/wiki/` — type picker widget and create form widget go here, not in app-specific lib/
- `WikiPageTypeExtension` pattern — `displayName` already uses an extension; `fields` getter follows the same pattern
- `statBlock` as flexible map — already used by WikiStatBlock widget for creature fields; reuse pattern for form data storage

### Integration Points
- `WikiModalProvider` must own the `pages` list (currently passed as parameter to `WikiModalShell`) — top-level `WikiProvider` in each app loads pages and passes a `WikiModalProvider` down
- After save, `WikiModalProvider.addPage(page)` updates the list and calls `notifyListeners()` — sidebar re-renders immediately
- `WikiModalShell.appBar` gains a "+" `IconButton` that sets `provider.isCreating = true`

</code_context>

<specifics>
## Specific Ideas

- 2×4 grid layout for 7 types (last row has 3 cards + empty cell, or expand "Other" card to fill)
- Back arrow in a mini `AppBar` at the top of the type picker / create form to cancel
- Form uses standard `TextField` widgets with Material 3 styling (already in use)
- Each type's field definitions should include: field key (maps to statBlock), label, and hint text

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 03-create-flow-per-app-integration*
*Context gathered: 2026-05-07*

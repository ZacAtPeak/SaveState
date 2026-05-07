# Feature Research

**Domain:** Flutter D&D wiki popup UI with responsive layouts
**Researched:** 2026-05-07
**Confidence:** HIGH

## Feature Landscape

### Table Stakes (Users Expect These)

Features users assume exist. Missing these = product feels incomplete.

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Full-screen modal popup triggered by book icon | Standard pattern for reference overlays in companion apps; users expect to return to previous context after closing | LOW | Use `showModalBottomSheet` with `isScrollControlled: true` and full-height constraints. Slide-up animation is Material 3 standard. |
| Searchable page list in sidebar | Any knowledge base requires findability; D&D players need to look up rules mid-game quickly | MEDIUM | Full-text search across title, aliases, tags, and markdown body. Title matches must rank higher. Requires in-memory index built at modal open time. |
| Page detail view with markdown rendering | Wiki pages contain freeform text; markdown is the standard for game content formatting | LOW | Use `flutter_markdown_plus` (the maintained fork of discontinued `flutter_markdown`). Supports GFM, tables, code blocks. |
| Responsive layout: two-panel on wide, single-panel on narrow | Users run on phones, tablets, and desktops; layout must adapt to window size, not device type | MEDIUM | Use `MediaQuery.sizeOf(context)` with Material 3 breakpoints (<600dp = single panel, >=600dp = two-panel). Branch on width, not platform. |
| Page type indicator (creature, item, spell, rule, etc.) | D&D content is heterogeneous; users need to instantly recognize what kind of page they're viewing | LOW | Colored chip or icon in page list items and detail header. Type enum already exists in codebase (`CreatureType`, etc.). |
| Tag display on page detail | Tags are the primary organization mechanism (no hierarchy in v1); users need to see and filter by them | LOW | Wrap chip list in detail header. Reuse `FilterChip` or custom styled `Chip` widgets. |
| Stat block rendering for creature-type pages | D&D stat blocks have a canonical visual format (AC, HP, abilities, actions); flat markdown cannot represent this | HIGH | Requires custom widget that maps structured stat block fields to the classic D&D stat block layout. Must handle variable sections (legendary actions, spell slots, etc.). See existing `CreatureDetail` (757-line monolith) — needs modularization. |
| Page list with type icon + title preview | Users browse by scanning; need visual differentiation between content types at a glance | LOW | `ListTile` with leading icon per type, title, and optional tag preview. |
| Back/close button and dismiss gesture | Modal must be dismissible; users expect both explicit (button) and implicit (swipe/tap outside) dismissal | LOW | `showModalBottomSheet` provides scrim tap dismissal. Add `AppBar` with close icon. Set `isDismissible: true`. |

### Differentiators (Competitive Advantage)

Features that set the product apart. Not required, but valuable.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Title-prioritized full-text search | Searching "fire" returns "Fireball" spell before pages mentioning fire in body text; dramatically faster lookup during gameplay | MEDIUM | Implement scoring: exact title match (10x), alias match (5x), title substring (3x), tag match (2x), body match (1x). Pure Dart, no external dependency. Filter results in-memory. |
| Alias-based search (alternative names) | "Longsword" found when searching "sword"; "Magic Missile" found when searching "missile"; critical for D&D terminology | LOW | Aliases stored as page field. Include alias strings in search index alongside title. |
| Typed page schemas with different field sets | A spell page shows casting time, range, components; an item page shows weight, cost, rarity — each type renders its relevant fields | MEDIUM | Define `WikiPageType` enum with per-type field schemas. Detail view branches on type to render appropriate field groups. Models in `core` package. |
| Create new page from within modal (plus button) | DM can add custom content without leaving the wiki context; reduces friction for content creation | MEDIUM | Plus button in modal app bar opens a type picker, then a form with fields appropriate to the selected type. Form validation per type schema. |
| Stat block as both inline card and reference widget | Stat blocks render as styled cards in creature pages, but also as compact inline references when linked from other pages | HIGH | Two rendering modes: `StatBlockCard` (full layout) and `StatBlockInline` (compact name + AC/HP). Both consume same structured data. |
| Keyboard navigation support (desktop) | Desktop DMs navigate with keyboard during sessions; arrow keys move through page list, Enter opens page, Escape closes modal | MEDIUM | Use Flutter's `Focus` and `Shortcuts` widgets. `RawKeyboardListener` for Escape. `ListView` with `FocusNode` per item. |

### Anti-Features (Commonly Requested, Often Problematic)

Features that seem good but create problems.

| Feature | Why Requested | Why Problematic | Alternative |
|---------|---------------|-----------------|-------------|
| Hierarchical folder/tree organization | Feels familiar from file systems and wikis like Notion | Adds significant complexity for D&D content that naturally spans multiple categories (a spell belongs to a class AND a school AND a level). Tag-based is simpler and sufficient for v1. | Tag-based organization with multi-tag filtering. Defer hierarchy to v2 if user feedback demands it. |
| Real-time peer-to-peer sync between DM and companion | Seems necessary for "shared" wiki | Merge conflicts are inevitable with concurrent edits. Single-author-per-page model + DM as source of truth is simpler and matches D&D table dynamics (DM controls content). | DM app is source of truth. Companion app reads. NSD sync deferred to next milestone per PROJECT.md. |
| Edit/delete existing pages in v1 | Seems like basic wiki functionality | This milestone is scoped to popup UI only. Edit/delete requires form state management, validation, undo, and conflict handling — each a significant feature. | Create-only for this milestone. Edit/delete in a subsequent milestone. |
| External wiki import (from D&D Beyond, Roll20, etc.) | Users have existing content | Each source has different data formats, licensing restrictions, and API requirements. Massive scope expansion. | Content created in-app for v1. Import/export deferred. |
| Rich text editor (WYSIWYG) for page body | Feels more user-friendly than markdown | Requires building or integrating a rich text editor, handling paste behavior, image insertion, and cross-platform consistency. Overkill for v1. | Markdown body field. Simple `TextField` with markdown syntax. |
| Cross-linking from app text into wiki | Useful for referencing wiki content from character sheets, encounters | Requires parsing app text for wiki references, maintaining link integrity, and handling broken links. Deferred per PROJECT.md. | Defer to next milestone. |

## Feature Dependencies

```
Wiki Modal (full-screen popup)
    ├──requires──> Responsive Layout System (MediaQuery size branching)
    │                  ├──requires──> Breakpoint constants (Material 3: 600dp)
    │                  └──requires──> Two-panel layout widget (sidebar + detail)
    │
    ├──requires──> Page List Sidebar
    │                  ├──requires──> WikiPage model (title, type, tags, aliases)
    │                  └──requires──> Page type icons/chips
    │
    ├──requires──> Full-Text Search
    │                  ├──requires──> Page List Sidebar (search filters the list)
    │                  ├──requires──> Search index (built from page data)
    │                  └──enhances──> Alias-based search (aliases feed into index)
    │
    ├──requires──> Page Detail View
    │                  ├──requires──> Markdown rendering (flutter_markdown_plus)
    │                  ├──requires──> WikiPage model (body, metadata)
    │                  └──requires──> Stat block rendering (for creature-type pages)
    │
    ├──requires──> Stat Block Rendering
    │                  ├──requires──> Structured stat block fields on WikiPage
    │                  └──requires──> WikiPageType enum (to determine rendering mode)
    │
    ├──requires──> Create Page Flow
    │                  ├──requires──> WikiPageType enum (type picker)
    │                  ├──requires──> Per-type form schemas
    │                  └──requires──> Persistence layer (save new pages)
    │
    └──enhances──> Keyboard Navigation (desktop usability)
                       └──requires──> Focus management in page list
```

### Dependency Notes

- **Wiki Modal requires Responsive Layout System:** The modal must adapt its internal layout based on window width. Use `MediaQuery.sizeOf` (not physical device size) per Flutter's adaptive design guidance.
- **Full-Text Search requires Page List Sidebar:** Search results replace or filter the page list. The search bar lives in the sidebar header.
- **Stat Block Rendering requires Structured Fields:** Cannot render stat blocks from markdown alone. WikiPage model must include optional structured fields (AC, HP, abilities, etc.) that are populated for creature-type pages.
- **Create Page Flow requires Persistence:** New pages must be saved. The persistence layer (file-based or SQLite) is a prerequisite — cannot create pages without storage.
- **Keyboard Navigation enhances but is not required for:** The modal works without keyboard support, but desktop UX is significantly degraded without it.

## MVP Definition

### Launch With (v1)

Minimum viable product — what's needed to validate the concept.

- [x] Full-screen modal popup via book icon — Core interaction; without this, no wiki access
- [x] Responsive layout (two-panel / single-panel) — Must work on phones and tablets/desktops
- [x] Page list with type indicator — Users need to see what pages exist
- [x] Full-text search with title prioritization — Primary way users find content
- [x] Page detail view with markdown rendering — Core content display
- [x] Stat block rendering for creature pages — D&D-specific differentiator; expected by DMs
- [x] Tag display on pages — Primary organization mechanism
- [x] Close/dismiss modal — Basic modal hygiene
- [x] Create new page from modal — DM needs to add content

### Add After Validation (v1.x)

Features to add once core is working.

- [ ] Alias-based search — Trigger: users searching alternative names and not finding pages
- [ ] Keyboard navigation — Trigger: desktop usage patterns observed
- [ ] Stat block inline references — Trigger: users linking between wiki pages
- [ ] Page type filter chips in sidebar — Trigger: page list grows beyond ~50 entries

### Future Consideration (v2+)

Features to defer until product-market fit is established.

- [ ] Edit/delete existing pages — Why defer: scope expansion; create-only validates content model first
- [ ] NSD sync from DM to companion — Why defer: next milestone; requires networking complexity
- [ ] Cross-linking from app text into wiki — Why defer: requires text parsing infrastructure
- [ ] Hierarchical organization — Why defer: tags sufficient for v1; adds complexity
- [ ] External import/export — Why defer: format diversity and licensing complexity
- [ ] Rich text editor — Why defer: markdown is sufficient; editor is a separate product

## Feature Prioritization Matrix

| Feature | User Value | Implementation Cost | Priority |
|---------|------------|---------------------|----------|
| Full-screen modal popup | HIGH | LOW | P1 |
| Responsive layout branching | HIGH | MEDIUM | P1 |
| Page list with type icons | HIGH | LOW | P1 |
| Full-text search (title-prioritized) | HIGH | MEDIUM | P1 |
| Page detail with markdown | HIGH | LOW | P1 |
| Stat block rendering | HIGH | HIGH | P1 |
| Tag display | MEDIUM | LOW | P1 |
| Create new page | HIGH | MEDIUM | P1 |
| Close/dismiss modal | HIGH | LOW | P1 |
| Alias-based search | MEDIUM | LOW | P2 |
| Keyboard navigation | MEDIUM | MEDIUM | P2 |
| Stat block inline references | MEDIUM | HIGH | P2 |
| Type filter chips | LOW | LOW | P2 |
| Edit/delete pages | HIGH | HIGH | P3 |
| NSD sync | HIGH | HIGH | P3 |
| Cross-linking from app text | MEDIUM | HIGH | P3 |

**Priority key:**
- P1: Must have for launch
- P2: Should have, add when possible
- P3: Nice to have, future consideration

## Competitor Feature Analysis

| Feature | D&D Beyond | Roll20 Compendium | Foundry VTT Journal | Our Approach |
|---------|-----------|-------------------|---------------------|--------------|
| Modal popup access | Web overlay panels | Sidebar panel | Journal sidebar | Full-screen slide-up modal; returns to context on dismiss |
| Search | Full-text, filters by source | Title-only search | Full-text with tags | Full-text with title-prioritized scoring + alias support |
| Stat block rendering | Official styled blocks | Plain text compendium | Markdown + HTML | Custom structured stat block widgets (card + inline) |
| Content creation | Publisher-only (SRD) | Homebrew builder | Full journal editor | Create-only in DM app; typed page schemas |
| Responsive layout | Web-only (responsive CSS) | Desktop app | Desktop app | Flutter adaptive: two-panel on wide, single on narrow |
| Organization | Source-based hierarchy | Category folders | Tag + folder hybrid | Tag-based only for v1 (simpler, multi-categorization) |
| Offline access | Limited (requires subscription) | Local compendium | Fully local | Fully local; no network dependency |

## Sources

- Flutter adaptive/responsive design docs: https://docs.flutter.dev/ui/adaptive-responsive (HIGH confidence — official Flutter docs, updated 2026-05-05)
- Flutter `showModalBottomSheet` API: https://api.flutter.dev/flutter/material/showModalBottomSheet.html (HIGH confidence — official API reference)
- Material 3 layout breakpoints: https://m3.material.io/foundations/layout/applying-layout/window-size-classes (HIGH confidence — official Material Design spec)
- `flutter_markdown_plus` package: https://pub.dev/packages/flutter_markdown_plus (HIGH confidence — pub.dev, maintained fork of discontinued `flutter_markdown`)
- `flutter_markdown` discontinuation notice: https://pub.dev/packages/flutter_markdown (HIGH confidence — official package page shows discontinued banner)
- SaveState PROJECT.md requirements (HIGH confidence — project source)
- Existing `Monster` model in `packages/core/lib/models/monster.dart` (HIGH confidence — codebase inspection)
- Existing `CreatureDetail` widget in `apps/dm_app/lib/widgets/creature_detail_view.dart` (HIGH confidence — codebase inspection, 757 lines, noted as monolithic)

---
*Feature research for: Flutter D&D wiki popup UI*
*Researched: 2026-05-07*

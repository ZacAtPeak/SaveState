---
phase: 02-modal-ui-components
created: "2026-05-07T17:30:00Z"
source: discuss-phase
---

# Phase 2 Context: Modal UI Components

## Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Modal presentation | Slide-up from bottom | Smooth animation, native mobile feel, dismissible by drag |
| Shared UI architecture | `packages/core/lib/wiki/` | Single source of truth, both apps import from core |
| Markdown rendering | `flutter_markdown` | Popular, well-maintained, supports custom builders |
| State management | Provider | Already in both apps, scalable, testable |
| Stat block display | New focused widget (<150 lines) | Clean separation, avoids 757-line anti-pattern |

## Carrying Forward from Phase 1

- WikiPage model + WikiPageType enum (7 types) in `core/lib/models/`
- WikiStorageService + WikiSearchService in `core/lib/services/`
- Provider 6.1.5+1 declared in both apps
- Material 3 theming in use
- Immutable models with final fields pattern established
- 36 unit tests passing in core package

## Constraints

- **Widget size limit:** <150 lines per widget (enforced to avoid creature_detail_view.dart anti-pattern)
- **Responsive breakpoint:** 600dp (two-panel >= 600dp, single-panel < 600dp)
- **Shared code location:** `packages/core/lib/wiki/`
- **No markdown dependency yet** — needs to be added

## Requirements (from ROADMAP.md)

- MODAL-01: Full-screen slide-up modal with two-panel layout >= 600dp
- MODAL-02: Single-panel list→detail navigation < 600dp
- MODAL-03: Sidebar with scrollable page list, type indicators, search bar
- LIST-01: Search results prioritize title matches
- LIST-02: Type indicators (icon or chip) on list items
- LIST-03: Scrollable page list
- LIST-04: Search bar filters as user types
- DETAIL-01: Markdown content with proper formatting
- DETAIL-02: Tags as chips in header
- DETAIL-03: Stat block as formatted card for creature-type pages
- DETAIL-04: Responsive detail view

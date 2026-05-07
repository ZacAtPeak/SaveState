# Requirements: SaveState Wiki Popup UI

**Defined:** 2026-05-07
**Core Value:** Users can find and reference any game-related information instantly through a unified, searchable wiki with deep cross-linking from every part of the app.

## v1 Requirements

### Modal & Layout

- [ ] **MODAL-01**: Book icon opens full-screen slide-up modal in both apps
- [ ] **MODAL-02**: Two-panel layout (sidebar + detail) on windows >=600dp wide
- [ ] **MODAL-03**: Single-panel list→detail navigation on windows <600dp
- [ ] **MODAL-04**: Modal dismissible via close button and tap outside

### Page List & Search

- [ ] **LIST-01**: Sidebar displays scrollable list of wiki pages with type icon and title
- [ ] **LIST-02**: Search bar at top of sidebar filters pages by full-text content
- [ ] **LIST-03**: Search results prioritize title matches over body matches
- [ ] **LIST-04**: Page type indicator shown as icon or chip in list items

### Detail View

- [ ] **DETAIL-01**: Selecting a page in the list displays its full content in the detail panel
- [ ] **DETAIL-02**: Markdown body renders with proper formatting (headers, lists, tables, code blocks)
- [ ] **DETAIL-03**: Tags displayed as chips in detail header
- [ ] **DETAIL-04**: Stat block renders as formatted UI card for creature-type pages

### Create Page

- [ ] **CREATE-01**: Plus button in modal opens page type picker
- [ ] **CREATE-02**: Type picker presents available wiki page types
- [ ] **CREATE-03**: Form displays fields appropriate to selected page type
- [ ] **CREATE-04**: New page saves with title, tags, aliases, markdown body, and structured fields

### Core Infrastructure

- [ ] **CORE-01**: WikiPage model in core package with all required fields
- [ ] **CORE-02**: WikiPageType enum with per-type field schemas
- [ ] **CORE-03**: File-based JSON persistence layer for wiki pages
- [ ] **CORE-04**: In-memory search service with title-prioritized scoring

## v2 Requirements

### Search Enhancements

- **LIST-05**: Alias-based search (alternative names match pages)
- **LIST-06**: Page type filter chips in sidebar

### Polish

- **POLISH-01**: Keyboard navigation support (arrow keys, Enter, Escape)
- **POLISH-02**: Stat block as compact inline reference widget

## Out of Scope

| Feature | Reason |
|---------|--------|
| Hierarchical page organization | Tag-based is simpler and sufficient for v1 |
| Edit/delete existing pages | Create-only validates content model first |
| NSD sync from DM to companion | Next milestone; requires networking complexity |
| Cross-linking from app text into wiki | Requires text parsing infrastructure |
| External wiki import/export | Format diversity and licensing complexity |
| Rich text editor (WYSIWYG) | Markdown is sufficient; editor is separate product |
| Real-time collaborative editing | Single-author model per page |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| CORE-01 | Phase 1 | Pending |
| CORE-02 | Phase 1 | Pending |
| CORE-03 | Phase 1 | Pending |
| CORE-04 | Phase 1 | Pending |
| MODAL-01 | Phase 2 | Pending |
| MODAL-02 | Phase 2 | Pending |
| MODAL-03 | Phase 2 | Pending |
| MODAL-04 | Phase 4 | Pending |
| LIST-01 | Phase 2 | Pending |
| LIST-02 | Phase 2 | Pending |
| LIST-03 | Phase 2 | Pending |
| LIST-04 | Phase 2 | Pending |
| DETAIL-01 | Phase 2 | Pending |
| DETAIL-02 | Phase 2 | Pending |
| DETAIL-03 | Phase 2 | Pending |
| DETAIL-04 | Phase 2 | Pending |
| CREATE-01 | Phase 2 | Pending |
| CREATE-02 | Phase 2 | Pending |
| CREATE-03 | Phase 2 | Pending |
| CREATE-04 | Phase 2 | Pending |

**Coverage:**
- v1 requirements: 20 total
- Mapped to phases: 20
- Unmapped: 0 ✓

---
*Requirements defined: 2026-05-07*
*Last updated: 2026-05-07 after initial definition*

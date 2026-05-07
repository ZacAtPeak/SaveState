# Roadmap: SaveState Wiki Popup UI

## Overview

Build a shared wiki popup UI accessible from both the companion and DM apps via a book icon. The wiki provides a full-screen modal with responsive layout (two-panel on wide screens, single-panel on narrow), searchable page list with title-prioritized full-text search, detail view with markdown rendering and stat blocks, and a create flow with type-driven forms. Core models and services live in the shared `core` package; UI components are shared from `packages/core/lib/wiki/`; per-app integration wires the modal trigger in each app.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3, 4): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [ ] **Phase 1: Core Infrastructure** - WikiPage model, type enum, JSON persistence, and in-memory search service
- [x] **Phase 2: Modal UI Components** - Responsive modal shell, searchable page list, and detail view with markdown + stat blocks (completed 2026-05-07)
- [ ] **Phase 3: Create Flow & Per-App Integration** - Type-driven create form, book icon triggers, and modal wiring in both apps
- [ ] **Phase 4: Polish & Testing** - Modal dismissal, search debounce, responsive verification, and core package tests

## Phase Details

### Phase 1: Core Infrastructure
**Goal**: Foundation data layer — wiki pages can be modeled, persisted, and searched
**Depends on**: Nothing (first phase)
**Requirements**: CORE-01, CORE-02, CORE-03, CORE-04
**Success Criteria** (what must be TRUE):
  1. WikiPage model serializes to/from JSON with all required fields (title, tags, aliases, markdown body, stat block fields, page type, UUID)
  2. WikiPageType enum provides distinct field schemas per page type (creature, spell, item, rule, location, npc, other)
  3. Pages can be saved to disk and loaded back from file-based JSON storage
  4. Search service returns pages ranked by relevance with title matches scored higher than body matches
**Plans**: 4 plans

Plans:
- [x] 01-01-PLAN.md — WikiPage model and WikiPageType enum with per-type field schemas
- [x] 01-02-PLAN.md — File-based JSON persistence layer (WikiStorageService)
- [x] 01-03-PLAN.md — In-memory search service with title-prioritized scoring (WikiSearchService)
- [x] 01-04-PLAN.md — Core package unit tests for models and search service

### Phase 2: Modal UI Components
**Goal**: Users can browse, search, and view wiki pages through a responsive full-screen modal
**Depends on**: Phase 1
**Requirements**: MODAL-01, MODAL-02, MODAL-03, LIST-01, LIST-02, LIST-03, LIST-04, DETAIL-01, DETAIL-02, DETAIL-03, DETAIL-04
**Success Criteria** (what must be TRUE):
  1. Modal opens as full-screen slide-up overlay and displays two-panel layout (sidebar + detail) on windows >=600dp wide
  2. Modal switches to single-panel list→detail navigation on windows <600dp
  3. Sidebar shows scrollable page list with type indicators (icon or chip) and filters results as user types in search bar
  4. Search results prioritize title matches over body matches
  5. Selecting a page renders markdown content with proper formatting, tags as chips in header, and stat block as formatted card for creature-type pages
**Plans**: 7 plans

Plans:
- [x] 02-01-PLAN.md — Modal shell with responsive layout branching (two-panel >=600dp, single-panel <600dp)
- [x] 02-02-PLAN.md — WikiPageList sidebar with scrollable list, type icons, and search bar
- [x] 02-03-PLAN.md — Search integration with title-prioritized filtering and 250ms debounce
- [x] 02-04-PLAN.md — WikiPageDetail view with markdown rendering (flutter_markdown) and tag chips
- [x] 02-05-PLAN.md — Stat block widget for creature-type pages as formatted UI card
- [x] 02-06-PLAN.md — Gap closure: Wire WikiPageList and WikiPageDetail into WikiModalShell
- [x] 02-07-PLAN.md — Gap closure: Add type displayName chips to WikiPageList list items
**UI hint**: yes

### Phase 3: Create Flow & Per-App Integration
**Goal**: Users can create new wiki pages and access the modal from both apps via book icon
**Depends on**: Phase 2
**Requirements**: CREATE-01, CREATE-02, CREATE-03, CREATE-04
**Success Criteria** (what must be TRUE):
  1. Plus button in modal opens page type picker showing all available wiki page types
  2. Selecting a type displays a form with fields appropriate to that page type
  3. Submitting the form saves a new page with title, tags, aliases, markdown body, and structured fields
  4. New page appears immediately in the sidebar list after creation
**Plans**: 3 plans

Plans:
- [ ] 03-01: Page type picker and dynamic create form driven by WikiPageType schemas
- [ ] 03-02: Form submission with validation and persistence integration
- [ ] 03-03: Book icon trigger wired into both companion_app and dm_app AppBar
**UI hint**: yes

### Phase 4: Polish & Testing
**Goal**: Modal is robust, responsive, and well-tested across both apps
**Depends on**: Phase 3
**Requirements**: MODAL-04
**Success Criteria** (what must be TRUE):
  1. Modal closes cleanly via close button and tap-outside gesture
  2. Search input has debounce (200-300ms) to prevent excessive re-filtering
  3. Layout renders correctly at phone (<600dp), tablet (600-840dp), and desktop (>840dp) breakpoints
  4. Core package unit tests pass for WikiPage model and WikiSearchService
**Plans**: 3 plans

Plans:
- [ ] 04-01: Modal dismissal behavior (close button + tap outside) with state preservation
- [ ] 04-02: Search debounce and responsive breakpoint verification
- [ ] 04-03: Widget tests for WikiPageList filtering and WikiPageDetail rendering
**UI hint**: yes

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3 → 4

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Core Infrastructure | 0/4 | Not started | - |
| 2. Modal UI Components | 7/7 | Complete   | 2026-05-07 |
| 3. Create Flow & Per-App Integration | 0/3 | Not started | - |
| 4. Polish & Testing | 0/3 | Not started | - |

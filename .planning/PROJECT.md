# SaveState Wiki

## What This Is

A shared wiki system for the SaveState D&D companion and DM apps that serves as the central knowledge base for all game content — rules, items, spells, locations, creatures, and more. Users access it by tapping a book icon, which opens a popup with a searchable page list and detail view. The wiki supports typed pages with structured stat blocks, markdown content, tag-based organization, and cross-linking from anywhere in both apps.

## Core Value

Users can find and reference any game-related information instantly through a unified, searchable wiki with deep cross-linking from every part of the app.

## Requirements

### Validated

- ✓ D&D character management — existing companion app
- ✓ Encounter and initiative tracking — existing
- ✓ Creature detail views — existing
- ✓ Local device discovery via NSD — existing core service
- ✓ Dart workspace monorepo with shared core package — existing
- ✓ Two Flutter apps (companion + DM) sharing models — existing

### Active

- [ ] Wiki popup UI accessible via book icon in both apps
- [ ] Slide-up full-screen modal animation
- [ ] Two-panel layout (sidebar + detail) on tablets/desktops
- [ ] Single-panel list→detail navigation on phones
- [ ] Page list sidebar with full-text search bar (title matches prioritized)
- [ ] Detail view renders all page data (markdown, stat blocks, tags, metadata)
- [ ] Plus button to create new wiki entries from modal
- [ ] Responsive layout adapts to screen size
- [ ] Typed page system with different field schemas per type
- [ ] Each page has: title, tags, aliases, markdown body, structured stat block fields
- [ ] DM app is source of truth for wiki content
- [ ] Both apps can create wiki pages
- [ ] Wiki models in core package shared between apps
- [ ] Persistence layer for wiki content

### Out of Scope

- Hierarchical page organization — tag-based is simpler and sufficient for v1
- Separate alias management UI — aliases managed as a page field like tags
- Peer-to-peer sync — DM is the single source of truth to avoid merge conflicts
- Mobile-responsive web version — this is a Flutter desktop/tablet app
- External wiki import/export — content created in-app for v1
- Real-time collaborative editing — single-author model per page
- NSD sync from DM to companion — deferred to next milestone
- Cross-linking from app text into wiki — deferred to next milestone
- Edit/delete existing pages — create-only for this milestone

## Context

**Technical environment:**
- Dart workspace monorepo with shared `core` package
- Two Flutter apps: `companion_app` and `dm_app`
- Core package contains domain models, NSD service, shared utilities
- Existing NSD (Network Service Discovery) infrastructure for local device communication
- Codebase map available at `.planning/codebase/`

**Existing concerns to address:**
- Model duplication (`EncounterEntry` vs `InitiativeEntry`) — avoid adding more duplication in wiki models
- SDK constraint inconsistencies between core and apps — align during wiki implementation
- Missing persistence layer — wiki needs proper storage solution
- No core package tests — wiki models in core should include tests
- Monolithic view files (757-line `creature_detail_view.dart`) — wiki views should be modular

## Constraints

- **Tech stack**: Must use existing Dart/Flutter workspace — no external frameworks
- **Networking**: Must integrate with existing NSD service for local sync — no cloud dependencies
- **Architecture**: Wiki models belong in `packages/core/lib/models/`, UI in each app's `lib/`
- **Performance**: Full-text search must work on-device without network calls
- **Compatibility**: Wiki content must be accessible in both companion and DM apps with consistent rendering

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Typed pages with different field schemas | Different content types (items, spells, rules) need different structured data | — Pending |
| DM as single source of truth | Avoids merge conflicts in local-only sync scenario | — Pending |
| Aliases as page field | Simpler than separate UI, managed like tags | — Pending |
| Stat blocks as both UI cards and inline refs | Supports both quick scanning and detailed reading | — Pending |
| Markdown + structured data hybrid | Freeform content plus queryable game stats | — Pending |
| Tag-based organization | Simpler than hierarchy, supports multiple categorization | — Pending |

## Current Milestone: v1.0 Wiki Popup UI

**Goal:** Users can browse, search, create, and view wiki pages through a responsive full-screen modal accessible from both apps.

**Target features:**
- Book icon opens slide-up full-screen modal in both apps
- Two-panel layout (sidebar list + detail view) on tablets/desktops
- Single-panel list→detail navigation on phones (companion app only)
- Search bar with full-text search, title matches prioritized
- Plus button to create new wiki entries from within the modal
- Detail view displays all page data (markdown body, stat blocks, tags, metadata)
- Responsive layout adapts to screen size, not app identity

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd-complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-05-07 after milestone v1.0 started*

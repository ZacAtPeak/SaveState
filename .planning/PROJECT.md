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
- [ ] Page list sidebar with full-text search bar
- [ ] Detail view renders markdown content
- [ ] Typed page system with different field schemas per type (Item, Spell, Rule, Location, Creature, etc.)
- [ ] Each page has: title, tags, aliases, markdown body, structured stat block fields
- [ ] Stat blocks render as formatted UI cards AND support inline markdown references
- [ ] Tag-based page organization (flat, no hierarchy)
- [ ] DM app is source of truth for wiki content
- [ ] Companion app syncs wiki content from DM via NSD
- [ ] Both apps can create, edit, and delete wiki pages
- [ ] Aliases field on pages enables cross-linking variations (e.g., "action" → "Actions" page)
- [ ] Cross-links from any app text (item descriptions, spell text, rules text) into wiki articles
- [ ] Clickable word links in primary detail views route to wiki articles

### Out of Scope

- Hierarchical page organization — tag-based is simpler and sufficient for v1
- Separate alias management UI — aliases managed as a page field like tags
- Peer-to-peer sync — DM is the single source of truth to avoid merge conflicts
- Mobile-responsive web version — this is a Flutter desktop/tablet app
- External wiki import/export — content created in-app for v1
- Real-time collaborative editing — single-author model per page

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
*Last updated: 2026-05-07 after initialization*

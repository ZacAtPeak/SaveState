# DM Screen App

## What This Is

A desktop/tablet DM screen app for tabletop RPGs. The DM manages combat encounters with an initiative tracker, browses and edits entities (NPCs, monsters, player characters), and tracks dice rolls — all while supporting multiple game systems that can be switched without losing data.

## Core Value

The DM's single source of truth at the table: initiative order, entity details, and roll history — organized by game system, extensible by the user.

## Requirements

### Validated

(None yet — ship to validate)

### Active

- [ ] Initiative tracker with auto-rolled initiative per game system rules
- [ ] Quick-link sidebar (bookmarked + recent entities)
- [ ] Entity detail view styled as a character sheet per game system
- [ ] Drag-and-drop field customization within entity edit mode
- [ ] Switch game system without losing entity data
- [ ] Custom entity creation (JSON import or built-in builder)
- [ ] Custom game system creation (JSON import or built-in builder)
- [ ] Roll tracker showing dice math and per-roll history
- [ ] Universal search across all entities
- [ ] Cross-platform: macOS, Linux, Windows, iPadOS
- [ ] Local-only storage (no cloud/server dependency)
- [ ] Networking architecture ready for future DM-host + companion-client LAN setup

### Out of Scope

- Mobile phone form factor — desktop/tablet only
- Web interface or cloud connectivity
- Real-time networking in v1 (architecture only)

## Context

- Flutter project already initialized in this repo
- UTS.db contains demo data for 6 game systems: D&D 5e, Pathfinder 2e, Call of Cthulhu, Vampire: The Masquerade, Cyberpunk Red, Warhammer Fantasy
- The database was referenced as the source of truth for entity schemas and demo content
- Networking will be DM-host + companion-client over local LAN (no web/server dependency)

## Constraints

- **Platform**: macOS, Linux, Windows, iPadOS — no phone scaling
- **Storage**: Local-only (SQLite or equivalent)
- **Extensibility**: Users create custom entities and game systems — builder must be end-user facing
- **Networking**: Designed for future LAN host/client model — keep data layer abstracted for this

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Flutter | Cross-platform, single codebase for all targets | — Pending |
| Local-only storage | No server dependency, works at table without internet | — Pending |
| Per-system character sheet UI | Each system has distinct field layouts | — Pending |
| Entity/system extensible | Users add content, not just consuming pre-built | — Pending |
| Architecture supports future networking | Data layer abstraction for eventual LAN sync | — Pending |

---

*Last updated: 2026-05-08 after initialization*

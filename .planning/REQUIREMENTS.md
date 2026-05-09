# Requirements: DM Screen App

**Defined:** 2026-05-08
**Core Value:** The DM's single source of truth at the table: initiative order, entity details, and roll history — organized by game system, extensible by the user.

## v1 Requirements

### Initiative Tracker

- [ ] **INIT-01**: User can add any entity to the initiative tracker
- [ ] **INIT-02**: Initiative is auto-rolled based on game system rules when entity is added
- [ ] **INIT-03**: Initiative cards display name, HP, AC, and current initiative value
- [ ] **INIT-04**: User can manually adjust HP directly from initiative cards
- [ ] **INIT-05**: Initiative order is sortable by rolling or manual drag-and-drop reordering
- [ ] **INIT-06**: User can remove entities from initiative tracker

### Quick-Link Sidebar

- [ ] **SIDE-01**: Sidebar displays bookmarked entities in a dedicated section
- [ ] **SIDE-02**: Sidebar displays recently viewed/edited entities
- [ ] **SIDE-03**: Clicking an entity in sidebar opens detail view
- [ ] **SIDE-04**: User can bookmark/unbookmark any entity
- [ ] **SIDE-05**: Sidebar is scrollable independently of main content

### Entity Detail View

- [ ] **DETL-01**: Detail view renders entity data as a character sheet styled per game system
- [ ] **DETL-02**: All entity fields are visible and editable in detail view
- [ ] **DETL-03**: User can toggle edit mode for the entity
- [ ] **DETL-04**: In edit mode, user can drag-and-drop fields to customize layout
- [ ] **DETL-05**: Field layout customization persists per entity
- [ ] **DETL-06**: Changes to entity data are auto-saved

### Game System Management

- [ ] **SYS-01**: User can switch active game system from settings
- [ ] **SYS-02**: Switching game system does not delete or alter existing entity data
- [ ] **SYS-03**: App ships with 6 game systems: D&D 5e, Pathfinder 2e, Call of Cthulhu, Vampire: The Masquerade, Cyberpunk Red, Warhammer Fantasy
- [ ] **SYS-04**: Demo data for all 6 systems loads from UTS.db on first launch
- [ ] **SYS-05**: User can import custom game system via JSON
- [ ] **SYS-06**: User can create custom game system via built-in builder
- [ ] **SYS-07**: User can edit existing game system definitions
- [ ] **SYS-08**: Game system defines: field layout, initiative rules, entity types, valid fields

### Custom Entity Management

- [ ] **CENT-01**: User can create new custom entity
- [ ] **CENT-02**: User can import custom entity via JSON
- [ ] **CENT-03**: User can create custom entity via built-in builder UI
- [ ] **CENT-04**: User can edit any custom or system entity
- [ ] **CENT-05**: User can delete custom entities
- [ ] **CENT-06**: System entities cannot be deleted, only disabled

### Roll Tracker

- [ ] **ROLL-01**: Roll tracker displays each roll with full dice math breakdown (e.g., "d20+5 = 17")
- [ ] **ROLL-02**: Roll tracker logs timestamp and context (which entity, combat round)
- [ ] **ROLL-03**: User can manually enter rolls to track
- [ ] **ROLL-04**: Roll history is scrollable and persistent across sessions
- [ ] **ROLL-05**: Roll tracker clears when starting new combat encounter

### Universal Search

- [ ] **SRCH-01**: Search bar accessible from main view
- [ ] **SRCH-02**: Search queries all entity fields (name, stats, notes, tags)
- [ ] **SRCH-03**: Search results update as user types
- [ ] **SRCH-04**: Clicking search result opens entity detail view
- [ ] **SRCH-05**: Search is scoped to current game system or global (user preference)

### Cross-Platform Support

- [ ] **PLAT-01**: App runs on macOS (desktop + iPad)
- [ ] **PLAT-02**: App runs on Windows
- [ ] **PLAT-03**: App runs on Linux
- [ ] **PLAT-04**: App runs on iPadOS (tablet-optimized, no phone layout)
- [ ] **PLAT-05**: UI layout adapts to window size (minimum 768px width)

### Data Layer

- [ ] **DATA-01**: All data stored locally (SQLite or equivalent)
- [ ] **DATA-02**: No cloud sync or server dependency in v1
- [ ] **DATA-03**: Data layer abstracted to support future LAN networking
- [ ] **DATA-04**: Entities, game systems, and roll history are queryable
- [ ] **DATA-05**: Import/export functionality for backup/restore

## v2 Requirements

### Networking

- [ ] **NETW-01**: DM app can host a game session over LAN
- [ ] **NETW-02**: Companion app (client) can connect to DM host over LAN
- [ ] **NETW-03**: Initiative and entity changes sync from DM to all companions in real-time
- [ ] **NETW-04**: Companion app displays read-only entity details and initiative
- [ ] **NETW-05**: Companion app does not require account or login

## Out of Scope

| Feature | Reason |
|---------|--------|
| Mobile phone form factor | Desktop/tablet only per user constraint |
| Web interface | LAN-only, no cloud/server |
| Real-time networking in v1 | Future phase, architecture only in v1 |
| Cloud sync | Local-only by design |
| Account/login system | Not needed for local-only app |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| INIT-01 | Phase 1 | Pending |
| INIT-02 | Phase 1 | Pending |
| INIT-03 | Phase 1 | Pending |
| INIT-04 | Phase 1 | Pending |
| INIT-05 | Phase 1 | Pending |
| INIT-06 | Phase 1 | Pending |
| SIDE-01 | Phase 1 | Pending |
| SIDE-02 | Phase 1 | Pending |
| SIDE-03 | Phase 1 | Pending |
| SIDE-04 | Phase 1 | Pending |
| SIDE-05 | Phase 1 | Pending |
| DETL-01 | Phase 2 | Pending |
| DETL-02 | Phase 2 | Pending |
| DETL-03 | Phase 2 | Pending |
| DETL-04 | Phase 2 | Pending |
| DETL-05 | Phase 2 | Pending |
| DETL-06 | Phase 2 | Pending |
| SYS-01 | Phase 3 | Pending |
| SYS-02 | Phase 3 | Pending |
| SYS-03 | Phase 3 | Pending |
| SYS-04 | Phase 3 | Pending |
| SYS-05 | Phase 3 | Pending |
| SYS-06 | Phase 3 | Pending |
| SYS-07 | Phase 3 | Pending |
| SYS-08 | Phase 3 | Pending |
| CENT-01 | Phase 3 | Pending |
| CENT-02 | Phase 3 | Pending |
| CENT-03 | Phase 3 | Pending |
| CENT-04 | Phase 3 | Pending |
| CENT-05 | Phase 3 | Pending |
| CENT-06 | Phase 3 | Pending |
| ROLL-01 | Phase 4 | Pending |
| ROLL-02 | Phase 4 | Pending |
| ROLL-03 | Phase 4 | Pending |
| ROLL-04 | Phase 4 | Pending |
| ROLL-05 | Phase 4 | Pending |
| SRCH-01 | Phase 4 | Pending |
| SRCH-02 | Phase 4 | Pending |
| SRCH-03 | Phase 4 | Pending |
| SRCH-04 | Phase 4 | Pending |
| SRCH-05 | Phase 4 | Pending |
| PLAT-01 | Phase 5 | Pending |
| PLAT-02 | Phase 5 | Pending |
| PLAT-03 | Phase 5 | Pending |
| PLAT-04 | Phase 5 | Pending |
| PLAT-05 | Phase 5 | Pending |
| DATA-01 | Phase 1 | Pending |
| DATA-02 | Phase 1 | Pending |
| DATA-03 | Phase 1 | Pending |
| DATA-04 | Phase 1 | Pending |
| DATA-05 | Phase 5 | Pending |
| NETW-01 | Phase 6 | Pending |
| NETW-02 | Phase 6 | Pending |
| NETW-03 | Phase 6 | Pending |
| NETW-04 | Phase 6 | Pending |
| NETW-05 | Phase 6 | Pending |

**Coverage:**
- v1 requirements: 44 total
- Mapped to phases: 44
- Unmapped: 0 ✓

---
*Requirements defined: 2026-05-08*
*Last updated: 2026-05-08 after initial definition*

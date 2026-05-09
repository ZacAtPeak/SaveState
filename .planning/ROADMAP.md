# Roadmap: DM Screen App

**Phases:** 6 | **Requirements:** 44 mapped | **Mode:** standard

| # | Phase | Goal | Requirements | Success Criteria |
|---|-------|------|--------------|------------------|
| 1 | Initiative & Core Layout | Initiative tracker strip with entity cards, sidebar quick-links, basic detail view shell | INIT-01–06, SIDE-01–05, DATA-01–04 | User can add entity to initiative, see it in strip, click to view details |
| 2 | Entity Detail View | Full character sheet rendering, edit mode with drag-and-drop field customization | DETL-01–06 | Entity detail view renders fields per system; edit mode customizes layout |
| 3 | Game System & Entity Builders | Game system switching, custom entity/system creation via JSON and builder UI | SYS-01–08, CENT-01–06 | User can switch systems without data loss; create/edit custom entities and systems |
| 4 | Roll Tracker & Search | Roll tracker with dice math, universal search across entities | ROLL-01–05, SRCH-01–05 | Roll tracker shows math breakdown; search queries all entity fields |
| 5 | Cross-Platform Polish | Platform builds (macOS, Windows, Linux, iPadOS), import/export | PLAT-01–05, DATA-05 | App runs on all target platforms; user can backup/restore data |
| 6 | Networking Architecture | Data layer abstracted for future LAN host/client, stubs in place | NETW-01–05 (future) | Data layer supports future real-time sync; no actual networking in v1 |

---

## Phase 1: Initiative & Core Layout

**Goal:** Initiative tracker strip, entity quick-link sidebar, and basic detail view shell

**Requirements:** INIT-01–06, SIDE-01–05, DATA-01–04

**Success Criteria:**
1. User can add an entity to the initiative tracker and see a card appear in the strip
2. Initiative card shows name, HP, AC, and current initiative value
3. User can adjust HP directly from the initiative card
4. Initiative is auto-rolled per game system rules when entity is added
5. Sidebar displays bookmarked entities and recent entities in separate sections
6. Clicking sidebar entity opens entity detail view
7. User can bookmark/unbookmark any entity
8. All data persists locally in SQLite

---

## Phase 2: Entity Detail View

**Goal:** Full character sheet rendering per game system, edit mode with drag-and-drop field customization

**Requirements:** DETL-01–06

**Success Criteria:**
1. Detail view renders entity fields as a character sheet styled for the active game system
2. All entity fields are visible and editable
3. Edit mode toggle enables drag-and-drop field rearrangement
4. Custom field layout persists per entity
5. Changes auto-save without explicit save button

---

## Phase 3: Game System & Entity Builders

**Goal:** Game system switching, custom entity/system creation via JSON import and built-in builder UI

**Requirements:** SYS-01–08, CENT-01–06

**Success Criteria:**
1. User can switch active game system from settings without losing entity data
2. All 6 game systems load from UTS.db on first launch
3. User can import a custom game system via JSON file
4. User can create a custom game system via built-in builder UI
5. User can import a custom entity via JSON file
6. User can create a custom entity via built-in builder UI
7. User can edit or delete custom entities; system entities can be disabled but not deleted

---

## Phase 4: Roll Tracker & Search

**Goal:** Roll tracker showing dice math breakdown and roll history; universal search across all entities

**Requirements:** ROLL-01–05, SRCH-01–05

**Success Criteria:**
1. Roll tracker shows each roll with full dice math (e.g., "d20+5 = 17")
2. Roll entries include timestamp and associated entity/combat context
3. User can manually enter and track rolls
4. Roll history is scrollable and persists across sessions
5. Roll tracker clears when starting a new combat encounter
6. Universal search bar queries all entity fields in real-time
7. Search results update as user types; clicking result opens entity detail

---

## Phase 5: Cross-Platform Polish

**Goal:** Platform builds for macOS, Windows, Linux, iPadOS; import/export backup functionality

**Requirements:** PLAT-01–05, DATA-05

**Success Criteria:**
1. App builds and runs on macOS (desktop + iPad)
2. App builds and runs on Windows
3. App builds and runs on Linux
4. App builds and runs on iPadOS with tablet-optimized layout (no phone layout)
5. UI adapts to window size with 768px minimum width
6. User can export all data to a backup file
7. User can import data from a backup file

---

## Phase 6: Networking Architecture

**Goal:** Data layer abstracted to support future LAN host/client networking; stubs in place for real-time sync

**Requirements:** NETW-01–05 (future-phase, architecture only)

**Success Criteria:**
1. Data layer supports future real-time sync without structural changes
2. Entity and initiative data models are network-serializable
3. Stubs/hooks exist for host broadcast and client receive operations
4. No actual networking implemented in v1 — architecture only

---
*Roadmap created: 2026-05-08*

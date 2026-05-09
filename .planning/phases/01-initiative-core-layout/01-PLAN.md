---
wave: 1
depends_on: []
files_modified:
  - pubspec.yaml
  - lib/main.dart
  - lib/data/database.dart
  - lib/data/models.dart
  - lib/ui/layout.dart
  - lib/ui/initiative_strip.dart
  - lib/ui/sidebar.dart
  - lib/ui/detail_view.dart
  - lib/ui/initiative_card.dart
  - test/initiative_test.dart
autonomous: true
---

# Plan: Initiative & Core Layout

## Overview

Establish the data layer foundation and core three-panel UI layout for the DM Screen App. Phase 1 delivers: SQLite-backed entity storage, the three-panel layout shell, initiative tracker strip with interactive cards, and quick-link sidebar with bookmark/recent sections.

**Mode:** standard
**Phase:** 01-initiative-core-layout
**Requirements covered:** INIT-01–06, SIDE-01–05, DATA-01–04

---

## Wave 1 Tasks

### Task 1.1: Database Foundation

**Objective:** Set up SQLite database with entity and game system schema

**Files:**
- `lib/data/database.dart` — Database singleton and initialization
- `lib/data/models.dart` — Entity, GameSystem, InitiativeEntry models
- `pubspec.yaml` — Add sqflite, path_provider dependencies

**Action:**
1. Add dependencies to pubspec.yaml:
   ```yaml
   dependencies:
     sqflite: ^2.3.0
     path_provider: ^2.1.1
     path: ^1.8.3
   ```

2. Create `lib/data/models.dart` with:
   - `Entity` class: id, name, gameSystemId, hp, maxHp, ac, initiative, isBookmarked, lastViewedAt, fieldLayout (JSON), createdAt, updatedAt
   - `GameSystem` class: id, name, initiativeRule (function/type), entityFields (list)
   - `InitiativeEntry` class: id, entityId, initiativeValue, combatId, order

3. Create `lib/data/database.dart`:
   - `DatabaseHelper` singleton with `init()` and `getDatabase()`
   - Tables: entities, game_systems, initiative_entries, roll_history
   - CRUD methods for entities

**Acceptance criteria (grep-verifiable):**
- `pubspec.yaml` contains `sqflite:`
- `lib/data/database.dart` contains `class DatabaseHelper`
- `lib/data/models.dart` contains `class Entity`
- `test/initiative_test.dart` passes with `flutter test`

---

### Task 1.2: UTS.db Demo Data Loader

**Objective:** Parse UTS.db and load demo entities for all 6 game systems

**Files:**
- `lib/data/uts_db_loader.dart` — UTS.db parser and data loader

**Action:**
1. Create `lib/data/uts_db_loader.dart`
2. Use `sqflite` to open UTS.db (path: `lib/UTS.db`)
3. Query existing tables to understand schema
4. Load demo entities into app database on first launch
5. Handle case where UTS.db doesn't exist (graceful degradation)

**Acceptance criteria (grep-verifiable):**
- `lib/data/uts_db_loader.dart` contains `class UtsDbLoader`
- `lib/data/uts_db_loader.dart` contains `loadDemoData`
- Database contains entities after loader runs

---

### Task 1.3: Three-Panel Layout Shell

**Objective:** Create the main app layout with sidebar, initiative strip, and detail view

**Files:**
- `lib/ui/layout.dart` — Main scaffold with three panels
- `lib/main.dart` — App entry point with theme

**Action:**
1. Update `lib/main.dart`:
   - Set Material 3 theme
   - Use `DatabaseHelper.instance.init()` on startup
   - Load `UtsDbLoader.loadDemoData()` on first launch
   - Route to main layout

2. Create `lib/ui/layout.dart`:
   - `MainLayout` widget with `Row` containing:
     - Left: `SidebarWidget` (fixed width ~250px)
     - Right: `Column` containing:
       - `InitiativeStripWidget` (height ~120px, ~1/3 of remaining)
       - `DetailViewWidget` (expanded, ~2/3 of remaining)
   - Minimum window width: 768px

**Acceptance criteria (grep-verifiable):**
- `lib/main.dart` contains `DatabaseHelper`
- `lib/ui/layout.dart` contains `class MainLayout`
- `lib/ui/layout.dart` contains `SidebarWidget`
- `lib/ui/layout.dart` contains `InitiativeStripWidget`
- `lib/ui/layout.dart` contains `DetailViewWidget`
- App renders without crash at minimum 768px width

---

### Task 1.4: Initiative Strip & Cards

**Objective:** Initiative tracker strip with interactive cards

**Files:**
- `lib/ui/initiative_strip.dart` — Horizontal scrollable initiative strip
- `lib/ui/initiative_card.dart` — Individual initiative card widget

**Action:**
1. Create `lib/ui/initiative_card.dart`:
   - Display: name, hp (current/max), ac, initiative value
   - Tap to select (opens detail view)
   - HP adjustment buttons (+/-) directly on card
   - Drag handle for reordering
   - Remove button (X)

2. Create `lib/ui/initiative_strip.dart`:
   - `InitiativeStripWidget` with `ListView.builder` (horizontal)
   - Add button (+) to add entities to initiative
   - Drop target for drag-and-drop reordering
   - Selected card highlighted

3. Add initiative logic:
   - `addToInitiative(Entity entity)` — rolls initiative based on game system rules
   - `removeFromInitiative(entityId)` — removes from strip
   - `reorderInitiative(oldIndex, newIndex)` — drag-and-drop reorder

**Acceptance criteria (grep-verifiable):**
- `lib/ui/initiative_card.dart` contains `class InitiativeCard`
- `lib/ui/initiative_card.dart` displays HP, AC, name, initiative
- `lib/ui/initiative_strip.dart` contains `class InitiativeStripWidget`
- Initiative cards can be added/removed
- HP can be adjusted from card

---

### Task 1.5: Quick-Link Sidebar

**Objective:** Sidebar with bookmarked and recent entity sections

**Files:**
- `lib/ui/sidebar.dart` — Sidebar widget

**Action:**
1. Create `lib/ui/sidebar.dart`:
   - `SidebarWidget` with two sections:
     - "Bookmarked" section (top)
     - "Recent" section (bottom, last 10 viewed)
   - `ListView` for each section
   - Each item: entity name, game system icon, tap to open detail

2. Implement bookmark toggle:
   - Star icon on each entity item
   - Tap star to bookmark/unbookmark
   - Bookmarks persist to database

3. Recent tracking:
   - Update `lastViewedAt` when entity opened in detail view
   - Sort recent by `lastViewedAt` descending

4. Scroll:
   - Each section scrolls independently
   - Sidebar scrolls independently of other panels

**Acceptance criteria (grep-verifiable):**
- `lib/ui/sidebar.dart` contains `class SidebarWidget`
- Sidebar has "Bookmarked" and "Recent" sections
- Entities can be bookmarked/unbookmarked
- Recent section shows last viewed entities
- Sidebar scrolls independently

---

### Task 1.6: Entity Detail View Shell

**Objective:** Basic detail view that shows when entity selected

**Files:**
- `lib/ui/detail_view.dart` — Entity detail view widget

**Action:**
1. Create `lib/ui/detail_view.dart`:
   - `DetailViewWidget` showing entity name, HP, AC, initiative
   - Placeholder for full character sheet (Phase 2)
   - Edit mode toggle (Phase 2 will implement drag-drop)

2. Wire up selection:
   - Click sidebar entity → opens in detail view
   - Click initiative card → opens in detail view
   - Update `lastViewedAt` when opened

**Acceptance criteria (grep-verifiable):**
- `lib/ui/detail_view.dart` contains `class DetailViewWidget`
- Detail view shows entity name and stats
- Clicking entity in sidebar opens detail view
- Clicking initiative card opens detail view

---

## Verification

After all tasks complete:

1. **Database:**
   - `flutter test` passes
   - App launches without SQLite errors

2. **Layout:**
   - Three panels visible: sidebar, initiative strip, detail view
   - Minimum 768px width maintained

3. **Initiative:**
   - Can add entity to initiative strip
   - Initiative auto-rolled based on game system
   - Cards show name, HP, AC, initiative
   - HP adjustable from card
   - Can remove from initiative

4. **Sidebar:**
   - Bookmarked section shows bookmarked entities
   - Recent section shows recently viewed
   - Can bookmark/unbookmark
   - Entity click opens detail view

5. **Detail View:**
   - Opens when entity selected
   - Shows entity name and stats

---

## Must-Haves (Goal-Backward Verification)

- [x] Entity can be added to initiative tracker
- [x] Initiative card shows name, HP, AC, initiative value
- [x] HP can be adjusted from initiative card
- [x] Initiative auto-rolled per game system rules
- [x] Sidebar shows bookmarked and recent entities
- [x] Sidebar entity click opens detail view
- [x] Bookmark/unbookmark works
- [x] Sidebar scrolls independently
- [x] All data persists in SQLite locally
- [x] No cloud/server dependency

**Phase 1 complete when:** All must-haves verified and committed.
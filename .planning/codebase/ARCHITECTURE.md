# Architecture

**Analysis Date:** 2026-05-07

## Pattern Overview

**Overall:** Package-based monorepo with shared domain layer and app-specific presentation layers.

**Key Characteristics:**
- Domain models are immutable value objects with JSON serialization
- Apps use `StatefulWidget` + `setState` for local state (Provider declared but not wired)
- Drag-and-drop data transfer between sidebar and initiative tracker
- Demo/fixture data lives in core, not in apps
- No external backend — all data is in-memory (networking packages declared but unused)

## Layers

**Domain Layer (core):**
- Purpose: D&D domain models, value types, enums, and demo data
- Location: `packages/core/lib/`
- Contains: `models/`, `data/`
- Depends on: `uuid` (ID generation), `nsd` (network discovery — declared), `shelf` + `http` (server/client — declared)
- Used by: Both `companion_app` and `dm_app`

**Presentation Layer (apps):**
- Purpose: Flutter UI, screens, widgets, and app-specific state
- Location: `apps/companion_app/lib/`, `apps/dm_app/lib/`
- Contains: `main.dart` (entry + root widget), `widgets/` (reusable components)
- Depends on: `flutter` (SDK), `core` (path dependency), `provider` (declared, not used)
- Used by: End users (players via companion_app, DMs via dm_app)

## Data Flow

**DM App — Combatant Registration:**

1. Demo data loaded in `HomeScreen` state (`_characters`, `_monsters`, `_npcs`)
2. Each entry wrapped in `_SidebarEntry` containing `CombatantDragData` + `CreatureDetail`
3. Sidebar renders `_DraggableCombatantTile` wrapping `Draggable<CombatantDragData>`
4. User drags tile onto `InitiativeTracker`'s `DragTarget<CombatantDragData>`
5. `_onCombatantDropped` rolls initiative (d20 + dex mod), creates `InitiativeEntry`
6. Entry added to `_sortedEntries`, sorted by initiative descending
7. `RollHistoryEntry` emitted via `onRoll` callback to parent state

**DM App — Detail View Selection:**

1. Sidebar tile tapped → `_onSelect` sets `_selectedDetail`
2. Initiative card tapped → `_onTrackerEntryTap` looks up detail via `_detailById` map
3. `CreatureDetailView` receives `CreatureDetail?` and renders tabbed content
4. Spell slot tracking is local to `_SpellSlotBlockState` (toggles available count)

**DM App — Turn Management:**

1. `_activeIndex` tracked in `HomeScreen` state
2. Previous/Next buttons call `_previousTurn` / `_nextTurn` on `InitiativeTracker`
3. `onActiveIndexChanged` callback propagates to parent
4. HP adjustments via `_adjustHP` (±1) mutate entry in place via `copyWith`

**Companion App — Skeleton:**

1. `HomeScreen` renders `GenericTabView` with 3 placeholder tabs (Characters, Inventory, Spells)
2. No data flow yet — all content is `Center(child: Text(...))` placeholders

## State Management

**Current approach:** `StatefulWidget` + `setState` in both apps.

- `HomeScreen` (dm_app) owns all state: entries, active index, sidebar expansion, roll history, selected detail
- `InitiativeTracker` maintains internal `_sortedEntries` copy, syncs to parent via callbacks
- `_SpellSlotBlockState` manages local spell slot toggling
- `provider ^6.1.2` is a dependency in both apps but **not wired up anywhere**

**Callback pattern:** Child widgets emit changes via `ValueChanged<T>` callbacks to parent `setState`:
```dart
// InitiativeTracker → HomeScreen
onEntriesChanged: _onEntriesChanged,        // List<InitiativeEntry>
onActiveIndexChanged: _onActiveIndexChanged, // int
onRoll: _onRoll,                            // RollHistoryEntry
onEntryTap: _onTrackerEntryTap,             // InitiativeEntry
```

## Key Abstractions

**CreatureDetail (`apps/dm_app/lib/widgets/creature_detail_view.dart`):**
- Purpose: Unified display model that normalizes `PlayerCharacter`, `Monster`, and `NPC` into a single view shape
- Factory constructors: `fromPlayerCharacter`, `fromMonster`, `fromNPC`
- Pattern: Adapter — maps three different domain types to one presentation type

**CombatantDragData (`apps/dm_app/lib/widgets/initiative_tracker.dart`):**
- Purpose: Lightweight data carrier for drag-and-drop (id, name, initiative modifier, HP, status)
- Factory constructors: `fromPlayerCharacter`, `fromMonster`, `fromNPC`
- Pattern: DTO — strips domain model down to what drag-and-drop needs

**InitiativeEntry (`apps/dm_app/lib/widgets/initiative_tracker.dart`):**
- Purpose: Runtime combat tracker entry with `sourceId` linking back to original creature
- Has `copyWith` for immutable updates
- Pattern: Value object with identity (unique `id` per instance, even for same creature)

**EncounterState / EncounterEntry (`packages/core/lib/models/encounter.dart`):**
- Purpose: Serialized encounter state (round, turn index, entries, notes)
- **Not exported** in `models.dart` barrel file — currently unused
- `EncounterState` has mutable fields (`round`, `currentTurnIndex`, `isActive`)

## Entry Points

**`apps/dm_app/lib/main.dart`:**
- Triggers: `flutter run` from `apps/dm_app/`
- Responsibilities: Creates `DmApp` (MaterialApp), renders `HomeScreen` with sidebar + initiative tracker + detail view + roll history drawer

**`apps/companion_app/lib/main.dart`:**
- Triggers: `flutter run` from `apps/companion_app/`
- Responsibilities: Creates `CompanionApp` (MaterialApp), renders `HomeScreen` with `GenericTabView` (3 placeholder tabs)

## Error Handling

**Strategy:** No explicit error handling — no try/catch, no error boundaries, no error states in UI.

**Patterns:**
- Null-safe defaults throughout (e.g., `json['id'] as String?` with fallback constructors)
- `DamageType.values.byName()` will throw on unknown values (no graceful fallback)
- Initiative tracker silently ignores out-of-range indices

## Cross-Cutting Concerns

**Logging:** None — no logging framework, no console output
**Validation:** None — models accept any values from JSON without validation
**Authentication:** None — no auth mechanism
**Serialization:** Manual `toJson`/`fromJson` on every model class (no codegen like `json_serializable`)

---

*Architecture analysis: 2026-05-07*

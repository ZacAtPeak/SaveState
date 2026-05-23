## Context

SaveState currently tracks spells known/prepared per character (via `entity_spells`) and has a full spell library, but has no concept of spell slot tracking. The `class_level_progression` table exists in the schema but is empty. The `entity_spellcasting` table exists but is unused. The frontend displays spells grouped by level but provides no cast interaction or slot consumption.

This change adds spell slot tracking as a core combat mechanic, modeled after the existing HP sync pattern (instant UI update + debounced DB persistence).

## Goals / Non-Goals

**Goals:**
- Derive max spell slots from character class/level/subclass (single-class and multiclass)
- Persist current (remaining) slot counts per entity, per slot type, per level
- Display slots grouped by type in Character Detail and Character Modal views
- Consume a slot when casting a spell, with upcast fallback when base level is depleted
- Support Pact Magic (Warlock) as a separate slot group from regular spellcasting
- Match the existing frontend pattern for state management and DB sync

**Non-Goals:**
- Spell slot recovery via rests (short/long rest) — deferred
- Spell-to-slot tracking (which spell consumed which slot)
- Direct cast from initiative strip (only via modal/detail views)
- Custom/homebrew spell slot systems (v2 concern)
- Level-up slot recalculation (level-up itself is not in scope)

## Decisions

### Decision 1: Caster type classification in the database, not Rust

**Choice:** Add a `spellcaster_type` column to `classes` and a nullable override `spellcaster_type` column to `subclasses`.

**Alternatives considered:**
- **Hardcoded Rust match statement**: Simpler initially but means caster classification is invisible to anyone reading the schema. Also means custom classes in v2 would require Rust changes.
- **Separate lookup table**: Over-engineered for the current 13 classes.

**Rationale:** The D&D 5e caster type classification is domain data, not application logic. Storing it in the DB keeps it visible, queryable, and trivially extensible. The subclass override handles the two edge cases (Eldritch Knight, Arcane Trickster) without special-casing in code. The Rust code becomes a generic loop: "read caster_type → apply formula."

### Decision 2: Max derived from class_level_progression, only current persisted

**Choice:** `get_spell_slots` computes max slots every time from `class_level_progression`. Only `current` values are stored in `entity_spell_slot_state`.

**Alternatives considered:**
- **Store both max and current in a single table**: Means max can drift from source of truth on level-up. Requires migration logic to recompute.
- **Store everything in the existing `entity_spellcasting` table**: Table exists but has flat columns (slots_lvl_1_max, slots_lvl_1_curr, ...). This is less flexible for Pact Magic (no second group) and doesn't map well to v2's resource-based model.

**Rationale:** The derive-vs-persist split means max is always correct — level up happens, next load sees new max. No reconciliation logic needed. The persisted table is minimal: only `(entity, type, level, curr)` rows for slots that have been used. On first load with no persisted rows, `curr = max`. This matches how physical character sheets work: the max is printed on the sheet, you erase and rewrite the current value.

### Decision 3: Single-class uses direct progression lookup, multiclass uses formula

**Choice:** Single-class characters look up slots directly from `class_level_progression(class_id, level)`. Multiclass characters compute caster level via the 5e formula and look up from the full caster table.

**Alternatives considered:**
- **Always use multiclass formula**: Would give wrong results for single-class half-casters (e.g., Paladin 5 would get 3 first-level slots instead of the correct 4/2).

**Rationale:** The 5e rules are clear that half-casters and third-casters have their own slot tables that give them more low-level slots than the multiclass formula would. The direct lookup gives the correct single-class values. The formula is only needed when mixing classes.

### Decision 4: Slot consumption as a single "Cast" action with fallback upcast

**Choice:** Clicking "Cast" on a spell consumes one slot at the spell's base level. If zero slots remain at that level, auto-upcast to the next available higher level. No level picker UI.

**Alternatives considered:**
- **Always show a level picker**: Correct for D&D (you can always choose to use a higher slot), but adds friction to every cast. Most of the time you cast at base level.
- **Show picker only on right-click / long-press**: More discoverability but adds UX complexity for this initial scope.

**Rationale:** The auto-upcast fallback handles the most common upcast scenario (base level depleted, want to keep casting) without UI friction. If a player wants to strategically upcast while they still have base-level slots — which is rare — they can manually track it or we add the picker later.

### Decision 5: Pact Magic as a separate slot group

**Choice:** Warlock pact slots produce a distinct `SpellSlotGroup` with `group_type = "pact_magic"`, separate from `"spellcasting"`.

**Alternatives considered:**
- **Merge into the same slot array**: Would need to distinguish pact from regular slots for recovery purposes (pact recharges on short rest, regular on long rest). Mixing them now makes the rest change harder later.

**Rationale:** The two slot groups have different recovery rules, different progression tables, and different visual presentation in the character sheet. Modeling them as separate groups from day one makes the rest feature trivial to add later, and matches how 5e physical sheets display them (separate section for Pact Magic).

## Data Model

### classes table (new column)

```sql
ALTER TABLE classes ADD COLUMN spellcaster_type TEXT NOT NULL DEFAULT 'none'
    CHECK (spellcaster_type IN ('full', 'half', 'half_up', 'third', 'pact', 'none'));
```

Values:
- `full`: bard, cleric, druid, sorcerer, wizard
- `half`: paladin, ranger
- `half_up`: artificer (rounds up in multiclass formula — unique behavior)
- `pact`: warlock (Pact Magic, separate from regular progression)
- `none`: barbarian, fighter, monk, rogue (base classes without subclass casting)
- `third`: (not used at class level — reserved for subclass overrides, but exists for consistency)

### subclasses table (new column)

```sql
ALTER TABLE subclasses ADD COLUMN spellcaster_type TEXT DEFAULT NULL
    CHECK (spellcaster_type IS NULL OR spellcaster_type IN ('third'));
```

NULL = inherit from parent class. Only `third` used as override.

### entity_spell_slot_state (new table)

```sql
CREATE TABLE entity_spell_slot_state (
    entity_id   TEXT NOT NULL,
    slot_type   TEXT NOT NULL CHECK (slot_type IN ('spellcasting', 'pact_magic')),
    slot_level  INTEGER NOT NULL CHECK (slot_level BETWEEN 1 AND 9),
    slots_curr  INTEGER NOT NULL DEFAULT 0,
    PRIMARY KEY (entity_id, slot_type, slot_level),
    FOREIGN KEY (entity_id) REFERENCES entities(id) ON DELETE CASCADE
);
```

### class_level_progression (seeded)

260 rows inserted (all 13 classes, levels 1-20). Full casters share the standard progression table. Half casters get their reduced progression. Warlock gets pact progression (exactly one non-zero slot column per level). Non-casters get all zeros.

## Rust Types

```rust
#[derive(Debug, Serialize, Deserialize)]
pub struct SpellSlotGroup {
    pub group_type: String,          // "spellcasting" or "pact_magic"
    pub spellcasting_ability: String, // e.g., "INT", "CHA"
    pub save_dc: i32,
    pub attack_bonus: i32,
    pub slots: Vec<SpellSlot>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct SpellSlot {
    pub level: i32,    // 1-9
    pub max: i32,      // derived from class_level_progression
    pub current: i32,  // from entity_spell_slot_state (or = max if no row)
}
```

## TypeScript Types

```typescript
interface SpellSlotGroup {
  group_type: 'spellcasting' | 'pact_magic';
  spellcasting_ability: string;
  save_dc: number;
  attack_bonus: number;
  slots: SpellSlot[];
}

interface SpellSlot {
  level: number;
  max: number;
  current: number;
}
```

## Architecture

```
                    ┌──────────────────────────────┐
                    │  app.svelte.ts store          │
                    │                              │
                    │  spellSlotGroups = $state()   │
                    │  loadSpellSlots(entityId)     │
                    │  consumeSlot(group, level)    │
                    └──────────────────┬───────────┘
                                       │ invoke()
                                       ▼
                    ┌──────────────────────────────┐
                    │  Rust: commands/slots.rs       │
                    │                              │
                    │  get_spell_slots()            │
                    │  set_spell_slots()            │
                    │                              │
                    │  compute_slots() (internal)   │
                    │    → load character_classes   │
                    │    → classify caster types    │
                    │    → compute caster level     │
                    │    → look up progression      │
                    │    → separate pact            │
                    │    → merge with persisted     │
                    └──────────────────┬───────────┘
                                       │ rusqlite
                                       ▼
                    ┌──────────────────────────────┐
                    │  SQLite                       │
                    │                              │
                    │  classes.spellcaster_type     │
                    │  subclasses.spellcaster_type  │
                    │  class_level_progression      │
                    │  entity_spell_slot_state      │
                    └──────────────────────────────┘
```

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| **Upcast auto-choice hides player agency**: Player might want to save their 4th-level slot even though it's the next available | Accept for v1. The auto-fallback fires only when base level is depleted. If players report wanting manual upcast with slots still available, we add a level picker later. |
| **Pact Magic recovery difference**: Warlock slots share the same `entity_spell_slot_state` table as regular slots. A future rest feature must know which slot group recharges on short vs long rest. | Mitigated by `slot_type` column — a rest function can filter by type. |
| **Subclass caster type duplication**: Caster type exists in both `classes` (the base value) and `subclasses` (the override). Two pieces of data that must stay in sync. | Low risk — only two subclasses have overrides. Adding a new subclass with an override is a DB update in one place. |
| **Character creation doesn't pick spells yet**: A created character will have computed max slots but no `entity_spells` rows (no known/prepared spells). The slot display will show empty. | Slots are displayed only when spells exist (gated by existing spell display logic). Adding spell selection to character creation is separate work. |

## 1. Database Schema Changes

- [x] 1.1 Add `spellcaster_type` column to `classes` table
- [x] 1.2 Add `spellcaster_type` column to `subclasses` table (nullable, defaults to NULL)
- [x] 1.3 Create `entity_spell_slot_state` table
- [x] 1.4 Update `Assets/savestate_schema.sql` with all new schema definitions

## 2. Seed Data

- [x] 2.1 Set `classes.spellcaster_type` values for all 13 classes (full/half/half_up/pact/none)
- [x] 2.2 Set `subclasses.spellcaster_type` for Eldritch Knight (`third`) and Arcane Trickster (`third`)
- [x] 2.3 Write and run seed SQL for `class_level_progression` — all 13 classes × levels 1-20 with correct slot values
- [x] 2.4 Verify seeded data with a query returning all 260 rows

## 3. Rust — Data Models

- [x] 3.1 Add `SpellSlotGroup` struct to `models.rs`
- [x] 3.2 Add `SpellSlot` struct to `models.rs`
- [x] 3.3 Add `SpellSlotsResponse` struct to `models.rs` (wraps Vec<SpellSlotGroup>)

## 4. Rust — Slot Computation Logic

- [x] 4.1 Create `src-tauri/src/commands/slots.rs` module
- [x] 4.2 Implement caster type classification function (reads from `classes.spellcaster_type` + `subclasses.spellcaster_type`)
- [x] 4.3 Implement multiclass caster level computation (full/half/half_up/third formula)
- [x] 4.4 Implement single-class slot lookup from `class_level_progression`
- [x] 4.5 Implement pact slot lookup from warlock progression
- [x] 4.6 Implement `get_spell_slots` command: compute max → merge with persisted current → return
- [x] 4.7 Implement `set_spell_slots` command: upsert current value for a single (entity, type, level)
- [x] 4.8 Register new commands in `lib.rs` via `tauri::generate_handler!`
- [x] 4.9 Add `commands/slots.rs` module declaration to `commands/mod.rs`

## 5. Rust — Wire Up Character Creation

- [ ] 5.1 Initialize `entity_spell_slot_state` rows for newly created spellcaster characters (set curr = max for all levels they have) — deferred; `get_spell_slots` already returns `current = max` when no rows exist

## 6. TypeScript — Types and Store

- [x] 6.1 Add `SpellSlot`, `SpellSlotGroup` interfaces to `src/lib/types/index.ts`
- [x] 6.2 Add `spellSlotGroups` state to `app.svelte.ts`
- [x] 6.3 Add `loadSpellSlots(entityId)` function to store (calls `get_spell_slots`)
- [x] 6.4 Add `consumeSlot(groupType, level)` function to store (updates local state + debounced `set_spell_slots`)
- [x] 6.5 Wire `loadSpellSlots` into `loadCharacterSpells` or as a separate load call when selecting a character

## 7. Frontend — Slot Display

- [x] 7.1 Add slot group rendering to `CharacterDetail.svelte` (section header with ability/save/attack, per-level dots/fraction)
- [x] 7.2 Add slot group rendering to `CharacterModal.svelte` (same layout)
- [x] 7.3 Add visual styling for depleted slots (dimmed/grayed when current = 0)
- [x] 7.4 Hide slot section for non-spellcasters (empty slot groups)

## 8. Frontend — Cast Interaction

- [x] 8.1 Add "Cast" button to `SpellCard.svelte`
- [x] 8.2 Implement click handler: consume slot at spell's level (call `consumeSlot`)
- [x] 8.3 Implement upcast fallback: if base level has 0 slots, find next higher level with slots and consume that
- [x] 8.4 Disable "Cast" when no slots available at spell's level or any higher level
- [x] 8.5 Ensure cantrip Cast does not consume a slot

## 9. Testing

- [x] 9.1 Write Rust unit tests for multiclass caster level computation (various combinations)
- [x] 9.2 Write Rust unit tests for single-class direct progression lookup
- [x] 9.3 Write Rust unit tests for pact slot computation
- [x] 9.4 Write Rust unit tests for merge-with-persisted-state logic
- [x] 9.5 Verify type-check passes: `npm run check`
- [x] 9.6 Verify build passes: `npm run tauri build` (or dev mode smoke test)

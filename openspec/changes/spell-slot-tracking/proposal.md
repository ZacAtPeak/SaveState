## Why

Spellcasters are half the game, but SaveState currently has no way to track spell slot usage during combat. HP changes, conditions, and turn order all feel like core loop mechanics — but when a wizard casts Fireball, there's no way to mark that a 3rd-level slot was consumed. This breaks immersion for the primary use case (D&D 5e combat) and makes the app incomplete for the audience it targets.

Adding spell slot tracking turns SaveState from "initiative tracker that happens to show spells" into "actual combat tool for spellcasters."

## What Changes

- A new Rust command (`get_spell_slots`) that computes a character's maximum spell slots from their class(es) and level(s), merges with persisted current slot state, and returns the combined result to the frontend
- A new Rust command (`set_spell_slots`) that persists current slot values (Upsert pattern matching `entity_id + slot_type + slot_level`)
- A new database table (`entity_spell_slot_state`) to store only current slot values (max slots are always derived from `class_level_progression`)
- A new column `spellcaster_type` on the `classes` table to classify each class's casting progression (`full`, `half`, `half_up`, `third`, `pact`, `none`)
- A new column `spellcaster_type` on the `subclasses` table as a nullable override (for Eldritch Knight → `third`, Arcane Trickster → `third`)
- Seeded `class_level_progression` data (~260 rows) so the slot lookup table is populated for all 13 classes × 20 levels
- Frontend slot display in the Character Detail and Character Modal views (dots-per-level or fraction display)
- Frontend "Cast" interaction: consuming a slot at a spell's base level (with fallback upcast if that level is empty)
- Warlock Pact Magic support: separate slot group, tracked independently from regular spellcasting

Does NOT include:
- Spell recovery via rests (short/long rest slot refill) — deferred to a future change
- Spell-to-slot tracking (which specific spell consumed which slot) — out of scope
- Direct cast-from-initiative-strip — only available via character modal/detail for now

## Capabilities

### New Capabilities
- `spell-slot-computation`: Derive max spell slots from class/level/subclass, handle single-class and multiclass (including Pact Magic separation)
- `spell-slot-persistence`: Read and write current slot counts to the database, with derive-vs-persist split (max computed, current stored)
- `spell-slot-ui`: Display spell slots per group per level in the character detail and modal views, with visual consumption indicator
- `spell-slot-consumption`: Consume a spell slot when casting a spell, with upcast fallback when base-level slots are depleted

### Modified Capabilities
- (none — existing specs are unchanged)

## Impact

- **Database**: 2 new columns (`classes.spellcaster_type`, `subclasses.spellcaster_type`), 1 new table (`entity_spell_slot_state`), ~260 rows seeded into `class_level_progression`
- **Rust**: 2 new commands in a new `commands/slots.rs`; shared multiclass computation logic; new types in `models.rs`
- **TypeScript**: New interfaces (`SpellSlotGroup`, `SpellSlot`) in `types/index.ts`; new store state and load/consume functions in `app.svelte.ts`
- **Frontend**: Slot display added to `CharacterDetail.svelte` and `CharacterModal.svelte`; Cast button interaction on `SpellCard.svelte`
- **Build**: No new dependencies; no config changes

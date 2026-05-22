# Spells in Character Detail View

## Summary

Add a "Spells" section to CharacterDetail.svelte that displays an entity's known/prepared spells pulled from the database, following the existing skills pattern.

## Data Flow

1. New Rust command `get_character_spells` in `commands/spells.rs` queries `entity_spells` + `spell_library` + `entity_spellcasting`
2. Returns `Vec<CharacterSpell>` across the IPC boundary
3. Store loads spells via `invoke<CharacterSpell[]>('get_character_spells', { entityId })`
4. CharacterDetail renders them grouped by level

## Models

### Rust (`models.rs`)
```rust
pub struct CharacterSpell {
    pub spell_id: String,
    pub name: String,
    pub level: i32,
    pub school: String,
    pub is_concentration: bool,
    pub is_ritual: bool,
    pub description: String,
    pub is_prepared: bool,
}
```

### TypeScript (`types/index.ts`)
```typescript
export interface CharacterSpell {
  spell_id: string;
  name: string;
  level: number;
  school: string;
  is_concentration: boolean;
  is_ritual: boolean;
  description: string;
  is_prepared: boolean;
}
```

## UI

Compact list below Skills section, visible only when entity has spells. Grouped by spell level (Cantrips, 1st Level, ... 9th Level). Each row: spell name, school label, concentration/ritual badges, prepared indicator.

## Files Changed

- `src-tauri/src/models.rs` — add `CharacterSpell` struct
- `src-tauri/src/db.rs` — add `GET_CHARACTER_SPELLS` query
- `src-tauri/src/commands/spells.rs` — new command
- `src-tauri/src/commands/mod.rs` — register module + export
- `src-tauri/src/lib.rs` — register command handler
- `src/lib/types/index.ts` — add `CharacterSpell` interface
- `src/lib/stores/app.svelte.ts` — add load method + state
- `src/lib/components/CharacterDetail.svelte` — render spells section

<script lang="ts">
  import type { Entity, PlayerCharacter } from '$lib/types';
  import CharacterCard from './CharacterCard.svelte';

  interface Props {
    playerCharacters: PlayerCharacter[];
    npcs: Entity[];
    creatures: Entity[];
    selectedCharacter: Entity | null;
    totalCount: number;
    onSelect: (entity: Entity) => void;
    onDragStart?: () => void;
    onAddCharacter: () => void;
  }

  let {
    playerCharacters,
    npcs,
    creatures,
    selectedCharacter,
    totalCount,
    onSelect,
    onDragStart,
    onAddCharacter
  }: Props = $props();
</script>

<div class="sidebar">
  <div class="elist-header">
    <span class="elist-title">Characters</span>
    <span class="elist-count">{totalCount}</span>
    <button class="elist-add" onclick={onAddCharacter}>+</button>
  </div>
  <div class="elist-filters">
    <button class="filter-btn active">All</button>
    <button class="filter-btn">PCs</button>
    <button class="filter-btn">NPCs</button>
    <button class="filter-btn">Creatures</button>
  </div>
  <div class="elist-scroll">
    {#each playerCharacters as char}
      <CharacterCard
        entity={char}
        selected={selectedCharacter?.id === char.id}
        {onSelect}
      />
    {/each}
    {#each npcs as npc}
      <CharacterCard
        entity={npc}
        selected={selectedCharacter?.id === npc.id}
        {onSelect}
      />
    {/each}
    {#each creatures as creature}
      <CharacterCard
        entity={creature}
        selected={selectedCharacter?.id === creature.id}
        {onSelect}
      />
    {/each}
  </div>
</div>

<style>
  .sidebar {
    width: 320px;
    flex-shrink: 0;
    background: var(--surface);
    border-right: 1px solid var(--border);
    overflow-y: auto;
    display: flex;
    flex-direction: column;
  }

  .elist-header {
    flex-shrink: 0;
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 12px 16px;
    border-bottom: 1px solid var(--border);
  }

  .elist-title {
    font-size: 11px;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.08em;
    color: var(--muted);
    flex: 1;
  }

  .elist-count {
    font-family: var(--font-mono);
    font-size: 10px;
    color: var(--muted);
    background: var(--surface-2);
    padding: 2px 8px;
    border-radius: 10px;
  }

  .elist-add {
    width: 24px;
    height: 24px;
    background: var(--surface-2);
    border: 1px solid var(--border);
    color: var(--muted);
    border-radius: var(--radius-sm);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 16px;
    font-weight: 300;
    transition: all 120ms;
  }

  .elist-add:hover {
    color: var(--fg);
    border-color: var(--gold);
    background: var(--gold-dim);
  }

  .elist-filters {
    flex-shrink: 0;
    display: flex;
    gap: 4px;
    padding: 8px 12px;
    border-bottom: 1px solid var(--border);
  }

  .filter-btn {
    height: 26px;
    padding: 0 12px;
    background: transparent;
    border: 1px solid transparent;
    color: var(--muted);
    font-size: 11px;
    font-weight: 500;
    border-radius: var(--radius-sm);
    transition: all 120ms;
  }

  .filter-btn:hover {
    color: var(--fg);
    border-color: var(--border);
  }

  .filter-btn.active {
    color: var(--fg);
    background: var(--surface-2);
    border-color: var(--border);
  }

  .elist-scroll {
    flex: 1;
    overflow-y: auto;
    padding: 10px;
    display: flex;
    flex-direction: column;
    gap: 6px;
    scrollbar-width: thin;
    scrollbar-color: var(--border) transparent;
  }

  .elist-scroll::-webkit-scrollbar { width: 4px; }
  .elist-scroll::-webkit-scrollbar-thumb { background: var(--border); border-radius: 2px; }
</style>
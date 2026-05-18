<script lang="ts">
  import type { Entity } from '$lib/types';

  interface Props {
    entity: Entity;
    selected: boolean;
    onSelect: (entity: Entity) => void;
  }

  let { entity, selected, onSelect }: Props = $props();

  function getEntityIcon(): string {
    if (entity.entity_type === 'pc') return '🧝';
    if (entity.entity_type === 'npc') return '🧑';
    return '👾';
  }

  function getSubtitle(): string {
    if (entity.entity_type === 'pc' && entity.race && entity.class) {
      return `${entity.race} ${entity.class}`;
    }
    if (entity.entity_type === 'creature' && entity.challenge_rating) {
      return `CR ${entity.challenge_rating}`;
    }
    if (entity.entity_type === 'npc') return 'NPC';
    return '';
  }

  function getBadgeClass(): string {
    if (entity.entity_type === 'pc') return 'type-pc';
    if (entity.entity_type === 'npc') return 'type-npc';
    return 'type-monster';
  }

  function getBadgeLabel(): string {
    if (entity.entity_type === 'pc') return 'PC';
    if (entity.entity_type === 'npc') return 'NPC';
    return 'MON';
  }
</script>

<div
  class="ecard"
  class:selected
  onclick={() => onSelect(entity)}
  draggable="true"
  ondragstart={(e) => {
    if (e.dataTransfer) {
      e.dataTransfer.setData('application/json', JSON.stringify(entity));
      e.dataTransfer.effectAllowed = 'copy';
    }
  }}
>
  <div class="ecard-head">
    <div class="ecard-av">{getEntityIcon()}</div>
    <div class="ecard-info">
      <div class="ecard-name">{entity.name}</div>
      <div class="ecard-sub">{getSubtitle()}</div>
    </div>
    <button class="ecard-fav">★</button>
  </div>
  <div class="ecard-tags">
    <span class="type-badge {getBadgeClass()}">{getBadgeLabel()}</span>
  </div>
</div>

<style>
  .ecard {
    background: var(--surface-2);
    border: 1px solid var(--border);
    border-radius: var(--radius-md);
    padding: 10px 12px;
    display: flex;
    flex-direction: column;
    gap: 8px;
    cursor: pointer;
    transition: all 120ms;
  }

  .ecard:hover {
    border-color: var(--gold);
    transform: translateX(2px);
  }

  .ecard.selected {
    border-color: var(--gold);
    background: color-mix(in oklch, var(--surface-2) 92%, var(--gold) 8%);
  }

  .ecard-head {
    display: flex;
    align-items: center;
    gap: 10px;
  }

  .ecard-av {
    width: 32px;
    height: 32px;
    flex-shrink: 0;
    background: var(--surface-3);
    border: 1px solid var(--border);
    border-radius: var(--radius-sm);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 16px;
  }

  .ecard-info {
    flex: 1;
    min-width: 0;
  }

  .ecard-name {
    font-size: 13px;
    font-weight: 600;
    color: var(--fg);
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  .ecard-sub {
    font-size: 11px;
    color: var(--muted);
    margin-top: 1px;
  }

  .ecard-fav {
    background: none;
    border: none;
    color: var(--border);
    font-size: 14px;
    padding: 2px;
    transition: color 120ms;
    flex-shrink: 0;
  }

  .ecard-fav.on, .ecard-fav:hover { color: var(--gold); }

  .ecard-tags {
    display: flex;
    align-items: center;
    gap: 4px;
  }

  .type-badge {
    display: inline-flex;
    align-items: center;
    font-family: var(--font-mono);
    font-size: 9px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.10em;
    padding: 2px 6px;
    border-radius: var(--radius-sm);
    width: fit-content;
  }

  .type-pc { color: var(--green); background: var(--green-dim); }
  .type-npc { color: var(--purple); background: var(--purple-dim); }
  .type-monster { color: var(--red); background: var(--red-dim); }
</style>
<script lang="ts">
  import type { Entity } from '$lib/types';

  interface Props {
    entity: Entity;
    selected: boolean;
    onSelect: (entity: Entity) => void;
  }

  let { entity, selected, onSelect }: Props = $props();

  function getEntityIcon(): string {
    if (entity.entity_type === 'pc') {
      return '<svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>';
    }
    if (entity.entity_type === 'npc') {
      return '<svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>';
    }
    return '<svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 3c-1.5 0-2.5 1-3 2-1 0-2.5 0-4 1.5-1.5 1.5-2 4-1.5 6 .5 2 2 4 3.5 5s3.5 1.5 5 0 3-3 3.5-5 .5-4.5-1.5-6C14.5 4 13 3 12 3z"/><path d="M10 14s.5-1 1-1 1 1 1 1"/><path d="M13 18s.5-1 1-1 1 1 1 1"/><circle cx="12" cy="10" r="1"/></svg>';
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
    <div class="ecard-av">{@html getEntityIcon()}</div>
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
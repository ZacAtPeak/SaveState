<script lang="ts">
  import type { InitiativeEntity } from '$lib/types';
  import { appStore } from '$lib/stores/app.svelte';

  interface Props {
    initiativeHeight: number;
    onAddCharacter: () => void;
  }

  let { initiativeHeight, onAddCharacter }: Props = $props();
  let initiativeList = $derived(appStore.initiativeList);

  function handleDragOver(e: DragEvent) {
    e.preventDefault();
  }

  function getHpPercent(entity: InitiativeEntity): number {
    return Math.max(0, Math.min(100, (entity.hit_points_current / entity.hit_points_max) * 100));
  }

  function getHpColor(entity: InitiativeEntity): string {
    const ratio = entity.hit_points_current / entity.hit_points_max;
    if (ratio <= 0.25) return 'var(--red)';
    if (ratio <= 0.5) return 'var(--gold)';
    return 'var(--green)';
  }

  function getHpClass(entity: InitiativeEntity): string {
    const ratio = entity.hit_points_current / entity.hit_points_max;
    if (ratio <= 0.25) return 'danger';
    if (ratio <= 0.5) return 'warn';
    return '';
  }
</script>

<div
  class="initiative-strip"
  style="height: {initiativeHeight}px;"
  ondragover={handleDragOver}
>
  <div class="init-header">
    <span class="round-badge">Round {appStore.currentRound}</span>
    <span class="init-label">Turn {appStore.currentTurnIndex + 1}</span>
    <div class="spacer"></div>
    <button class="btn-ghost" onclick={appStore.prevTurn}>◀ Prev</button>
    <button class="btn-ghost" onclick={onAddCharacter}>+ Add</button>
    <button class="btn-primary" onclick={appStore.nextTurn}>Next Turn ▶</button>
  </div>
  {#if initiativeList.length === 0}
    <div class="drag-hint">
      <span class="drag-hint-icon">⚔</span>
      <span>Drag characters here to add to initiative</span>
    </div>
  {:else}
    <div class="initiative-list">
      {#each initiativeList as entity, i}
        <div class="initiative-card" class:active-turn={i === appStore.currentTurnIndex}>
          <span class="init-name">{entity.name}</span>
          <span class="init-value">{entity.initiative}</span>
          <span class="type-badge type-pc">PC</span>
          <div class="mini-hp-text">
            <span class="mini-hp-current {getHpClass(entity)}">{entity.hit_points_current}</span>
            <span class="mini-hp-sep">/</span>
            <span class="mini-hp-max">{entity.hit_points_max}</span>
          </div>
          <div class="mini-hp-bar">
            <div class="mini-hp-fill" style="width: {getHpPercent(entity)}%; background: {getHpColor(entity)}"></div>
          </div>
          <div class="initiative-stats">
            <div class="stat-chip">
              <span class="stat-label">HP</span>
              <span class="stat-value {getHpClass(entity)}">{entity.hit_points_current}</span>
            </div>
            <div class="stat-chip">
              <span class="stat-label">Max</span>
              <span class="stat-value">{entity.hit_points_max}</span>
            </div>
            <div class="stat-chip">
              <span class="stat-label">AC</span>
              <span class="stat-value">{entity.armor_class}</span>
            </div>
          </div>
        </div>
      {/each}
    </div>
  {/if}
  <div class="resize-handle"></div>
</div>

<style>
  .initiative-strip {
    flex-shrink: 0;
    min-height: 190px;
    display: flex;
    flex-direction: column;
    background: var(--surface);
    border-bottom: 1px solid var(--border);
    position: relative;
    overflow: hidden;
  }

  .init-header {
    flex-shrink: 0;
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 10px 16px;
    border-bottom: 1px solid var(--border);
  }

  .round-badge {
    font-family: var(--font-mono);
    font-size: 11px;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.08em;
    color: var(--gold);
    background: var(--gold-dim);
    padding: 4px 10px;
    border-radius: var(--radius-sm);
  }

  .init-label {
    font-family: var(--font-mono);
    font-size: 11px;
    color: var(--muted);
    text-transform: uppercase;
    letter-spacing: 0.06em;
  }

  .init-header .spacer { flex: 1; }

  .btn-ghost {
    height: 30px;
    padding: 0 14px;
    background: var(--surface-2);
    border: 1px solid var(--border);
    color: var(--muted);
    font-size: 12px;
    font-weight: 500;
    border-radius: var(--radius-md);
    transition: all 120ms;
  }

  .btn-ghost:hover {
    color: var(--fg);
    border-color: var(--gold);
  }

  .btn-primary {
    height: 30px;
    padding: 0 16px;
    background: var(--gold);
    border: none;
    color: oklch(11% 0.012 250);
    font-size: 12px;
    font-weight: 600;
    border-radius: var(--radius-md);
    transition: opacity 120ms;
  }

  .btn-primary:hover { opacity: 0.85; }

  .initiative-list {
    flex: 1;
    display: flex;
    gap: 10px;
    padding: 12px 16px;
    overflow-x: auto;
    overflow-y: hidden;
    scrollbar-width: thin;
    scrollbar-color: var(--border) transparent;
  }

  .initiative-list::-webkit-scrollbar { height: 4px; }
  .initiative-list::-webkit-scrollbar-thumb { background: var(--border); border-radius: 2px; }

  .initiative-card {
    flex-shrink: 0;
    width: 120px;
    background: var(--surface-2);
    border: 1px solid var(--border);
    border-radius: var(--radius-lg);
    padding: 10px;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 6px;
    cursor: pointer;
    position: relative;
    transition: all 150ms;
  }

  .initiative-card:hover {
    border-color: var(--gold);
    transform: translateY(-2px);
    box-shadow: 0 4px 12px oklch(0% 0 0 / 0.3);
  }

  .initiative-card.active-turn {
    border-color: var(--gold);
    background: color-mix(in oklch, var(--surface-2) 90%, var(--gold) 10%);
  }

  .init-name {
    font-size: 12px;
    font-weight: 600;
    color: var(--fg);
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    width: 100%;
    text-align: left;
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

  .init-value {
    position: absolute;
    top: 8px;
    right: 8px;
    font-family: var(--font-mono);
    font-size: 18px;
    font-weight: 700;
    color: var(--gold);
    font-variant-numeric: tabular-nums;
  }

  .type-pc { color: var(--green); background: var(--green-dim); }

  .mini-hp-text {
    display: flex;
    align-items: baseline;
    gap: 2px;
    width: 100%;
  }

  .mini-hp-current {
    font-family: var(--font-mono);
    font-size: 14px;
    font-weight: 700;
    color: var(--fg);
    font-variant-numeric: tabular-nums;
  }

  .mini-hp-sep {
    font-family: var(--font-mono);
    font-size: 10px;
    color: var(--muted);
  }

  .mini-hp-max {
    font-family: var(--font-mono);
    font-size: 11px;
    color: var(--muted);
    font-variant-numeric: tabular-nums;
  }

  .mini-hp-current.danger { color: var(--red); }
  .mini-hp-current.warn { color: var(--gold); }

  .mini-hp-bar {
    width: 100%;
    height: 4px;
    background: var(--surface-3);
    border-radius: 2px;
    overflow: hidden;
  }

  .mini-hp-fill {
    height: 100%;
    border-radius: 2px;
    transition: width 250ms ease;
  }

  .initiative-stats {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 4px;
    width: 100%;
  }

  .stat-chip {
    display: flex;
    flex-direction: column;
    align-items: center;
    background: var(--surface-3);
    border-radius: var(--radius-sm);
    padding: 3px 2px;
    gap: 1px;
  }

  .stat-label {
    font-family: var(--font-mono);
    font-size: 8px;
    color: var(--muted);
    text-transform: uppercase;
    letter-spacing: 0.07em;
  }

  .stat-value {
    font-family: var(--font-mono);
    font-size: 11px;
    font-weight: 700;
    color: var(--fg);
    font-variant-numeric: tabular-nums;
  }

  .stat-value.danger { color: var(--red); }
  .stat-value.warn { color: var(--gold); }

  .drag-hint {
    flex: 1;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 8px;
    color: var(--muted);
    font-size: 13px;
  }

  .drag-hint-icon {
    font-size: 32px;
    opacity: 0.4;
  }

  .resize-handle {
    position: absolute;
    bottom: 0;
    left: 0;
    right: 0;
    height: 6px;
    cursor: ns-resize;
    background: linear-gradient(transparent, var(--border));
    transition: background 150ms;
  }

  .resize-handle:hover {
    background: linear-gradient(transparent, var(--gold));
  }
</style>
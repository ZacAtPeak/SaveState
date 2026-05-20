<script lang="ts">
  import type { InitiativeEntity } from '$lib/types';
  import { appStore } from '$lib/stores/app.svelte';

  interface Props {
    initiativeHeight: number;
    onAddCharacter: () => void;
    onEntityDoubleClick?: (instanceId: string) => void;
  }

  let { initiativeHeight, onAddCharacter, onEntityDoubleClick }: Props = $props();
  let initiativeList = $derived(appStore.initiativeList);

  let saveName = $state('');

  function handleSaveNaming() {
    if (!saveName.trim()) return;
    appStore.saveCurrentEncounter(saveName.trim());
    appStore.showSaveNaming = false;
    saveName = '';
  }

  function handleKeydown(e: KeyboardEvent) {
    if (appStore.showSaveNaming && e.key === 'Escape') {
      appStore.showSaveNaming = false;
      saveName = '';
    }
    if (appStore.showSaveNaming && e.key === 'Enter') {
      handleSaveNaming();
    }
  }

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

  function getBadgeClass(entity: InitiativeEntity): string {
    if (entity.entity_type === 'pc') return 'type-pc';
    if (entity.entity_type === 'npc') return 'type-npc';
    return 'type-monster';
  }

  function getModifier(score: number): number {
    return Math.floor((score - 10) / 2);
  }

  let processedIds = new Set<string>();

  $effect(() => {
    const list = initiativeList;
    if (list.length === 0) {
      processedIds.clear();
      return;
    }
    const newIds = [...appStore.newInstanceIds].filter(id => !processedIds.has(id));
    if (newIds.length === 0) return;
    for (const id of newIds) processedIds.add(id);
    const elements = newIds.map(id => document.querySelector(`[data-instance-id="${id}"]`) as HTMLElement | null).filter((el): el is HTMLElement => el !== null);
    if (elements.length === 0) return;
    for (const el of elements) {
      el.style.transform = 'scale(0)';
      el.style.opacity = '0';
    }
    import('gsap').then(({ default: gsap }) => {
      gsap.to(elements, {
        scale: 1, opacity: 1,
        duration: 0.4,
        ease: "elastic.out(1, 0.4)",
        stagger: newIds.length > 1 ? 0.05 : 0,
        onComplete: () => {
          for (const id of newIds) appStore.clearNewInstanceId(id);
        }
      });
    });
  });

  function selectEntityFromInitiative(instanceId: string) {
    const initEntity = appStore.initiativeList.find(e => e.instance_id === instanceId);
    if (!initEntity) return;
    const entity = appStore.playerCharacters.find(e => e.id === initEntity.id)
      ?? appStore.npcs.find(e => e.id === initEntity.id)
      ?? appStore.creatures.find(e => e.id === initEntity.id);
    if (entity) appStore.selectCharacter(entity);
  }
</script>

<svelte:body onkeydown={handleKeydown} />

<div
  class="initiative-strip"
  style="height: {initiativeHeight}px;"
  ondragover={handleDragOver}
>
  <div class="init-header">
    <span class="round-badge">Round {appStore.currentRound}</span>
    <span class="init-label">Turn {appStore.currentTurnIndex + 1}</span>
    <button class="btn-clear" onclick={appStore.clearEncounter} aria-label="Clear encounter">
      <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
    </button>
    <div class="spacer"></div>
    <button class="btn-ghost" onclick={appStore.prevTurn}>◀ Prev</button>
    <button class="btn-save" onclick={() => {
      if (!appStore.currentEncounterId) {
        appStore.showSaveNaming = true;
      } else {
        appStore.saveCurrentEncounter();
      }
    }}>
      <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/><polyline points="17 21 17 13 7 13 7 21"/><polyline points="7 3 7 8 15 8"/></svg>
      {appStore.currentEncounterName ?? '+ save'}
    </button>
    <button class="btn-primary" onclick={appStore.nextTurn}>Next Turn ▶</button>
  </div>

  {#if appStore.showSaveNaming}
    <div class="save-overlay" onclick={() => { appStore.showSaveNaming = false; saveName = ''; }}>
      <div class="save-modal" onclick={(e) => e.stopPropagation()}>
        <span class="save-modal-title">Save Encounter</span>
        <input
          class="save-name-input"
          type="text"
          bind:value={saveName}
          placeholder="Encounter name..."
          autofocus
        />
        <div class="save-modal-actions">
          <button class="btn-ghost" onclick={() => { appStore.showSaveNaming = false; saveName = ''; }}>Cancel</button>
          <button class="btn-primary" onclick={handleSaveNaming} disabled={!saveName.trim()}>Save</button>
        </div>
      </div>
    </div>
  {/if}
  {#if initiativeList.length === 0}
    <div class="drag-hint">
      <span class="drag-hint-icon">
        <svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14.5 17.5L3 6V3h3l11.5 11.5"/><path d="M13 19l6-6"/><path d="M16 16l4 4"/><path d="M19 21l2-2"/></svg>
      </span>
      <span>Drag characters here to add to initiative</span>
    </div>
  {:else}
    <div class="initiative-list">
      {#each initiativeList as entity, i}
        <div class="initiative-card" class:active-turn={i === appStore.currentTurnIndex} data-instance-id={entity.instance_id} onclick={() => selectEntityFromInitiative(entity.instance_id)} ondblclick={() => onEntityDoubleClick?.(entity.instance_id)}>
          <span class="init-name">{entity.name}</span>
          <span class="init-value {getBadgeClass(entity)}">{entity.initiative}</span>
          <div class="mini-hp-row">
            <div class="mini-hp-text">
              <span class="mini-hp-current {getHpClass(entity)}">{entity.hit_points_current}</span>
              <span class="mini-hp-sep">/</span>
              <span class="mini-hp-max">{entity.hit_points_max}</span>
            </div>
            <div class="spacer"></div>
            <div class="mini-ac">
              <span class="stat-label">AC</span>
              <span class="stat-value">{entity.armor_class}</span>
            </div>
          </div>
          <div class="mini-hp-bar">
            <div class="mini-hp-fill" style="width: {getHpPercent(entity)}%; background: {getHpColor(entity)}"></div>
          </div>
          <div class="ability-grid">
            <div class="stat-chip">
              <span class="stat-label">STR</span>
              <span class="stat-value">{getModifier(entity.strength) >= 0 ? '+' : ''}{getModifier(entity.strength)}</span>
            </div>
            <div class="stat-chip">
              <span class="stat-label">DEX</span>
              <span class="stat-value">{getModifier(entity.dexterity) >= 0 ? '+' : ''}{getModifier(entity.dexterity)}</span>
            </div>
            <div class="stat-chip">
              <span class="stat-label">CON</span>
              <span class="stat-value">{getModifier(entity.constitution) >= 0 ? '+' : ''}{getModifier(entity.constitution)}</span>
            </div>
            <div class="stat-chip">
              <span class="stat-label">INT</span>
              <span class="stat-value">{getModifier(entity.intelligence) >= 0 ? '+' : ''}{getModifier(entity.intelligence)}</span>
            </div>
            <div class="stat-chip">
              <span class="stat-label">WIS</span>
              <span class="stat-value">{getModifier(entity.wisdom) >= 0 ? '+' : ''}{getModifier(entity.wisdom)}</span>
            </div>
            <div class="stat-chip">
              <span class="stat-label">CHA</span>
              <span class="stat-value">{getModifier(entity.charisma) >= 0 ? '+' : ''}{getModifier(entity.charisma)}</span>
            </div>
          </div>
        </div>
      {/each}
    </div>
  {/if}
</div>

<style>
  .initiative-strip {
    flex-shrink: 0;
    min-height: 235px;
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

  .btn-clear {
    height: 30px;
    width: 30px;
    background: none;
    border: 1px solid transparent;
    color: var(--muted);
    border-radius: var(--radius-md);
    display: inline-flex;
    align-items: center;
    justify-content: center;
    transition: all 120ms;
    margin-left: 4px;
  }

  .btn-clear:hover {
    color: var(--red);
    border-color: var(--red);
  }

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
    font-variant-numeric: tabular-nums;
    color: var(--fg);
  }

  .type-pc { color: var(--green); }
  .type-npc { color: var(--purple); }
  .type-monster { color: var(--red); }

  .init-value {
    position: absolute;
    top: 8px;
    right: 8px;
    font-family: var(--font-mono);
    font-size: 18px;
    font-weight: 700;
    color: var(--fg);
    font-variant-numeric: tabular-nums;
  }

  .mini-hp-text {
    display: flex;
    align-items: baseline;
    gap: 2px;
  }

  .mini-hp-row {
    display: flex;
    align-items: center;
    width: 100%;
  }

  .mini-hp-row .spacer { flex: 1; }

  .mini-ac {
    display: flex;
    align-items: center;
    gap: 4px;
  }

  .mini-ac .stat-label {
    font-family: var(--font-mono);
    font-size: 9px;
    color: var(--muted);
    text-transform: uppercase;
    letter-spacing: 0.07em;
  }

  .mini-ac .stat-value {
    font-family: var(--font-mono);
    font-size: 12px;
    font-weight: 700;
    color: var(--fg);
    font-variant-numeric: tabular-nums;
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

  .ability-grid {
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

  .btn-save {
    height: 30px;
    padding: 0 12px;
    background: var(--surface-2);
    border: 1px solid var(--border);
    color: var(--muted);
    font-size: 12px;
    font-weight: 500;
    border-radius: var(--radius-md);
    transition: all 120ms;
    display: inline-flex;
    align-items: center;
    gap: 6px;
  }

  .btn-save:hover {
    color: var(--green);
    border-color: var(--green);
  }

  .save-overlay {
    position: fixed;
    inset: 0;
    background: oklch(0% 0 0 / 0.5);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 1000;
  }

  .save-modal {
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: var(--radius-lg);
    padding: 20px;
    width: 320px;
    display: flex;
    flex-direction: column;
    gap: 12px;
    box-shadow: 0 24px 48px oklch(0% 0 0 / 0.4);
  }

  .save-modal-title {
    font-family: var(--font-display);
    font-size: 15px;
    font-weight: 600;
    color: var(--fg);
  }

  .save-name-input {
    padding: 10px 12px;
    background: var(--bg);
    border: 1px solid var(--border);
    border-radius: var(--radius-sm);
    color: var(--fg);
    font-size: 14px;
  }

  .save-name-input:focus {
    outline: none;
    border-color: var(--gold);
  }

  .save-modal-actions {
    display: flex;
    justify-content: flex-end;
    gap: 8px;
  }
</style>
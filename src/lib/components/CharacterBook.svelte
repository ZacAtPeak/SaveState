<script lang="ts">
  import { appStore } from '$lib/stores/app.svelte';
  import type { Entity } from '$lib/types';

  interface Props {
    onClose: () => void;
  }

  let { onClose }: Props = $props();

  let isClosing = $state(false);
  let selectedEntity = $state<Entity | null>(null);

  let allEntities = $derived([
    ...appStore.playerCharacters.map(c => ({ ...c, category: 'character' as const })),
    ...appStore.creatures.map(c => ({ ...c, category: 'creature' as const })),
    ...appStore.npcs.map(n => ({ ...n, category: 'npc' as const }))
  ]);

  function handleClose() {
    isClosing = true;
    setTimeout(() => {
      onClose();
    }, 250);
  }

  function selectEntity(entity: Entity) {
    selectedEntity = entity;
  }

  function getModifier(score: number): number {
    return Math.floor((score - 10) / 2);
  }

  function getEntityIcon(entity: Entity): string {
    if (entity.entity_type === 'pc') {
      return '<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>';
    }
    if (entity.entity_type === 'npc') {
      return '<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>';
    }
    return '<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M5.81 7C5.81 7 5.36 7.63 4.82 8.67M18.19 7C18.19 7 18.64 7.63 19.18 8.67M4.82 8.67C4.01 10.21 3 12.67 3 15.33C5.81 15.33 7.5 17 7.5 17C7.5 17 8.62 22 12 22C15.38 22 16.5 17 16.5 17C16.5 17 18.19 15.33 21 15.33C21 12.67 19.99 10.21 19.18 8.67M4.82 8.67C4.82 8.67 1.88 6.44 4.82 2C5.81 2.56 8.62 4.78 8.62 4.78C8.62 4.78 10.31 3.67 12 3.67C13.69 3.67 15.38 4.78 15.38 4.78C15.38 4.78 18.19 2.56 19.31 2C22.13 6.44 19.18 8.67 19.18 8.67"/><path d="M11 18L12 19M13 18L12 18"/><path d="M8.5 12.5L10 14M15.5 12.5L14 14"/></svg>';
  }

  function getBadgeLabel(entity: Entity): string {
    if (entity.entity_type === 'pc') return 'PC';
    if (entity.entity_type === 'npc') return 'NPC';
    return 'Creature';
  }

  function getHpPercent(entity: Entity): number {
    return Math.max(0, Math.min(100, (entity.hit_points_current / entity.hit_points_max) * 100));
  }

  function getHpColor(entity: Entity): string {
    const ratio = entity.hit_points_current / entity.hit_points_max;
    if (ratio <= 0.25) return 'var(--red)';
    if (ratio <= 0.5) return 'var(--gold)';
    return 'var(--green)';
  }
</script>

<div class="book-overlay" onclick={handleClose}></div>
<div class="book-panel" class:closing={isClosing}>
  <div class="book-header">
    <h2>Character Book</h2>
    <button class="close-btn" onclick={handleClose}>
      <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 6L6 18M6 6l12 12"/></svg>
    </button>
  </div>

  <div class="book-content">
    <div class="entity-list">
      <div class="list-header">
        <span>All Characters</span>
        <span class="count">{allEntities.length}</span>
      </div>
      {#if allEntities.length === 0}
        <div class="empty-list">No characters yet</div>
      {:else}
        <div class="list-items">
          {#each allEntities as entity}
            <button
              class="entity-item"
              class:selected={selectedEntity?.id === entity.id}
              onclick={() => selectEntity(entity)}
            >
              <span class="entity-icon">{@html getEntityIcon(entity)}</span>
              <span class="entity-name">{entity.name}</span>
              <span class="entity-type">{getBadgeLabel(entity)}</span>
            </button>
          {/each}
        </div>
      {/if}
    </div>

    <div class="entity-detail">
      {#if !selectedEntity}
        <div class="detail-empty">
          <div class="empty-icon">📖</div>
          <span>Select a character to view details</span>
        </div>
      {:else}
        <div class="detail-header">
          <div class="detail-title-row">
            <span class="detail-icon">{@html getEntityIcon(selectedEntity)}</span>
            <div class="detail-title">
              <h3>{selectedEntity.name}</h3>
              <span class="detail-sub">{selectedEntity.class} · Level {selectedEntity.level}</span>
            </div>
          </div>
        </div>

        <div class="detail-section">
          <div class="stat-row">
            <div class="stat-box">
              <span class="stat-label">AC</span>
              <span class="stat-value">{selectedEntity.armor_class}</span>
            </div>
            <div class="stat-box">
              <span class="stat-label">HP</span>
              <span class="stat-value">{selectedEntity.hit_points_current}/{selectedEntity.hit_points_max}</span>
            </div>
            <div class="stat-box">
              <span class="stat-label">Speed</span>
              <span class="stat-value">{selectedEntity.speed ?? 30}ft</span>
            </div>
          </div>
          <div class="hp-bar">
            <div class="hp-fill" style="width: {getHpPercent(selectedEntity)}%; background: {getHpColor(selectedEntity)}"></div>
          </div>
        </div>

        <div class="detail-section">
          <h4>Ability Scores</h4>
          <div class="ability-grid">
            <div class="ability-card">
              <span class="ability-label">STR</span>
              <span class="ability-score">{selectedEntity.strength}</span>
              <span class="ability-mod">{getModifier(selectedEntity.strength) >= 0 ? '+' : ''}{getModifier(selectedEntity.strength)}</span>
            </div>
            <div class="ability-card">
              <span class="ability-label">DEX</span>
              <span class="ability-score">{selectedEntity.dexterity}</span>
              <span class="ability-mod">{getModifier(selectedEntity.dexterity) >= 0 ? '+' : ''}{getModifier(selectedEntity.dexterity)}</span>
            </div>
            <div class="ability-card">
              <span class="ability-label">CON</span>
              <span class="ability-score">{selectedEntity.constitution}</span>
              <span class="ability-mod">{getModifier(selectedEntity.constitution) >= 0 ? '+' : ''}{getModifier(selectedEntity.constitution)}</span>
            </div>
            <div class="ability-card">
              <span class="ability-label">INT</span>
              <span class="ability-score">{selectedEntity.intelligence}</span>
              <span class="ability-mod">{getModifier(selectedEntity.intelligence) >= 0 ? '+' : ''}{getModifier(selectedEntity.intelligence)}</span>
            </div>
            <div class="ability-card">
              <span class="ability-label">WIS</span>
              <span class="ability-score">{selectedEntity.wisdom}</span>
              <span class="ability-mod">{getModifier(selectedEntity.wisdom) >= 0 ? '+' : ''}{getModifier(selectedEntity.wisdom)}</span>
            </div>
            <div class="ability-card">
              <span class="ability-label">CHA</span>
              <span class="ability-score">{selectedEntity.charisma}</span>
              <span class="ability-mod">{getModifier(selectedEntity.charisma) >= 0 ? '+' : ''}{getModifier(selectedEntity.charisma)}</span>
            </div>
          </div>
        </div>

        {#if selectedEntity.skills && selectedEntity.skills.length > 0}
          <div class="detail-section">
            <h4>Skills</h4>
            <div class="skills-list">
              {#each selectedEntity.skills as skill}
                <div class="skill-item">
                  <span class="skill-name">{skill.name}</span>
                  <span class="skill-bonus">{skill.bonus >= 0 ? '+' : ''}{skill.bonus}</span>
                </div>
              {/each}
            </div>
          </div>
        {/if}

        {#if selectedEntity.equipment && selectedEntity.equipment.length > 0}
          <div class="detail-section">
            <h4>Equipment</h4>
            <div class="equipment-list">
              {#each selectedEntity.equipment as item}
                <div class="equipment-item">
                  <span class="equipment-name">{item}</span>
                </div>
              {/each}
            </div>
          </div>
        {/if}

        {#if selectedEntity.spells && selectedEntity.spells.length > 0}
          <div class="detail-section">
            <h4>Spells</h4>
            <div class="spells-list">
              {#each selectedEntity.spells as spell}
                <div class="spell-item">
                  <span class="spell-name">{spell}</span>
                </div>
              {/each}
            </div>
          </div>
        {/if}
      {/if}
    </div>
  </div>
</div>

<style>
  .book-overlay {
    position: fixed;
    inset: 0;
    background: oklch(0% 0 0 / 0.5);
    z-index: 100;
    animation: fadeIn 0.2s ease-out;
  }

  @keyframes fadeIn {
    from { opacity: 0; }
    to { opacity: 1; }
  }

  .book-panel {
    position: fixed;
    bottom: 0;
    left: 0;
    right: 0;
    height: 75vh;
    background: var(--surface);
    border-top: 1px solid var(--border);
    border-radius: var(--radius-lg) var(--radius-lg) 0 0;
    z-index: 101;
    display: flex;
    flex-direction: column;
    animation: slideUp 0.35s cubic-bezier(0.34, 1.56, 0.64, 1);
    transform-origin: bottom center;
  }

  .book-panel.closing {
    animation: slideDown 0.25s cubic-bezier(0.55, 0, 1, 0.45) forwards;
  }

  @keyframes slideUp {
    from {
      opacity: 0;
      transform: translateY(100%) scale(0.95);
    }
    to {
      opacity: 1;
      transform: translateY(0) scale(1);
    }
  }

  @keyframes slideDown {
    from {
      opacity: 1;
      transform: translateY(0) scale(1);
    }
    to {
      opacity: 0;
      transform: translateY(100%) scale(0.95);
    }
  }

  .book-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 20px 24px;
    border-bottom: 1px solid var(--border);
    flex-shrink: 0;
  }

  .book-header h2 {
    font-size: 18px;
    font-weight: 600;
    color: var(--fg);
  }

  .close-btn {
    width: 32px;
    height: 32px;
    background: var(--surface-2);
    border: 1px solid var(--border);
    color: var(--muted);
    border-radius: var(--radius-md);
    display: flex;
    align-items: center;
    justify-content: center;
    transition: all 120ms;
  }

  .close-btn:hover {
    color: var(--fg);
    border-color: var(--gold);
  }

  .book-content {
    flex: 1;
    display: flex;
    min-height: 0;
    overflow: hidden;
  }

  .entity-list {
    width: 280px;
    flex-shrink: 0;
    border-right: 1px solid var(--border);
    display: flex;
    flex-direction: column;
    overflow: hidden;
  }

  .list-header {
    padding: 16px 20px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    font-size: 12px;
    font-weight: 600;
    color: var(--muted);
    text-transform: uppercase;
    letter-spacing: 0.06em;
    border-bottom: 1px solid var(--border);
  }

  .count {
    background: var(--surface-2);
    padding: 2px 8px;
    border-radius: var(--radius-sm);
  }

  .empty-list {
    flex: 1;
    display: flex;
    align-items: center;
    justify-content: center;
    color: var(--muted);
    font-size: 13px;
    opacity: 0.6;
  }

  .list-items {
    flex: 1;
    overflow-y: auto;
    padding: 8px;
  }

  .entity-item {
    width: 100%;
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 10px 12px;
    background: none;
    border: none;
    border-radius: var(--radius-md);
    color: var(--fg);
    font-size: 13px;
    font-weight: 500;
    text-align: left;
    transition: background 120ms;
    cursor: pointer;
  }

  .entity-item:hover {
    background: var(--surface-2);
  }

  .entity-item.selected {
    background: var(--gold-dim);
    border: 1px solid var(--gold);
  }

  .entity-icon {
    font-size: 16px;
    width: 24px;
    text-align: center;
  }

  .entity-name {
    flex: 1;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  .entity-type {
    font-size: 10px;
    font-family: var(--font-mono);
    color: var(--muted);
    text-transform: uppercase;
  }

  .entity-detail {
    flex: 1;
    overflow-y: auto;
    padding: 24px;
  }

  .detail-empty {
    flex: 1;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 12px;
    color: var(--muted);
    height: 100%;
  }

  .empty-icon {
    font-size: 48px;
    opacity: 0.2;
  }

  .detail-header {
    margin-bottom: 24px;
  }

  .detail-title-row {
    display: flex;
    align-items: center;
    gap: 16px;
  }

  .detail-icon {
    font-size: 40px;
  }

  .detail-title h3 {
    font-size: 24px;
    font-weight: 700;
    color: var(--fg);
    margin-bottom: 4px;
  }

  .detail-sub {
    font-size: 14px;
    color: var(--muted);
  }

  .detail-section {
    margin-bottom: 24px;
  }

  .detail-section h4 {
    font-size: 11px;
    font-weight: 600;
    color: var(--muted);
    text-transform: uppercase;
    letter-spacing: 0.08em;
    margin-bottom: 12px;
  }

  .stat-row {
    display: flex;
    gap: 16px;
    margin-bottom: 12px;
  }

  .stat-box {
    flex: 1;
    display: flex;
    flex-direction: column;
    align-items: center;
    background: var(--surface-2);
    border: 1px solid var(--border);
    border-radius: var(--radius-md);
    padding: 12px;
    gap: 4px;
  }

  .stat-box .stat-label {
    font-size: 10px;
    font-family: var(--font-mono);
    color: var(--muted);
    text-transform: uppercase;
    letter-spacing: 0.07em;
  }

  .stat-box .stat-value {
    font-size: 20px;
    font-weight: 700;
    font-family: var(--font-mono);
    color: var(--fg);
  }

  .hp-bar {
    height: 8px;
    background: var(--surface-3);
    border-radius: 4px;
    overflow: hidden;
  }

  .hp-fill {
    height: 100%;
    border-radius: 4px;
    transition: width 250ms ease;
  }

  .ability-grid {
    display: grid;
    grid-template-columns: repeat(6, 1fr);
    gap: 8px;
  }

  .ability-card {
    display: flex;
    flex-direction: column;
    align-items: center;
    background: var(--surface-2);
    border: 1px solid var(--border);
    border-radius: var(--radius-md);
    padding: 12px 8px;
    gap: 4px;
  }

  .ability-label {
    font-size: 10px;
    font-family: var(--font-mono);
    color: var(--muted);
    text-transform: uppercase;
    letter-spacing: 0.07em;
  }

  .ability-score {
    font-size: 18px;
    font-weight: 700;
    font-family: var(--font-mono);
    color: var(--fg);
  }

  .ability-mod {
    font-size: 12px;
    font-family: var(--font-mono);
    color: var(--gold);
    font-weight: 600;
  }

  .skills-list, .equipment-list, .spells-list {
    display: flex;
    flex-direction: column;
    gap: 6px;
  }

  .skill-item, .equipment-item, .spell-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 8px 12px;
    background: var(--surface-2);
    border: 1px solid var(--border);
    border-radius: var(--radius-sm);
  }

  .skill-name, .equipment-name, .spell-name {
    font-size: 13px;
    color: var(--fg);
  }

  .skill-bonus {
    font-size: 12px;
    font-family: var(--font-mono);
    font-weight: 600;
    color: var(--gold);
  }
</style>
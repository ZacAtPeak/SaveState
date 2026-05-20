<script lang="ts">
  import { appStore } from '$lib/stores/app.svelte';

  interface Props {
    onClose: () => void;
  }

  let { onClose }: Props = $props();

  let encounterName = $state('');
  let selections = $state<Record<string, number>>({});

  function toggleCreature(id: string, delta: number) {
    const current = selections[id] ?? 0;
    const next = Math.max(0, current + delta);
    selections = { ...selections, [id]: next };
  }

  function getCount(id: string): number {
    return selections[id] ?? 0;
  }

  function getTotalCreatures(): number {
    return Object.values(selections).reduce((a, b) => a + b, 0);
  }

  async function handleSave() {
    if (!encounterName.trim()) return;
    const creatureSelections = Object.entries(selections)
      .filter(([_, count]) => count > 0)
      .map(([entityId, count]) => ({ entityId, count }));
    await appStore.saveEncounter(encounterName.trim(), creatureSelections);
    onClose();
  }
</script>

<div class="modal-overlay" onclick={onClose}>
  <div class="modal" onclick={(e) => e.stopPropagation()}>
    <h2>Build Encounter</h2>

    <label class="name-field">
      <span>Encounter Name</span>
      <input type="text" bind:value={encounterName} placeholder="e.g. Goblin Ambush" />
    </label>

    <div class="creature-list">
      {#each appStore.creatures as creature}
        <div class="creature-row">
          <div class="creature-info">
            <span class="creature-name">{creature.name}</span>
            <span class="creature-meta">CR {creature.challenge_rating} · AC {creature.armor_class} · HP {creature.hit_points_max}</span>
          </div>
          <div class="stepper">
            <button class="step-btn" onclick={() => toggleCreature(creature.id, -1)} disabled={getCount(creature.id) <= 0} aria-label="Decrease count">
              <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M5 12h14"/></svg>
            </button>
            <span class="step-count">{getCount(creature.id)}</span>
            <button class="step-btn" onclick={() => toggleCreature(creature.id, 1)} aria-label="Increase count">
              <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 5v14M5 12h14"/></svg>
            </button>
          </div>
        </div>
      {/each}
      {#if appStore.creatures.length === 0}
        <div class="empty-list">No creatures available</div>
      {/if}
    </div>

    <div class="modal-actions">
      <span class="total-count">{getTotalCreatures()} creature{getTotalCreatures() !== 1 ? 's' : ''} selected</span>
      <div class="action-btns">
        <button class="btn-secondary" onclick={onClose}>Cancel</button>
        <button class="btn-primary" onclick={handleSave} disabled={!encounterName.trim() || getTotalCreatures() === 0}>Save Encounter</button>
      </div>
    </div>
  </div>
</div>

<style>
  .modal-overlay {
    position: fixed;
    inset: 0;
    background: oklch(0% 0 0 / 0.7);
    backdrop-filter: blur(4px);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 1000;
  }

  .modal {
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: var(--radius-lg);
    padding: 24px;
    width: 480px;
    max-height: 90vh;
    display: flex;
    flex-direction: column;
    gap: 16px;
    box-shadow: 0 24px 48px oklch(0% 0 0 / 0.4);
  }

  .modal h2 {
    font-family: var(--font-display);
    font-size: 18px;
    font-weight: 600;
    color: var(--fg);
    margin: 0;
  }

  .name-field {
    display: flex;
    flex-direction: column;
    gap: 6px;
    font-size: 11px;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.06em;
    color: var(--muted);
  }

  .name-field input {
    padding: 10px 12px;
    background: var(--bg);
    border: 1px solid var(--border);
    border-radius: var(--radius-sm);
    color: var(--fg);
    font-size: 14px;
  }

  .name-field input:focus {
    outline: none;
    border-color: var(--gold);
  }

  .creature-list {
    flex: 1;
    overflow-y: auto;
    display: flex;
    flex-direction: column;
    gap: 4px;
    border: 1px solid var(--border);
    border-radius: var(--radius-md);
    padding: 8px;
    min-height: 200px;
  }

  .creature-row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 8px 10px;
    border-radius: var(--radius-sm);
    transition: background 120ms;
  }

  .creature-row:hover {
    background: var(--surface-2);
  }

  .creature-info {
    display: flex;
    flex-direction: column;
    gap: 2px;
  }

  .creature-name {
    font-size: 13px;
    font-weight: 500;
    color: var(--fg);
  }

  .creature-meta {
    font-size: 11px;
    color: var(--muted);
  }

  .stepper {
    display: flex;
    align-items: center;
    gap: 6px;
  }

  .step-btn {
    width: 28px;
    height: 28px;
    background: var(--surface-2);
    border: 1px solid var(--border);
    color: var(--fg);
    border-radius: var(--radius-sm);
    display: flex;
    align-items: center;
    justify-content: center;
    transition: all 120ms;
  }

  .step-btn:hover:not(:disabled) {
    border-color: var(--gold);
    color: var(--gold);
  }

  .step-btn:disabled {
    opacity: 0.3;
    cursor: default;
  }

  .step-count {
    width: 24px;
    text-align: center;
    font-size: 14px;
    font-weight: 600;
    font-family: var(--font-mono);
    color: var(--fg);
  }

  .empty-list {
    flex: 1;
    display: flex;
    align-items: center;
    justify-content: center;
    color: var(--muted);
    font-size: 13px;
    padding: 40px;
  }

  .modal-actions {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 10px;
  }

  .total-count {
    font-size: 12px;
    color: var(--muted);
  }

  .action-btns {
    display: flex;
    gap: 10px;
  }

  .btn-secondary {
    height: 36px;
    padding: 0 18px;
    background: var(--surface-2);
    border: 1px solid var(--border);
    color: var(--muted);
    font-size: 13px;
    font-weight: 500;
    border-radius: var(--radius-md);
    transition: all 120ms;
  }

  .btn-secondary:hover {
    color: var(--fg);
    border-color: var(--gold);
  }

  .btn-primary {
    height: 36px;
    padding: 0 18px;
    background: var(--gold);
    border: none;
    color: oklch(11% 0.012 250);
    font-size: 13px;
    font-weight: 600;
    border-radius: var(--radius-md);
    transition: opacity 120ms;
  }

  .btn-primary:hover { opacity: 0.85; }
  .btn-primary:disabled { opacity: 0.4; cursor: default; }
</style>

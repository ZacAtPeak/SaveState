<script lang="ts">
  import { appStore } from '$lib/stores/app.svelte';

  interface Props {
    onClose: () => void;
  }

  let { onClose }: Props = $props();

  let loaded = $state(false);

  $effect(() => {
    if (!loaded) {
      appStore.loadSavedStates();
      loaded = true;
    }
  });

  function handleLoad(id: string) {
    appStore.loadSavedEncounter(id);
    onClose();
  }

  function handleDelete(id: string) {
    appStore.deleteSavedState(id);
  }

  function formatDate(ts: number): string {
    return new Date(ts).toLocaleString();
  }
</script>

<div class="settings-overlay" onclick={onClose}>
  <div class="settings-modal" onclick={(e) => e.stopPropagation()}>
    <div class="settings-header">
      <h2>Settings</h2>
      <button class="close-btn" onclick={onClose} aria-label="Close">
        <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 6L6 18M6 6l12 12"/></svg>
      </button>
    </div>

    <div class="settings-section">
      <h3>Saved Encounters</h3>
      {#if appStore.savedStates.length === 0}
        <div class="empty-list">No saved encounters</div>
      {:else}
        <div class="saved-list">
          {#each appStore.savedStates as state}
            <div class="saved-row">
              <div class="saved-info">
                <span class="saved-name">{state.name}</span>
                <span class="saved-meta">{formatDate(state.saved_at)} · {state.initiative_entities.length} creatures · Round {state.current_round}</span>
              </div>
              <div class="saved-actions">
                <button class="btn-load" onclick={() => handleLoad(state.id)}>Load</button>
                <button class="btn-delete" onclick={() => handleDelete(state.id)} aria-label="Delete">
                  <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="3 6 5 6 21 6"/><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/></svg>
                </button>
              </div>
            </div>
          {/each}
        </div>
      {/if}
    </div>
  </div>
</div>

<style>
  .settings-overlay {
    position: fixed;
    inset: 0;
    background: oklch(0% 0 0 / 0.7);
    backdrop-filter: blur(4px);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 1000;
  }

  .settings-modal {
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: var(--radius-lg);
    padding: 24px;
    width: 520px;
    max-height: 80vh;
    display: flex;
    flex-direction: column;
    gap: 20px;
    box-shadow: 0 24px 48px oklch(0% 0 0 / 0.4);
  }

  .settings-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
  }

  .settings-header h2 {
    font-family: var(--font-display);
    font-size: 18px;
    font-weight: 600;
    color: var(--fg);
    margin: 0;
  }

  .close-btn {
    width: 32px;
    height: 32px;
    background: none;
    border: 1px solid var(--border);
    color: var(--muted);
    border-radius: var(--radius-sm);
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    transition: all 120ms;
  }

  .close-btn:hover {
    color: var(--fg);
    border-color: var(--gold);
  }

  .settings-section h3 {
    font-size: 12px;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.06em;
    color: var(--muted);
    margin: 0 0 8px 0;
  }

  .saved-list {
    display: flex;
    flex-direction: column;
    gap: 4px;
    max-height: 400px;
    overflow-y: auto;
    border: 1px solid var(--border);
    border-radius: var(--radius-md);
    padding: 8px;
  }

  .saved-row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 10px;
    border-radius: var(--radius-sm);
    transition: background 120ms;
  }

  .saved-row:hover {
    background: var(--surface-2);
  }

  .saved-info {
    display: flex;
    flex-direction: column;
    gap: 2px;
  }

  .saved-name {
    font-size: 13px;
    font-weight: 500;
    color: var(--fg);
  }

  .saved-meta {
    font-size: 11px;
    color: var(--muted);
  }

  .saved-actions {
    display: flex;
    gap: 6px;
    align-items: center;
  }

  .btn-load {
    height: 30px;
    padding: 0 14px;
    background: var(--gold);
    border: none;
    color: oklch(11% 0.012 250);
    font-size: 12px;
    font-weight: 600;
    border-radius: var(--radius-md);
    cursor: pointer;
    transition: opacity 120ms;
  }

  .btn-load:hover {
    opacity: 0.85;
  }

  .btn-delete {
    width: 30px;
    height: 30px;
    background: none;
    border: 1px solid var(--border);
    color: var(--muted);
    border-radius: var(--radius-sm);
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    transition: all 120ms;
  }

  .btn-delete:hover {
    color: var(--red);
    border-color: var(--red);
  }

  .empty-list {
    padding: 32px;
    text-align: center;
    color: var(--muted);
    font-size: 13px;
  }
</style>

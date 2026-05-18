<script lang="ts">
  import '../lib/styles/theme.css';
  import AppBar from '$lib/components/AppBar.svelte';
  import InitiativeStrip from '$lib/components/InitiativeStrip.svelte';
  import CharacterList from '$lib/components/CharacterList.svelte';
  import CharacterDetail from '$lib/components/CharacterDetail.svelte';
  import CreateCharacterModal from '$lib/components/CreateCharacterModal.svelte';
  import DiceRoller from '$lib/components/DiceRoller.svelte';
  import { appStore } from '$lib/stores/app.svelte';
  import type { Entity, CreateCharacterRequest } from '$lib/types';

  let initiativeHeight = $state(200);

  function startResize(event: MouseEvent) {
    event.preventDefault();
    const startY = event.clientY;
    const startHeight = initiativeHeight;

    function onMouseMove(e: MouseEvent) {
      const delta = e.clientY - startY;
      initiativeHeight = Math.max(150, Math.min(400, startHeight + delta));
    }

    function onMouseUp() {
      document.removeEventListener('mousemove', onMouseMove);
      document.removeEventListener('mouseup', onMouseUp);
    }

    document.addEventListener('mousemove', onMouseMove);
    document.addEventListener('mouseup', onMouseUp);
  }

  function toggleSettings() {
    appStore.showSettings = !appStore.showSettings;
    if (appStore.showDiceRoller) appStore.showDiceRoller = false;
  }

  function toggleDiceRoller() {
    appStore.showDiceRoller = !appStore.showDiceRoller;
    if (appStore.showSettings) appStore.showSettings = false;
  }

  function toggleCreateCharacter() {
    appStore.showCreateCharacter = !appStore.showCreateCharacter;
    if (appStore.showSettings) appStore.showSettings = false;
    if (appStore.showDiceRoller) appStore.showDiceRoller = false;
  }

  function handleDragOver(event: DragEvent) {
    event.preventDefault();
    if (event.dataTransfer) {
      event.dataTransfer.dropEffect = 'copy';
    }
  }

  function handleDrop(event: DragEvent) {
    event.preventDefault();
    const charData = event.dataTransfer?.getData('application/json');
    if (charData) {
      try {
        const char = JSON.parse(charData);
        appStore.addToInitiative(char);
      } catch (e) {
        console.error('Failed to parse dropped character:', e);
      }
    }
  }

  async function handleCreateCharacter(req: CreateCharacterRequest) {
    try {
      await appStore.createCharacter(req);
    } catch (e) {
      console.error('Failed to create character:', e);
    }
  }

  appStore.loadCharacters();
</script>

<AppBar
  onAddCharacter={toggleCreateCharacter}
  onAddCreature={toggleCreateCharacter}
  onAddNPC={toggleCreateCharacter}
  onAddOther={toggleCreateCharacter}
  onToggleDiceRoller={toggleDiceRoller}
  onToggleSettings={toggleSettings}
/>

{#if appStore.showCreateCharacter}
  <CreateCharacterModal
    onClose={toggleCreateCharacter}
    onSubmit={handleCreateCharacter}
  />
{/if}

{#if appStore.showDiceRoller}
  <DiceRoller onClose={toggleDiceRoller} />
{/if}

<main class="container">
  <div
    class="initiative-strip-wrapper"
    style="height: {initiativeHeight}px; background: var(--surface);"
    ondragover={handleDragOver}
    ondragenter={(e) => e.preventDefault()}
    ondrop={handleDrop}
  >
    <InitiativeStrip
      {initiativeHeight}
      onAddCharacter={toggleCreateCharacter}
    />
    <div class="resize-handle" onmousedown={startResize}></div>
  </div>
  <div class="bottom-pane">
    <CharacterList
      playerCharacters={appStore.playerCharacters}
      npcs={appStore.npcs}
      monsters={appStore.monsters}
      selectedCharacter={appStore.selectedCharacter}
      totalCount={appStore.playerCharacters.length + appStore.monsters.length + appStore.npcs.length}
      onSelect={appStore.selectCharacter}
      onAddCharacter={toggleCreateCharacter}
    />
    <div class="details-view">
      {#if !appStore.selectedCharacter}
        <div class="detail-empty">
          <div class="detail-empty-icon">📋</div>
          <span>Select a character to view their details</span>
        </div>
      {:else}
        <CharacterDetail
          character={appStore.selectedCharacter}
          skills={appStore.characterSkills}
          onHpChange={(delta) => appStore.updateInitiativeHp(appStore.selectedCharacter!.id, delta)}
        />
      {/if}
    </div>
  </div>
</main>

<style>
  .container {
    height: 100vh;
    width: 100vw;
    display: flex;
    flex-direction: column;
    overflow: hidden;
  }

  .initiative-strip-wrapper {
    flex-shrink: 0;
    position: relative;
    min-height: 180px;
    width: 100%;
    overflow: visible;
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
    z-index: 10;
  }

  .resize-handle:hover {
    background: linear-gradient(transparent, var(--gold));
  }

  .bottom-pane {
    flex: 1;
    display: flex;
    min-height: 0;
    overflow: hidden;
  }

  .details-view {
    flex: 1;
    background: var(--bg);
    overflow-y: auto;
    display: flex;
    flex-direction: column;
  }

  .detail-empty {
    flex: 1;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 12px;
    color: var(--muted);
  }

  .detail-empty-icon {
    font-size: 48px;
    opacity: 0.2;
  }
</style>
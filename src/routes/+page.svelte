<script lang="ts">
  import '../lib/styles/theme.css';
  import AppBar from '$lib/components/AppBar.svelte';
  import InitiativeStrip from '$lib/components/InitiativeStrip.svelte';
  import CharacterList from '$lib/components/CharacterList.svelte';
  import CharacterDetail from '$lib/components/CharacterDetail.svelte';
  import CreateCharacterModal from '$lib/components/CreateCharacterModal.svelte';
  import DiceRoller from '$lib/components/DiceRoller.svelte';
  import CharacterBook from '$lib/components/CharacterBook.svelte';
  import EncounterBuilder from '$lib/components/EncounterBuilder.svelte';
  import SettingsPanel from '$lib/components/SettingsPanel.svelte';
  import CharacterModal from '$lib/components/CharacterModal.svelte';
  import { appStore } from '$lib/stores/app.svelte';
  import type { Entity, CreateCharacterRequest } from '$lib/types';

  let initiativeHeight = $state(230);

  function toggleSettings() {
    appStore.showSettings = !appStore.showSettings;
    if (appStore.showDiceRoller) appStore.showDiceRoller = false;
  }

  function toggleDiceRoller() {
    appStore.showDiceRoller = !appStore.showDiceRoller;
    if (appStore.showSettings) appStore.showSettings = false;
    if (appStore.showBook) appStore.showBook = false;
  }

  function toggleBook() {
    appStore.showBook = !appStore.showBook;
    if (appStore.showSettings) appStore.showSettings = false;
    if (appStore.showDiceRoller) appStore.showDiceRoller = false;
  }

  function toggleCreateCharacter() {
    appStore.showCreateCharacter = !appStore.showCreateCharacter;
    if (appStore.showSettings) appStore.showSettings = false;
    if (appStore.showDiceRoller) appStore.showDiceRoller = false;
  }

  function toggleEncounterBuilder() {
    appStore.showEncounterBuilder = !appStore.showEncounterBuilder;
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

  function handleInitiativeDoubleClick(instanceId: string) {
    const initEntity = appStore.initiativeList.find(e => e.instance_id === instanceId);
    if (!initEntity) return;
    const entity = appStore.playerCharacters.find(e => e.id === initEntity.id)
      ?? appStore.npcs.find(e => e.id === initEntity.id)
      ?? appStore.creatures.find(e => e.id === initEntity.id);
    if (entity) appStore.openCharacterModal(entity, instanceId);
  }

  appStore.loadCharacters();
  appStore.loadEncounters();
</script>

<AppBar
  onAddCharacter={toggleCreateCharacter}
  onAddCreature={toggleCreateCharacter}
  onAddNPC={toggleCreateCharacter}
  onAddOther={toggleCreateCharacter}
  onToggleDiceRoller={toggleDiceRoller}
  onToggleBook={toggleBook}
  onToggleSettings={toggleSettings}
  onAddEncounter={toggleEncounterBuilder}
  onLongRest={appStore.longRest}
/>

{#if appStore.showCreateCharacter}
  <CreateCharacterModal
    onClose={toggleCreateCharacter}
    onSubmit={handleCreateCharacter}
  />
{/if}

{#if appStore.showEncounterBuilder}
  <EncounterBuilder onClose={toggleEncounterBuilder} />
{/if}

{#if appStore.showSettings}
  <SettingsPanel onClose={toggleSettings} />
{/if}

{#if appStore.showDiceRoller}
  <DiceRoller onClose={toggleDiceRoller} />
{/if}

{#if appStore.showBook}
  <CharacterBook onClose={toggleBook} />
{/if}

  {#if appStore.showCharacterModal && appStore.modalCharacter}
  <CharacterModal
    character={appStore.modalCharacter}
    skills={appStore.characterSkills}
    spells={appStore.characterSpells}
    onClose={appStore.closeCharacterModal}
  />
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
      onEntityDoubleClick={handleInitiativeDoubleClick}
    />
  </div>
  <div class="bottom-pane">
    <CharacterList
      playerCharacters={appStore.playerCharacters}
      npcs={appStore.npcs}
      creatures={appStore.creatures}
      selectedCharacter={appStore.selectedCharacter}
      totalCount={appStore.playerCharacters.length + appStore.creatures.length + appStore.npcs.length}
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
          spells={appStore.characterSpells}
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
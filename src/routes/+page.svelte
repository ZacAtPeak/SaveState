<script lang="ts">
  import { invoke } from '@tauri-apps/api/core';

  let initiativeHeight = $state(33.33);

  let expandedSections = $state({
    characters: false,
    monsters: false,
    npcs: false,
    other: false
  });

  interface PlayerCharacter {
    id: string;
    name: string;
    entity_type: string;
    class: string;
    level: number;
    race: string;
    player_name: string | null;
    armor_class: number;
    hit_points_max: number;
    hit_points_current: number;
    strength: number;
    dexterity: number;
    constitution: number;
    intelligence: number;
    wisdom: number;
    charisma: number;
  }

  interface InitiativeEntity {
    id: string;
    name: string;
    initiative: number;
    armor_class: number;
    hit_points_current: number;
    hit_points_max: number;
  }

  let playerCharacters = $state<PlayerCharacter[]>([]);
  let loading = $state(true);
  let selectedCharacter = $state<PlayerCharacter | null>(null);
  let initiativeList = $state<InitiativeEntity[]>([]);

  async function loadCharacters() {
    try {
      loading = true;
      playerCharacters = await invoke<PlayerCharacter[]>('get_player_characters');
      expandedSections.characters = true;
    } catch (e) {
      console.error('Failed to load characters:', e);
    } finally {
      loading = false;
    }
  }

  loadCharacters();

  function startResize(event: MouseEvent) {
    event.preventDefault();
    const startY = event.clientY;
    const startHeight = initiativeHeight;
    const containerHeight = window.innerHeight;

    function onMouseMove(e: MouseEvent) {
      const delta = e.clientY - startY;
      const deltaPercent = (delta / containerHeight) * 100;
      initiativeHeight = Math.max(10, Math.min(90, startHeight + deltaPercent));
    }

    function onMouseUp() {
      document.removeEventListener('mousemove', onMouseMove);
      document.removeEventListener('mouseup', onMouseUp);
    }

    document.addEventListener('mousemove', onMouseMove);
    document.addEventListener('mouseup', onMouseUp);
  }

  function toggleSection(section: keyof typeof expandedSections) {
    expandedSections[section] = !expandedSections[section];
  }

  function selectCharacter(char: PlayerCharacter) {
    selectedCharacter = char;
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
        const char: PlayerCharacter = JSON.parse(charData);
        const dexMod = Math.floor((char.dexterity - 10) / 2);
        const initiative = Math.floor(Math.random() * 20) + 1 + dexMod;
        const newEntity: InitiativeEntity = {
          id: char.id,
          name: char.name,
          initiative,
          armor_class: char.armor_class,
          hit_points_current: char.hit_points_current,
          hit_points_max: char.hit_points_max
        };
        initiativeList = [...initiativeList, newEntity].sort((a, b) => b.initiative - a.initiative);
      } catch (e) {
        console.error('Failed to parse dropped character:', e);
      }
    }
  }

  function onDragStart(event: DragEvent, char: PlayerCharacter) {
    if (event.dataTransfer) {
      event.dataTransfer.setData('application/json', JSON.stringify(char));
      event.dataTransfer.effectAllowed = 'copy';
    }
  }
</script>

<main class="container">
  <div
    class="initiative-strip"
    style="height: {initiativeHeight}%;"
    ondragover={handleDragOver}
    ondrop={handleDrop}
  >
    {#if initiativeList.length === 0}
      <h1>Initiative Strip</h1>
      <p class="drag-hint">Drag characters here to add to initiative</p>
    {:else}
      <div class="initiative-list">
        {#each initiativeList as entity}
          <div class="initiative-card">
            <span class="initiative-value">{entity.initiative}</span>
            <span class="initiative-name">{entity.name}</span>
            <span class="initiative-hp">{entity.hit_points_current}/{entity.hit_points_max}</span>
          </div>
        {/each}
      </div>
    {/if}
    <div class="resize-handle" onmousedown={startResize}></div>
  </div>
  <div class="bottom-pane">
    <div class="sidebar">
      <div class="collapsible-section">
        <button class="section-header" onclick={() => toggleSection('characters')}>
          <span>Characters</span>
          <span class="chevron">{expandedSections.characters ? '▼' : '▶'}</span>
        </button>
        {#if expandedSections.characters}
          <div class="section-content">
            {#if loading}
              <p class="loading">Loading characters...</p>
            {:else if playerCharacters.length === 0}
              <p class="empty">No characters found</p>
            {:else}
              <ul class="character-list">
                {#each playerCharacters as char}
                  <li>
                    <button
                      class="character-item"
                      class:selected={selectedCharacter?.id === char.id}
                      onclick={() => selectCharacter(char)}
                      draggable="true"
                      ondragstart={(e) => onDragStart(e, char)}
                    >
                      <span class="char-name">{char.name}</span>
                      <span class="char-info">{char.race} {char.class} Lvl {char.level}</span>
                    </button>
                  </li>
                {/each}
              </ul>
            {/if}
          </div>
        {/if}
      </div>
      <div class="collapsible-section">
        <button class="section-header" onclick={() => toggleSection('monsters')}>
          <span>Monsters</span>
          <span class="chevron">{expandedSections.monsters ? '▼' : '▶'}</span>
        </button>
        {#if expandedSections.monsters}
          <div class="section-content">Monsters content</div>
        {/if}
      </div>
      <div class="collapsible-section">
        <button class="section-header" onclick={() => toggleSection('npcs')}>
          <span>NPCs</span>
          <span class="chevron">{expandedSections.npcs ? '▼' : '▶'}</span>
        </button>
        {#if expandedSections.npcs}
          <div class="section-content">NPCs content</div>
        {/if}
      </div>
      <div class="collapsible-section">
        <button class="section-header" onclick={() => toggleSection('other')}>
          <span>Other</span>
          <span class="chevron">{expandedSections.other ? '▼' : '▶'}</span>
        </button>
        {#if expandedSections.other}
          <div class="section-content">Other content</div>
        {/if}
      </div>
    </div>
    <div class="details-view">
      <h2>Details</h2>
      {#if selectedCharacter}
        <div class="character-details">
          <h3>{selectedCharacter.name}</h3>
          <p class="subtitle">{selectedCharacter.race} {selectedCharacter.class} - Level {selectedCharacter.level}</p>
          {#if selectedCharacter.player_name}
            <p class="player-name">Player: {selectedCharacter.player_name}</p>
          {/if}

          <div class="stats-grid">
            <div class="stat-row">
              <span class="stat-label">AC</span>
              <span class="stat-value">{selectedCharacter.armor_class}</span>
            </div>
            <div class="stat-row">
              <span class="stat-label">HP</span>
              <span class="stat-value">{selectedCharacter.hit_points_current} / {selectedCharacter.hit_points_max}</span>
            </div>
          </div>

          <h4>Ability Scores</h4>
          <div class="ability-grid">
            <div class="ability">
              <span class="ability-name">STR</span>
              <span class="ability-score">{selectedCharacter.strength}</span>
            </div>
            <div class="ability">
              <span class="ability-name">DEX</span>
              <span class="ability-score">{selectedCharacter.dexterity}</span>
            </div>
            <div class="ability">
              <span class="ability-name">CON</span>
              <span class="ability-score">{selectedCharacter.constitution}</span>
            </div>
            <div class="ability">
              <span class="ability-name">INT</span>
              <span class="ability-score">{selectedCharacter.intelligence}</span>
            </div>
            <div class="ability">
              <span class="ability-name">WIS</span>
              <span class="ability-score">{selectedCharacter.wisdom}</span>
            </div>
            <div class="ability">
              <span class="ability-name">CHA</span>
              <span class="ability-score">{selectedCharacter.charisma}</span>
            </div>
          </div>
        </div>
      {:else}
        <p>Select an item to view details</p>
      {/if}
    </div>
  </div>
</main>

<style>
:root {
  font-family: Inter, Avenir, Helvetica, Arial, sans-serif;
  font-size: 16px;
  line-height: 24px;
  font-weight: 400;
  color: #0f0f0f;
  background-color: #f6f6f6;
  font-synthesis: none;
  text-rendering: optimizeLegibility;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  -webkit-text-size-adjust: 100%;
}

@media (prefers-color-scheme: dark) {
  :root {
    color: #f6f6f6;
    background-color: #2f2f2f;
  }
}

.container {
  margin: 0;
  padding: 0;
  height: 100vh;
  width: 100vw;
  display: flex;
  flex-direction: column;
}

.initiative-strip {
  min-height: 200px;
  width: 100%;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  text-align: center;
  background-color: #2f2f2f;
  color: #f6f6f6;
  border-bottom: 3px solid #555;
  position: relative;
}

.resize-handle {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  height: 8px;
  cursor: ns-resize;
  background: linear-gradient(transparent, rgba(255,255,255,0.1));
}

.resize-handle:hover {
  background: linear-gradient(transparent, rgba(255,255,255,0.3));
}

.initiative-strip h1 {
  margin: 0;
}

.bottom-pane {
  flex: 1;
  display: flex;
  flex-direction: row;
  min-height: 0;
  overflow: hidden;
}

.sidebar {
  width: 33.33%;
  min-width: 200px;
  background-color: #f6f6f6;
  border-right: 1px solid #ccc;
  overflow-y: auto;
  flex-shrink: 0;
}

@media (prefers-color-scheme: dark) {
  .sidebar {
    background-color: #1a1a1a;
    border-color: #444;
  }
}

.details-view {
  flex: 1;
  background-color: #e8e8e8;
  padding: 20px;
  overflow-y: auto;
}

@media (prefers-color-scheme: dark) {
  .details-view {
    background-color: #252525;
  }
}

.details-view h2 {
  margin-top: 0;
}

.collapsible-section {
  border-bottom: 1px solid #ddd;
}

@media (prefers-color-scheme: dark) {
  .collapsible-section {
    border-color: #444;
  }
}

.section-header {
  width: 100%;
  padding: 12px 16px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: none;
  border: none;
  cursor: pointer;
  font-size: 16px;
  font-weight: 600;
  color: inherit;
  text-align: left;
}

.section-header:hover {
  background-color: rgba(0,0,0,0.05);
}

@media (prefers-color-scheme: dark) {
  .section-header:hover {
    background-color: rgba(255,255,255,0.05);
  }
}

.chevron {
  font-size: 12px;
}

.section-content {
  padding: 12px 16px;
  background-color: rgba(0,0,0,0.03);
}

@media (prefers-color-scheme: dark) {
  .section-content {
    background-color: rgba(255,255,255,0.03);
  }
}

.loading, .empty {
  color: #666;
  font-style: italic;
}

@media (prefers-color-scheme: dark) {
  .loading, .empty {
    color: #999;
  }
}

.character-list {
  list-style: none;
  padding: 0;
  margin: 0;
}

.character-item {
  width: 100%;
  padding: 8px 12px;
  background: none;
  border: none;
  text-align: left;
  cursor: pointer;
  border-radius: 4px;
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.character-item:hover {
  background-color: rgba(0,0,0,0.05);
}

@media (prefers-color-scheme: dark) {
  .character-item:hover {
    background-color: rgba(255,255,255,0.05);
  }
}

.character-item.selected {
  background-color: rgba(0,0,0,0.1);
}

@media (prefers-color-scheme: dark) {
  .character-item.selected {
    background-color: rgba(255,255,255,0.1);
  }
}

.char-name {
  font-weight: 600;
  color: inherit;
}

.char-info {
  font-size: 12px;
  color: #666;
}

@media (prefers-color-scheme: dark) {
  .char-info {
    color: #999;
  }
}

.character-details {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.character-details h3 {
  margin: 0;
  font-size: 24px;
}

.subtitle {
  margin: 0;
  color: #666;
}

@media (prefers-color-scheme: dark) {
  .subtitle {
    color: #999;
  }
}

.player-name {
  margin: 0;
  color: #888;
  font-style: italic;
}

.stats-grid {
  display: flex;
  gap: 24px;
}

.stat-row {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.stat-label {
  font-size: 12px;
  color: #888;
  text-transform: uppercase;
}

.stat-value {
  font-size: 18px;
  font-weight: 600;
}

.character-details h4 {
  margin: 8px 0;
  font-size: 14px;
  text-transform: uppercase;
  color: #888;
}

.ability-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 12px;
}

.ability {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 8px;
  background-color: rgba(0,0,0,0.03);
  border-radius: 4px;
}

@media (prefers-color-scheme: dark) {
  .ability {
    background-color: rgba(255,255,255,0.05);
  }
}

.ability-name {
  font-size: 12px;
  color: #888;
}

.ability-score {
  font-size: 20px;
  font-weight: 700;
}
</style>

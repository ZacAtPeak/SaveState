<script lang="ts">
  import { invoke } from '@tauri-apps/api/core';

  let initiativeHeight = $state(33.33);

  let expandedSections = $state({
    characters: false,
    monsters: false,
    npcs: false,
    other: false
  });

  interface Entity {
    id: string;
    name: string;
    entity_type: string;
    armor_class: number;
    hit_points_max: number;
    hit_points_current: number;
    strength: number;
    dexterity: number;
    constitution: number;
    intelligence: number;
    wisdom: number;
    charisma: number;
    race?: string;
    class?: string;
    level?: number;
    player_name?: string | null;
    proficiency_bonus?: number;
    challenge_rating?: string;
  }

  interface PlayerCharacter extends Entity {
    race: string;
    class: string;
    level: number;
    player_name: string | null;
    proficiency_bonus: number;
  }

  interface InitiativeEntity {
    id: string;
    name: string;
    initiative: number;
    armor_class: number;
    hit_points_current: number;
    hit_points_max: number;
  }

  interface CharacterSkill {
    skill_id: string;
    skill_name: string;
    associated_ability: string;
    ability_score: number;
    is_proficient: boolean;
    is_expert: boolean;
    proficiency_bonus: number;
    total_modifier: number;
  }

  let playerCharacters = $state<PlayerCharacter[]>([]);
  let loading = $state(true);
  let monsters = $state<Entity[]>([]);
  let npcs = $state<Entity[]>([]);
  let selectedCharacter = $state<Entity | null>(null);
  let characterSkills = $state<CharacterSkill[]>([]);
  let initiativeList = $state<InitiativeEntity[]>([]);

  async function loadCharacters() {
    try {
      loading = true;
      playerCharacters = await invoke<PlayerCharacter[]>('get_player_characters');
      monsters = await invoke<any[]>('get_monsters');
      npcs = await invoke<any[]>('get_npcs');
      expandedSections.characters = true;
      expandedSections.monsters = true;
      expandedSections.npcs = true;
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

  function selectCharacter(char: Entity) {
    selectedCharacter = char;
    if (char.proficiency_bonus) {
      loadCharacterSkills(char.id, char.proficiency_bonus);
    }
  }

  async function loadCharacterSkills(entityId: string, proficiencyBonus: number) {
    try {
      characterSkills = await invoke<CharacterSkill[]>('get_character_skills', {
        entityId,
        proficiencyBonus
      });
    } catch (e) {
      console.error('Failed to load character skills:', e);
    }
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
        const char: Entity = JSON.parse(charData);
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

  function onDragStart(event: DragEvent, char: Entity) {
    if (event.dataTransfer) {
      event.dataTransfer.setData('application/json', JSON.stringify(char));
      event.dataTransfer.effectAllowed = 'copy';
    }
  }

  let showSettings = $state(false);
  let showDiceRoller = $state(false);
  let showCreateCharacter = $state(false);

  let newChar = $state({
    name: '',
    class: '',
    level: 1,
    race: '',
    player_name: '',
    armor_class: 10,
    hit_points_max: 10,
    hit_points_current: 10,
    strength: 10,
    dexterity: 10,
    constitution: 10,
    intelligence: 10,
    wisdom: 10,
    charisma: 10
  });

  function toggleSettings() {
    showSettings = !showSettings;
    if (showDiceRoller) showDiceRoller = false;
  }

  function toggleDiceRoller() {
    showDiceRoller = !showDiceRoller;
    if (showSettings) showSettings = false;
  }

  function toggleCreateCharacter() {
    showCreateCharacter = !showCreateCharacter;
    if (showSettings) showSettings = false;
    if (showDiceRoller) showDiceRoller = false;
  }

  async function handleCreateCharacter() {
    try {
      const created = await invoke<PlayerCharacter>('create_player_character', {
        req: {
          name: newChar.name,
          class: newChar.class,
          level: newChar.level,
          race: newChar.race,
          player_name: newChar.player_name || null,
          armor_class: newChar.armor_class,
          hit_points_max: newChar.hit_points_max,
          hit_points_current: newChar.hit_points_current,
          strength: newChar.strength,
          dexterity: newChar.dexterity,
          constitution: newChar.constitution,
          intelligence: newChar.intelligence,
          wisdom: newChar.wisdom,
          charisma: newChar.charisma
        }
      });
      playerCharacters = [...playerCharacters, created];
      showCreateCharacter = false;
      newChar = {
        name: '', class: '', level: 1, race: '', player_name: '',
        armor_class: 10, hit_points_max: 10, hit_points_current: 10,
        strength: 10, dexterity: 10, constitution: 10,
        intelligence: 10, wisdom: 10, charisma: 10
      };
    } catch (e) {
      console.error('Failed to create character:', e);
    }
  }
</script>

<div class="app-bar">
  <div class="app-bar-spacer"></div>
  <div class="app-bar-actions">
    <button class="app-bar-btn" onclick={toggleCreateCharacter} aria-label="Add">
      +
    </button>
    <button class="app-bar-btn" onclick={toggleDiceRoller} aria-label="Dice Roller">
      🎲
    </button>
    <button class="app-bar-btn" onclick={toggleSettings} aria-label="Settings">
      ⚙️
    </button>
  </div>
</div>

{#if showCreateCharacter}
<div class="modal-overlay" onclick={toggleCreateCharacter}>
  <div class="modal" onclick={(e) => e.stopPropagation()}>
    <h2>Create New Character</h2>
    <div class="form-grid">
      <label>
        Name
        <input type="text" bind:value={newChar.name} />
      </label>
      <label>
        Class
        <input type="text" bind:value={newChar.class} />
      </label>
      <label>
        Level
        <input type="number" bind:value={newChar.level} min="1" max="20" />
      </label>
      <label>
        Race
        <input type="text" bind:value={newChar.race} />
      </label>
      <label>
        Player Name
        <input type="text" bind:value={newChar.player_name} />
      </label>
      <label>
        Armor Class
        <input type="number" bind:value={newChar.armor_class} min="1" />
      </label>
      <label>
        Max HP
        <input type="number" bind:value={newChar.hit_points_max} min="1" />
      </label>
      <label>
        Current HP
        <input type="number" bind:value={newChar.hit_points_current} min="0" />
      </label>
    </div>
    <h3>Ability Scores</h3>
    <div class="form-grid">
      <label>
        Strength
        <input type="number" bind:value={newChar.strength} min="1" max="30" />
      </label>
      <label>
        Dexterity
        <input type="number" bind:value={newChar.dexterity} min="1" max="30" />
      </label>
      <label>
        Constitution
        <input type="number" bind:value={newChar.constitution} min="1" max="30" />
      </label>
      <label>
        Intelligence
        <input type="number" bind:value={newChar.intelligence} min="1" max="30" />
      </label>
      <label>
        Wisdom
        <input type="number" bind:value={newChar.wisdom} min="1" max="30" />
      </label>
      <label>
        Charisma
        <input type="number" bind:value={newChar.charisma} min="1" max="30" />
      </label>
    </div>
    <div class="modal-actions">
      <button class="btn-secondary" onclick={toggleCreateCharacter}>Cancel</button>
      <button class="btn-primary" onclick={handleCreateCharacter}>Create</button>
    </div>
  </div>
</div>
{/if}

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
            <span class="initiative-ac">AC {entity.armor_class}</span>
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
                      <span class="char-info">{char.race} {char.class}</span>
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
          <div class="section-content">
            <p>Loading: {monsters.length} monsters</p>
            {#if monsters.length === 0}
              <p class="empty">No monsters found</p>
            {:else}
              <ul class="character-list">
                {#each monsters as mon}
                  <li>
                    <button
                      class="character-item"
                      onclick={() => selectCharacter(mon)}
                      draggable="true"
                      ondragstart={(e) => onDragStart(e, mon)}
                    >
                      <span class="char-name">{mon.name}</span>
                      <span class="char-info">CR {mon.challenge_rating}</span>
                    </button>
                  </li>
                {/each}
              </ul>
            {/if}
          </div>
        {/if}
      </div>
      <div class="collapsible-section">
        <button class="section-header" onclick={() => toggleSection('npcs')}>
          <span>NPCs</span>
          <span class="chevron">{expandedSections.npcs ? '▼' : '▶'}</span>
        </button>
        {#if expandedSections.npcs}
          <div class="section-content">
            <p>Loading: {npcs.length} NPCs</p>
            {#if npcs.length === 0}
              <p class="empty">No NPCs found</p>
            {:else}
              <ul class="character-list">
                {#each npcs as npc}
                  <li>
                    <button
                      class="character-item"
                      onclick={() => selectCharacter(npc)}
                      draggable="true"
                      ondragstart={(e) => onDragStart(e, npc)}
                    >
                      <span class="char-name">{npc.name}</span>
                      <span class="char-info">NPC</span>
                    </button>
                  </li>
                {/each}
              </ul>
            {/if}
          </div>
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
          <p class="subtitle">{selectedCharacter.entity_type === 'pc' ? `${selectedCharacter.race} - ${selectedCharacter.class}` : selectedCharacter.entity_type}</p>
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
            {#if selectedCharacter.challenge_rating !== undefined}
              <div class="stat-row">
                <span class="stat-label">CR</span>
                <span class="stat-value">{selectedCharacter.challenge_rating}</span>
              </div>
            {/if}
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

          <h4>Skills</h4>
          <div class="skills-grid">
            {#each characterSkills as skill}
              <div class="skill">
                <span class="skill-name">{skill.skill_name}</span>
                <span class="skill-ability">({skill.associated_ability.substring(0, 3).toUpperCase()})</span>
                <span class="skill-modifier">{skill.total_modifier >= 0 ? '+' : ''}{skill.total_modifier}</span>
                {#if skill.is_expert}
                  <span class="skill-badge expert">Expert</span>
                {:else if skill.is_proficient}
                  <span class="skill-badge proficient">Proficient</span>
                {/if}
              </div>
            {/each}
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
  background-color: #2f2f2f;
  color: #f6f6f6;
  border-bottom: 3px solid #555;
  position: relative;
  overflow-y: auto;
}

.drag-hint {
  color: #888;
  font-style: italic;
  margin: 0;
}

.initiative-list {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  padding: 16px;
  justify-content: center;
}

.initiative-card {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
  padding: 12px 8px;
  background-color: #3a3a3a;
  border-radius: 8px;
  border: 2px solid #555;
  width: 70px;
  height: 100px;
}

.initiative-value {
  font-weight: bold;
  font-size: 20px;
  color: #ffd700;
}

.initiative-name {
  font-weight: 600;
  font-size: 11px;
  text-align: center;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  width: 100%;
}

.initiative-hp {
  font-size: 12px;
  color: #aaa;
}

.initiative-ac {
  font-size: 11px;
  color: #88aaff;
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

.app-bar {
  display: flex;
  align-items: center;
  padding: 12px 20px;
  background-color: #1a1a1a;
  color: #f6f6f6;
  border-bottom: 2px solid #333;
}

.app-bar-spacer {
  flex: 1;
}

.app-title {
  margin: 0;
  font-size: 20px;
  font-weight: 700;
}

.app-bar-actions {
  display: flex;
  gap: 8px;
}

.app-bar-btn {
  background: none;
  border: none;
  font-size: 20px;
  cursor: pointer;
  padding: 8px;
  border-radius: 4px;
}

.app-bar-btn:hover {
    background-color: rgba(255,255,255,0.1);
  }

  .modal-overlay {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(0,0,0,0.6);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 1000;
  }

  .modal {
    background: #f6f6f6;
    border-radius: 8px;
    padding: 24px;
    max-width: 500px;
    width: 90%;
    max-height: 90vh;
    overflow-y: auto;
  }

  @media (prefers-color-scheme: dark) {
    .modal {
      background: #2f2f2f;
      color: #f6f6f6;
    }
  }

  .modal h2 {
    margin-top: 0;
  }

  .modal h3 {
    margin-top: 20px;
    margin-bottom: 12px;
  }

  .form-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 12px;
  }

  .form-grid label {
    display: flex;
    flex-direction: column;
    gap: 4px;
    font-size: 14px;
  }

  .form-grid input {
    padding: 8px;
    border: 1px solid #ccc;
    border-radius: 4px;
    font-size: 14px;
  }

  @media (prefers-color-scheme: dark) {
    .form-grid input {
      background: #1a1a1a;
      border-color: #555;
      color: #f6f6f6;
    }
  }

  .modal-actions {
    display: flex;
    justify-content: flex-end;
    gap: 12px;
    margin-top: 24px;
  }

  .btn-primary, .btn-secondary {
    padding: 10px 20px;
    border-radius: 4px;
    cursor: pointer;
    font-size: 14px;
  }

  .btn-primary {
    background: #4a7c4a;
    color: white;
    border: none;
  }

  .btn-primary:hover {
    background: #3a6c3a;
  }

  .btn-secondary {
    background: transparent;
    border: 1px solid #ccc;
    color: inherit;
  }

  .btn-secondary:hover {
    background: rgba(0,0,0,0.05);
  }

  @media (prefers-color-scheme: dark) {
    .btn-secondary {
      border-color: #555;
    }
    .btn-secondary:hover {
      background: rgba(255,255,255,0.05);
    }
  }

.skills-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(140px, 1fr));
  gap: 8px;
  margin-top: 8px;
}

.skill {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 4px;
  padding: 6px 8px;
  background-color: rgba(255,255,255,0.03);
  border-radius: 4px;
}

.skill-name {
  font-size: 12px;
  font-weight: 600;
}

.skill-ability {
  font-size: 10px;
  color: #888;
}

.skill-modifier {
  font-size: 14px;
  font-weight: 700;
  margin-left: auto;
}

.skill-badge {
  font-size: 9px;
  padding: 2px 4px;
  border-radius: 3px;
  font-weight: 600;
  text-transform: uppercase;
}

.skill-badge.proficient {
  background-color: #4a7c4a;
  color: #fff;
}

.skill-badge.expert {
  background-color: #7c6c4a;
  color: #fff;
}

@media (prefers-color-scheme: dark) {
  .skill {
    background-color: rgba(255,255,255,0.05);
  }
}
</style>

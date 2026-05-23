<script lang="ts">
  import { onMount } from 'svelte';
  import { appStore } from '$lib/stores/app.svelte';
  import type { CreateCharacterRequest, StatRollMethod, DndClass, Race, Background, Subclass, Subrace } from '$lib/types';
  import StatRoller from './StatRoller.svelte';
  import SkillPicker from './SkillPicker.svelte';
  import SavePicker from './SavePicker.svelte';

  const ABILITY_KEYS = ['strength', 'dexterity', 'constitution', 'intelligence', 'wisdom', 'charisma'] as const;

  const ALIGNMENTS = [
    ['Lawful Good', 'Neutral Good', 'Chaotic Good'],
    ['Lawful Neutral', 'Neutral', 'Chaotic Neutral'],
    ['Lawful Evil', 'Neutral Evil', 'Chaotic Evil'],
    ['Unaligned'],
  ];

  const CLASS_HIT_DIE: Record<string, number> = {
    artificer: 8, barbarian: 12, bard: 8, cleric: 8,
    druid: 8, fighter: 10, monk: 8, paladin: 10,
    ranger: 10, rogue: 8, sorcerer: 6, warlock: 8, wizard: 6,
  };

  const CLASS_SAVES_MAP: Record<string, string[]> = {
    barbarian: ['STR', 'CON'], bard: ['DEX', 'CHA'], cleric: ['WIS', 'CHA'],
    druid: ['INT', 'WIS'], fighter: ['STR', 'CON'], monk: ['STR', 'DEX'],
    paladin: ['WIS', 'CHA'], ranger: ['STR', 'DEX'], rogue: ['DEX', 'INT'],
    sorcerer: ['CON', 'CHA'], warlock: ['WIS', 'CHA'], wizard: ['INT', 'WIS'],
    artificer: ['CON', 'INT'],
  };

  interface Props {
    onClose: () => void;
    onSubmit: (req: CreateCharacterRequest) => void;
  }

  let { onClose, onSubmit }: Props = $props();

  // Basic fields
  let charName = $state('');
  let playerName = $state('');

  // Reference data
  let classes: DndClass[] = $state([]);
  let classSubclasses: Subclass[] = $state([]);
  let racesList: Race[] = $state([]);
  let raceSubraces: Subrace[] = $state([]);
  let backgroundsList: Background[] = $state([]);

  // Selections
  let selectedClassId = $state<string>('');
  let selectedSubclassId = $state<string>('');
  let selectedRaceId = $state<string>('');
  let selectedSubraceId = $state<string>('');
  let selectedBackgroundId = $state<string>('');
  let selectedAlignment = $state<string>('');
  let charLevel = $state<number>(1);

  // Stats
  let statRollMethod: StatRollMethod = $state('standard_array');
  let rawScores: number[] = $state([15, 14, 13, 12, 10, 8]);

  // Proficiencies
  let selectedSkillIds: string[] = $state([]);
  let selectedSaveIds: string[] = $state([]);

  // Derived calculations
  let selectedClass = $derived(classes.find(c => c.id === selectedClassId));
  let selectedRace = $derived(racesList.find(r => r.id === selectedRaceId));
  let selectedBackground = $derived(backgroundsList.find(b => b.id === selectedBackgroundId));

  let hitDieMax = $derived(selectedClass ? CLASS_HIT_DIE[selectedClass.id] || 8 : 8);
  let conMod = $derived(Math.floor((rawScores[2] - 10) / 2));
  let minHP = $derived(hitDieMax + conMod);
  let proficiencyBonus = $derived(Math.floor((charLevel - 1) / 4) + 2);
  let speed = $derived(selectedRace?.speed_walk ?? 30);

  // Auto-calculated AC (unarmored default or from class)
  let autoAC = $derived(10 + Math.floor((rawScores[1] - 10) / 2));

  // Validation state
  let validationErrors = $state<string[]>([]);
  let validationWarnings = $state<string[]>([]);
  let validationDebounceTimer: ReturnType<typeof setTimeout> | null = null;

  // Load reference data on mount
  onMount(() => {
    loadReferenceData();
  });

  async function loadReferenceData() {
    try {
      const [c, r, b] = await Promise.all([
        appStore.loadClasses(),
        appStore.loadRaces(),
        appStore.loadBackgrounds(),
      ]);
      classes = c || [];
      racesList = r || [];
      backgroundsList = b || [];

      // Preload subclasses for any class subclasses loaded
      if (appStore.subclasses.length > 0) {
        classSubclasses = appStore.subclasses;
      }
    } catch (e) {
      console.error('Failed to load reference data:', e);
    }
  }

  // When class changes, load subclasses
  async function onClassChange() {
    if (selectedClassId) {
      await appStore.loadSubclasses(selectedClassId);
      classSubclasses = appStore.subclasses;
    } else {
      classSubclasses = [];
    }
    selectedSubclassId = '';
    triggerValidation();
  }

  // When race changes, load subraces
  async function onRaceChange() {
    if (selectedRaceId) {
      await appStore.loadSubraces(selectedRaceId);
      raceSubraces = appStore.subraces;
    } else {
      raceSubraces = [];
    }
    selectedSubraceId = '';
    triggerValidation();
  }

  // Stats change handler from StatRoller
  function onStatsChange(newScores: number[], method: StatRollMethod) {
    rawScores = newScores;
    statRollMethod = method;
    triggerValidation();
  }

  // Skills change handler from SkillPicker
  function onSkillsChange(skills: string[]) {
    selectedSkillIds = skills;
    triggerValidation();
  }

  // Saves change handler from SavePicker
  function onSavesChange(saves: string[]) {
    selectedSaveIds = saves;
    triggerValidation();
  }

  // Debounced validation
  function triggerValidation() {
    if (validationDebounceTimer) clearTimeout(validationDebounceTimer);
    validationDebounceTimer = setTimeout(async () => {
      const errors: string[] = [];
      const warnings: string[] = [];

      if (!charName.trim()) errors.push('Character name is required');
      if (!selectedClassId) errors.push('Class is required');
      if (!selectedRaceId) errors.push('Race is required');

      // Run backend validation for stats
      try {
        const result = await appStore.validateStats(
          statRollMethod,
          rawScores,
          selectedClassId ? [selectedClassId] : [],
          selectedSubclassId || null,
          selectedSkillIds.length
        );
        if (result) {
          errors.push(...result.errors);
          warnings.push(...result.warnings);
        }
      } catch {
        // Backend validation unavailable, use basic checks
        if (statRollMethod === 'standard_array') {
          const sorted = [...rawScores].sort((a, b) => a - b);
          const expected = [8, 10, 12, 13, 14, 15];
          if (JSON.stringify(sorted) !== JSON.stringify(expected)) {
            errors.push('Standard Array scores must be exactly 15, 14, 13, 12, 10, 8');
          }
        }
      }

      validationErrors = errors;
      validationWarnings = warnings;
    }, 300);
  }

  let canSubmit = $derived(validationErrors.length === 0 && charName.trim() !== '');

  function handleSubmit() {
    if (!canSubmit) return;

    // Build ability scores: raw scores + racial bonuses
    const finalScores = [...rawScores];
    if (selectedRace) {
      for (const bonus of selectedRace.ability_bonuses) {
        const idx = ABILITY_KEYS.indexOf(bonus.ability.toLowerCase() as typeof ABILITY_KEYS[number]);
        if (idx >= 0) finalScores[idx] += bonus.bonus;
      }
    }

    const acValue = autoAC;

    // Determine HP: use min HP or user-entered
    const hpValue = Math.max(minHP, 10);

    onSubmit({
      name: charName,
      class: selectedClass?.name ?? '',
      level: charLevel,
      race: selectedRace?.name ?? '',
      player_name: playerName || null,
      armor_class: acValue,
      hit_points_max: hpValue,
      hit_points_current: hpValue,
      strength: finalScores[0],
      dexterity: finalScores[1],
      constitution: finalScores[2],
      intelligence: finalScores[3],
      wisdom: finalScores[4],
      charisma: finalScores[5],
      // Expanded fields
      stat_roll_method: statRollMethod,
      raw_scores: rawScores,
      race_id: selectedRaceId || undefined,
      subrace_id: selectedSubraceId || undefined,
      class_ids_and_levels: selectedClassId ? [{ class_id: selectedClassId, level: charLevel }] : undefined,
      subclass_id: selectedSubclassId || undefined,
      background_id: selectedBackgroundId || undefined,
      alignment: selectedAlignment || undefined,
      proficient_skill_ids: selectedSkillIds,
      proficient_save_ids: selectedSaveIds,
    });
    onClose();
  }
</script>

<div class="modal-overlay" onclick={onClose}>
  <div class="modal" onclick={(e) => e.stopPropagation()}>
    <h2>Create New Character</h2>

    <!-- SECTION: Basic Details -->
    <div class="section">
      <h3>Details</h3>
      <div class="detail-grid">
        <label class="field-full">
          Name
          <input
            type="text"
            bind:value={charName}
            placeholder="Character name"
            oninput={triggerValidation}
          />
        </label>
        <label>
          Player
          <input type="text" bind:value={playerName} placeholder="Optional" />
        </label>
        <label>
          Level
          <input
            type="number"
            bind:value={charLevel}
            min="1"
            max="40"
            oninput={triggerValidation}
          />
        </label>
      </div>
    </div>

    <!-- SECTION: Class & Subclass -->
    <div class="section">
      <h3>Class</h3>
      <div class="detail-grid">
        <label>
          Class
          <select bind:value={selectedClassId} onchange={onClassChange}>
            <option value="">-- Select Class --</option>
            {#each classes as cls}
              <option value={cls.id}>{cls.name}</option>
            {/each}
          </select>
        </label>
        {#if classSubclasses.length > 0}
          <label>
            Subclass
            <select bind:value={selectedSubclassId} onchange={triggerValidation}>
              <option value="">-- Select Subclass --</option>
              {#each classSubclasses as sub}
                <option value={sub.id}>{sub.name}</option>
              {/each}
            </select>
          </label>
        {/if}
      </div>
      {#if selectedClass}
        <div class="readout-row">
          <span class="readout">Hit Die: <strong>{selectedClass.hit_die}</strong></span>
          <span class="readout">Saves: <strong>{selectedClass.saving_throw_1}, {selectedClass.saving_throw_2}</strong></span>
        </div>
      {/if}
    </div>

    <!-- SECTION: Race & Background -->
    <div class="section">
      <h3>Race & Background</h3>
      <div class="detail-grid">
        <label>
          Race
          <select bind:value={selectedRaceId} onchange={onRaceChange}>
            <option value="">-- Select Race --</option>
            {#each racesList as r}
              <option value={r.id}>{r.name}</option>
            {/each}
          </select>
        </label>
        {#if raceSubraces.length > 0}
          <label>
            Subrace
            <select bind:value={selectedSubraceId} onchange={triggerValidation}>
              <option value="">-- Select Subrace --</option>
              {#each raceSubraces as sr}
                <option value={sr.id}>{sr.name}</option>
              {/each}
            </select>
          </label>
        {/if}
        <label>
          Background
          <select bind:value={selectedBackgroundId} onchange={triggerValidation}>
            <option value="">-- Select Background --</option>
            {#each backgroundsList as bg}
              <option value={bg.id}>{bg.name}</option>
            {/each}
          </select>
        </label>
        <label>
          Alignment
          <select bind:value={selectedAlignment} onchange={triggerValidation}>
            <option value="">-- Select Alignment --</option>
            {#each ALIGNMENTS as row}
              {#each row as alignment}
                <option value={alignment}>{alignment}</option>
              {/each}
            {/each}
          </select>
        </label>
      </div>
    </div>

    <!-- SECTION: Auto-Calculated Readouts -->
    {#if selectedClass || selectedRace}
      <div class="section">
        <h3>Derived Stats</h3>
        <div class="readout-grid">
          {#if selectedClass}
            <div class="readout-box">
              <span class="readout-label">Proficiency Bonus</span>
              <span class="readout-value">+{proficiencyBonus}</span>
            </div>
            <div class="readout-box">
              <span class="readout-label">HP (Min)</span>
              <span class="readout-value">{minHP}</span>
            </div>
          {/if}
          {#if selectedRace}
            <div class="readout-box">
              <span class="readout-label">Speed</span>
              <span class="readout-value">{speed} ft</span>
            </div>
            <div class="readout-box">
              <span class="readout-label">Size</span>
              <span class="readout-value">{selectedRace.size}</span>
            </div>
            <div class="readout-box">
              <span class="readout-label">Darkvision</span>
              <span class="readout-value">{selectedRace.darkvision > 0 ? selectedRace.darkvision + ' ft' : 'None'}</span>
            </div>
          {/if}
          <div class="readout-box">
            <span class="readout-label">Base AC</span>
            <span class="readout-value">{autoAC}</span>
          </div>
        </div>
      </div>
    {/if}

    <!-- SECTION: Ability Scores -->
    <div class="section">
      <h3>Ability Scores</h3>
      <StatRoller
        method={statRollMethod}
        scores={rawScores}
        onChange={onStatsChange}
      />
    </div>

    <!-- SECTION: Proficiencies -->
    <div class="section">
      <h3>Proficiencies</h3>
      <SavePicker
        selectedSaves={selectedSaveIds}
        selectedClassIds={selectedClassId ? [selectedClassId] : []}
        onChange={onSavesChange}
      />
      <div class="proficiency-spacer"></div>
      <SkillPicker
        selectedSkills={selectedSkillIds}
        skillPicks={selectedClass?.skill_picks ?? 2}
        selectedBackgroundId={selectedBackgroundId || null}
        backgrounds={backgroundsList}
        onChange={onSkillsChange}
      />
    </div>

    <!-- SECTION: Validation Errors -->
    {#if validationErrors.length > 0}
      <div class="validation-errors">
        {#each validationErrors as error}
          <div class="error-item">✗ {error}</div>
        {/each}
      </div>
    {/if}

    {#if validationWarnings.length > 0}
      <div class="validation-warnings">
        {#each validationWarnings as warning}
          <div class="warning-item">⚠ {warning}</div>
        {/each}
      </div>
    {/if}

    <div class="modal-actions">
      <button class="btn-secondary" onclick={onClose}>Cancel</button>
      <button class="btn-primary" onclick={handleSubmit} disabled={!canSubmit}>
        Create Character
      </button>
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
    padding: 24px 28px;
    width: 640px;
    max-height: 90vh;
    overflow-y: auto;
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

  .section {
    display: flex;
    flex-direction: column;
    gap: 10px;
  }

  .section h3 {
    font-size: 12px;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.08em;
    color: var(--muted);
    margin: 4px 0 0;
    border-bottom: 1px solid var(--border);
    padding-bottom: 4px;
  }

  .detail-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 8px;
  }

  .field-full {
    grid-column: 1 / -1;
  }

  .detail-grid label {
    display: flex;
    flex-direction: column;
    gap: 4px;
    font-size: 11px;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.06em;
    color: var(--muted);
  }

  .detail-grid input,
  .detail-grid select {
    padding: 9px 10px;
    background: var(--bg);
    border: 1px solid var(--border);
    border-radius: var(--radius-sm);
    color: var(--fg);
    font-size: 14px;
    transition: border-color 120ms;
  }

  .detail-grid input:focus,
  .detail-grid select:focus {
    outline: none;
    border-color: var(--gold);
  }

  .detail-grid select {
    cursor: pointer;
    appearance: auto;
  }

  .readout-row {
    display: flex;
    gap: 16px;
    font-size: 11px;
    color: var(--muted);
  }

  .readout-row strong {
    color: var(--fg);
  }

  .readout-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(100px, 1fr));
    gap: 6px;
  }

  .readout-box {
    display: flex;
    flex-direction: column;
    align-items: center;
    padding: 8px;
    background: var(--surface-2);
    border: 1px solid var(--border);
    border-radius: var(--radius-sm);
  }

  .readout-label {
    font-size: 9px;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.06em;
    color: var(--muted);
  }

  .readout-value {
    font-size: 16px;
    font-weight: 700;
    color: var(--fg);
  }

  .proficiency-spacer {
    height: 8px;
  }

  .validation-errors {
    display: flex;
    flex-direction: column;
    gap: 4px;
    padding: 8px 10px;
    background: oklch(25% 0.08 30 / 0.3);
    border: 1px solid oklch(50% 0.15 30);
    border-radius: var(--radius-sm);
  }

  .error-item {
    font-size: 11px;
    color: oklch(75% 0.15 30);
  }

  .validation-warnings {
    display: flex;
    flex-direction: column;
    gap: 4px;
    padding: 8px 10px;
    background: oklch(25% 0.05 80 / 0.3);
    border: 1px solid oklch(50% 0.1 80);
    border-radius: var(--radius-sm);
  }

  .warning-item {
    font-size: 11px;
    color: oklch(80% 0.1 80);
  }

  .modal-actions {
    display: flex;
    gap: 10px;
    justify-content: flex-end;
    margin-top: 8px;
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

  .btn-primary:hover:not(:disabled) { opacity: 0.85; }
  .btn-primary:disabled {
    opacity: 0.4;
    cursor: not-allowed;
  }
</style>

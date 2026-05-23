<script lang="ts">
  const ALL_SAVES = [
    { id: 'strength', label: 'STR' },
    { id: 'dexterity', label: 'DEX' },
    { id: 'constitution', label: 'CON' },
    { id: 'intelligence', label: 'INT' },
    { id: 'wisdom', label: 'WIS' },
    { id: 'charisma', label: 'CHA' },
  ];

  // Map class saving throws
  const CLASS_SAVES: Record<string, [string, string]> = {
    barbarian: ['STR', 'CON'],
    bard: ['DEX', 'CHA'],
    cleric: ['WIS', 'CHA'],
    druid: ['INT', 'WIS'],
    fighter: ['STR', 'CON'],
    monk: ['STR', 'DEX'],
    paladin: ['WIS', 'CHA'],
    ranger: ['STR', 'DEX'],
    rogue: ['DEX', 'INT'],
    sorcerer: ['CON', 'CHA'],
    warlock: ['WIS', 'CHA'],
    wizard: ['INT', 'WIS'],
    artificer: ['CON', 'INT'],
  };

  const SAVE_KEY_TO_ID: Record<string, string> = {
    'STR': 'strength',
    'DEX': 'dexterity',
    'CON': 'constitution',
    'INT': 'intelligence',
    'WIS': 'wisdom',
    'CHA': 'charisma',
  };

  interface Props {
    selectedSaves: string[];
    selectedClassIds: string[];
    onChange: (saves: string[]) => void;
  }

  let { selectedSaves, selectedClassIds, onChange }: Props = $props();

  // Auto-select class proficiency saves
  function getClassSaveIds(): string[] {
    const ids: string[] = [];
    for (const classId of selectedClassIds) {
      const saves = CLASS_SAVES[classId];
      if (saves) {
        saves.forEach(s => {
          const mappedId = SAVE_KEY_TO_ID[s];
          if (mappedId && !ids.includes(mappedId)) ids.push(mappedId);
        });
      }
    }
    return ids;
  }

  let classSaveIds = $derived(getClassSaveIds());

  // Ensure class saves are always selected
  $effect(() => {
    const autoSaves = classSaveIds;
    const currentSelected = selectedSaves;
    const missing = autoSaves.filter(id => !currentSelected.includes(id));
    if (missing.length > 0) {
      onChange([...currentSelected, ...missing]);
    }
  });

  function toggleSave(saveId: string) {
    const isClassSave = classSaveIds.includes(saveId);
    if (isClassSave) return; // Can't toggle off class saves

    if (selectedSaves.includes(saveId)) {
      onChange(selectedSaves.filter(s => s !== saveId));
    } else {
      onChange([...selectedSaves, saveId]);
    }
  }
</script>

<div class="save-picker">
  <div class="save-label">Saving Throw Proficiencies</div>
  <div class="save-grid">
    {#each ALL_SAVES as save}
      {@const isSelected = selectedSaves.includes(save.id)}
      {@const isClassSave = classSaveIds.includes(save.id)}
      <button
        class="save-btn"
        class:selected={isSelected}
        class:class-save={isClassSave}
        onclick={() => toggleSave(save.id)}
        title={isClassSave ? 'Granted by class' : 'Click to toggle'}
      >
        <span class="save-abbrev">{save.label}</span>
      </button>
    {/each}
  </div>
</div>

<style>
  .save-picker {
    display: flex;
    flex-direction: column;
    gap: 6px;
  }

  .save-label {
    font-size: 11px;
    font-weight: 600;
    color: var(--muted);
  }

  .save-grid {
    display: grid;
    grid-template-columns: repeat(6, 1fr);
    gap: 4px;
  }

  .save-btn {
    padding: 6px 4px;
    font-size: 11px;
    font-weight: 700;
    border: 1px solid var(--border);
    background: var(--surface);
    color: var(--muted);
    border-radius: var(--radius-sm);
    cursor: pointer;
    transition: all 120ms;
    text-align: center;
  }

  .save-btn:hover:not(.class-save) {
    border-color: var(--gold);
    color: var(--fg);
  }

  .save-btn.selected {
    background: var(--gold);
    border-color: var(--gold);
    color: oklch(11% 0.012 250);
  }

  .save-btn.class-save {
    background: oklch(30% 0.05 250);
    border-color: oklch(40% 0.08 250);
    color: oklch(80% 0.06 250);
    cursor: default;
  }

  .save-abbrev {
    display: block;
  }
</style>

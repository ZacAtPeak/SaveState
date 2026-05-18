<script lang="ts">
  import type { CreateCharacterRequest } from '$lib/types';

  interface Props {
    onClose: () => void;
    onSubmit: (req: CreateCharacterRequest) => void;
  }

  let { onClose, onSubmit }: Props = $props();

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

  function handleSubmit() {
    onSubmit({
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
    });
    onClose();
  }
</script>

<div class="modal-overlay" onclick={onClose}>
  <div class="modal" onclick={(e) => e.stopPropagation()}>
    <h2>Create New Character</h2>
    <div class="form-grid">
      <label>
        Name
        <input type="text" bind:value={newChar.name} placeholder="Character name" />
      </label>
      <label>
        Class
        <input type="text" bind:value={newChar.class} placeholder="e.g. Ranger" />
      </label>
      <label>
        Level
        <input type="number" bind:value={newChar.level} min="1" max="20" />
      </label>
      <label>
        Race
        <input type="text" bind:value={newChar.race} placeholder="e.g. Elf" />
      </label>
      <label>
        Player Name
        <input type="text" bind:value={newChar.player_name} placeholder="Optional" />
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
      <button class="btn-secondary" onclick={onClose}>Cancel</button>
      <button class="btn-primary" onclick={handleSubmit}>Create Character</button>
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
    width: 420px;
    max-height: 90vh;
    overflow-y: auto;
    display: flex;
    flex-direction: column;
    gap: 20px;
    box-shadow: 0 24px 48px oklch(0% 0 0 / 0.4);
  }

  .modal h2 {
    font-family: var(--font-display);
    font-size: 18px;
    font-weight: 600;
    color: var(--fg);
    margin: 0;
  }

  .modal h3 {
    font-size: 12px;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.08em;
    color: var(--muted);
    margin: 4px 0 0;
  }

  .form-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 12px;
  }

  .form-grid label {
    display: flex;
    flex-direction: column;
    gap: 5px;
    font-size: 11px;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.06em;
    color: var(--muted);
  }

  .form-grid input {
    padding: 10px 12px;
    background: var(--bg);
    border: 1px solid var(--border);
    border-radius: var(--radius-sm);
    color: var(--fg);
    font-size: 14px;
    transition: border-color 120ms;
  }

  .form-grid input:focus {
    outline: none;
    border-color: var(--gold);
  }

  .form-grid input::placeholder {
    color: var(--muted);
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

  .btn-primary:hover { opacity: 0.85; }
</style>
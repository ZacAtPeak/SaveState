<script lang="ts">
  import type { Entity, CharacterSkill, CharacterSpell } from '$lib/types';
  import { appStore } from '$lib/stores/app.svelte';

  const LEVEL_ORDINALS: Record<number, string> = {
    1: '1st', 2: '2nd', 3: '3rd', 4: '4th', 5: '5th',
    6: '6th', 7: '7th', 8: '8th', 9: '9th'
  };

  interface Props {
    character: Entity;
    skills: CharacterSkill[];
    spells: CharacterSpell[];
    onClose: () => void;
  }

  let { character, skills, spells, onClose }: Props = $props();

  let customStatus = $state('');

  const conditions = [
    'Blinded', 'Charmed', 'Deafened', 'Frightened',
    'Grappled', 'Incapacitated', 'Invisible', 'Paralyzed',
    'Petrified', 'Poisoned', 'Prone', 'Restrained',
    'Stunned', 'Unconscious', 'Exhaustion'
  ];

  const abilityScores = [
    { key: 'strength' as const, label: 'STR' },
    { key: 'dexterity' as const, label: 'DEX' },
    { key: 'constitution' as const, label: 'CON' },
    { key: 'intelligence' as const, label: 'INT' },
    { key: 'wisdom' as const, label: 'WIS' },
    { key: 'charisma' as const, label: 'CHA' }
  ];

  const editableStats = [
    { key: 'armor_class', label: 'AC' },
    { key: 'speed', label: 'Speed' },
    { key: 'strength', label: 'STR' },
    { key: 'dexterity', label: 'DEX' },
    { key: 'constitution', label: 'CON' },
    { key: 'intelligence', label: 'INT' },
    { key: 'wisdom', label: 'WIS' },
    { key: 'charisma', label: 'CHA' }
  ];

  let isEditing = $state(false);
  let editValues = $state<Record<string, number>>({});
  let editHpCurrent = $state(0);
  let editHpMax = $state(0);

  let isInitiativeInstance = $derived(!!appStore.modalInstanceId);
  let statusKey = $derived(appStore.modalInstanceId ?? character.id);
  let instanceHp = $derived(
    isInitiativeInstance
      ? appStore.initiativeList.find(e => e.instance_id === appStore.modalInstanceId)
      : null
  );
  let hpCurrent = $derived(instanceHp?.hit_points_current ?? character.hit_points_current);
  let hpMax = $derived(instanceHp?.hit_points_max ?? character.hit_points_max);
  let entityStatuses = $derived(appStore.characterStatuses[statusKey] ?? []);

  function getModifier(score: number): number {
    return Math.floor((score - 10) / 2);
  }

  function getHpPercent(): number {
    return Math.max(0, Math.min(100, (hpCurrent / hpMax) * 100));
  }

  function getHpColor(): string {
    const ratio = hpCurrent / hpMax;
    if (ratio <= 0.25) return 'var(--red)';
    if (ratio <= 0.5) return 'var(--gold)';
    return 'var(--green)';
  }

  function getHpClass(): string {
    const ratio = hpCurrent / hpMax;
    if (ratio <= 0.25) return 'danger';
    if (ratio <= 0.5) return 'warn';
    return '';
  }

  function getStatValue(key: string): number {
    const overrides = appStore.modalInstanceId ? appStore.instanceStatOverrides[appStore.modalInstanceId] : undefined;
    if (!isEditing && overrides && overrides[key] !== undefined) return overrides[key];
    if (key === 'speed') return character.speed ?? 30;
    return (character as Record<string, any>)[key] ?? 0;
  }

  function getEditValue(key: string): number {
    return editValues[key] !== undefined ? editValues[key] : getStatValue(key);
  }

  function setEditValue(key: string, val: number) {
    editValues = { ...editValues, [key]: val };
  }

  function getEntityIcon(): string {
    if (character.entity_type === 'pc') {
      return '<svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>';
    }
    if (character.entity_type === 'npc') {
      return '<svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>';
    }
    return '<svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M5.81 7C5.81 7 5.36 7.63 4.82 8.67M18.19 7C18.19 7 18.64 7.63 19.18 8.67M4.82 8.67C4.01 10.21 3 12.67 3 15.33C5.81 15.33 7.5 17 7.5 17C7.5 17 8.62 22 12 22C15.38 22 16.5 17 16.5 17C16.5 17 18.19 15.33 21 15.33C21 12.67 19.99 10.21 19.18 8.67M4.82 8.67C4.82 8.67 1.88 6.44 4.82 2C5.81 2.56 8.62 4.78 8.62 4.78C8.62 4.78 10.31 3.67 12 3.67C13.69 3.67 15.38 4.78 15.38 4.78C15.38 4.78 18.19 2.56 19.31 2C22.13 6.44 19.18 8.67 19.18 8.67"/><path d="M11 18L12 19M13 18L12 18"/><path d="M8.5 12.5L10 14M15.5 12.5L14 14"/></svg>';
  }

  function getSubtitle(): string {
    if (character.entity_type === 'pc') {
      return `${character.race} ${character.class} · Level ${character.level}`;
    }
    if (character.entity_type === 'npc') return 'NPC';
    return `Creature · CR ${character.challenge_rating || '?'}`;
  }

  function getTypeLabel(): string {
    if (character.entity_type === 'pc') return 'PC';
    if (character.entity_type === 'npc') return 'NPC';
    return 'Monster';
  }

  function getTypeClass(): string {
    if (character.entity_type === 'pc') return 'type-pc';
    if (character.entity_type === 'npc') return 'type-npc';
    return 'type-monster';
  }

  function adjustHp(delta: number) {
    if (isInitiativeInstance && appStore.modalInstanceId) {
      appStore.updateInitiativeInstanceHp(appStore.modalInstanceId, delta);
    } else {
      appStore.updateHp(character.id, delta);
    }
  }

  function startEditing() {
    editValues = {};
    const instanceId = appStore.modalInstanceId;
    if (instanceId) {
      const overrides = appStore.instanceStatOverrides[instanceId] ?? {};
      for (const { key } of editableStats) {
        if (overrides[key] !== undefined) {
          editValues[key] = overrides[key];
        }
      }
    }
    editHpCurrent = hpCurrent;
    editHpMax = hpMax;
    isEditing = true;
  }

  function cancelEditing() {
    isEditing = false;
    editValues = {};
  }

  function saveEditing() {
    if (!appStore.modalInstanceId) { isEditing = false; return; }
    const instanceId = appStore.modalInstanceId;
    for (const { key } of editableStats) {
      if (editValues[key] !== undefined) {
        appStore.setInstanceStat(instanceId, key, editValues[key]);
      }
    }
    if (editHpCurrent !== hpCurrent || editHpMax !== hpMax) {
      appStore.setInstanceStat(instanceId, 'hit_points_current', editHpCurrent);
      appStore.setInstanceStat(instanceId, 'hit_points_max', editHpMax);
    }
    appStore.syncInitiativeInstanceFromOverrides(instanceId);
    isEditing = false;
    editValues = {};
  }

  function addCustomStatus() {
    const s = customStatus.trim();
    if (s && !entityStatuses.includes(s)) {
      appStore.addStatus(statusKey, s);
      customStatus = '';
    }
  }

  function handleCustomStatusKeydown(e: KeyboardEvent) {
    if (e.key === 'Enter') {
      addCustomStatus();
    }
  }

  function toggleCondition(condition: string) {
    if (entityStatuses.includes(condition)) {
      appStore.removeStatus(statusKey, condition);
    } else {
      appStore.addStatus(statusKey, condition);
    }
  }

  let slotLevels = $derived(
    Object.keys(appStore.spellSlotsMax[character.id] ?? {})
      .map(Number)
      .sort((a, b) => a - b)
      .filter(l => (appStore.spellSlotsMax[character.id]?.[String(l)] ?? 0) > 0)
  );

  let activeConcentration = $derived(appStore.concentrationMap[statusKey] ?? null);

  let characterCastLog = $derived(
    appStore.castLog.filter(e => e.status_key === statusKey).slice(0, 8)
  );

  function castSpell(spell: CharacterSpell) {
    if (spell.level > 0) {
      appStore.useSpellSlot(character.id, spell.level);
    }
    if (spell.is_concentration) {
      appStore.setConcentration(statusKey, spell.name);
    }
    appStore.logCast(character.id, statusKey, spell.name, spell.level);
  }
</script>

<div class="modal-overlay" onclick={onClose} role="presentation">
  <div class="modal" onclick={(e) => e.stopPropagation()} role="dialog" aria-label="Character details">
    <div class="modal-header">
      <div class="modal-header-left">
        <div class="modal-av">{@html getEntityIcon()}</div>
        <div class="modal-name-block">
          <div class="modal-name">{character.name}</div>
          <div class="modal-sub">{getSubtitle()}</div>
        </div>
        <span class="type-badge {getTypeClass()}">{getTypeLabel()}</span>
      </div>
      <div class="modal-header-right">
        {#if isInitiativeInstance}
          {#if isEditing}
            <button class="header-btn save-btn" onclick={saveEditing} aria-label="Save">Save</button>
            <button class="header-btn" onclick={cancelEditing} aria-label="Cancel">Cancel</button>
          {:else}
            <button class="header-btn" onclick={startEditing} aria-label="Edit stats">
              <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 3a2.85 2.83 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5Z"/><path d="m15 5 4 4"/></svg>
            </button>
          {/if}
        {/if}
        <button class="close-btn" onclick={onClose} aria-label="Close">
          <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 6L6 18M6 6l12 12"/></svg>
        </button>
      </div>
    </div>

    <div class="modal-body">
      <div class="left-col">
        <div class="section">
          <div class="section-title">Hit Points</div>
          <div class="hp-block">
            <div class="hp-head">
              {#if isEditing}
                <div class="hp-edit-row">
                  <label class="hp-edit-field">
                    Current
                    <input type="number" value={editHpCurrent} oninput={(e) => editHpCurrent = parseInt((e.target as HTMLInputElement).value) || 0} min="0" />
                  </label>
                  <span class="hp-edit-sep">/</span>
                  <label class="hp-edit-field">
                    Max
                    <input type="number" value={editHpMax} oninput={(e) => editHpMax = parseInt((e.target as HTMLInputElement).value) || 0} min="1" />
                  </label>
                </div>
              {:else}
                <span class="hp-num {getHpClass()}">
                  {hpCurrent} / {hpMax}
                </span>
              {/if}
            </div>
            <div class="hp-bar">
              <div class="hp-fill" style="width: {getHpPercent()}%; background: {getHpColor()}"></div>
            </div>
            <div class="hp-adjust">
              <button class="hp-btn" onclick={() => adjustHp(-10)} aria-label="Damage 10">−10</button>
              <button class="hp-btn" onclick={() => adjustHp(-5)} aria-label="Damage 5">−5</button>
              <button class="hp-btn" onclick={() => adjustHp(-1)} aria-label="Damage 1">−1</button>
              <button class="hp-btn heal" onclick={() => adjustHp(1)} aria-label="Heal 1">+1</button>
              <button class="hp-btn heal" onclick={() => adjustHp(5)} aria-label="Heal 5">+5</button>
              <button class="hp-btn heal" onclick={() => adjustHp(10)} aria-label="Heal 10">+10</button>
            </div>
          </div>
        </div>

        <div class="section">
          <div class="section-title">Conditions</div>
          <div class="conditions-grid">
            {#each conditions as condition}
              <button
                class="cond-btn"
                class:active={entityStatuses.includes(condition)}
                onclick={() => toggleCondition(condition)}
              >
                {condition}
              </button>
            {/each}
          </div>
          <div class="custom-status-row">
            <input
              type="text"
              bind:value={customStatus}
              onkeydown={handleCustomStatusKeydown}
              placeholder="Custom status..."
            />
            <button class="add-status-btn" onclick={addCustomStatus} disabled={!customStatus.trim()}>Add</button>
          </div>
          {#if entityStatuses.length > 0}
            <div class="active-statuses">
              {#each entityStatuses as status}
                <button class="status-chip" onclick={() => appStore.removeStatus(statusKey, status)}>
                  {status}
                  <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 6L6 18M6 6l12 12"/></svg>
                </button>
              {/each}
            </div>
          {:else}
            <div class="no-statuses">No active conditions</div>
          {/if}
        </div>
      </div>

      <div class="right-col">
        <div class="section">
          <div class="section-title">Stats</div>
          <div class="stats-grid">
            {#each editableStats.slice(0, 3) as stat}
              <div class="stat-box">
                <span class="stat-label">{stat.label}</span>
                {#if isEditing}
                  <input class="stat-input" type="number" value={getEditValue(stat.key)} oninput={(e) => setEditValue(stat.key, parseInt((e.target as HTMLInputElement).value) || 0)} min="0" max="99" />
                {:else}
                  <span class="stat-value">{getStatValue(stat.key)}{stat.key === 'speed' ? 'ft' : ''}</span>
                {/if}
              </div>
            {/each}
          </div>
        </div>

        <div class="section">
          <div class="section-title">Ability Scores</div>
          <div class="abilities-grid">
            {#each abilityScores as ability}
              <div class="ability">
                <span class="ability-label">{ability.label}</span>
                {#if isEditing}
                  <input class="stat-input" type="number" value={getEditValue(ability.key)} oninput={(e) => setEditValue(ability.key, parseInt((e.target as HTMLInputElement).value) || 0)} min="1" max="30" />
                {:else}
                  <span class="ability-score">{getStatValue(ability.key)}</span>
                {/if}
                <span class="ability-mod">{getModifier(getStatValue(ability.key)) >= 0 ? '+' : ''}{getModifier(getStatValue(ability.key))}</span>
              </div>
            {/each}
          </div>
        </div>

        {#if skills.length > 0}
          <div class="section">
            <div class="section-title">Skills</div>
            <div class="skills-grid">
              {#each skills as skill}
                <div class="skill">
                  <span class="skill-name">{skill.skill_name}</span>
                  <span class="skill-ability">({skill.associated_ability.substring(0, 3).toUpperCase()})</span>
                  <span class="skill-mod-plus">{skill.total_modifier >= 0 ? '+' : ''}{skill.total_modifier}</span>
                  {#if skill.is_expert}
                    <span class="skill-badge expert">Expert</span>
                  {:else if skill.is_proficient}
                    <span class="skill-badge proficient">Proficient</span>
                  {/if}
                </div>
              {/each}
            </div>
          </div>
        {/if}

        {#if character.equipment && character.equipment.length > 0}
          <div class="section">
            <div class="section-title">Equipment</div>
            <div class="equip-list">
              {#each character.equipment as item}
                <div class="equip-item">{item}</div>
              {/each}
            </div>
          </div>
        {/if}

        {#if slotLevels.length > 0}
          <div class="section">
            <div class="section-title">Spell Slots</div>
            <div class="slot-grid">
              {#each slotLevels as level}
                {@const key = String(level)}
                {@const max = appStore.spellSlotsMax[character.id]?.[key] ?? 0}
                {@const curr = appStore.spellSlotsCurr[character.id]?.[key] ?? 0}
                <div class="slot-row">
                  <span class="slot-level">{LEVEL_ORDINALS[level]}</span>
                  <div class="slot-pips">
                    {#each Array(max) as _, i}
                      <button
                        class="slot-pip"
                        class:used={i >= curr}
                        onclick={() => i < curr
                          ? appStore.useSpellSlot(character.id, level)
                          : appStore.restoreSpellSlot(character.id, level)}
                        aria-label="{i < curr ? 'Use' : 'Restore'} {LEVEL_ORDINALS[level]} slot"
                      ></button>
                    {/each}
                  </div>
                  <span class="slot-count">{curr}/{max}</span>
                </div>
              {/each}
            </div>
          </div>
        {/if}

        {#if spells.length > 0}
          <div class="section">
            <div class="section-title-row">
              <span class="section-title">Spells</span>
              {#if activeConcentration}
                <span class="concentration-badge">
                  <span class="conc-dot"></span>
                  {activeConcentration}
                  <button class="conc-clear" onclick={() => appStore.clearConcentration(statusKey)} aria-label="End concentration">×</button>
                </span>
              {/if}
            </div>
            <div class="spell-rows">
              {#each spells as spell}
                <div class="spell-row">
                  <span class="spell-prep-dot" class:prepared={spell.is_prepared}></span>
                  <span class="spell-row-name">{spell.name}</span>
                  <span class="spell-row-level">{spell.level === 0 ? 'C' : spell.level}</span>
                  {#if spell.is_concentration}
                    <span class="spell-row-tag conc">Conc</span>
                  {/if}
                  <button class="cast-btn" onclick={() => castSpell(spell)} aria-label="Cast {spell.name}">
                    Cast
                  </button>
                </div>
              {/each}
            </div>
          </div>
        {/if}

        {#if characterCastLog.length > 0}
          <div class="section">
            <div class="section-title">Cast Log</div>
            <div class="cast-log">
              {#each characterCastLog as entry}
                <div class="cast-entry">
                  <span class="cast-round">R{entry.round}</span>
                  <span class="cast-spell">{entry.spell_name}</span>
                  {#if entry.level > 0}
                    <span class="cast-level">{LEVEL_ORDINALS[entry.level]}</span>
                  {:else}
                    <span class="cast-level">Cantrip</span>
                  {/if}
                </div>
              {/each}
            </div>
          </div>
        {/if}
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
    width: 640px;
    max-height: 90vh;
    display: flex;
    flex-direction: column;
    box-shadow: 0 24px 48px oklch(0% 0 0 / 0.4);
  }

  .modal-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 20px 24px;
    border-bottom: 1px solid var(--border);
    flex-shrink: 0;
  }

  .modal-header-left {
    display: flex;
    align-items: center;
    gap: 14px;
    min-width: 0;
  }

  .modal-av {
    width: 44px;
    height: 44px;
    flex-shrink: 0;
    background: var(--surface-2);
    border: 1px solid var(--border);
    border-radius: var(--radius-md);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 22px;
  }

  .modal-name-block {
    min-width: 0;
  }

  .modal-name {
    font-family: var(--font-display);
    font-size: 20px;
    font-weight: 600;
    color: var(--fg);
    line-height: 1.2;
  }

  .modal-sub {
    font-size: 12px;
    color: var(--muted);
    margin-top: 2px;
  }

  .type-badge {
    display: inline-flex;
    align-items: center;
    font-family: var(--font-mono);
    font-size: 9px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.10em;
    padding: 3px 7px;
    border-radius: var(--radius-sm);
    flex-shrink: 0;
  }

  .type-pc { color: var(--green); background: var(--green-dim); }
  .type-npc { color: var(--purple); background: var(--purple-dim); }
  .type-monster { color: var(--red); background: var(--red-dim); }

  .modal-header-right {
    display: flex;
    align-items: center;
    gap: 8px;
  }

  .header-btn {
    height: 32px;
    padding: 0 10px;
    background: var(--surface-2);
    border: 1px solid var(--border);
    color: var(--muted);
    border-radius: var(--radius-md);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 12px;
    font-weight: 500;
    transition: all 120ms;
  }

  .header-btn:hover {
    color: var(--fg);
    border-color: var(--gold);
  }

  .header-btn.save-btn {
    background: var(--gold);
    border-color: var(--gold);
    color: oklch(11% 0.012 250);
    font-weight: 600;
  }

  .header-btn.save-btn:hover {
    opacity: 0.85;
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
    flex-shrink: 0;
  }

  .close-btn:hover {
    color: var(--fg);
    border-color: var(--gold);
  }

  .modal-body {
    flex: 1;
    display: flex;
    overflow-y: auto;
    gap: 0;
  }

  .left-col {
    width: 280px;
    flex-shrink: 0;
    padding: 20px;
    border-right: 1px solid var(--border);
    display: flex;
    flex-direction: column;
    gap: 20px;
    overflow-y: auto;
  }

  .right-col {
    flex: 1;
    padding: 20px;
    display: flex;
    flex-direction: column;
    gap: 20px;
    overflow-y: auto;
  }

  .section-title {
    font-family: var(--font-mono);
    font-size: 10px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.10em;
    color: var(--muted);
    padding-bottom: 8px;
    border-bottom: 1px solid var(--border);
    margin-bottom: 10px;
  }

  .hp-block {
    display: flex;
    flex-direction: column;
    gap: 8px;
  }

  .hp-head {
    display: flex;
    align-items: center;
    gap: 8px;
  }

  .hp-num {
    font-family: var(--font-mono);
    font-size: 16px;
    font-weight: 700;
    color: var(--fg);
    font-variant-numeric: tabular-nums;
  }

  .hp-num.danger { color: var(--red); }
  .hp-num.warn { color: var(--gold); }

  .hp-edit-row {
    display: flex;
    align-items: center;
    gap: 8px;
    width: 100%;
  }

  .hp-edit-field {
    display: flex;
    flex-direction: column;
    gap: 2px;
    font-size: 9px;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.06em;
    color: var(--muted);
  }

  .hp-edit-field input {
    width: 60px;
    padding: 5px 8px;
    background: var(--bg);
    border: 1px solid var(--border);
    border-radius: var(--radius-sm);
    color: var(--fg);
    font-size: 14px;
    font-family: var(--font-mono);
    text-align: center;
  }

  .hp-edit-field input:focus {
    outline: none;
    border-color: var(--gold);
  }

  .hp-edit-sep {
    font-family: var(--font-mono);
    font-size: 16px;
    color: var(--muted);
    margin-top: 14px;
  }

  .stat-input {
    width: 100%;
    padding: 4px 6px;
    background: var(--bg);
    border: 1px solid var(--border);
    border-radius: var(--radius-sm);
    color: var(--fg);
    font-size: 14px;
    font-family: var(--font-mono);
    text-align: center;
  }

  .stat-input:focus {
    outline: none;
    border-color: var(--gold);
  }

  .hp-bar {
    height: 8px;
    background: var(--surface-2);
    border-radius: var(--radius-sm);
    overflow: hidden;
  }

  .hp-fill {
    height: 100%;
    border-radius: var(--radius-sm);
    transition: width 220ms ease;
  }

  .hp-adjust {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 4px;
  }

  .hp-btn {
    height: 32px;
    background: var(--surface-2);
    border: 1px solid var(--border);
    color: var(--muted);
    border-radius: var(--radius-sm);
    font-size: 12px;
    font-family: var(--font-mono);
    font-weight: 500;
    transition: all 100ms;
  }

  .hp-btn:hover {
    color: var(--red);
    border-color: var(--red);
    background: var(--red-dim);
  }

  .hp-btn.heal:hover {
    color: var(--green);
    border-color: var(--green);
    background: var(--green-dim);
  }

  .conditions-grid {
    display: grid;
    grid-template-columns: 1fr 1fr 1fr;
    gap: 4px;
  }

  .cond-btn {
    height: 28px;
    background: var(--surface-2);
    border: 1px solid var(--border);
    color: var(--muted);
    border-radius: var(--radius-sm);
    font-size: 10px;
    font-weight: 500;
    transition: all 100ms;
    padding: 0 4px;
  }

  .cond-btn:hover {
    color: var(--fg);
    border-color: var(--gold);
  }

  .cond-btn.active {
    color: var(--gold);
    background: var(--gold-dim);
    border-color: var(--gold);
  }

  .custom-status-row {
    display: flex;
    gap: 6px;
    margin-top: 8px;
  }

  .custom-status-row input {
    flex: 1;
    padding: 7px 10px;
    background: var(--bg);
    border: 1px solid var(--border);
    border-radius: var(--radius-sm);
    color: var(--fg);
    font-size: 12px;
  }

  .custom-status-row input:focus {
    outline: none;
    border-color: var(--gold);
  }

  .custom-status-row input::placeholder {
    color: var(--muted);
  }

  .add-status-btn {
    height: 30px;
    padding: 0 12px;
    background: var(--surface-2);
    border: 1px solid var(--border);
    color: var(--muted);
    border-radius: var(--radius-sm);
    font-size: 11px;
    font-weight: 600;
    transition: all 120ms;
  }

  .add-status-btn:hover:not(:disabled) {
    color: var(--fg);
    border-color: var(--gold);
  }

  .add-status-btn:disabled {
    opacity: 0.4;
  }

  .active-statuses {
    display: flex;
    flex-wrap: wrap;
    gap: 4px;
    margin-top: 8px;
  }

  .status-chip {
    display: inline-flex;
    align-items: center;
    gap: 4px;
    padding: 4px 8px;
    background: var(--gold-dim);
    border: 1px solid var(--gold);
    color: var(--gold);
    border-radius: var(--radius-sm);
    font-size: 11px;
    font-weight: 500;
    transition: all 120ms;
  }

  .status-chip:hover {
    border-color: var(--red);
    color: var(--red);
    background: var(--red-dim);
  }

  .no-statuses {
    font-size: 11px;
    color: var(--muted);
    font-style: italic;
    margin-top: 6px;
  }

  .stats-grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 8px;
  }

  .stat-box {
    background: var(--surface-2);
    border: 1px solid var(--border);
    border-radius: var(--radius-md);
    padding: 10px;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 2px;
  }

  .stat-label {
    font-family: var(--font-mono);
    font-size: 9px;
    text-transform: uppercase;
    letter-spacing: 0.08em;
    color: var(--muted);
  }

  .stat-value {
    font-family: var(--font-mono);
    font-size: 20px;
    font-weight: 700;
    color: var(--fg);
    font-variant-numeric: tabular-nums;
  }

  .abilities-grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 6px;
  }

  .ability {
    background: var(--surface-2);
    border: 1px solid var(--border);
    border-radius: var(--radius-md);
    padding: 10px 6px;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 2px;
  }

  .ability-label {
    font-family: var(--font-mono);
    font-size: 9px;
    font-weight: 600;
    color: var(--muted);
    text-transform: uppercase;
    letter-spacing: 0.05em;
  }

  .ability-score {
    font-family: var(--font-mono);
    font-size: 18px;
    font-weight: 700;
    color: var(--fg);
  }

  .ability-mod {
    font-family: var(--font-mono);
    font-size: 11px;
    font-weight: 500;
    color: var(--gold);
  }

  .skills-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(130px, 1fr));
    gap: 4px;
  }

  .skill {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    gap: 3px;
    padding: 6px 8px;
    background: var(--surface-2);
    border: 1px solid var(--border);
    border-radius: var(--radius-sm);
  }

  .skill-name {
    font-size: 11px;
    font-weight: 600;
    color: var(--fg);
  }

  .skill-ability {
    font-family: var(--font-mono);
    font-size: 9px;
    color: var(--muted);
  }

  .skill-mod-plus {
    font-family: var(--font-mono);
    font-size: 12px;
    font-weight: 700;
    color: var(--gold);
    margin-left: auto;
  }

  .skill-badge {
    font-family: var(--font-mono);
    font-size: 8px;
    padding: 1px 4px;
    border-radius: 3px;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.04em;
  }

  .skill-badge.proficient {
    background: var(--green-dim);
    color: var(--green);
  }

  .skill-badge.expert {
    background: var(--accent-dim);
    color: var(--accent);
  }

  .equip-list {
    display: flex;
    flex-wrap: wrap;
    gap: 4px;
  }

  .equip-item {
    padding: 5px 9px;
    background: var(--surface-2);
    border: 1px solid var(--border);
    border-radius: var(--radius-sm);
    font-size: 11px;
    color: var(--fg);
  }

  /* Spell Slots */
  .slot-grid {
    display: flex;
    flex-direction: column;
    gap: 5px;
  }

  .slot-row {
    display: flex;
    align-items: center;
    gap: 8px;
  }

  .slot-level {
    font-family: var(--font-mono);
    font-size: 10px;
    color: var(--muted);
    width: 28px;
    flex-shrink: 0;
  }

  .slot-pips {
    display: flex;
    gap: 3px;
    flex: 1;
  }

  .slot-pip {
    width: 12px;
    height: 12px;
    border-radius: 50%;
    background: var(--accent);
    border: 1px solid var(--accent);
    flex-shrink: 0;
    transition: all 100ms;
  }

  .slot-pip.used {
    background: transparent;
    border-color: var(--border);
  }

  .slot-pip:hover {
    opacity: 0.7;
  }

  .slot-count {
    font-family: var(--font-mono);
    font-size: 10px;
    color: var(--muted);
    width: 24px;
    text-align: right;
    flex-shrink: 0;
  }

  /* Spells section header row */
  .section-title-row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding-bottom: 8px;
    border-bottom: 1px solid var(--border);
    margin-bottom: 10px;
    gap: 8px;
  }

  .section-title-row .section-title {
    border-bottom: none;
    padding-bottom: 0;
    margin-bottom: 0;
  }

  .concentration-badge {
    display: inline-flex;
    align-items: center;
    gap: 5px;
    padding: 3px 8px 3px 6px;
    background: var(--accent-dim);
    border: 1px solid var(--accent);
    border-radius: var(--radius-sm);
    font-size: 10px;
    font-weight: 500;
    color: var(--accent);
    flex-shrink: 0;
    max-width: 160px;
    overflow: hidden;
  }

  .conc-dot {
    width: 6px;
    height: 6px;
    border-radius: 50%;
    background: var(--accent);
    flex-shrink: 0;
    animation: pulse 2s infinite;
  }

  @keyframes pulse {
    0%, 100% { opacity: 1; }
    50% { opacity: 0.4; }
  }

  .conc-clear {
    background: none;
    border: none;
    color: var(--accent);
    font-size: 14px;
    line-height: 1;
    padding: 0;
    display: flex;
    align-items: center;
    opacity: 0.7;
    flex-shrink: 0;
  }

  .conc-clear:hover {
    opacity: 1;
  }

  /* Spell rows */
  .spell-rows {
    display: flex;
    flex-direction: column;
    gap: 3px;
  }

  .spell-row {
    display: flex;
    align-items: center;
    gap: 5px;
    padding: 5px 8px;
    background: var(--surface-2);
    border: 1px solid var(--border);
    border-radius: var(--radius-sm);
  }

  .spell-prep-dot {
    width: 6px;
    height: 6px;
    border-radius: 50%;
    background: var(--surface-3);
    border: 1px solid var(--border);
    flex-shrink: 0;
  }

  .spell-prep-dot.prepared {
    background: var(--accent);
    border-color: var(--accent);
  }

  .spell-row-name {
    font-size: 11px;
    font-weight: 600;
    color: var(--fg);
    flex: 1;
    min-width: 0;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  .spell-row-level {
    font-family: var(--font-mono);
    font-size: 9px;
    font-weight: 700;
    padding: 1px 4px;
    border-radius: 3px;
    background: var(--accent-dim);
    color: var(--accent);
    flex-shrink: 0;
  }

  .spell-row-tag {
    font-family: var(--font-mono);
    font-size: 8px;
    font-weight: 600;
    padding: 1px 4px;
    border-radius: 3px;
    text-transform: uppercase;
    letter-spacing: 0.04em;
    flex-shrink: 0;
  }

  .spell-row-tag.conc {
    background: var(--accent-dim);
    color: var(--accent);
    opacity: 0.7;
  }

  .cast-btn {
    height: 22px;
    padding: 0 8px;
    background: var(--surface);
    border: 1px solid var(--border);
    color: var(--muted);
    border-radius: var(--radius-sm);
    font-size: 10px;
    font-weight: 600;
    font-family: var(--font-mono);
    flex-shrink: 0;
    transition: all 100ms;
  }

  .cast-btn:hover {
    color: var(--gold);
    border-color: var(--gold);
    background: var(--gold-dim);
  }

  /* Cast Log */
  .cast-log {
    display: flex;
    flex-direction: column;
    gap: 3px;
  }

  .cast-entry {
    display: flex;
    align-items: center;
    gap: 6px;
    padding: 4px 8px;
    background: var(--surface-2);
    border-radius: var(--radius-sm);
  }

  .cast-round {
    font-family: var(--font-mono);
    font-size: 9px;
    font-weight: 700;
    color: var(--muted);
    width: 20px;
    flex-shrink: 0;
  }

  .cast-spell {
    font-size: 11px;
    color: var(--fg);
    flex: 1;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  .cast-level {
    font-family: var(--font-mono);
    font-size: 9px;
    color: var(--muted);
    flex-shrink: 0;
  }
</style>

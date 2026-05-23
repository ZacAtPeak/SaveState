<script lang="ts">
  import type { Entity, CharacterSkill, CharacterSpell, SpellSlotGroup } from '$lib/types';
  import { groupByLevel } from '$lib/utils/spells';
  import SpellCard from '$lib/components/SpellCard.svelte';
  import { appStore } from '$lib/stores/app.svelte';

  interface Props {
    character: Entity;
    skills: CharacterSkill[];
    spells: CharacterSpell[];
  }

  let { character, skills, spells }: Props = $props();

  function getHpPercent(): number {
    return Math.max(0, Math.min(100, (character.hit_points_current / character.hit_points_max) * 100));
  }

  function getHpColor(): string {
    const ratio = character.hit_points_current / character.hit_points_max;
    if (ratio <= 0.25) return 'var(--red)';
    if (ratio <= 0.5) return 'var(--gold)';
    return 'var(--green)';
  }

  function getHpClass(): string {
    const ratio = character.hit_points_current / character.hit_points_max;
    if (ratio <= 0.25) return 'danger';
    if (ratio <= 0.5) return 'warn';
    return '';
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

  const abilityScores = [
    { key: 'strength', label: 'STR' },
    { key: 'dexterity', label: 'DEX' },
    { key: 'constitution', label: 'CON' },
    { key: 'intelligence', label: 'INT' },
    { key: 'wisdom', label: 'WIS' },
    { key: 'charisma', label: 'CHA' }
  ] as const;

  function getModifier(score: number): number {
    return Math.floor((score - 10) / 2);
  }

  let spellsByLevel = $derived(groupByLevel(spells));

  let slotGroups = $state<SpellSlotGroup[]>([]);
  let hasSlots = $state(false);
  $effect(() => {
    const groups = appStore.spellSlotGroups;
    slotGroups = groups;
    hasSlots = groups.length > 0 && groups.some(g => g.slots.length > 0);
  });

  function getLevelLabel(level: number): string {
    const suffix = level === 1 ? 'st' : level === 2 ? 'nd' : level === 3 ? 'rd' : 'th';
    return `${level}${suffix}`;
  }

  function getGroupLabel(group: SpellSlotGroup): string {
    if (group.group_type === 'pact_magic') {
      return `Pact Magic (${group.spellcasting_ability})`;
    }
    return `Spellcasting (${group.spellcasting_ability})`;
  }
</script>

<div class="detail-body">
  <div class="detail-top">
    <div class="detail-av">{@html getEntityIcon()}</div>
    <div class="detail-name-block">
      <div class="detail-name">{character.name}</div>
      <div class="detail-sub">{getSubtitle()}</div>
    </div>
    <button class="detail-fav on">★</button>
  </div>

  <div class="detail-hp-section">
    <div class="detail-hp-head">
      <span class="detail-hp-lbl">Hit Points</span>
      <span class="detail-hp-num {getHpClass()}">
        {character.hit_points_current} / {character.hit_points_max}
      </span>
    </div>
    <div class="detail-hp-bar">
      <div class="detail-hp-fill" style="width: {getHpPercent()}%; background: {getHpColor()}"></div>
    </div>

  </div>

  <div class="detail-stats-grid">
    <div class="dstat">
      <div class="dstat-label">AC</div>
      <div class="dstat-value">{character.armor_class}</div>
    </div>
    <div class="dstat">
      <div class="dstat-label">Speed</div>
      <div class="dstat-value">30</div>
    </div>
    <div class="dstat">
      <div class="dstat-label">Passive</div>
      <div class="dstat-value">10</div>
    </div>
  </div>

  <div>
    <div class="detail-section-title">Ability Scores</div>
    <div class="ability-grid">
      {#each abilityScores as ability}
        <div class="ability">
          <span class="ability-name">{ability.label}</span>
          <span class="ability-score">{character[ability.key]}</span>
          <span class="ability-modifier">{getModifier(character[ability.key]) >= 0 ? '+' : ''}{getModifier(character[ability.key])}</span>
        </div>
      {/each}
    </div>
  </div>

  {#if hasSlots}
    <div class="detail-section sticky">
      <div class="detail-section-title">Spell Slots</div>
      {#each slotGroups as group}
        <div class="slot-group">
          <div class="slot-group-header">
            <span class="slot-group-title">{getGroupLabel(group)}</span>
            <span class="slot-group-stats">DC {group.save_dc} · ATK {group.attack_bonus >= 0 ? '+' : ''}{group.attack_bonus}</span>
          </div>
          <div class="slot-levels">
            {#each group.slots as slot}
              <div class="slot-level" class:depleted={slot.current === 0}>
                <span class="slot-lvl-label">{getLevelLabel(slot.level)}</span>
                <div class="slot-dots">
                  {#each {length: slot.max} as _}
                    <span class="slot-dot" class:filled={slot.current > 0}></span>
                  {/each}
                </div>
                <span class="slot-fraction">{slot.current}/{slot.max}</span>
              </div>
            {/each}
          </div>
        </div>
      {/each}
    </div>
  {/if}

  {#if skills.length > 0}
    <div>
      <div class="detail-section-title">Skills</div>
      <div class="skills-grid">
        {#each skills as skill}
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
  {/if}

  {#if spells.length > 0}
    <div>
      <div class="detail-section-title">Spells</div>
      {#each spellsByLevel as group}
        <div class="spell-group">
          <div class="spell-level-header">{group.label}</div>
          <div class="spell-grid">
            {#each group.spells as spell}
              <SpellCard {spell} compact />
            {/each}
          </div>
        </div>
      {/each}
    </div>
  {/if}

  <div class="detail-conds">
    <span class="no-conds">No active conditions</span>
  </div>
</div>

<style>
  .detail-body {
    flex: 1;
    padding: 24px;
    display: flex;
    flex-direction: column;
    gap: 20px;
  }

  .detail-top {
    display: flex;
    align-items: flex-start;
    gap: 16px;
  }

  .detail-av {
    width: 56px;
    height: 56px;
    flex-shrink: 0;
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: var(--radius-lg);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 28px;
  }

  .detail-name-block {
    flex: 1;
    min-width: 0;
  }

  .detail-name {
    font-family: var(--font-display);
    font-size: 24px;
    font-weight: 600;
    color: var(--fg);
    line-height: 1.2;
  }

  .detail-sub {
    font-size: 13px;
    color: var(--muted);
    margin-top: 4px;
  }

  .detail-fav {
    background: none;
    border: none;
    font-size: 24px;
    color: var(--border);
    transition: color 120ms;
    padding: 4px;
  }

  .detail-fav.on, .detail-fav:hover { color: var(--gold); }

  .detail-hp-section {
    display: flex;
    flex-direction: column;
    gap: 10px;
  }

  .detail-hp-head {
    display: flex;
    align-items: center;
    gap: 10px;
  }

  .detail-hp-lbl {
    font-family: var(--font-mono);
    font-size: 11px;
    text-transform: uppercase;
    letter-spacing: 0.07em;
    color: var(--muted);
  }

  .detail-hp-num {
    font-family: var(--font-mono);
    font-size: 14px;
    font-weight: 700;
    color: var(--fg);
    font-variant-numeric: tabular-nums;
  }

  .detail-hp-num.danger { color: var(--red); }
  .detail-hp-num.warn { color: var(--gold); }

  .detail-hp-bar {
    height: 8px;
    background: var(--surface-2);
    border-radius: var(--radius-sm);
    overflow: hidden;
  }

  .detail-hp-fill {
    height: 100%;
    border-radius: var(--radius-sm);
    transition: width 220ms ease;
  }

  .detail-section-title {
    font-family: var(--font-mono);
    font-size: 10px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.10em;
    color: var(--muted);
    padding: 0 0 8px 0;
    border-bottom: 1px solid var(--border);
    margin-bottom: 4px;
  }

  .detail-section.sticky {
    position: sticky;
    top: 0;
    z-index: 1;
    background: var(--bg);
    padding: 8px 0 12px 0;
    border-bottom: 1px solid var(--border);
    margin-bottom: 4px;
  }

  .detail-section.sticky .detail-section-title {
    border-bottom: none;
    margin-bottom: 8px;
    padding-bottom: 0;
  }

  .detail-stats-grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 8px;
  }

  .dstat {
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: var(--radius-md);
    padding: 12px;
    display: flex;
    flex-direction: column;
    gap: 4px;
  }

  .dstat-label {
    font-family: var(--font-mono);
    font-size: 9px;
    text-transform: uppercase;
    letter-spacing: 0.08em;
    color: var(--muted);
  }

  .dstat-value {
    font-family: var(--font-mono);
    font-size: 22px;
    font-weight: 700;
    color: var(--fg);
    font-variant-numeric: tabular-nums;
  }

  .ability-grid {
    display: grid;
    grid-template-columns: repeat(6, 1fr);
    gap: 8px;
  }

  .ability {
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: var(--radius-md);
    padding: 12px 8px;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 4px;
  }

  .ability-name {
    font-family: var(--font-mono);
    font-size: 10px;
    font-weight: 600;
    color: var(--muted);
    text-transform: uppercase;
    letter-spacing: 0.05em;
  }

  .ability-score {
    font-family: var(--font-mono);
    font-size: 20px;
    font-weight: 700;
    color: var(--fg);
  }

  .ability-modifier {
    font-family: var(--font-mono);
    font-size: 11px;
    font-weight: 500;
    color: var(--muted);
  }

  .detail-conds {
    display: flex;
    flex-wrap: wrap;
    gap: 6px;
  }

  .no-conds {
    font-size: 12px;
    color: var(--muted);
    font-style: italic;
  }

  .skills-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
    gap: 6px;
  }

  .skill {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    gap: 4px;
    padding: 8px 10px;
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: var(--radius-sm);
  }

  .skill-name {
    font-size: 12px;
    font-weight: 600;
    color: var(--fg);
  }

  .skill-ability {
    font-family: var(--font-mono);
    font-size: 10px;
    color: var(--muted);
  }

  .skill-modifier {
    font-family: var(--font-mono);
    font-size: 13px;
    font-weight: 700;
    color: var(--gold);
    margin-left: auto;
  }

  .skill-badge {
    font-family: var(--font-mono);
    font-size: 9px;
    padding: 2px 5px;
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

  .slot-group {
    margin-bottom: 10px;
    display: flex;
    flex-direction: column;
    gap: 6px;
  }

  .slot-group-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 8px;
  }

  .slot-group-title {
    font-family: var(--font-mono);
    font-size: 11px;
    font-weight: 600;
    color: var(--fg);
  }

  .slot-group-stats {
    font-family: var(--font-mono);
    font-size: 10px;
    color: var(--muted);
  }

  .slot-levels {
    display: flex;
    flex-wrap: wrap;
    gap: 6px;
  }

  .slot-level {
    display: flex;
    align-items: center;
    gap: 6px;
    padding: 5px 8px;
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: var(--radius-sm);
  }

  .slot-level.depleted {
    opacity: 0.4;
  }

  .slot-lvl-label {
    font-family: var(--font-mono);
    font-size: 9px;
    font-weight: 600;
    color: var(--muted);
    min-width: 16px;
  }

  .slot-dots {
    display: flex;
    gap: 3px;
  }

  .slot-dot {
    width: 8px;
    height: 8px;
    border-radius: 50%;
    background: var(--surface-3);
    border: 1px solid var(--border);
  }

  .slot-dot.filled {
    background: var(--accent);
    border-color: var(--accent);
  }

  .slot-fraction {
    font-family: var(--font-mono);
    font-size: 10px;
    font-weight: 600;
    color: var(--fg);
    font-variant-numeric: tabular-nums;
  }

  .spell-group {
    margin-bottom: 8px;
  }

  .spell-level-header {
    font-family: var(--font-mono);
    font-size: 10px;
    font-weight: 600;
    color: var(--muted);
    text-transform: uppercase;
    letter-spacing: 0.06em;
    margin-bottom: 4px;
    padding: 2px 0;
    border-bottom: 1px solid var(--border);
  }

  .spell-grid {
    display: flex;
    flex-direction: column;
    gap: 3px;
  }


</style>
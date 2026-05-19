<script lang="ts">
  import type { Entity, CharacterSkill } from '$lib/types';

  interface Props {
    character: Entity;
    skills: CharacterSkill[];
    onHpChange?: (delta: number) => void;
  }

  let { character, skills, onHpChange }: Props = $props();

  function adjustHp(delta: number) {
    if (onHpChange) {
      onHpChange(delta);
    }
  }

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
    return '<svg xmlns="http://www.w3.org/2000/svg" width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 3c-1.5 0-2.5 1-3 2-1 0-2.5 0-4 1.5-1.5 1.5-2 4-1.5 6 .5 2 2 4 3.5 5s3.5 1.5 5 0 3-3 3.5-5 .5-4.5-1.5-6C14.5 4 13 3 12 3z"/><path d="M10 14s.5-1 1-1 1 1 1 1"/><path d="M13 18s.5-1 1-1 1 1 1 1"/><circle cx="12" cy="10" r="1"/></svg>';
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
    <div class="detail-hp-adj">
      <button class="hp-btn danger-btn" onclick={() => adjustHp(-10)}>−10</button>
      <button class="hp-btn" onclick={() => adjustHp(-5)}>−5</button>
      <button class="hp-btn" onclick={() => adjustHp(-1)}>−1</button>
      <button class="hp-btn" onclick={() => adjustHp(1)}>+1</button>
      <button class="hp-btn" onclick={() => adjustHp(5)}>+5</button>
      <button class="hp-btn" onclick={() => adjustHp(10)}>+10</button>
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

  .detail-hp-adj {
    display: flex;
    gap: 6px;
  }

  .hp-btn {
    flex: 1;
    height: 32px;
    background: var(--surface);
    border: 1px solid var(--border);
    color: var(--muted);
    border-radius: var(--radius-sm);
    font-size: 12px;
    font-family: var(--font-mono);
    font-weight: 500;
    transition: all 100ms;
  }

  .hp-btn:hover {
    color: var(--fg);
    border-color: var(--gold);
    background: var(--gold-dim);
  }

  .hp-btn.danger-btn {
    border-color: var(--red);
    color: var(--red);
  }

  .hp-btn.danger-btn:hover {
    background: var(--red-dim);
  }

  .detail-section-title {
    font-family: var(--font-mono);
    font-size: 10px;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.10em;
    color: var(--muted);
    padding-bottom: 8px;
    border-bottom: 1px solid var(--border);
    margin-bottom: 4px;
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
</style>
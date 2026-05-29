<script lang="ts">
  import type { Entity, CharacterSkill, CharacterSpell, CharacterActionWithSource, InventoryItemResponse, SpellSlotGroup } from '$lib/types';
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

  // ── Actions with source (innate + item) ──────────────────────────
  let characterActions = $state<CharacterActionWithSource[]>([]);
  $effect(() => {
    characterActions = appStore.characterActionsWithSource;
  });

  let actionGroups = $derived.by(() => {
    const groups: { label: string; type: string; actions: CharacterActionWithSource[] }[] = [];
    const order = ['action', 'bonus_action', 'reaction'];
    const labels: Record<string, string> = {
      action: 'Actions',
      bonus_action: 'Bonus Actions',
      reaction: 'Reactions'
    };
    for (const t of order) {
      const filtered = characterActions.filter(a => a.action_type === t);
      if (filtered.length > 0) {
        groups.push({ label: labels[t], type: t, actions: filtered });
      }
    }
    return groups;
  });

  // ── Inventory ─────────────────────────────────────────────────────
  let inventory = $state<InventoryItemResponse[]>([]);
  $effect(() => {
    inventory = appStore.characterInventory;
  });

  let equippedItems = $derived(inventory.filter(i => i.is_equipped));
  let unequippedItems = $derived(inventory.filter(i => !i.is_equipped));

  function getWeaponDamageLabel(item: InventoryItemResponse): string {
    const wp = item.weapon_profile;
    if (!wp) return '';
    const dmg = `${wp.damage_dice} ${wp.damage_type}`;
    if (wp.versatile_dice) return `${dmg} (${wp.versatile_dice})`;
    return dmg;
  }

  function getWeaponProperties(item: InventoryItemResponse): string {
    const wp = item.weapon_profile;
    if (!wp?.properties) return '';
    try {
      const props: string[] = JSON.parse(wp.properties);
      return props.join(', ');
    } catch {
      return wp.properties;
    }
  }

  function handleEquip(itemId: string, slot: string) {
    appStore.equipItem(itemId, slot);
  }

  function handleUnequip(itemId: string) {
    appStore.unequipItem(itemId);
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
            <span class="slot-group-title">DC {group.save_dc} · ATK {group.attack_bonus >= 0 ? '+' : ''}{group.attack_bonus}</span>
          </div>
          <div class="slot-levels">
            {#each group.slots as slot}
              <div class="slot-level" class:depleted={slot.current === 0}>
                <span class="slot-lvl-label">{getLevelLabel(slot.level)}</span>
                <div class="slot-dots">
                  {#each {length: slot.max} as _, i}
                    <span class="slot-dot" class:filled={i < slot.current}></span>
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

  {#if spells.length > 0 || actionGroups.length > 0}
    <div class="spells-actions-grid">
      {#if spells.length > 0}
        <div class="col-spells">
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
      {#if actionGroups.length > 0}
        <div class="col-actions">
          <div class="detail-section-title">Combat Actions</div>
          {#each actionGroups as group}
            <div class="action-type-group">
              <div class="action-type-header">{group.label}</div>
              <div class="action-list">
                {#each group.actions as action}
                  <div class="action-card" class:action-source-item={action.source === 'item'}>
                    <div class="action-card-name">
                      {action.name}
                      {#if action.is_attack && action.attack_bonus}
                        <span class="action-atk">+{action.attack_bonus} to hit</span>
                      {/if}
                    </div>
                    {#if action.damage_dice}
                      <div class="action-damage">
                        {action.damage_dice}{#if action.damage_type} {action.damage_type}{/if}
                      </div>
                    {/if}
                    {#if action.uses_per_day}
                      <div class="action-uses">
                        {action.uses_current ?? action.uses_per_day}/{action.uses_per_day} per day
                      </div>
                    {/if}
                    {#if action.recharge_formula}
                      <div class="action-recharge">{action.recharge_formula}</div>
                    {/if}
                    {#if action.source === 'item' && action.source_item_name}
                      <div class="action-source-badge">from {action.source_item_name}</div>
                    {/if}
                    <div class="action-desc">{action.description}</div>
                  </div>
                {/each}
              </div>
            </div>
          {/each}
        </div>
      {/if}
    </div>
  {/if}

  {#if inventory.length > 0}
    <div>
      <div class="detail-section-title">Inventory</div>

      {#if equippedItems.length > 0}
        <div class="inventory-group">
          <div class="inv-subtitle">Equipped</div>
          <div class="inventory-grid">
            {#each equippedItems as item}
              <div class="inv-card">
                <div class="inv-card-head">
                  <span class="inv-card-name">{item.item.name}</span>
                  <span class="inv-card-slot">{item.equipped_slot ?? 'equipped'}</span>
                </div>
                {#if item.weapon_profile}
                  <div class="inv-weapon-info">
                    <span class="inv-damage">{getWeaponDamageLabel(item)}</span>
                    {#if item.weapon_profile.weapon_range === 'ranged'}
                      <span class="inv-range">Range {item.weapon_profile.range_normal}/{item.weapon_profile.range_long} ft</span>
                    {/if}
                  </div>
                  {#if getWeaponProperties(item)}
                    <div class="inv-props">{getWeaponProperties(item)}</div>
                  {/if}
                {/if}
                <div class="inv-card-actions">
                  <span class="inv-qty">×{item.quantity}</span>
                  <button class="inv-btn" onclick={() => handleUnequip(item.item.id)} aria-label="Unequip">Unequip</button>
                </div>
              </div>
            {/each}
          </div>
        </div>
      {/if}

      {#if unequippedItems.length > 0}
        <div class="inventory-group">
          <div class="inv-subtitle">Inventory</div>
          <div class="inventory-grid">
            {#each unequippedItems as item}
              <div class="inv-card inv-inventory">
                <div class="inv-card-head">
                  <span class="inv-card-name">{item.item.name}</span>
                  <span class="inv-qty-label">×{item.quantity}</span>
                </div>
                {#if item.weapon_profile}
                  <div class="inv-weapon-info">
                    <span class="inv-damage">{getWeaponDamageLabel(item)}</span>
                  </div>
                {/if}
                <div class="inv-card-actions">
                  {#if item.item.item_type === 'weapon'}
                    <button class="inv-btn equip-btn" onclick={() => handleEquip(item.item.id, 'weapon_main')}>Equip (Main)</button>
                    <button class="inv-btn" onclick={() => handleEquip(item.item.id, 'weapon_offhand')}>Off-hand</button>
                  {:else}
                    <button class="inv-btn equip-btn" onclick={() => handleEquip(item.item.id, 'item')}>Equip</button>
                  {/if}
                </div>
              </div>
            {/each}
          </div>
        </div>
      {/if}
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

  .spells-actions-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 16px;
  }

  .spells-actions-grid > :only-child {
    grid-column: 1 / -1;
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

  .action-type-group {
    margin-bottom: 10px;
  }

  .action-type-header {
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

  .action-list {
    display: flex;
    flex-direction: column;
    gap: 6px;
  }

  .action-card {
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: var(--radius-md);
    padding: 10px 12px;
    display: flex;
    flex-direction: column;
    gap: 4px;
  }

  .action-source-item {
    border-left: 3px solid var(--accent);
  }

  .action-card-name {
    font-size: 13px;
    font-weight: 600;
    color: var(--fg);
    display: flex;
    align-items: center;
    gap: 8px;
  }

  .action-atk {
    font-family: var(--font-mono);
    font-size: 10px;
    font-weight: 500;
    color: var(--accent);
    background: var(--accent-dim);
    padding: 1px 6px;
    border-radius: 4px;
  }

  .action-damage {
    font-family: var(--font-mono);
    font-size: 12px;
    font-weight: 700;
    color: var(--red);
  }

  .action-uses {
    font-family: var(--font-mono);
    font-size: 10px;
    color: var(--muted);
    font-weight: 500;
  }

  .action-recharge {
    font-family: var(--font-mono);
    font-size: 10px;
    color: var(--gold);
    font-weight: 500;
  }

  .action-source-badge {
    font-family: var(--font-mono);
    font-size: 9px;
    color: var(--accent);
    background: var(--accent-dim);
    padding: 1px 6px;
    border-radius: 4px;
    width: fit-content;
  }

  .action-desc {
    font-size: 11px;
    color: var(--muted);
    line-height: 1.4;
  }

  /* ── Inventory Styles ─────────────────────────────────────────── */

  .inventory-group {
    margin-bottom: 12px;
  }

  .inv-subtitle {
    font-family: var(--font-mono);
    font-size: 10px;
    font-weight: 600;
    color: var(--muted);
    text-transform: uppercase;
    letter-spacing: 0.06em;
    margin-bottom: 6px;
  }

  .inventory-grid {
    display: flex;
    flex-direction: column;
    gap: 6px;
  }

  .inv-card {
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: var(--radius-md);
    padding: 10px 12px;
    display: flex;
    flex-direction: column;
    gap: 4px;
  }

  .inv-card.inv-inventory {
    border-style: dashed;
    opacity: 0.85;
  }

  .inv-card-head {
    display: flex;
    align-items: center;
    gap: 8px;
  }

  .inv-card-name {
    font-size: 13px;
    font-weight: 600;
    color: var(--fg);
  }

  .inv-card-slot {
    font-family: var(--font-mono);
    font-size: 9px;
    color: var(--accent);
    background: var(--accent-dim);
    padding: 1px 5px;
    border-radius: 3px;
    text-transform: uppercase;
    letter-spacing: 0.04em;
  }

  .inv-qty {
    font-family: var(--font-mono);
    font-size: 10px;
    color: var(--muted);
    font-variant-numeric: tabular-nums;
  }

  .inv-qty-label {
    font-family: var(--font-mono);
    font-size: 10px;
    color: var(--muted);
    margin-left: auto;
  }

  .inv-weapon-info {
    display: flex;
    align-items: center;
    gap: 10px;
  }

  .inv-damage {
    font-family: var(--font-mono);
    font-size: 12px;
    font-weight: 700;
    color: var(--red);
  }

  .inv-range {
    font-family: var(--font-mono);
    font-size: 10px;
    color: var(--muted);
  }

  .inv-props {
    font-family: var(--font-mono);
    font-size: 10px;
    color: var(--muted);
    text-transform: lowercase;
  }

  .inv-card-actions {
    display: flex;
    align-items: center;
    gap: 6px;
    margin-top: 2px;
  }

  .inv-btn {
    height: 26px;
    padding: 0 8px;
    background: var(--surface-2);
    border: 1px solid var(--border);
    color: var(--muted);
    border-radius: var(--radius-sm);
    font-size: 10px;
    font-weight: 600;
    transition: all 120ms;
  }

  .inv-btn:hover {
    color: var(--fg);
    border-color: var(--gold);
  }

  .inv-btn.equip-btn {
    color: var(--green);
  }

  .inv-btn.equip-btn:hover {
    background: var(--green-dim);
    border-color: var(--green);
  }
</style>

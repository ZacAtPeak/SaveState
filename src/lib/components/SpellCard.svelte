<script lang="ts">
  import type { CharacterSpell, SpellSlotGroup } from '$lib/types';
  import { appStore } from '$lib/stores/app.svelte';

  interface Props {
    spell: CharacterSpell;
    compact?: boolean;
    spellSlotGroups?: SpellSlotGroup[];
  }

  let { spell, compact = false, spellSlotGroups = [] }: Props = $props();

  $effect(() => {
    // Use provided groups or fall back to store
    if (spellSlotGroups.length === 0) {
      spellSlotGroups = appStore.spellSlotGroups;
    }
  });

  // Find if a slot is available at the spell's level or any higher level
  function findAvailableSlot(): { groupType: string; level: number } | null {
    // Cantrips don't consume slots
    if (spell.level === 0) return null;

    const groups = spellSlotGroups.length > 0 ? spellSlotGroups : appStore.spellSlotGroups;

    for (const group of groups) {
      const slots = group.slots;
      // Try exact level first
      let exactSlot = slots.find(s => s.level === spell.level);
      if (exactSlot && exactSlot.current > 0) {
        return { groupType: group.group_type, level: exactSlot.level };
      }
      // Try upcast — find next higher level with slots
      let upcastSlot = slots
        .filter(s => s.level > spell.level && s.current > 0)
        .sort((a, b) => a.level - b.level)[0];
      if (upcastSlot) {
        return { groupType: group.group_type, level: upcastSlot.level };
      }
    }

    return null;
  }

  let canCast = $derived(spell.level === 0 || findAvailableSlot() !== null);

  function handleCast() {
    if (spell.level === 0) {
      // Cantrip — no slot consumed, just visual feedback
      return;
    }

    const available = findAvailableSlot();
    if (!available) return;

    appStore.consumeSlot(available.groupType, available.level);
  }
</script>

<div class="spell-card" class:compact>
  <div class="spell-name-row">
    <span class="spell-prep-dot" class:prepared={spell.is_prepared}></span>
    <span class="spell-name">{spell.name}</span>
    <span class="spell-level-badge">{spell.level === 0 ? 'C' : spell.level}</span>
    <span class="spell-school">{spell.school}</span>
    <button
      class="cast-btn"
      disabled={!canCast}
      onclick={handleCast}
      title={spell.level === 0 ? 'Cast cantrip (no slot consumed)' : canCast ? 'Cast spell' : 'No available spell slots'}
    >
      Cast
    </button>
  </div>
  <div class="spell-badges">
    {#if spell.is_concentration}<span class="spell-tag">Concentration</span>{/if}
    {#if spell.is_ritual}<span class="spell-tag">Ritual</span>{/if}
  </div>
  <div class="spell-desc">{spell.description}</div>
</div>

<style>
  .spell-card {
    padding: 12px 14px;
    background: var(--surface-2);
    border: 1px solid var(--border);
    border-radius: var(--radius-sm);
  }

  .spell-card.compact {
    padding: 8px 10px;
    background: var(--surface);
  }

  .spell-name-row {
    display: flex;
    align-items: center;
    gap: 6px;
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

  .spell-name {
    font-size: 12px;
    font-weight: 600;
    color: var(--fg);
    line-height: 1.3;
  }

  .spell-level-badge {
    font-family: var(--font-mono);
    font-size: 9px;
    font-weight: 700;
    padding: 1px 5px;
    border-radius: 3px;
    background: var(--accent-dim);
    color: var(--accent);
    flex-shrink: 0;
  }

  .spell-school {
    font-family: var(--font-mono);
    font-size: 9px;
    color: var(--muted);
    margin-left: auto;
  }

  .cast-btn {
    font-family: var(--font-mono);
    font-size: 9px;
    font-weight: 700;
    padding: 3px 8px;
    border-radius: 3px;
    background: var(--gold-dim);
    color: var(--gold);
    border: 1px solid var(--gold);
    cursor: pointer;
    transition: all 120ms;
    flex-shrink: 0;
    text-transform: uppercase;
    letter-spacing: 0.05em;
  }

  .cast-btn:hover:not(:disabled) {
    background: var(--gold);
    color: oklch(11% 0.012 250);
  }

  .cast-btn:disabled {
    opacity: 0.3;
    cursor: not-allowed;
    background: var(--surface-3);
    border-color: var(--border);
    color: var(--muted);
  }

  .spell-badges {
    display: flex;
    gap: 4px;
    margin-top: 4px;
    padding-left: 12px;
  }

  .spell-tag {
    font-family: var(--font-mono);
    font-size: 8px;
    padding: 1px 5px;
    border-radius: 3px;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.04em;
    background: var(--accent-dim);
    color: var(--accent);
  }

  .spell-desc {
    font-size: 11px;
    color: var(--muted);
    line-height: 1.4;
    margin-top: 4px;
    padding-left: 12px;
    display: -webkit-box;
    -webkit-line-clamp: 2;
    -webkit-box-orient: vertical;
    overflow: hidden;
  }
</style>

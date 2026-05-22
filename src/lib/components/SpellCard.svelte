<script lang="ts">
  import type { CharacterSpell } from '$lib/types';

  interface Props {
    spell: CharacterSpell;
    compact?: boolean;
  }

  let { spell, compact = false }: Props = $props();
</script>

<div class="spell-card" class:compact>
  <div class="spell-name-row">
    <span class="spell-prep-dot" class:prepared={spell.is_prepared}></span>
    <span class="spell-name">{spell.name}</span>
    <span class="spell-level-badge">{spell.level === 0 ? 'C' : spell.level}</span>
    <span class="spell-school">{spell.school}</span>
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

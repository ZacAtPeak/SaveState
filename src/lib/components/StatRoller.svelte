<script lang="ts">
  import type { StatRollMethod } from '$lib/types';

  const ABILITIES = ['Strength', 'Dexterity', 'Constitution', 'Intelligence', 'Wisdom', 'Charisma'];
  const ABILITY_KEYS = ['strength', 'dexterity', 'constitution', 'intelligence', 'wisdom', 'charisma'];
  const STANDARD_ARRAY = [15, 14, 13, 12, 10, 8];

  const POINT_BUY_COST: Record<number, number> = { 8: 0, 9: 1, 10: 2, 11: 3, 12: 4, 13: 5, 14: 7, 15: 9 };
  const POINT_BUY_MAX = 27;

  interface Props {
    method: StatRollMethod;
    scores: number[];
    onChange: (scores: number[], method: StatRollMethod) => void;
  }

  let { method, scores, onChange }: Props = $props();

  // Point buy state
  let remainingBudget = $derived(POINT_BUY_MAX - scores.reduce((sum, s) => sum + (POINT_BUY_COST[s] || 0), 0));

  // Rolled state
  let rolledValues: number[] = $state([]);

  // Standard array assignment state
  let assignedSlots: (number | null)[] = $state([null, null, null, null, null, null]);
  let availableValues = $state<number[]>([...STANDARD_ARRAY]);

  function handleMethodChange(newMethod: StatRollMethod) {
    method = newMethod;
    if (newMethod === 'standard_array') {
      assignedSlots = [null, null, null, null, null, null];
      availableValues = [...STANDARD_ARRAY];
      onChange([...STANDARD_ARRAY], newMethod);
    } else if (newMethod === 'point_buy') {
      onChange([8, 8, 8, 8, 8, 8], newMethod);
    } else if (newMethod === 'rolled') {
      rolledValues = [];
      onChange([10, 10, 10, 10, 10, 10], newMethod);
    } else if (newMethod === 'manual') {
      onChange([10, 10, 10, 10, 10, 10], newMethod);
    }
  }

  // Standard Array: assign value to ability slot
  function assignValue(value: number, abilityIndex: number) {
    if (assignedSlots[abilityIndex] === value) {
      // Unassign
      assignedSlots[abilityIndex] = null;
      availableValues = [...availableValues, value].sort((a, b) => b - a);
    } else if (assignedSlots[abilityIndex] !== null) {
      // Swap: return old value to pool
      const oldVal = assignedSlots[abilityIndex]!;
      assignedSlots[abilityIndex] = value;
      availableValues = availableValues.filter(v => v !== value);
      availableValues.push(oldVal);
      availableValues.sort((a, b) => b - a);
    } else {
      // Assign
      assignedSlots[abilityIndex] = value;
      availableValues = availableValues.filter(v => v !== value);
    }

    const newScores = assignedSlots.map(s => s ?? 8);
    onChange(newScores, method);
  }

  // Point Buy: adjust score
  function adjustPointBuy(abilityIndex: number, delta: number) {
    const newScores = [...scores];
    const current = newScores[abilityIndex];
    const newVal = current + delta;

    if (newVal < 8 || newVal > 15) return;

    const currentCost = POINT_BUY_COST[current] || 0;
    const newCost = POINT_BUY_COST[newVal] || 0;
    const costDiff = newCost - currentCost;

    if (remainingBudget - costDiff < 0) return;

    newScores[abilityIndex] = newVal;
    onChange(newScores, method);
  }

  // Roll 4d6 drop lowest
  function rollStats() {
    const rolls: number[] = [];
    for (let i = 0; i < 6; i++) {
      const dice = Array.from({ length: 4 }, () => Math.floor(Math.random() * 6) + 1);
      dice.sort((a, b) => b - a);
      rolls.push(dice[0] + dice[1] + dice[2]);
    }
    rolledValues = [...rolls];
    onChange([...rolls], method);
  }

  // Re-roll a single stat
  function rerollStat(abilityIndex: number) {
    const dice = Array.from({ length: 4 }, () => Math.floor(Math.random() * 6) + 1);
    dice.sort((a, b) => b - a);
    const newVal = dice[0] + dice[1] + dice[2];
    const newScores = [...scores];
    newScores[abilityIndex] = newVal;
    const newRolled = [...rolledValues];
    newRolled[abilityIndex] = newVal;
    rolledValues = newRolled;
    onChange(newScores, method);
  }

  // Manual: update score
  function updateManual(abilityIndex: number, value: number) {
    const clamped = Math.max(1, Math.min(30, value));
    const newScores = [...scores];
    newScores[abilityIndex] = clamped;
    onChange(newScores, method);
  }

  // Compute ability modifier
  function abilityMod(val: number): string {
    const mod = Math.floor((val - 10) / 2);
    return mod >= 0 ? `+${mod}` : `${mod}`;
  }

  function getScore(abilityIndex: number): number {
    if (method === 'standard_array') return assignedSlots[abilityIndex] ?? 8;
    return scores[abilityIndex] ?? 10;
  }
</script>

<div class="stat-roller">
  <div class="method-tabs">
    {#each ['standard_array', 'point_buy', 'rolled', 'manual'] as tabMethod}
      <button
        class="method-tab"
        class:active={method === tabMethod}
        onclick={() => handleMethodChange(tabMethod as StatRollMethod)}
      >
        {tabMethod === 'standard_array' ? 'Standard Array' :
         tabMethod === 'point_buy' ? 'Point Buy' :
         tabMethod === 'rolled' ? '4d6 Drop' : 'Manual'}
      </button>
    {/each}
  </div>

  <div class="ability-grid">
    {#each ABILITIES as ability, i}
      <div class="ability-slot">
        <span class="ability-label">{ability}</span>

        {#if method === 'standard_array'}
          <div class="score-value" class:assigned={assignedSlots[i] !== null}>
            {assignedSlots[i] ?? '-'}
          </div>
          <div class="ability-mod">{abilityMod(getScore(i))}</div>
        {:else if method === 'point_buy'}
          <div class="score-controls">
            <button class="btn-adj" onclick={() => adjustPointBuy(i, -1)} disabled={scores[i] <= 8}>−</button>
            <div class="score-value">{scores[i] ?? 8}</div>
            <button class="btn-adj" onclick={() => adjustPointBuy(i, 1)} disabled={scores[i] >= 15}>+</button>
          </div>
          <div class="ability-mod">{abilityMod(scores[i] ?? 8)}</div>
          <div class="cost-label">Cost: {POINT_BUY_COST[scores[i]] || 0}</div>
        {:else if method === 'rolled'}
          <div class="score-value">{getScore(i)}</div>
          <div class="ability-mod">{abilityMod(getScore(i))}</div>
          <button class="btn-reroll" onclick={() => rerollStat(i)} title="Re-roll this stat">⟳</button>
        {:else if method === 'manual'}
          <input
            type="number"
            min="1"
            max="30"
            value={scores[i] ?? 10}
            oninput={(e) => updateManual(i, parseInt((e.target as HTMLInputElement).value) || 10)}
            class="score-input"
          />
          <div class="ability-mod">{abilityMod(scores[i] ?? 10)}</div>
        {/if}
      </div>
    {/each}
  </div>

  {#if method === 'standard_array'}
    <div class="pool-section">
      <span class="pool-label">Available Values:</span>
      <div class="pool-values">
        {#each availableValues as val}
          <button
            class="pool-value"
            onclick={() => {
              const firstEmpty = assignedSlots.findIndex(s => s === null);
              if (firstEmpty >= 0) assignValue(val, firstEmpty);
            }}
            disabled={!assignedSlots.some(s => s === null)}
          >
            {val}
          </button>
        {/each}
        {#if availableValues.length === 0}
          <span class="pool-empty">All assigned</span>
        {/if}
      </div>
    </div>
  {/if}

  {#if method === 'point_buy'}
    <div class="budget-display">
      <span>Remaining Budget:</span>
      <span class:budget-warn={remainingBudget < 0} class:budget-ok={remainingBudget >= 0}>
        {remainingBudget} / {POINT_BUY_MAX}
      </span>
    </div>
  {/if}

  {#if method === 'rolled'}
    <button class="btn-roll" onclick={rollStats}>
      🎲 Roll All
    </button>
  {/if}
</div>

<style>
  .stat-roller {
    display: flex;
    flex-direction: column;
    gap: 12px;
  }

  .method-tabs {
    display: flex;
    gap: 4px;
    background: var(--surface-2);
    border-radius: var(--radius-sm);
    padding: 3px;
  }

  .method-tab {
    flex: 1;
    padding: 6px 8px;
    border: none;
    background: transparent;
    color: var(--muted);
    font-size: 11px;
    font-weight: 600;
    border-radius: 4px;
    cursor: pointer;
    transition: all 120ms;
    text-transform: uppercase;
    letter-spacing: 0.04em;
  }

  .method-tab.active {
    background: var(--gold);
    color: oklch(11% 0.012 250);
  }

  .method-tab:hover:not(.active) {
    color: var(--fg);
  }

  .ability-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 8px;
  }

  .ability-slot {
    display: flex;
    align-items: center;
    gap: 6px;
    padding: 6px 8px;
    background: var(--surface-2);
    border: 1px solid var(--border);
    border-radius: var(--radius-sm);
  }

  .ability-label {
    font-size: 10px;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.04em;
    color: var(--muted);
    min-width: 60px;
  }

  .score-value {
    font-size: 16px;
    font-weight: 700;
    color: var(--fg);
    min-width: 30px;
    text-align: center;
  }

  .score-value.assigned {
    color: var(--gold);
  }

  .ability-mod {
    font-size: 11px;
    color: var(--muted);
    min-width: 20px;
    text-align: center;
  }

  .score-controls {
    display: flex;
    align-items: center;
    gap: 4px;
  }

  .btn-adj {
    width: 22px;
    height: 22px;
    border: 1px solid var(--border);
    background: var(--surface);
    color: var(--fg);
    border-radius: 4px;
    cursor: pointer;
    font-size: 14px;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: all 120ms;
  }

  .btn-adj:hover:not(:disabled) {
    border-color: var(--gold);
    color: var(--gold);
  }

  .btn-adj:disabled {
    opacity: 0.3;
    cursor: not-allowed;
  }

  .cost-label {
    font-size: 9px;
    color: var(--muted);
    min-width: 30px;
    text-align: right;
  }

  .pool-section {
    display: flex;
    align-items: center;
    gap: 8px;
  }

  .pool-label {
    font-size: 11px;
    color: var(--muted);
    font-weight: 600;
  }

  .pool-values {
    display: flex;
    gap: 4px;
  }

  .pool-value {
    width: 28px;
    height: 28px;
    border: 1px solid var(--border);
    background: var(--surface);
    color: var(--fg);
    border-radius: 4px;
    cursor: pointer;
    font-size: 12px;
    font-weight: 600;
    transition: all 120ms;
  }

  .pool-value:hover:not(:disabled) {
    border-color: var(--gold);
    color: var(--gold);
  }

  .pool-value:disabled {
    opacity: 0.3;
    cursor: not-allowed;
  }

  .pool-empty {
    font-size: 11px;
    color: var(--muted);
    font-style: italic;
  }

  .budget-display {
    display: flex;
    justify-content: space-between;
    font-size: 12px;
    font-weight: 600;
    padding: 6px 10px;
    background: var(--surface-2);
    border-radius: var(--radius-sm);
  }

  .budget-ok { color: oklch(70% 0.15 145); }
  .budget-warn { color: oklch(70% 0.2 30); }

  .btn-roll {
    padding: 8px 16px;
    border: 1px solid var(--border);
    background: var(--surface);
    color: var(--fg);
    border-radius: var(--radius-sm);
    cursor: pointer;
    font-size: 13px;
    font-weight: 600;
    transition: all 120ms;
  }

  .btn-roll:hover {
    border-color: var(--gold);
    color: var(--gold);
  }

  .score-input {
    width: 40px;
    padding: 4px;
    background: var(--bg);
    border: 1px solid var(--border);
    border-radius: 4px;
    color: var(--fg);
    font-size: 14px;
    font-weight: 700;
    text-align: center;
  }

  .score-input:focus {
    outline: none;
    border-color: var(--gold);
  }

  .btn-reroll {
    width: 22px;
    height: 22px;
    border: none;
    background: transparent;
    color: var(--muted);
    cursor: pointer;
    font-size: 14px;
    transition: all 120ms;
  }

  .btn-reroll:hover {
    color: var(--gold);
  }
</style>

<script lang="ts">
  import { appStore } from '$lib/stores/app.svelte';
  import type { DiceRoll } from '$lib/types';

  interface Props {
    onClose: () => void;
  }

  let { onClose }: Props = $props();

  let selectedDice = $state('d20');
  let diceCount = $state(1);
  let modifier = $state(0);
  let isClosing = $state(false);

  const diceTypes = [
    { label: 'd2', sides: 2 },
    { label: 'd4', sides: 4 },
    { label: 'd6', sides: 6 },
    { label: 'd8', sides: 8 },
    { label: 'd10', sides: 10 },
    { label: 'd12', sides: 12 },
    { label: 'd20', sides: 20 },
    { label: 'd100', sides: 100 },
  ];

  function rollDice(sides: number, count: number) {
    const results: number[] = [];
    for (let i = 0; i < count; i++) {
      results.push(Math.floor(Math.random() * sides) + 1);
    }
    const sum = results.reduce((a, b) => a + b, 0);
    const total = sum + modifier;

    let mathStr: string;
    if (count === 1) {
      mathStr = modifier !== 0 ? `${results[0]} ${modifier >= 0 ? '+' : ''}${modifier}` : `${results[0]}`;
    } else {
      const resultsStr = results.join(' + ');
      mathStr = modifier !== 0 ? `(${resultsStr}) ${modifier >= 0 ? '+' : ''}${modifier}` : resultsStr;
    }

    const roll: DiceRoll = {
      id: crypto.randomUUID(),
      dice: selectedDice,
      sides,
      count,
      results,
      modifier,
      math: mathStr,
      total,
      timestamp: Date.now()
    };

    appStore.addDiceRoll(roll);
  }

  function handleRoll() {
    const dice = diceTypes.find(d => d.label === selectedDice);
    if (dice) rollDice(dice.sides, diceCount);
  }

  function handleClose() {
    isClosing = true;
    setTimeout(() => {
      onClose();
    }, 250);
  }

  function clearHistory() {
    appStore.clearDiceHistory();
  }

  function formatTime(timestamp: number): string {
    const d = new Date(timestamp);
    return d.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
  }

  function getRollClass(roll: DiceRoll): string {
    const allCrit = roll.results.every(r => r === roll.sides);
    const allFumble = roll.results.every(r => r === 1);
    if (allCrit) return 'crit';
    if (allFumble) return 'fumble';
    if (roll.count > 1 && roll.results.includes(1) && roll.results.includes(roll.sides)) return 'mixed';
    return '';
  }
</script>

<div class="dice-panel-overlay"></div>
<div class="dice-panel" class:closing={isClosing}>
  <div class="dice-panel-header">
    <h2>Dice Roller</h2>
    <button class="close-btn" onclick={handleClose}>
      <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 6L6 18M6 6l12 12"/></svg>
    </button>
  </div>

  <div class="dice-selector">
    {#each diceTypes as dice}
      <button
        class="dice-btn"
        class:active={selectedDice === dice.label}
        onclick={() => selectedDice = dice.label}
      >
        {dice.label}
      </button>
    {/each}
  </div>

  <div class="count-mod-row">
    <div class="count-row">
      <label>Count</label>
      <input type="number" bind:value={diceCount} min="1" max="20" />
    </div>
    <div class="mod-row">
      <label>Modifier</label>
      <input type="number" bind:value={modifier} />
    </div>
  </div>

  <button class="roll-btn" onclick={handleRoll}>
    Roll {diceCount}{selectedDice}{modifier !== 0 ? ` ${modifier >= 0 ? '+' : ''}${modifier}` : ''}
  </button>

  <div class="dice-history">
    <div class="history-header">
      <h3>Roll History</h3>
      {#if appStore.diceHistory.length > 0}
        <button class="clear-btn" onclick={clearHistory}>Clear</button>
      {/if}
    </div>
    {#if appStore.diceHistory.length === 0}
      <div class="empty-history">No rolls yet</div>
    {:else}
      <div class="roll-list">
        {#each appStore.diceHistory as roll}
          <div class="roll-item {getRollClass(roll)}">
            <div class="roll-info">
              <span class="roll-dice">{roll.count}{roll.dice}</span>
              <span class="roll-math">{roll.math}</span>
            </div>
            <div class="roll-result">
              <span class="roll-total">{roll.total}</span>
              <span class="roll-time">{formatTime(roll.timestamp)}</span>
            </div>
          </div>
        {/each}
      </div>
    {/if}
  </div>
</div>

<style>
  .dice-panel-overlay {
    position: fixed;
    inset: 0;
    background: oklch(0% 0 0 / 0.5);
    z-index: 100;
    animation: fadeIn 0.2s ease-out;
  }

  @keyframes fadeIn {
    from { opacity: 0; }
    to { opacity: 1; }
  }

  .dice-panel {
    position: fixed;
    top: 0;
    right: 0;
    bottom: 0;
    width: 320px;
    background: var(--surface);
    border-left: 1px solid var(--border);
    z-index: 101;
    display: flex;
    flex-direction: column;
    padding: 20px;
    gap: 20px;
    overflow-y: auto;
    animation: slideIn 0.35s cubic-bezier(0.34, 1.56, 0.64, 1);
    transform-origin: top right;
  }

  .dice-panel.closing {
    animation: slideOut 0.25s cubic-bezier(0.55, 0, 1, 0.45) forwards;
  }

  @keyframes slideIn {
    from {
      opacity: 0;
      transform: translateX(100%) scale(0.9);
    }
    to {
      opacity: 1;
      transform: translateX(0) scale(1);
    }
  }

  @keyframes slideOut {
    from {
      opacity: 1;
      transform: translateX(0) scale(1);
    }
    to {
      opacity: 0;
      transform: translateX(100%) scale(0.9);
    }
  }

  .dice-panel-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .dice-panel-header h2 {
    font-size: 18px;
    font-weight: 600;
    color: var(--fg);
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
  }

  .close-btn:hover {
    color: var(--fg);
    border-color: var(--gold);
  }

  .dice-selector {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 8px;
  }

  .dice-btn {
    height: 40px;
    background: var(--surface-2);
    border: 1px solid var(--border);
    color: var(--muted);
    font-size: 12px;
    font-weight: 600;
    border-radius: var(--radius-md);
    transition: all 120ms;
  }

  .dice-btn:hover {
    border-color: var(--gold);
    color: var(--fg);
  }

  .dice-btn.active {
    background: var(--gold);
    border-color: var(--gold);
    color: oklch(11% 0.012 250);
  }

  .count-mod-row {
    display: flex;
    gap: 16px;
  }

  .count-row, .mod-row {
    flex: 1;
    display: flex;
    flex-direction: column;
    gap: 6px;
  }

  .count-row label, .mod-row label {
    font-size: 11px;
    color: var(--muted);
    text-transform: uppercase;
    letter-spacing: 0.06em;
  }

  .count-row input, .mod-row input {
    width: 100%;
    height: 40px;
    background: var(--surface-2);
    border: 1px solid var(--border);
    border-radius: var(--radius-md);
    color: var(--fg);
    font-family: var(--font-mono);
    font-size: 16px;
    text-align: center;
    padding: 0 8px;
  }

  .count-row input:focus, .mod-row input:focus {
    outline: none;
    border-color: var(--gold);
  }

  .roll-btn {
    height: 48px;
    background: var(--gold);
    border: none;
    color: oklch(11% 0.012 250);
    font-size: 14px;
    font-weight: 600;
    border-radius: var(--radius-lg);
    transition: opacity 120ms;
  }

  .roll-btn:hover { opacity: 0.85; }

  .dice-history {
    flex: 1;
    display: flex;
    flex-direction: column;
    gap: 12px;
    min-height: 0;
  }

  .history-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .history-header h3 {
    font-size: 13px;
    font-weight: 600;
    color: var(--muted);
    text-transform: uppercase;
    letter-spacing: 0.06em;
  }

  .clear-btn {
    font-size: 11px;
    color: var(--muted);
    background: none;
    border: none;
    transition: color 120ms;
  }

  .clear-btn:hover { color: var(--red); }

  .empty-history {
    flex: 1;
    display: flex;
    align-items: center;
    justify-content: center;
    color: var(--muted);
    font-size: 13px;
    opacity: 0.6;
  }

  .roll-list {
    flex: 1;
    overflow-y: auto;
    display: flex;
    flex-direction: column;
    gap: 8px;
  }

  .roll-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 12px;
    background: var(--surface-2);
    border: 1px solid var(--border);
    border-radius: var(--radius-md);
  }

  .roll-item.crit {
    border-color: var(--green);
    background: color-mix(in oklch, var(--surface-2) 90%, var(--green) 10%);
  }

  .roll-item.fumble {
    border-color: var(--red);
    background: color-mix(in oklch, var(--surface-2) 90%, var(--red) 10%);
  }

  .roll-item.mixed {
    border-color: var(--gold);
    background: color-mix(in oklch, var(--surface-2) 90%, var(--gold) 10%);
  }

  .roll-info {
    display: flex;
    flex-direction: column;
    gap: 2px;
  }

  .roll-dice {
    font-size: 11px;
    font-weight: 700;
    color: var(--gold);
    text-transform: uppercase;
  }

  .roll-math {
    font-family: var(--font-mono);
    font-size: 12px;
    color: var(--muted);
  }

  .roll-result {
    display: flex;
    flex-direction: column;
    align-items: flex-end;
    gap: 2px;
  }

  .roll-total {
    font-family: var(--font-mono);
    font-size: 20px;
    font-weight: 700;
    color: var(--fg);
  }

  .roll-item.crit .roll-total { color: var(--green); }
  .roll-item.fumble .roll-total { color: var(--red); }
  .roll-item.mixed .roll-total { color: var(--gold); }

  .roll-time {
    font-size: 10px;
    color: var(--muted);
  }
</style>
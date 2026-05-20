# Encounter Builder Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add "Encounter" option to the plus menu that opens a builder to assemble creature groups and save them for later deployment into the initiative strip via the CharacterBook.

**Architecture:** A new `EncounterBuilder.svelte` modal captures creature selections + quantity. Saved encounters live in `appStore.encounters[]` (in-memory). `CharacterBook.svelte` gets a tab bar with "Characters" and "Encounters" tabs to browse and deploy saved encounters.

**Tech Stack:** Svelte 5 runes, TypeScript, existing `Creature` type and `addToInitiative` method

---

### Task 1: Add SavedEncounter type

**Files:**
- Modify: `src/lib/types/index.ts`

- [ ] **Step 1: Add SavedEncounter type**

Add after `DiceRoll` interface:

```typescript
export interface SavedEncounter {
  id: string;
  name: string;
  creatures: { entityId: string; count: number }[];
}
```

### Task 2: Add encounter state and methods to appStore

**Files:**
- Modify: `src/lib/stores/app.svelte.ts`

- [ ] **Step 1: Add encounters state and showEncounterBuilder toggle**

After `showCreateCharacter = $state(false)` (line 15), add:
```typescript
let encounters = $state<SavedEncounter[]>([]);
let showEncounterBuilder = $state(false);
```

- [ ] **Step 2: Add saveEncounter method**

After `clearDiceHistory` (around line 138), add:
```typescript
function saveEncounter(name: string, creatureSelections: { entityId: string; count: number }[]) {
  const encounter: SavedEncounter = {
    id: crypto.randomUUID(),
    name,
    creatures: creatureSelections.filter(c => c.count > 0)
  };
  encounters = [...encounters, encounter];
}
```

- [ ] **Step 3: Add deployEncounter method**

After `saveEncounter`, add:
```typescript
function deployEncounter(encounterId: string) {
  const encounter = encounters.find(e => e.id === encounterId);
  if (!encounter) return;
  for (const selection of encounter.creatures) {
    const creature = creatures.find(c => c.id === selection.entityId);
    if (!creature) continue;
    for (let i = 0; i < selection.count; i++) {
      addToInitiative(creature);
    }
  }
}
```

- [ ] **Step 4: Add deleteEncounter method**

After `deployEncounter`, add:
```typescript
function deleteEncounter(encounterId: string) {
  encounters = encounters.filter(e => e.id !== encounterId);
}
```

- [ ] **Step 5: Add import for SavedEncounter type**

Add `SavedEncounter` to the existing import from `$lib/types` on line 2:
```typescript
import type { Entity, PlayerCharacter, Creature, InitiativeEntity, CharacterSkill, CreateCharacterRequest, DiceRoll, SavedEncounter } from '$lib/types';
```

- [ ] **Step 6: Export new getters and methods**

Add in the return block:
```typescript
get encounters() { return encounters; },
set encounters(v) { encounters = v; },
get showEncounterBuilder() { return showEncounterBuilder; },
set showEncounterBuilder(v) { showEncounterBuilder = v; },
saveEncounter,
deployEncounter,
deleteEncounter,
```

### Task 3: Create EncounterBuilder modal component

**Files:**
- Create: `src/lib/components/EncounterBuilder.svelte`

- [ ] **Step 1: Write the component**

```svelte
<script lang="ts">
  import { appStore } from '$lib/stores/app.svelte';

  interface Props {
    onClose: () => void;
  }

  let { onClose }: Props = $props();

  let encounterName = $state('');
  let selections = $state<Record<string, number>>({});

  function toggleCreature(id: string, delta: number) {
    const current = selections[id] ?? 0;
    const next = Math.max(0, current + delta);
    selections = { ...selections, [id]: next };
  }

  function getCount(id: string): number {
    return selections[id] ?? 0;
  }

  function getTotalCreatures(): number {
    return Object.values(selections).reduce((a, b) => a + b, 0);
  }

  function handleSave() {
    if (!encounterName.trim()) return;
    const creatureSelections = Object.entries(selections)
      .filter(([_, count]) => count > 0)
      .map(([entityId, count]) => ({ entityId, count }));
    appStore.saveEncounter(encounterName.trim(), creatureSelections);
    onClose();
  }
</script>

<div class="modal-overlay" onclick={onClose}>
  <div class="modal" onclick={(e) => e.stopPropagation()}>
    <h2>Build Encounter</h2>

    <label class="name-field">
      <span>Encounter Name</span>
      <input type="text" bind:value={encounterName} placeholder="e.g. Goblin Ambush" />
    </label>

    <div class="creature-list">
      {#each appStore.creatures as creature}
        <div class="creature-row">
          <div class="creature-info">
            <span class="creature-name">{creature.name}</span>
            <span class="creature-meta">CR {creature.challenge_rating} · AC {creature.armor_class} · HP {creature.hit_points_max}</span>
          </div>
          <div class="stepper">
            <button class="step-btn" onclick={() => toggleCreature(creature.id, -1)} disabled={getCount(creature.id) <= 0}>
              <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M5 12h14"/></svg>
            </button>
            <span class="step-count">{getCount(creature.id)}</span>
            <button class="step-btn" onclick={() => toggleCreature(creature.id, 1)}>
              <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 5v14M5 12h14"/></svg>
            </button>
          </div>
        </div>
      {/each}
      {#if appStore.creatures.length === 0}
        <div class="empty-list">No creatures available</div>
      {/if}
    </div>

    <div class="modal-actions">
      <span class="total-count">{getTotalCreatures()} creature{getTotalCreatures() !== 1 ? 's' : ''} selected</span>
      <div class="action-btns">
        <button class="btn-secondary" onclick={onClose}>Cancel</button>
        <button class="btn-primary" onclick={handleSave} disabled={!encounterName.trim() || getTotalCreatures() === 0}>Save Encounter</button>
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
    padding: 24px;
    width: 480px;
    max-height: 90vh;
    display: flex;
    flex-direction: column;
    gap: 16px;
    box-shadow: 0 24px 48px oklch(0% 0 0 / 0.4);
  }

  .modal h2 {
    font-family: var(--font-display);
    font-size: 18px;
    font-weight: 600;
    color: var(--fg);
    margin: 0;
  }

  .name-field {
    display: flex;
    flex-direction: column;
    gap: 6px;
    font-size: 11px;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.06em;
    color: var(--muted);
  }

  .name-field input {
    padding: 10px 12px;
    background: var(--bg);
    border: 1px solid var(--border);
    border-radius: var(--radius-sm);
    color: var(--fg);
    font-size: 14px;
  }

  .name-field input:focus {
    outline: none;
    border-color: var(--gold);
  }

  .creature-list {
    flex: 1;
    overflow-y: auto;
    display: flex;
    flex-direction: column;
    gap: 4px;
    border: 1px solid var(--border);
    border-radius: var(--radius-md);
    padding: 8px;
    min-height: 200px;
  }

  .creature-row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 8px 10px;
    border-radius: var(--radius-sm);
    transition: background 120ms;
  }

  .creature-row:hover {
    background: var(--surface-2);
  }

  .creature-info {
    display: flex;
    flex-direction: column;
    gap: 2px;
  }

  .creature-name {
    font-size: 13px;
    font-weight: 500;
    color: var(--fg);
  }

  .creature-meta {
    font-size: 11px;
    color: var(--muted);
  }

  .stepper {
    display: flex;
    align-items: center;
    gap: 6px;
  }

  .step-btn {
    width: 28px;
    height: 28px;
    background: var(--surface-2);
    border: 1px solid var(--border);
    color: var(--fg);
    border-radius: var(--radius-sm);
    display: flex;
    align-items: center;
    justify-content: center;
    transition: all 120ms;
  }

  .step-btn:hover:not(:disabled) {
    border-color: var(--gold);
    color: var(--gold);
  }

  .step-btn:disabled {
    opacity: 0.3;
    cursor: default;
  }

  .step-count {
    width: 24px;
    text-align: center;
    font-size: 14px;
    font-weight: 600;
    font-family: var(--font-mono);
    color: var(--fg);
  }

  .empty-list {
    flex: 1;
    display: flex;
    align-items: center;
    justify-content: center;
    color: var(--muted);
    font-size: 13px;
    padding: 40px;
  }

  .modal-actions {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 10px;
  }

  .total-count {
    font-size: 12px;
    color: var(--muted);
  }

  .action-btns {
    display: flex;
    gap: 10px;
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
  .btn-primary:disabled { opacity: 0.4; cursor: default; }
</style>
```

### Task 4: Add Encounter menu item to AppBar

**Files:**
- Modify: `src/lib/components/AppBar.svelte`

- [ ] **Step 1: Add onAddEncounter prop**

Add `onAddEncounter: () => void;` to the `Props` interface and destructure it:
```typescript
let { onAddCharacter, onAddCreature, onAddNPC, onAddOther, onAddEncounter, onToggleDiceRoller, onToggleBook, onToggleSettings }: Props = $props();
```

- [ ] **Step 2: Add handleAddEncounter handler**

After `handleAddOther` (around line 53), add:
```typescript
function handleAddEncounter() {
  closeMenu();
  onAddEncounter();
}
```

- [ ] **Step 3: Add menu item between NPC and Other**

After the NPC button and before "Other", add:
```svelte
<button class="menu-item" onclick={handleAddEncounter}>
  <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14.5 17.5L3 6V3h3l11.5 11.5"/><path d="M13 19l6-6"/><path d="M16 16l4 4"/><path d="M19 21l2-2"/></svg>
  <span>Encounter</span>
</button>
```

### Task 5: Wire up in +page.svelte

**Files:**
- Modify: `src/routes/+page.svelte`

- [ ] **Step 1: Add toggleEncounterBuilder function**

After `toggleCreateCharacter` (around line 36), add:
```typescript
function toggleEncounterBuilder() {
  appStore.showEncounterBuilder = !appStore.showEncounterBuilder;
  if (appStore.showSettings) appStore.showSettings = false;
  if (appStore.showDiceRoller) appStore.showDiceRoller = false;
}
```

- [ ] **Step 2: Add import for EncounterBuilder**

```typescript
import EncounterBuilder from '$lib/components/EncounterBuilder.svelte';
```

- [ ] **Step 3: Pass onAddEncounter to AppBar**

Add `onAddEncounter={toggleEncounterBuilder}` to the `<AppBar>` component.

- [ ] **Step 4: Render EncounterBuilder modal conditionally**

After the CreateCharacterModal block and before DiceRoller, add:
```svelte
{#if appStore.showEncounterBuilder}
  <EncounterBuilder onClose={toggleEncounterBuilder} />
{/if}
```

### Task 6: Add Encounters tab to CharacterBook

**Files:**
- Modify: `src/lib/components/CharacterBook.svelte`

- [ ] **Step 1: Add tab state**

After `selectedEntity`, add:
```typescript
let activeTab = $state<'characters' | 'encounters'>('characters');
```

- [ ] **Step 2: Add tab bar to the left panel**

Replace the `list-header` div and surrounding structure with:
```svelte
<div class="list-header">
  <div class="tabs">
    <button class="tab" class:active={activeTab === 'characters'} onclick={() => activeTab = 'characters'}>Characters</button>
    <button class="tab" class:active={activeTab === 'encounters'} onclick={() => activeTab = 'encounters'}>Encounters</button>
  </div>
</div>
```

- [ ] **Step 3: Show encounter list when encounters tab is active**

After the `list-items` block and before closing `entity-list`, add:
```svelte
{#if activeTab === 'encounters'}
  <div class="encounter-list">
    {#each appStore.encounters as encounter}
      <div class="encounter-card">
        <div class="encounter-header">
          <span class="encounter-name">{encounter.name}</span>
          <span class="encounter-count">{encounter.creatures.reduce((a, c) => a + c.count, 0)} creatures</span>
        </div>
        <div class="encounter-creatures">
          {#each encounter.creatures as selection}
            <div class="encounter-creature-row">
              <span class="creature-ref">{selection.count}x {appStore.creatures.find(c => c.id === selection.entityId)?.name ?? 'Unknown'}</span>
            </div>
          {/each}
        </div>
        <div class="encounter-actions">
          <button class="deploy-btn" onclick={() => { appStore.deployEncounter(encounter.id); }}>
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M5 12h14M12 5l7 7-7 7"/></svg>
            Deploy to Initiative
          </button>
          <button class="delete-btn" onclick={() => appStore.deleteEncounter(encounter.id)}>
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 6L6 18M6 6l12 12"/></svg>
          </button>
        </div>
      </div>
    {/each}
    {#if appStore.encounters.length === 0}
      <div class="empty-list">No saved encounters</div>
    {/if}
  </div>
{/if}
```

- [ ] **Step 4: Wrap entity list content with conditional**

Wrap the existing entity list items in `{#if activeTab === 'characters'}` block:
```svelve
{#if activeTab === 'characters'}
  {#if allEntities.length === 0}
    ...
  {:else}
    <div class="list-items">...</div>
  {/if}
{/if}
```

- [ ] **Step 5: Add tab and encounter-card styles**

Add to the style section:
```css
.tabs {
  display: flex;
  gap: 4px;
}

.tab {
  flex: 1;
  padding: 8px 12px;
  background: none;
  border: none;
  color: var(--muted);
  font-size: 12px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.06em;
  border-radius: var(--radius-sm);
  cursor: pointer;
  transition: all 120ms;
}

.tab:hover {
  color: var(--fg);
  background: var(--surface-2);
}

.tab.active {
  color: var(--gold);
  background: var(--gold-dim);
}

.encounter-list {
  flex: 1;
  overflow-y: auto;
  padding: 8px;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.encounter-card {
  background: var(--surface-2);
  border: 1px solid var(--border);
  border-radius: var(--radius-md);
  padding: 12px;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.encounter-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.encounter-name {
  font-size: 14px;
  font-weight: 600;
  color: var(--fg);
}

.encounter-count {
  font-size: 11px;
  color: var(--muted);
  font-family: var(--font-mono);
}

.encounter-creatures {
  display: flex;
  flex-direction: column;
  gap: 3px;
}

.encounter-creature-row {
  font-size: 12px;
  color: var(--muted);
}

.encounter-actions {
  display: flex;
  gap: 6px;
  margin-top: 4px;
}

.deploy-btn {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  height: 32px;
  background: var(--gold);
  border: none;
  color: oklch(11% 0.012 250);
  font-size: 12px;
  font-weight: 600;
  border-radius: var(--radius-md);
  transition: opacity 120ms;
}

.deploy-btn:hover { opacity: 0.85; }

.delete-btn {
  width: 32px;
  height: 32px;
  background: var(--surface-3);
  border: 1px solid var(--border);
  color: var(--muted);
  border-radius: var(--radius-md);
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 120ms;
}

.delete-btn:hover {
  color: var(--red);
  border-color: var(--red);
}
```

### Task 7: Verify

- [ ] **Step 1: Run type check**

Run: `npm run check`
Expected: No type errors.

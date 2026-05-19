<script lang="ts">
  interface Props {
    onAddCharacter: () => void;
    onAddCreature: () => void;
    onAddNPC: () => void;
    onAddOther: () => void;
    onToggleDiceRoller: () => void;
    onToggleBook: () => void;
    onToggleSettings: () => void;
  }

  let { onAddCharacter, onAddCreature, onAddNPC, onAddOther, onToggleDiceRoller, onToggleBook, onToggleSettings }: Props = $props();

  let showMenu = $state(false);
  let isClosing = $state(false);
  let addBtnEl: HTMLButtonElement;

  function toggleMenu(e: MouseEvent) {
    e.stopPropagation();
    if (showMenu) {
      closeMenu();
    } else {
      showMenu = true;
    }
  }

  function closeMenu() {
    isClosing = true;
    setTimeout(() => {
      showMenu = false;
      isClosing = false;
    }, 200);
  }

  function handleAddCharacter() {
    closeMenu();
    onAddCharacter();
  }

  function handleAddCreature() {
    closeMenu();
    onAddCreature();
  }

  function handleAddNPC() {
    closeMenu();
    onAddNPC();
  }

  function handleAddOther() {
    closeMenu();
    onAddOther();
  }

  function handleClickOutside(e: MouseEvent) {
    if (showMenu && addBtnEl && !addBtnEl.contains(e.target as Node)) {
      const menuEl = document.querySelector('.add-menu');
      if (menuEl && !menuEl.contains(e.target as Node)) {
        closeMenu();
      }
    }
  }

  $effect(() => {
    if (showMenu) {
      document.addEventListener('click', handleClickOutside);
    } else {
      document.removeEventListener('click', handleClickOutside);
    }
    return () => document.removeEventListener('click', handleClickOutside);
  });
</script>

<div class="app-bar">
  <div class="app-brand">
    <div class="app-brand-icon">
      <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14.5 17.5L3 6V3h3l11.5 11.5"/><path d="M13 19l6-6"/><path d="M16 16l4 4"/><path d="M19 21l2-2"/></svg>
    </div>
    <span>Save State</span>
  </div>
  <div class="app-bar-spacer"></div>
  <div class="app-bar-actions">
    <div class="add-menu-container">
      <button class="app-bar-btn" bind:this={addBtnEl} onclick={toggleMenu} aria-label="Add" class:active={showMenu}>
        <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 5v14M5 12h14"/></svg>
      </button>
      {#if showMenu}
        <div class="add-menu" class:closing={isClosing}>
          <button class="menu-item" onclick={handleAddCharacter}>
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
            <span>Character</span>
          </button>
          <button class="menu-item" onclick={handleAddCreature}>
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 3c-1.5 0-2.5 1-3 2-1 0-2.5 0-4 1.5-1.5 1.5-2 4-1.5 6 .5 2 2 4 3.5 5s3.5 1.5 5 0 3-3 3.5-5 .5-4.5-1.5-6C14.5 4 13 3 12 3z"/><path d="M10 14s.5-1 1-1 1 1 1 1"/><path d="M13 18s.5-1 1-1 1 1 1 1"/><circle cx="12" cy="10" r="1"/></svg>
            <span>Creature</span>
          </button>
          <button class="menu-item" onclick={handleAddNPC}>
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
            <span>NPC</span>
          </button>
          <button class="menu-item" onclick={handleAddOther}>
            <span class="menu-icon">✨</span>
            <span>Other</span>
          </button>
        </div>
      {/if}
    </div>
    <button class="app-bar-btn" onclick={onToggleDiceRoller} aria-label="Roll dice">
      <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="2" width="20" height="20" rx="4"/><circle cx="8" cy="8" r="1.5" fill="currentColor"/><circle cx="16" cy="8" r="1.5" fill="currentColor"/><circle cx="8" cy="16" r="1.5" fill="currentColor"/><circle cx="16" cy="16" r="1.5" fill="currentColor"/><circle cx="12" cy="12" r="1.5" fill="currentColor"/></svg>
    </button>
    <button class="app-bar-btn" onclick={onToggleBook} aria-label="Character book">
      <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg>
    </button>
    <button class="app-bar-btn" onclick={onToggleSettings} aria-label="Settings">
      <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg>
    </button>
  </div>
</div>

<style>
  .app-bar {
    display: flex;
    align-items: center;
    height: 56px;
    padding: 0 20px;
    background: var(--surface);
    border-bottom: 1px solid var(--border);
    gap: 24px;
  }

  .app-brand {
    display: flex;
    align-items: center;
    gap: 10px;
    font-family: var(--font-display);
    font-size: 16px;
    font-weight: 600;
    letter-spacing: 0.02em;
    color: var(--fg);
  }

  .app-brand-icon {
    width: 32px;
    height: 32px;
    background: linear-gradient(135deg, var(--gold) 0%, var(--accent) 100%);
    border-radius: var(--radius-md);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 16px;
  }

  .app-bar-spacer { flex: 1; }

  .app-bar-actions {
    display: flex;
    gap: 8px;
  }

  .app-bar-btn {
    width: 36px;
    height: 36px;
    background: var(--surface-2);
    border: 1px solid var(--border);
    color: var(--muted);
    border-radius: var(--radius-md);
    display: flex;
    align-items: center;
    justify-content: center;
    transition: all 120ms;
  }

  .app-bar-btn:hover {
    color: var(--fg);
    border-color: var(--gold);
    background: var(--gold-dim);
  }

  .app-bar-btn.active {
    color: var(--gold);
    border-color: var(--gold);
    background: var(--gold-dim);
  }

  .add-menu-container {
    position: relative;
  }

  .add-menu {
    position: absolute;
    top: calc(100% + 8px);
    right: 0;
    min-width: 160px;
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: var(--radius-lg);
    padding: 6px;
    box-shadow: 0 8px 24px oklch(0% 0 0 / 0.4);
    z-index: 200;
    animation: menuBounceIn 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
    transform-origin: top right;
  }

  @keyframes menuBounceIn {
    from {
      opacity: 0;
      transform: scale(0.8) translateY(-8px);
    }
    to {
      opacity: 1;
      transform: scale(1) translateY(0);
    }
  }

  .add-menu.closing {
    animation: menuBounceOut 0.2s cubic-bezier(0.55, 0, 1, 0.45) forwards;
  }

  @keyframes menuBounceOut {
    from {
      opacity: 1;
      transform: scale(1) translateY(0);
    }
    to {
      opacity: 0;
      transform: scale(0.8) translateY(-8px);
    }
  }

  .menu-item {
    width: 100%;
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 10px 12px;
    background: none;
    border: none;
    color: var(--fg);
    font-size: 13px;
    font-weight: 500;
    border-radius: var(--radius-md);
    transition: background 120ms;
    text-align: left;
  }

  .menu-item:hover {
    background: var(--surface-2);
  }

  .menu-item svg {
    width: 18px;
    height: 18px;
    flex-shrink: 0;
  }
</style>
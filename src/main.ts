import { invoke } from "@tauri-apps/api/core";

interface Actor {
  id: string;
  system_id: string;
  name: string;
  actor_type: string;
  base_hp: number;
  base_ac: number;
  stats_blob: string | null;
}

interface GameSystem {
  id: string;
  name: string;
}

interface Combatant {
  id: string;
  actor_id: string;
  name: string;
  hp: number;
  ac: number;
  initiative: number;
}

interface EntityEntry {
  id: string;
  entity_type_id: string;
  name: string;
  description: string | null;
  system_id: string | null;
  metadata_blob: string | null;
  type_name: string | null;
  type_desc: string | null;
  tags: string | null;
}

interface Skill {
  id: string;
  system_id: string;
  name: string;
  description: string | null;
  associated_stat: string | null;
  mechanics_blob: string | null;
}

let currentSystemId: string | null = null;
let actors: Actor[] = [];
let encounter: Combatant[] = [];
let activeCombatantIndex = 0;
let pendingActorId: string | null = null;
let isDraggingActor = false;
let currentActorId: string | null = null;
let entityEntries: EntityEntry[] = [];
let skills: Skill[] = [];

async function loadGameSystems() {
  try {
    const systems: GameSystem[] = await invoke("get_game_systems");
    const select = document.querySelector<HTMLSelectElement>("#game-system-select")!;

    systems.forEach(system => {
      const option = document.createElement("option");
      option.value = system.id;
      option.textContent = system.name;
      select.appendChild(option);
    });

    select.addEventListener("change", () => {
      currentSystemId = select.value || null;
      loadActors();
    });
  } catch (error) {
    console.error("Failed to load game systems:", error);
  }
}

async function loadActors() {
  try {
    actors = await invoke("get_actors", { systemId: currentSystemId });
    await loadEntityEntries();
    await loadSkills();
    renderActorList();
    renderActorDetail();
  } catch (error) {
    console.error("Failed to load actors:", error);
  }
}

async function loadEntityEntries() {
  try {
    entityEntries = await invoke("get_entity_entries", { systemId: currentSystemId });
  } catch (error) {
    console.error("Failed to load entity entries:", error);
  }
}

async function loadSkills() {
  try {
    skills = await invoke("get_skills", { systemId: currentSystemId });
  } catch (error) {
    console.error("Failed to load skills:", error);
  }
}

function renderActorList() {
  const listItems = document.querySelector<HTMLDivElement>("#actor-list-items")!;
  listItems.innerHTML = actors.map(actor =>
    `<div class="actor-list-item" data-id="${escapeHtml(actor.id)}">${escapeHtml(actor.name)}</div>`
  ).join("");

  listItems.querySelectorAll(".actor-list-item").forEach(item => {
    item.addEventListener("click", () => {
      listItems.querySelectorAll(".actor-list-item").forEach(i => i.classList.remove("selected"));
      item.classList.add("selected");
      renderActorDetail(item.getAttribute("data-id")!);
    });
  });

  setupActorDrag();
}

function renderActorDetail(id?: string) {
  const app = document.querySelector<HTMLDivElement>("#app")!;
  if (!id && actors.length > 0) {
    id = actors[0].id;
  }

  if (!id) {
    app.innerHTML = "<p class=\"empty\">Select an actor from the list.</p>";
    return;
  }

  const actor = actors.find(a => a.id === id);
  if (!actor) {
    app.innerHTML = "<p class=\"error\">Actor not found.</p>";
    return;
  }

  let abilitiesHtml = "";
  let skillsHtml = "";
  if (actor.stats_blob) {
    try {
      const stats = JSON.parse(actor.stats_blob);
      const isCoC = actor.system_id === 'sys_coc';
      const dndAbilityNames: Record<string, string> = {
        str: "Strength",
        dex: "Dexterity",
        con: "Constitution",
        int: "Intelligence",
        wis: "Wisdom",
        cha: "Charisma"
      };
      const cocAbilityNames: Record<string, string> = {
        str: "STR",
        dex: "DEX",
        con: "CON",
        siz: "SIZ",
        int: "INT",
        pow: "POW",
        app: "APP",
        edu: "EDU"
      };
      const abilityNames = isCoC ? cocAbilityNames : dndAbilityNames;
      
      abilitiesHtml = `
        <div class="abilities-section">
          <div class="abilities-header">
            <span class="abilities-label">Abilities</span>
          </div>
          <div class="abilities-grid">
            ${Object.entries(stats).map(([key, value]) => {
              const score = Number(value);
              const name = abilityNames[key] || key.toUpperCase();
              if (isCoC) {
                const half = Math.floor(score / 2);
                const fifth = Math.floor(score / 5);
                return `
                  <div class="ability-box">
                    <span class="ability-name ${isCoC ? 'no-transform' : ''}">${name}</span>
                    <span class="ability-score">${score}</span>
                    <span class="ability-mod coc-mod">${half} / ${fifth}</span>
                  </div>
                `;
              } else {
                const mod = Math.floor((score - 10) / 2);
                const modStr = mod >= 0 ? `+${mod}` : `${mod}`;
                return `
                  <div class="ability-box">
                    <span class="ability-name">${name}</span>
                    <span class="ability-score">${score}</span>
                    <span class="ability-mod">${modStr}</span>
                  </div>
                `;
              }
            }).join("")}
          </div>
        </div>
      `;
    } catch {
      abilitiesHtml = "";
    }
  }

  const actorSkills = skills.filter(s => s.system_id === actor.system_id);
  if (actorSkills.length > 0) {
    skillsHtml = `
      <div class="skills-section">
        <div class="skills-header">
          <span class="skills-label">Skills</span>
        </div>
        <div class="skills-grid">
          ${actorSkills.map(skill => `
            <div class="skill-box">
              <span class="skill-name">${escapeHtml(skill.name)}</span>
              ${skill.associated_stat ? `<span class="skill-stat">${escapeHtml(skill.associated_stat)}</span>` : ''}
            </div>
          `).join('')}
        </div>
      </div>
    `;
  }

  app.innerHTML = `
    <div class="actor-header">
      <h1>${escapeHtml(actor.name)}</h1>
    </div>
    <div class="actor-divider"></div>
    <div class="actor-info">
      <p><strong>Type:</strong> ${escapeHtml(actor.actor_type)}</p>
      <p><strong>HP:</strong> ${actor.base_hp}</p>
      <p><strong>AC:</strong> ${actor.base_ac}</p>
    </div>
    ${abilitiesHtml}
    ${skillsHtml}
  `;
}

function setupActorDrag() {
  document.querySelectorAll(".actor-list-item").forEach(item => {
    item.addEventListener("pointerdown", (e) => {
      isDraggingActor = true;
      currentActorId = (item as HTMLElement).getAttribute("data-id");
      (item as HTMLElement).classList.add("dragging");
      e.preventDefault();
    });
  });
}

function initEncounterTracker() {
  const tracker = document.querySelector<HTMLDivElement>("#encounter-tracker")!;
  const trackerItems = document.querySelector<HTMLDivElement>("#encounter-tracker-items")!;

  document.addEventListener("pointerup", (e) => {
    if (!isDraggingActor) return;
    
    if (currentActorId) {
      const rect = tracker.getBoundingClientRect();
      if (e.clientX >= rect.left && e.clientX <= rect.right &&
          e.clientY >= rect.top && e.clientY <= rect.bottom) {
        const actor = actors.find(a => a.id === currentActorId);
        if (actor) {
          showInitiativeModal(actor);
        }
      }
    }
    
    document.querySelectorAll(".actor-list-item").forEach(i => {
      i.classList.remove("dragging");
    });
    trackerItems.classList.remove("drag-over");
    isDraggingActor = false;
    currentActorId = null;
  });

  document.addEventListener("pointermove", (e) => {
    if (!isDraggingActor) return;
    const rect = tracker.getBoundingClientRect();
    if (e.clientX >= rect.left && e.clientX <= rect.right &&
        e.clientY >= rect.top && e.clientY <= rect.bottom) {
      trackerItems.classList.add("drag-over");
    } else {
      trackerItems.classList.remove("drag-over");
    }
  });

  document.querySelector<HTMLButtonElement>("#encounter-prev")!.addEventListener("click", () => {
    if (encounter.length === 0) return;
    activeCombatantIndex = (activeCombatantIndex - 1 + encounter.length) % encounter.length;
    renderEncounterTracker();
  });

  document.querySelector<HTMLButtonElement>("#encounter-next")!.addEventListener("click", () => {
    if (encounter.length === 0) return;
    activeCombatantIndex = (activeCombatantIndex + 1) % encounter.length;
    renderEncounterTracker();
  });
}

function showInitiativeModal(actor: Actor) {
  pendingActorId = actor.id;
  const modal = document.querySelector<HTMLDivElement>("#initiative-modal")!;
  const nameEl = document.querySelector<HTMLParagraphElement>("#initiative-actor-name")!;
  const input = document.querySelector<HTMLInputElement>("#initiative-input")!;

  nameEl.textContent = actor.name;
  input.value = "";
  modal.classList.add("active");
  input.focus();
}

function confirmInitiative() {
  if (!pendingActorId) return;

  const actor = actors.find(a => a.id === pendingActorId);
  if (!actor) return;

  const input = document.querySelector<HTMLInputElement>("#initiative-input")!;
  const initiative = parseInt(input.value) || 0;

  const combatant: Combatant = {
    id: crypto.randomUUID(),
    actor_id: actor.id,
    name: actor.name,
    hp: actor.base_hp,
    ac: actor.base_ac,
    initiative: initiative
  };

  encounter.push(combatant);
  encounter.sort((a, b) => b.initiative - a.initiative);

  if (encounter.length === 1) {
    activeCombatantIndex = 0;
  }

  closeInitiativeModal();
  renderEncounterTracker();
}

function closeInitiativeModal() {
  const modal = document.querySelector<HTMLDivElement>("#initiative-modal")!;
  modal.classList.remove("active");
  pendingActorId = null;
}

function renderEncounterTracker() {
  const trackerItems = document.querySelector<HTMLDivElement>("#encounter-tracker-items")!;

  if (encounter.length === 0) {
    trackerItems.innerHTML = '<span class="empty-hint">No combatants in encounter</span>';
    return;
  }

  trackerItems.innerHTML = encounter.map((combatant, index) => `
    <div class="combatant-chip ${index === activeCombatantIndex ? 'active' : ''}">
      <div class="name">${escapeHtml(combatant.name)}</div>
      <div class="hp">HP: ${combatant.hp} | AC: ${combatant.ac}</div>
      <div class="initiative">Init: ${combatant.initiative}</div>
    </div>
  `).join("");
}

function escapeHtml(text: string | null): string {
  if (text === null) return "—";
  const div = document.createElement("div");
  div.textContent = text;
  return div.innerHTML;
}

function initResize() {
  const handle = document.querySelector<HTMLDivElement>("#resize-handle")!;
  const list = document.querySelector<HTMLDivElement>("#actor-list")!;
  const mainContent = document.querySelector<HTMLDivElement>("#main-content")!;
  let isResizing = false;

  handle.addEventListener("mousedown", (e) => {
    isResizing = true;
    e.preventDefault();
  });

  const trackerHandle = document.querySelector<HTMLDivElement>("#tracker-resize-handle")!;
  const tracker = document.querySelector<HTMLDivElement>("#encounter-tracker")!;
  let isResizingTracker = false;

  trackerHandle.addEventListener("mousedown", (e) => {
    isResizingTracker = true;
    e.preventDefault();
    e.stopPropagation();
  });

  document.addEventListener("mousemove", (e) => {
    if (isResizing) {
      const width = Math.max(100, Math.min(window.innerWidth * 0.5, e.clientX));
      list.style.width = `${width}px`;
      mainContent.style.marginLeft = `${width}px`;
    }
    if (isResizingTracker) {
      const height = Math.max(60, Math.min(window.innerHeight * 0.5, e.clientY - tracker.getBoundingClientRect().top));
      tracker.style.height = `${height}px`;
    }
  });

  document.addEventListener("mouseup", () => {
    isResizing = false;
    isResizingTracker = false;
  });
}

function openWikiModal() {
  const modal = document.querySelector<HTMLDivElement>("#wiki-modal")!;
  renderWikiList();
  modal.classList.add("active");
}

function closeWikiModal() {
  const modal = document.querySelector<HTMLDivElement>("#wiki-modal")!;
  modal.classList.remove("active");
}

function renderWikiList() {
  const list = document.querySelector<HTMLDivElement>("#wiki-list")!;
  if (entityEntries.length === 0) {
    list.innerHTML = '<span class="empty-hint">No entries found</span>';
    return;
  }

  list.innerHTML = entityEntries.map(entry =>
    `<div class="wiki-list-item" data-id="${escapeHtml(entry.id)}">${escapeHtml(entry.name)}</div>`
  ).join("");

  list.querySelectorAll(".wiki-list-item").forEach(item => {
    item.addEventListener("click", () => {
      list.querySelectorAll(".wiki-list-item").forEach(i => i.classList.remove("selected"));
      item.classList.add("selected");
      renderWikiDetail(item.getAttribute("data-id")!);
    });
  });
}

function renderWikiDetail(id: string) {
  const detail = document.querySelector<HTMLDivElement>("#wiki-detail")!;
  const entry = entityEntries.find(e => e.id === id);
  if (!entry) {
    detail.innerHTML = '<span class="empty-hint">Entry not found</span>';
    return;
  }

  let metadataHtml = "";
  if (entry.metadata_blob) {
    try {
      const meta = JSON.parse(entry.metadata_blob);
      metadataHtml = Object.entries(meta).map(([key, value]) =>
        `<p><strong>${escapeHtml(key)}:</strong> ${escapeHtml(String(value))}</p>`
      ).join("");
    } catch {
      metadataHtml = `<p><strong>Metadata:</strong> ${escapeHtml(entry.metadata_blob)}</p>`;
    }
  }

  const tagsHtml = entry.tags
    ? `<p><strong>Tags:</strong> ${entry.tags.split(',').map(tag => `<span class="wiki-tag">${escapeHtml(tag.trim())}</span>`).join(' ')}</p>`
    : "";

  detail.innerHTML = `
    <h3>${escapeHtml(entry.name)}</h3>
    ${entry.description ? `<p>${escapeHtml(entry.description)}</p>` : ""}
    <p><strong>Type:</strong> ${entry.type_name ? escapeHtml(entry.type_name) : escapeHtml(entry.entity_type_id)}</p>
    ${entry.type_desc ? `<p><em>${escapeHtml(entry.type_desc)}</em></p>` : ""}
    ${entry.system_id ? `<p><strong>System:</strong> ${escapeHtml(entry.system_id)}</p>` : ""}
    ${tagsHtml}
    ${metadataHtml}
  `;
}

window.addEventListener("DOMContentLoaded", () => {
  document.querySelector<HTMLButtonElement>("#settings-btn")!.addEventListener("click", () => {
    document.querySelector<HTMLDivElement>("#settings-modal")!.classList.add("active");
  });
  document.querySelector<HTMLButtonElement>("#close-modal")!.addEventListener("click", () => {
    document.querySelector<HTMLDivElement>("#settings-modal")!.classList.remove("active");
  });
  document.querySelector<HTMLDivElement>("#settings-modal")!.addEventListener("click", (e) => {
    if (e.target === e.currentTarget) {
      (e.currentTarget as HTMLElement).classList.remove("active");
    }
  });

  document.querySelector<HTMLButtonElement>("#reset-db-btn")!.addEventListener("click", async () => {
    try {
      await invoke("reset_database");
      alert("Database reset successfully");
    } catch (error) {
      alert(`Error: ${error}`);
    }
  });

  document.querySelector<HTMLButtonElement>("#initiative-confirm")!.addEventListener("click", confirmInitiative);
  document.querySelector<HTMLInputElement>("#initiative-input")!.addEventListener("keydown", (e) => {
    if (e.key === "Enter") {
      confirmInitiative();
    }
  });
  document.querySelector<HTMLDivElement>("#initiative-modal")!.addEventListener("click", (e) => {
    if (e.target === e.currentTarget) {
      closeInitiativeModal();
    }
  });

  document.querySelector<HTMLButtonElement>("#search-btn")!.addEventListener("click", () => alert("Search"));
  document.querySelector<HTMLButtonElement>("#wiki-btn")!.addEventListener("click", openWikiModal);
  document.querySelector<HTMLButtonElement>("#close-wiki")!.addEventListener("click", closeWikiModal);
  document.querySelector<HTMLDivElement>("#wiki-modal")!.addEventListener("click", (e) => {
    if (e.target === e.currentTarget) {
      closeWikiModal();
    }
  });
  document.querySelector<HTMLButtonElement>("#dice-btn")!.addEventListener("click", () => alert("Dice Roller"));

  initResize();
  initEncounterTracker();
  loadGameSystems();
  loadActors();
});
import { invoke } from "@tauri-apps/api/core";

interface CharacterDetail {
  name: string;
  class_name: string;
  level: number;
  race: string;
  background: string;
  armor_class: number;
  hit_points: number;
  max_hp: number;
  speed: number;
  strength: number;
  dexterity: number;
  constitution: number;
  intelligence: number;
  wisdom: number;
  charisma: number;
  proficiency_bonus: number;
  notes: string;
}

function mod(score: number): string {
  const m = Math.floor((score - 10) / 2);
  return m >= 0 ? `+${m}` : `${m}`;
}

function renderDetail(pc: CharacterDetail) {
  const empty = document.getElementById("detail-empty")!;
  const content = document.getElementById("detail-content")!;
  empty.classList.add("hidden");
  content.classList.remove("hidden");
  content.innerHTML = `
    <div class="detail-header">
      <div>
        <div class="detail-name">${pc.name}</div>
        <div class="detail-class">${pc.class_name} ${pc.level}</div>
        <div class="detail-class" style="color:var(--text-secondary); margin-top:0.2rem;">${pc.race} · ${pc.background}</div>
      </div>
      <div class="detail-ac">
        <div class="detail-ac-value">${pc.armor_class}</div>
        <div class="detail-ac-label">Armor Class</div>
      </div>
    </div>

    <div class="detail-stats">
      <div class="stat-block">
        <div class="stat-name">STR</div>
        <div class="stat-value">${pc.strength}</div>
        <div class="stat-mod">${mod(pc.strength)}</div>
      </div>
      <div class="stat-block">
        <div class="stat-name">DEX</div>
        <div class="stat-value">${pc.dexterity}</div>
        <div class="stat-mod">${mod(pc.dexterity)}</div>
      </div>
      <div class="stat-block">
        <div class="stat-name">CON</div>
        <div class="stat-value">${pc.constitution}</div>
        <div class="stat-mod">${mod(pc.constitution)}</div>
      </div>
      <div class="stat-block">
        <div class="stat-name">INT</div>
        <div class="stat-value">${pc.intelligence}</div>
        <div class="stat-mod">${mod(pc.intelligence)}</div>
      </div>
      <div class="stat-block">
        <div class="stat-name">WIS</div>
        <div class="stat-value">${pc.wisdom}</div>
        <div class="stat-mod">${mod(pc.wisdom)}</div>
      </div>
      <div class="stat-block">
        <div class="stat-name">CHA</div>
        <div class="stat-value">${pc.charisma}</div>
        <div class="stat-mod">${mod(pc.charisma)}</div>
      </div>
    </div>

    <div style="display:grid; grid-template-columns:1fr 1fr; gap:1rem; margin-bottom:2rem;">
      <div class="stat-block">
        <div class="stat-name">Hit Points</div>
        <div class="stat-value">${pc.hit_points} / ${pc.max_hp}</div>
      </div>
      <div class="stat-block">
        <div class="stat-name">Speed</div>
        <div class="stat-value">${pc.speed} ft</div>
      </div>
    </div>

    ${pc.notes ? `
    <div class="detail-sections">
      <div>
        <div class="detail-section-title">Notes</div>
        <p>${pc.notes}</p>
      </div>
    </div>` : ''}
  `;
}

function showEmpty() {
  const empty = document.getElementById("detail-empty")!;
  const content = document.getElementById("detail-content")!;
  empty.classList.remove("hidden");
  content.classList.add("hidden");
}

async function selectCharacter(id: number) {
  document.querySelectorAll(".character-list li").forEach(li => {
    li.classList.toggle("selected", (li as HTMLElement).dataset.id === String(id));
  });
  try {
    const pc = await invoke<CharacterDetail>("get_character_detail", { id });
    renderDetail(pc);
  } catch (e) {
    console.error("Failed to load character:", e);
    showEmpty();
  }
}

window.addEventListener("DOMContentLoaded", async () => {
  const listEl = document.querySelector("#character-list") as HTMLUListElement;
  if (!listEl) return;

  try {
    const characters = await invoke<any[]>("get_all_characters");
    listEl.innerHTML = "";
    for (const char of characters) {
      const li = document.createElement("li");
      li.textContent = char.name;
      li.dataset.id = String(char.id);
      li.addEventListener("click", () => selectCharacter(char.id));
      listEl.appendChild(li);
    }
  } catch (e) {
    console.error("Failed to load characters:", e);
  }

});

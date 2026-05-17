import { useState, useEffect } from "react";
import "./BestiaryViewer.css";

interface Monster {
  name: string;
  source: string;
  page?: number;
  size?: string[];
  type: string;
  alignment?: string[];
  ac?: { ac: number; from?: string[] }[];
  hp?: { average: number; formula?: string; special?: string };
  speed?: { walk?: number; fly?: number; [key: string]: number | undefined };
  str?: number;
  dex?: number;
  con?: number;
  int?: number;
  wis?: number;
  cha?: number;
  save?: string;
  resist?: string[];
  immune?: string[];
  conditionImmune?: string[];
  senses?: string[];
  passive?: number;
  languages?: string[];
  cr?: string;
  trait?: { name: string; entries: string[] }[];
  action?: { name: string; entries: string[] }[];
  legendary?: { name: string; entries: string[] }[];
  spellcasting?: { name: string; headerEntries: string[]; spellList: string[] }[];
  damageTags?: string[];
  miscTags?: string[];
  hasToken?: boolean;
}

function BestiaryViewer({ onClose }: { onClose?: () => void }) {
  const [sources, setSources] = useState<string[]>([]);
  const [selectedSource, setSelectedSource] = useState<string>("");
  const [monsters, setMonsters] = useState<Monster[]>([]);
  const [selectedMonster, setSelectedMonster] = useState<Monster | null>(null);
  const [searchQuery, setSearchQuery] = useState("");
  const [loading, setLoading] = useState(true);
  const [filterType, setFilterType] = useState<string>("all");

  useEffect(() => {
    fetch("/src/assets/data/bestiary/index.json")
      .then((res) => res.json())
      .then((data) => {
        const sourceList = Object.keys(data);
        setSources(sourceList);
        setSelectedSource(sourceList[0]);
        setLoading(false);
      })
      .catch((err) => console.error("Failed to load index:", err));
  }, []);

  useEffect(() => {
    if (!selectedSource) return;

    const indexMap: Record<string, string> = {
      PHB: "bestiary-phb.json",
      VGM: "bestiary-vgm.json",
      MM: "bestiary-mm.json",
    };

    const filename = indexMap[selectedSource] || `bestiary-${selectedSource.toLowerCase()}.json`;

    fetch(`/src/assets/data/bestiary/${filename}`)
      .then((res) => res.json())
      .then((data) => {
        const monsterList = data.monster || [];
        setMonsters(monsterList);
        setSelectedMonster(null);
      })
      .catch((err) => {
        console.error("Failed to load bestiary:", err);
        setMonsters([]);
      });
  }, [selectedSource]);

  const filteredMonsters = monsters.filter((m) => {
    const matchesSearch = m.name.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesType = filterType === "all" || m.type.toLowerCase().includes(filterType.toLowerCase());
    return matchesSearch && matchesType;
  });

  const types = ["all", ...new Set(monsters.map((m) => m.type))].sort();

  const getModifier = (stat: number | undefined) => {
    if (!stat) return "—";
    const mod = Math.floor((stat - 10) / 2);
    return mod >= 0 ? `+${mod}` : `${mod}`;
  };

  const parseDamage = (entries: string[]): string => {
    return entries
      .join(" ")
      .replace(/\{@atk mw\}/g, "Melee Weapon Attack:")
      .replace(/\{@atk rw\}/g, "Ranged Weapon Attack:")
      .replace(/\{@hit (\d+)\}/g, "+$1 to hit")
      .replace(/\{@h\}/g, "Hit:")
      .replace(/\{@damage (.+?)\}/g, "$1")
      .replace(/\{@d (\d+)d(\d+)\}/g, "$1d$2")
      .replace(/[{}]/g, "");
  };

  if (loading) {
    return (
      <div className="bestiary-loading">
        <div className="loading-spinner" />
        <span>Opening the grimoire...</span>
      </div>
    );
  }

  return (
    <div className="bestiary-container">
      <header className="bestiary-header">
        {onClose && (
          <button className="close-btn" onClick={onClose} aria-label="Close Bestiary">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
              <path d="M18 6L6 18M6 6l12 12" />
            </svg>
          </button>
        )}
        <div className="header-ornament" />
        <h1 className="bestiary-title">Bestiary</h1>
        <p className="bestiary-subtitle">A Compendium of Creatures</p>
        <div className="header-ornament" />
      </header>

      <div className="bestiary-controls">
        <div className="source-selector">
          <label htmlFor="source-select">Source:</label>
          <select
            id="source-select"
            value={selectedSource}
            onChange={(e) => setSelectedSource(e.target.value)}
          >
            {sources.map((source) => (
              <option key={source} value={source}>
                {source}
              </option>
            ))}
          </select>
        </div>

        <div className="search-box">
          <input
            type="text"
            placeholder="Search creatures..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
          />
          <svg className="search-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <circle cx="11" cy="11" r="8" />
            <path d="M21 21l-4.35-4.35" />
          </svg>
        </div>

        <div className="type-filter">
          <label htmlFor="type-filter">Type:</label>
          <select
            id="type-filter"
            value={filterType}
            onChange={(e) => setFilterType(e.target.value)}
          >
            {types.map((type) => (
              <option key={type} value={type}>
                {type === "all" ? "All Types" : type}
              </option>
            ))}
          </select>
        </div>
      </div>

      <div className="bestiary-content">
        <aside className="monster-list">
          <div className="list-header">
            <span>{filteredMonsters.length} creatures</span>
          </div>
          <div className="list-scroll">
            {filteredMonsters.map((monster) => (
              <button
                key={`${monster.name}-${monster.source}`}
                className={`monster-item ${selectedMonster?.name === monster.name ? "selected" : ""}`}
                onClick={() => setSelectedMonster(monster)}
              >
                <span className="monster-name">{monster.name}</span>
                <span className="monster-type">{monster.type}</span>
              </button>
            ))}
          </div>
        </aside>

        <main className="monster-detail">
          {selectedMonster ? (
            <article className="monster-card">
              <header className="card-header">
                <div className="card-title-section">
                  <h2 className="monster-name">{selectedMonster.name}</h2>
                  <div className="monster-meta">
                    <span className="meta-source">{selectedMonster.source}</span>
                    {selectedMonster.page && (
                      <span className="meta-page">p. {selectedMonster.page}</span>
                    )}
                    <span className="meta-size">
                      {selectedMonster.size?.join(" ")} {selectedMonster.type}
                    </span>
                    {selectedMonster.alignment?.map((a, i) => (
                      <span key={i} className="meta-alignment">{a}</span>
                    ))}
                  </div>
                </div>
                {selectedMonster.cr && (
                  <div className="cr-badge">
                    <span className="cr-label">CR</span>
                    <span className="cr-value">{selectedMonster.cr}</span>
                  </div>
                )}
              </header>

              <div className="stats-block">
                <div className="stat-row">
                  <div className="stat">
                    <span className="stat-label">STR</span>
                    <span className="stat-value">{selectedMonster.str ?? "—"}</span>
                    <span className="stat-mod">{getModifier(selectedMonster.str)}</span>
                  </div>
                  <div className="stat">
                    <span className="stat-label">DEX</span>
                    <span className="stat-value">{selectedMonster.dex ?? "—"}</span>
                    <span className="stat-mod">{getModifier(selectedMonster.dex)}</span>
                  </div>
                  <div className="stat">
                    <span className="stat-label">CON</span>
                    <span className="stat-value">{selectedMonster.con ?? "—"}</span>
                    <span className="stat-mod">{getModifier(selectedMonster.con)}</span>
                  </div>
                  <div className="stat">
                    <span className="stat-label">INT</span>
                    <span className="stat-value">{selectedMonster.int ?? "—"}</span>
                    <span className="stat-mod">{getModifier(selectedMonster.int)}</span>
                  </div>
                  <div className="stat">
                    <span className="stat-label">WIS</span>
                    <span className="stat-value">{selectedMonster.wis ?? "—"}</span>
                    <span className="stat-mod">{getModifier(selectedMonster.wis)}</span>
                  </div>
                  <div className="stat">
                    <span className="stat-label">CHA</span>
                    <span className="stat-value">{selectedMonster.cha ?? "—"}</span>
                    <span className="stat-mod">{getModifier(selectedMonster.cha)}</span>
                  </div>
                </div>
              </div>

              <div className="combat-block">
                <div className="combat-row">
                  <div className="combat-stat">
                    <span className="combat-label">Armor Class</span>
                    <span className="combat-value">
                      {selectedMonster.ac?.map((a, i) => (
                        <span key={i}>
                          {a.ac} {a.from && `(${a.from.join(", ")})`}
                        </span>
                      ))}
                    </span>
                  </div>
                  <div className="combat-stat">
                    <span className="combat-label">Hit Points</span>
                    <span className="combat-value">
                      {selectedMonster.hp?.special ||
                        `${selectedMonster.hp?.average}${selectedMonster.hp?.formula ? ` (${selectedMonster.hp.formula})` : ""}`}
                    </span>
                  </div>
                  <div className="combat-stat">
                    <span className="combat-label">Speed</span>
                    <span className="combat-value">
                      {selectedMonster.speed
                        ? Object.entries(selectedMonster.speed)
                            .map(([k, v]) => `${v} ft. ${k}`)
                            .join(", ")
                        : "—"}
                    </span>
                  </div>
                </div>
              </div>

              {selectedMonster.resist || selectedMonster.immune || selectedMonster.conditionImmune ? (
                <div className="defenses-block">
                  {selectedMonster.resist && (
                    <div className="defense-row">
                      <span className="defense-label">Damage Resistances</span>
                      <span className="defense-value">{selectedMonster.resist.join(", ")}</span>
                    </div>
                  )}
                  {selectedMonster.immune && (
                    <div className="defense-row">
                      <span className="defense-label">Damage Immunities</span>
                      <span className="defense-value">{selectedMonster.immune.join(", ")}</span>
                    </div>
                  )}
                  {selectedMonster.conditionImmune && (
                    <div className="defense-row">
                      <span className="defense-label">Condition Immunities</span>
                      <span className="defense-value">{selectedMonster.conditionImmune.join(", ")}</span>
                    </div>
                  )}
                </div>
              ) : null}

              {selectedMonster.senses && (
                <div className="senses-block">
                  <span className="senses-label">Senses</span>
                  <span className="senses-value">{selectedMonster.senses.join(", ")}</span>
                  {selectedMonster.passive && (
                    <span className="passive-wis">passive Wisdom {selectedMonster.passive}</span>
                  )}
                </div>
              )}

              {selectedMonster.languages && (
                <div className="languages-block">
                  <span className="languages-label">Languages</span>
                  <span className="languages-value">{selectedMonster.languages.join(", ")}</span>
                </div>
              )}

              {selectedMonster.trait && selectedMonster.trait.length > 0 && (
                <section className="traits-section">
                  <h3 className="section-title">Traits</h3>
                  {selectedMonster.trait.map((trait, i) => (
                    <div key={i} className="trait">
                      <span className="trait-name">{trait.name}.</span>
                      <span className="trait-text">{parseDamage(trait.entries)}</span>
                    </div>
                  ))}
                </section>
              )}

              {selectedMonster.spellcasting && selectedMonster.spellcasting.length > 0 && (
                <section className="spellcasting-section">
                  <h3 className="section-title">Spellcasting</h3>
                  {selectedMonster.spellcasting.map((sc, i) => (
                    <div key={i} className="spellcasting">
                      <span className="spell-name">{sc.name}.</span>
                      <span className="spell-text">{sc.headerEntries?.join(" ")}</span>
                    </div>
                  ))}
                </section>
              )}

              {selectedMonster.action && selectedMonster.action.length > 0 && (
                <section className="actions-section">
                  <h3 className="section-title">Actions</h3>
                  {selectedMonster.action.map((action, i) => (
                    <div key={i} className="action">
                      <span className="action-name">{action.name}.</span>
                      <span className="action-text">{parseDamage(action.entries)}</span>
                    </div>
                  ))}
                </section>
              )}

              {selectedMonster.legendary && selectedMonster.legendary.length > 0 && (
                <section className="legendary-section">
                  <h3 className="section-title">Legendary Actions</h3>
                  {selectedMonster.legendary.map((leg, i) => (
                    <div key={i} className="legendary">
                      <span className="legendary-name">{leg.name}.</span>
                      <span className="legendary-text">{parseDamage(leg.entries)}</span>
                    </div>
                  ))}
                </section>
              )}
            </article>
          ) : (
            <div className="empty-state">
              <svg className="empty-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor">
                <path d="M12 2L2 7l10 5 10-5-10-5z" />
                <path d="M2 17l10 5 10-5" />
                <path d="M2 12l10 5 10-5" />
              </svg>
              <p>Select a creature to view its details</p>
            </div>
          )}
        </main>
      </div>
    </div>
  );
}

export default BestiaryViewer;
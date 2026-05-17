import { useEffect, useMemo, useRef, useState, type PointerEvent as ReactPointerEvent } from "react";
import BestiaryViewer from "./components/BestiaryViewer";
import "./App.css";

const STARRED_MONSTERS_STORAGE_KEY = "savestate.starred-monsters";
const ENCOUNTER_STRIP_STORAGE_KEY = "savestate.encounter-strip";

export interface StarredMonster {
  id: string;
  name: string;
  source: string;
  type: string;
  cr?: string;
}

function App() {
  const encounterStripRef = useRef<HTMLElement | null>(null);
  const [showBestiary, setShowBestiary] = useState(false);
  const [starredMonsters, setStarredMonsters] = useState<StarredMonster[]>(() => {
    if (typeof window === "undefined") return [];

    try {
      const stored = window.localStorage.getItem(STARRED_MONSTERS_STORAGE_KEY);
      return stored ? (JSON.parse(stored) as StarredMonster[]) : [];
    } catch (error) {
      console.error("Failed to load starred monsters:", error);
      return [];
    }
  });
  const [encounterStripMonsters, setEncounterStripMonsters] = useState<StarredMonster[]>(() => {
    if (typeof window === "undefined") return [];

    try {
      const stored = window.localStorage.getItem(ENCOUNTER_STRIP_STORAGE_KEY);
      return stored ? (JSON.parse(stored) as StarredMonster[]) : [];
    } catch (error) {
      console.error("Failed to load encounter strip monsters:", error);
      return [];
    }
  });
  const [isStripActive, setIsStripActive] = useState(false);
  const [draggedMonster, setDraggedMonster] = useState<StarredMonster | null>(null);
  const [dragPosition, setDragPosition] = useState<{ x: number; y: number } | null>(null);

  useEffect(() => {
    try {
      window.localStorage.setItem(STARRED_MONSTERS_STORAGE_KEY, JSON.stringify(starredMonsters));
    } catch (error) {
      console.error("Failed to save starred monsters:", error);
    }
  }, [starredMonsters]);

  useEffect(() => {
    try {
      window.localStorage.setItem(ENCOUNTER_STRIP_STORAGE_KEY, JSON.stringify(encounterStripMonsters));
    } catch (error) {
      console.error("Failed to save encounter strip monsters:", error);
    }
  }, [encounterStripMonsters]);

  useEffect(() => {
    setEncounterStripMonsters((current) =>
      current.filter((monster) => starredMonsters.some((entry) => entry.id === monster.id)),
    );
  }, [starredMonsters]);

  useEffect(() => {
    if (!draggedMonster) return;

    const updateDragState = (clientX: number, clientY: number) => {
      setDragPosition({ x: clientX, y: clientY });

      const stripBounds = encounterStripRef.current?.getBoundingClientRect();
      const isOverStrip = stripBounds
        ? clientX >= stripBounds.left &&
          clientX <= stripBounds.right &&
          clientY >= stripBounds.top &&
          clientY <= stripBounds.bottom
        : false;

      setIsStripActive(isOverStrip);
    };

    const handlePointerMove = (event: PointerEvent) => {
      updateDragState(event.clientX, event.clientY);
    };

    const handlePointerUp = (event: PointerEvent) => {
      updateDragState(event.clientX, event.clientY);

      const stripBounds = encounterStripRef.current?.getBoundingClientRect();
      const droppedInStrip = stripBounds
        ? event.clientX >= stripBounds.left &&
          event.clientX <= stripBounds.right &&
          event.clientY >= stripBounds.top &&
          event.clientY <= stripBounds.bottom
        : false;

      if (droppedInStrip) {
        addMonsterToStrip(draggedMonster);
      }

      setDraggedMonster(null);
      setDragPosition(null);
      setIsStripActive(false);
    };

    window.addEventListener("pointermove", handlePointerMove);
    window.addEventListener("pointerup", handlePointerUp);

    return () => {
      window.removeEventListener("pointermove", handlePointerMove);
      window.removeEventListener("pointerup", handlePointerUp);
    };
  }, [draggedMonster]);

  const starredMonsterIds = useMemo(
    () => new Set(starredMonsters.map((monster) => monster.id)),
    [starredMonsters],
  );

  const handleToggleStar = (monster: StarredMonster) => {
    setStarredMonsters((current) => {
      const exists = current.some((entry) => entry.id === monster.id);
      if (exists) {
        return current.filter((entry) => entry.id !== monster.id);
      }

      return [...current, monster].sort((a, b) => a.name.localeCompare(b.name));
    });
  };

  const addMonsterToStrip = (monster: StarredMonster) => {
    setEncounterStripMonsters((current) => {
      if (current.some((entry) => entry.id === monster.id)) {
        return current;
      }

      return [...current, monster];
    });
  };

  const removeMonsterFromStrip = (monsterId: string) => {
    setEncounterStripMonsters((current) => current.filter((monster) => monster.id !== monsterId));
  };

  const handlePinnedMonsterPointerDown =
    (monster: StarredMonster) => (event: ReactPointerEvent<HTMLElement>) => {
      if (event.button !== 0) return;

      event.preventDefault();
      setDraggedMonster(monster);
      setDragPosition({ x: event.clientX, y: event.clientY });
      setIsStripActive(false);
    };

  if (showBestiary) {
    return (
      <BestiaryViewer
        onClose={() => setShowBestiary(false)}
        starredMonsterIds={starredMonsterIds}
        onToggleStar={handleToggleStar}
      />
    );
  }

  return (
    <div className="home-container">
      <header className="app-bar">
        <div className="app-bar-brand">
          <p className="home-kicker">Field Ledger</p>
          <h1>SaveState</h1>
        </div>

        <div className="app-bar-actions">
          <div className="hero-stat-card">
            <span className="hero-stat-value">{starredMonsters.length}</span>
            <span className="hero-stat-label">Starred Entries</span>
          </div>

          <button className="book-icon-btn" onClick={() => setShowBestiary(true)} aria-label="Open Bestiary">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5">
              <path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20" />
              <path d="M4 4.5A2.5 2.5 0 0 1 6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15z" />
              <path d="M8 7h8M8 11h8M8 15h4" />
            </svg>
          </button>
        </div>
      </header>

      <section
        ref={encounterStripRef}
        className={`encounter-strip ${isStripActive ? "drag-active" : ""}`}
        aria-label="Encounter strip"
      >
        {encounterStripMonsters.length > 0 && (
          <div className="encounter-strip-list">
            {encounterStripMonsters.map((monster) => (
              <article key={monster.id} className="encounter-chip">
                <div>
                  <h2>{monster.name}</h2>
                  <p>{monster.type}</p>
                </div>
                <button
                  className="encounter-chip-remove"
                  onClick={() => removeMonsterFromStrip(monster.id)}
                  aria-label={`Remove ${monster.name} from encounter strip`}
                >
                  <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8">
                    <path d="M18 6L6 18M6 6l12 12" />
                  </svg>
                </button>
              </article>
            ))}
          </div>
        )}
      </section>

      <section className="home-content">
        <aside className="starred-panel">
          <div className="panel-heading">
            <p className="panel-kicker">Pinned Creatures</p>
            <h2>Starred Monsters</h2>
          </div>

          {starredMonsters.length > 0 ? (
            <div className="starred-list">
              {starredMonsters.map((monster) => (
                <article
                  key={monster.id}
                  className={`starred-card ${draggedMonster?.id === monster.id ? "dragging" : ""}`}
                  onPointerDown={handlePinnedMonsterPointerDown(monster)}
                >
                  <div>
                    <h3>{monster.name}</h3>
                    <p>{monster.type}</p>
                  </div>
                  <div className="starred-meta">
                    <span>{monster.source}</span>
                    <span>{monster.cr ? `CR ${monster.cr}` : "Unrated"}</span>
                  </div>
                </article>
              ))}
            </div>
          ) : (
            <div className="starred-empty">
              <p>No starred monsters yet.</p>
              <span>Open the bestiary and mark creatures with the star to populate this shelf.</span>
            </div>
          )}
        </aside>
      </section>

      {draggedMonster && dragPosition && (
        <div
          className="drag-ghost"
          style={{
            left: `${dragPosition.x}px`,
            top: `${dragPosition.y}px`,
          }}
        >
          <h3>{draggedMonster.name}</h3>
          <p>{draggedMonster.type}</p>
        </div>
      )}
    </div>
  );
}

export default App;

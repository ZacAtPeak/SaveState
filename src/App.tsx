import { useEffect, useMemo, useRef, useState, type PointerEvent as ReactPointerEvent } from "react";
import BestiaryViewer from "./components/BestiaryViewer";
import MonsterDetail from "./components/MonsterDetail";
import {
  fetchAllMonsters,
  fetchBestiaryIndex,
  getMonsterId,
  isPointInRect,
  type Monster,
  type StarredMonster,
} from "./components/bestiaryShared";
import { useLocalStorageState } from "./hooks/useLocalStorageState";
import "./App.css";

const STARRED_MONSTERS_STORAGE_KEY = "savestate.starred-monsters";
const ENCOUNTER_STRIP_STORAGE_KEY = "savestate.encounter-strip";

const byName = (a: StarredMonster, b: StarredMonster) => a.name.localeCompare(b.name);

interface InitiativeEntry {
  entryId: string;
  monster: StarredMonster;
}

const createEntryId = (monsterId: string) => {
  const randomPart =
    typeof crypto !== "undefined" && typeof crypto.randomUUID === "function"
      ? crypto.randomUUID()
      : `${Date.now()}-${Math.random().toString(16).slice(2)}`;
  return `${monsterId}::${randomPart}`;
};

const createInitiativeEntry = (monster: StarredMonster): InitiativeEntry => ({
  entryId: createEntryId(monster.id),
  monster,
});

const isStarredMonster = (value: unknown): value is StarredMonster => {
  if (!value || typeof value !== "object") return false;
  const candidate = value as Partial<StarredMonster>;
  return typeof candidate.id === "string" && typeof candidate.name === "string";
};

const isInitiativeEntry = (value: unknown): value is InitiativeEntry => {
  if (!value || typeof value !== "object") return false;
  const candidate = value as Partial<InitiativeEntry>;
  return typeof candidate.entryId === "string" && isStarredMonster(candidate.monster);
};

const normalizeInitiativeEntries = (value: unknown): InitiativeEntry[] => {
  if (!Array.isArray(value)) return [];

  return value.flatMap((entry) => {
    if (isInitiativeEntry(entry)) return [entry];
    if (isStarredMonster(entry)) return [createInitiativeEntry(entry)];
    return [];
  });
};

function App() {
  const encounterStripRef = useRef<HTMLElement | null>(null);

  const [showBestiary, setShowBestiary] = useState(false);
  const [starredMonsters, setStarredMonsters] = useLocalStorageState<StarredMonster[]>(
    STARRED_MONSTERS_STORAGE_KEY,
    [],
  );
  const [rawEncounterStripMonsters, setRawEncounterStripMonsters] = useLocalStorageState<unknown[]>(
    ENCOUNTER_STRIP_STORAGE_KEY,
    [],
  );
  const [isStripActive, setIsStripActive] = useState(false);
  const [draggedMonster, setDraggedMonster] = useState<StarredMonster | null>(null);
  const [dragPosition, setDragPosition] = useState<{ x: number; y: number } | null>(null);
  const [monsterDetails, setMonsterDetails] = useState<Record<string, Monster>>({});
  const [selectedPinnedMonsterId, setSelectedPinnedMonsterId] = useState<string | null>(null);

  const starredMonsterIds = useMemo(
    () => new Set(starredMonsters.map((monster) => monster.id)),
    [starredMonsters],
  );
  const encounterStripMonsters = useMemo(
    () => normalizeInitiativeEntries(rawEncounterStripMonsters),
    [rawEncounterStripMonsters],
  );

  useEffect(() => {
    const normalizedEntries = normalizeInitiativeEntries(rawEncounterStripMonsters);
    const needsMigration =
      normalizedEntries.length !== rawEncounterStripMonsters.length ||
      normalizedEntries.some((entry, index) => entry !== rawEncounterStripMonsters[index]);

    if (needsMigration) {
      setRawEncounterStripMonsters(normalizedEntries);
    }
  }, [rawEncounterStripMonsters, setRawEncounterStripMonsters]);

  useEffect(() => {
    setRawEncounterStripMonsters((current) =>
      normalizeInitiativeEntries(current).filter((entry) => starredMonsterIds.has(entry.monster.id)),
    );
  }, [starredMonsterIds, setRawEncounterStripMonsters]);

  useEffect(() => {
    const loadMonsterDetails = async () => {
      try {
        const index = await fetchBestiaryIndex();
        const monsters = await fetchAllMonsters(index);
        const byId = Object.fromEntries(monsters.map((monster) => [getMonsterId(monster), monster]));
        setMonsterDetails(byId);
      } catch (error) {
        console.error("Failed to load monster details:", error);
      }
    };

    void loadMonsterDetails();
  }, []);

  useEffect(() => {
    if (starredMonsters.length === 0) {
      setSelectedPinnedMonsterId(null);
      return;
    }

    setSelectedPinnedMonsterId((current) =>
      current && starredMonsterIds.has(current) ? current : starredMonsters[0].id,
    );
  }, [starredMonsters, starredMonsterIds]);

  useEffect(() => {
    if (!draggedMonster) return;

    const isOverStrip = (clientX: number, clientY: number) =>
      isPointInRect(clientX, clientY, encounterStripRef.current?.getBoundingClientRect());

    const handlePointerMove = (event: PointerEvent) => {
      setDragPosition({ x: event.clientX, y: event.clientY });
      setIsStripActive(isOverStrip(event.clientX, event.clientY));
    };

    const handlePointerUp = (event: PointerEvent) => {
      if (isOverStrip(event.clientX, event.clientY)) {
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

  const handleToggleStar = (monster: StarredMonster) => {
    setStarredMonsters((current) => {
      const exists = current.some((entry) => entry.id === monster.id);
      if (exists) return current.filter((entry) => entry.id !== monster.id);
      return [...current, monster].sort(byName);
    });
  };

  const addMonsterToStrip = (monster: StarredMonster) => {
    setRawEncounterStripMonsters((current) => [
      ...normalizeInitiativeEntries(current),
      createInitiativeEntry(monster),
    ]);
  };

  const removeMonsterFromStrip = (entryId: string) => {
    setRawEncounterStripMonsters((current) =>
      normalizeInitiativeEntries(current).filter((entry) => entry.entryId !== entryId),
    );
  };

  const handlePinnedMonsterPointerDown =
    (monster: StarredMonster) => (event: ReactPointerEvent<HTMLElement>) => {
      if (event.button !== 0) return;
      event.preventDefault();
      setDraggedMonster(monster);
      setDragPosition({ x: event.clientX, y: event.clientY });
      setIsStripActive(false);
    };

  const selectedPinnedMonster = selectedPinnedMonsterId
    ? monsterDetails[selectedPinnedMonsterId] ?? null
    : null;

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
          <button className="book-icon-btn" type="button" aria-label="Open Dice Roller">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.7" strokeLinejoin="round">
              <path d="M12 2.75 20.25 7.5v9L12 21.25 3.75 16.5v-9L12 2.75Z" />
              <circle cx="9" cy="9" r="1" fill="currentColor" stroke="none" />
              <circle cx="15" cy="9" r="1" fill="currentColor" stroke="none" />
              <circle cx="9" cy="15" r="1" fill="currentColor" stroke="none" />
              <circle cx="15" cy="15" r="1" fill="currentColor" stroke="none" />
            </svg>
          </button>

          <button
            className="book-icon-btn"
            type="button"
            onClick={() => setShowBestiary(true)}
            aria-label="Open Bestiary"
          >
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
            {encounterStripMonsters.map(({ entryId, monster }) => (
              <article key={entryId} className="encounter-chip">
                <div>
                  <h2>{monster.name}</h2>
                  <p>{monster.type}</p>
                </div>
                <button
                  className="encounter-chip-remove"
                  onClick={() => removeMonsterFromStrip(entryId)}
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
              {starredMonsters.map((monster) => {
                const isDragging = draggedMonster?.id === monster.id;
                const isSelected = selectedPinnedMonsterId === monster.id;
                return (
                  <article
                    key={monster.id}
                    className={`starred-card ${isDragging ? "dragging" : ""} ${isSelected ? "selected" : ""}`}
                    onPointerDown={handlePinnedMonsterPointerDown(monster)}
                    onClick={() => setSelectedPinnedMonsterId(monster.id)}
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
                );
              })}
            </div>
          ) : (
            <div className="starred-empty">
              <p>No starred monsters yet.</p>
              <span>Open the bestiary and mark creatures with the star to populate this shelf.</span>
            </div>
          )}
        </aside>

        <MonsterDetail
          monster={selectedPinnedMonster}
          starredMonsterIds={starredMonsterIds}
          onToggleStar={handleToggleStar}
          emptyMessage="Select a pinned creature to inspect it here"
        />
      </section>

      {draggedMonster && dragPosition && (
        <div
          className="drag-ghost"
          style={{ left: `${dragPosition.x}px`, top: `${dragPosition.y}px` }}
        >
          <h3>{draggedMonster.name}</h3>
          <p>{draggedMonster.type}</p>
        </div>
      )}
    </div>
  );
}

export default App;

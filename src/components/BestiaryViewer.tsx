import { useEffect, useMemo, useState } from "react";
import MonsterDetail from "./MonsterDetail";
import {
  fetchAllMonsters,
  fetchBestiaryFile,
  fetchBestiaryIndex,
  getMonsterId,
  getMonsterType,
  toStarredMonster,
  type BestiaryIndex,
  type Monster,
  type StarredMonster,
} from "./bestiaryShared";
import "./BestiaryViewer.css";

const ALL_SOURCES_VALUE = "all";
const ALL_TYPES_VALUE = "all";

interface BestiaryViewerProps {
  onClose?: () => void;
  starredMonsterIds: Set<string>;
  onToggleStar: (monster: StarredMonster) => void;
}

function BestiaryViewer({ onClose, starredMonsterIds, onToggleStar }: BestiaryViewerProps) {
  const [sourceFiles, setSourceFiles] = useState<BestiaryIndex>({});
  const [selectedSource, setSelectedSource] = useState<string>("");
  const [monsters, setMonsters] = useState<Monster[]>([]);
  const [selectedMonster, setSelectedMonster] = useState<Monster | null>(null);
  const [searchQuery, setSearchQuery] = useState("");
  const [filterType, setFilterType] = useState<string>(ALL_TYPES_VALUE);
  const [isReady, setIsReady] = useState(false);

  useEffect(() => {
    const loadIndex = async () => {
      try {
        const index = await fetchBestiaryIndex();
        setSourceFiles(index);
        setSelectedSource(ALL_SOURCES_VALUE);
      } catch (error) {
        console.error("Failed to load index:", error);
      } finally {
        setIsReady(true);
      }
    };

    void loadIndex();
  }, []);

  useEffect(() => {
    if (!selectedSource) return;

    const loadMonsters = async () => {
      try {
        if (selectedSource === ALL_SOURCES_VALUE) {
          setMonsters(await fetchAllMonsters(sourceFiles));
        } else {
          const filename = sourceFiles[selectedSource];
          if (!filename) {
            console.error(`No bestiary filename found for source "${selectedSource}"`);
            setMonsters([]);
          } else {
            setMonsters(await fetchBestiaryFile(filename));
          }
        }
        setSelectedMonster(null);
      } catch (error) {
        console.error("Failed to load bestiary:", error);
        setMonsters([]);
      }
    };

    void loadMonsters();
  }, [selectedSource, sourceFiles]);

  const filteredMonsters = useMemo(() => {
    const needle = searchQuery.toLowerCase();
    const typeNeedle = filterType.toLowerCase();
    return monsters.filter((monster) => {
      const matchesSearch = monster.name.toLowerCase().includes(needle);
      const matchesType =
        filterType === ALL_TYPES_VALUE || getMonsterType(monster).toLowerCase().includes(typeNeedle);
      return matchesSearch && matchesType;
    });
  }, [monsters, searchQuery, filterType]);

  const types = useMemo(
    () => [ALL_TYPES_VALUE, ...new Set(monsters.map(getMonsterType))].sort(),
    [monsters],
  );

  const sources = Object.keys(sourceFiles);

  if (!isReady) {
    return (
      <div className="bestiary-loading">
        <div className="loading-spinner" />
        <span>Opening the grimoire...</span>
      </div>
    );
  }

  if (sources.length === 0) {
    return (
      <div className="bestiary-loading">
        <span>Failed to load bestiary data</span>
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
            <option value={ALL_SOURCES_VALUE}>All Sources</option>
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
                {type === ALL_TYPES_VALUE ? "All Types" : type}
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
            {filteredMonsters.map((monster) => {
              const monsterId = getMonsterId(monster);
              const isStarred = starredMonsterIds.has(monsterId);
              return (
                <div
                  key={monsterId}
                  className={`monster-item ${selectedMonster?.name === monster.name ? "selected" : ""}`}
                >
                  <button className="monster-select-btn" onClick={() => setSelectedMonster(monster)}>
                    <span className="monster-name">{monster.name}</span>
                    <span className="monster-type">{getMonsterType(monster)}</span>
                  </button>
                  <button
                    className={`star-toggle ${isStarred ? "active" : ""}`}
                    onClick={() => onToggleStar(toStarredMonster(monster))}
                    aria-label={
                      isStarred
                        ? `Remove ${monster.name} from starred monsters`
                        : `Star ${monster.name}`
                    }
                  >
                    <svg viewBox="0 0 24 24" fill="currentColor" stroke="currentColor" strokeWidth="1.4">
                      <path d="M12 3.4l2.67 5.41 5.98.87-4.33 4.22 1.02 5.96L12 17.05 6.66 19.86l1.02-5.96-4.33-4.22 5.98-.87L12 3.4z" />
                    </svg>
                  </button>
                </div>
              );
            })}
          </div>
        </aside>

        <MonsterDetail
          monster={selectedMonster}
          starredMonsterIds={starredMonsterIds}
          onToggleStar={onToggleStar}
        />
      </div>
    </div>
  );
}

export default BestiaryViewer;

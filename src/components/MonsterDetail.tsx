import {
  ABILITY_KEYS,
  formatArmorClass,
  formatHitPoints,
  formatSpeed,
  getModifier,
  getMonsterId,
  getMonsterType,
  parseDamageEntries,
  toStarredMonster,
  type Monster,
  type StarredMonster,
} from "./bestiaryShared";
import "./BestiaryViewer.css";

interface MonsterDetailProps {
  monster: Monster | null;
  starredMonsterIds?: Set<string>;
  onToggleStar?: (monster: StarredMonster) => void;
  emptyMessage?: string;
}

type Entry = { name: string; entries: string[] };

interface EntrySectionProps {
  title: string;
  className: string;
  itemClassName: string;
  entries: Entry[] | undefined;
  renderText?: (entry: Entry) => string;
}

function EntrySection({
  title,
  className,
  itemClassName,
  entries,
  renderText = (entry) => parseDamageEntries(entry.entries),
}: EntrySectionProps) {
  if (!entries || entries.length === 0) return null;

  return (
    <section className={className}>
      <h3 className="section-title">{title}</h3>
      {entries.map((entry, index) => (
        <div key={index} className={itemClassName}>
          <span className={`${itemClassName}-name`}>{entry.name}.</span>
          <span className={`${itemClassName}-text`}>{renderText(entry)}</span>
        </div>
      ))}
    </section>
  );
}

interface DefenseRowProps {
  label: string;
  values: string[] | undefined;
}

function DefenseRow({ label, values }: DefenseRowProps) {
  if (!values) return null;
  return (
    <div className="defense-row">
      <span className="defense-label">{label}</span>
      <span className="defense-value">{values.join(", ")}</span>
    </div>
  );
}

const STAR_ICON = (
  <svg viewBox="0 0 24 24" fill="currentColor" stroke="currentColor" strokeWidth="1.4">
    <path d="M12 3.4l2.67 5.41 5.98.87-4.33 4.22 1.02 5.96L12 17.05 6.66 19.86l1.02-5.96-4.33-4.22 5.98-.87L12 3.4z" />
  </svg>
);

function MonsterDetail({
  monster,
  starredMonsterIds,
  onToggleStar,
  emptyMessage = "Select a creature to view its details",
}: MonsterDetailProps) {
  if (!monster) {
    return (
      <main className="monster-detail">
        <div className="empty-state">
          <svg className="empty-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path d="M12 2L2 7l10 5 10-5-10-5z" />
            <path d="M2 17l10 5 10-5" />
            <path d="M2 12l10 5 10-5" />
          </svg>
          <p>{emptyMessage}</p>
        </div>
      </main>
    );
  }

  const isStarred = starredMonsterIds?.has(getMonsterId(monster)) ?? false;
  const canToggleStar = onToggleStar && starredMonsterIds;
  const hasDefenses = Boolean(monster.resist || monster.immune || monster.conditionImmune);

  return (
    <main className="monster-detail">
      <article className="monster-card">
        <header className="card-header">
          <div className="card-title-section">
            <h2 className="monster-name">{monster.name}</h2>
            <div className="monster-meta">
              <span className="meta-source">{monster.source}</span>
              {monster.page && <span className="meta-page">p. {monster.page}</span>}
              <span className="meta-size">
                {monster.size?.join(" ")} {getMonsterType(monster)}
              </span>
              {monster.alignment?.map((alignment, index) => (
                <span key={index} className="meta-alignment">
                  {alignment}
                </span>
              ))}
            </div>
          </div>
          <div className="card-header-actions">
            {canToggleStar && (
              <button
                className={`detail-star-toggle ${isStarred ? "active" : ""}`}
                onClick={() => onToggleStar(toStarredMonster(monster))}
              >
                {STAR_ICON}
                <span>{isStarred ? "Starred" : "Star"}</span>
              </button>
            )}
            {monster.cr && (
              <div className="cr-badge">
                <span className="cr-label">CR</span>
                <span className="cr-value">{monster.cr}</span>
              </div>
            )}
          </div>
        </header>

        <div className="stats-block">
          <div className="stat-row">
            {ABILITY_KEYS.map((statKey) => (
              <div key={statKey} className="stat">
                <span className="stat-label">{statKey.toUpperCase()}</span>
                <span className="stat-value">{monster[statKey] ?? "—"}</span>
                <span className="stat-mod">{getModifier(monster[statKey])}</span>
              </div>
            ))}
          </div>
        </div>

        <div className="combat-block">
          <div className="combat-row">
            <div className="combat-stat">
              <span className="combat-label">Armor Class</span>
              <span className="combat-value">{formatArmorClass(monster.ac)}</span>
            </div>
            <div className="combat-stat">
              <span className="combat-label">Hit Points</span>
              <span className="combat-value">{formatHitPoints(monster.hp)}</span>
            </div>
            <div className="combat-stat">
              <span className="combat-label">Speed</span>
              <span className="combat-value">{formatSpeed(monster.speed)}</span>
            </div>
          </div>
        </div>

        {hasDefenses && (
          <div className="defenses-block">
            <DefenseRow label="Damage Resistances" values={monster.resist} />
            <DefenseRow label="Damage Immunities" values={monster.immune} />
            <DefenseRow label="Condition Immunities" values={monster.conditionImmune} />
          </div>
        )}

        {monster.senses && (
          <div className="senses-block">
            <span className="senses-label">Senses</span>
            <span className="senses-value">{monster.senses.join(", ")}</span>
            {monster.passive && <span className="passive-wis">passive Wisdom {monster.passive}</span>}
          </div>
        )}

        {monster.languages && (
          <div className="languages-block">
            <span className="languages-label">Languages</span>
            <span className="languages-value">{monster.languages.join(", ")}</span>
          </div>
        )}

        <EntrySection
          title="Traits"
          className="traits-section"
          itemClassName="trait"
          entries={monster.trait}
        />

        {monster.spellcasting && monster.spellcasting.length > 0 && (
          <section className="spellcasting-section">
            <h3 className="section-title">Spellcasting</h3>
            {monster.spellcasting.map((spellcasting, index) => (
              <div key={index} className="spellcasting">
                <span className="spell-name">{spellcasting.name}.</span>
                <span className="spell-text">{spellcasting.headerEntries?.join(" ")}</span>
              </div>
            ))}
          </section>
        )}

        <EntrySection
          title="Actions"
          className="actions-section"
          itemClassName="action"
          entries={monster.action}
        />

        <EntrySection
          title="Legendary Actions"
          className="legendary-section"
          itemClassName="legendary"
          entries={monster.legendary}
        />
      </article>
    </main>
  );
}

export default MonsterDetail;

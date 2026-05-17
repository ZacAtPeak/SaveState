export interface Monster {
  name: string;
  source: string;
  page?: number;
  size?: string[];
  type: string | { type?: string; tags?: string[] };
  alignment?: string[];
  ac?: Array<number | { ac: number; from?: string[] }>;
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

export interface StarredMonster {
  id: string;
  name: string;
  source: string;
  type: string;
  cr?: string;
}

export type BestiaryIndex = Record<string, string>;

export const ABILITY_KEYS = ["str", "dex", "con", "int", "wis", "cha"] as const;

export const normalizeMonsterType = (
  value: Monster["type"] | string[] | { choose?: string[] } | undefined,
): string => {
  if (!value) return "unknown";
  if (typeof value === "string") return value;
  if (Array.isArray(value)) return value.join(", ");
  if ("choose" in value && Array.isArray(value.choose)) return value.choose.join(" / ");
  if ("type" in value) return normalizeMonsterType(value.type);
  return "unknown";
};

export const getMonsterType = (monster: Monster): string => normalizeMonsterType(monster.type);

export const getMonsterId = (monster: Pick<Monster, "name" | "source">): string =>
  `${monster.name}::${monster.source}`;

export const toStarredMonster = (monster: Monster): StarredMonster => ({
  id: getMonsterId(monster),
  name: monster.name,
  source: monster.source,
  type: getMonsterType(monster),
  cr: monster.cr,
});

export const formatArmorClass = (acList?: Monster["ac"]): string => {
  if (!acList?.length) return "—";

  return acList
    .map((entry) => {
      if (typeof entry === "number") return `${entry}`;
      return `${entry.ac}${entry.from?.length ? ` (${entry.from.join(", ")})` : ""}`;
    })
    .join(", ");
};

export const formatSpeed = (speed: Monster["speed"]): string => {
  if (!speed) return "—";
  return Object.entries(speed)
    .map(([key, value]) => `${value} ft. ${key}`)
    .join(", ");
};

export const formatHitPoints = (hp: Monster["hp"]): string => {
  if (!hp) return "—";
  if (hp.special) return hp.special;
  return `${hp.average}${hp.formula ? ` (${hp.formula})` : ""}`;
};

export const getModifier = (stat: number | undefined): string => {
  if (!stat) return "—";
  const mod = Math.floor((stat - 10) / 2);
  return mod >= 0 ? `+${mod}` : `${mod}`;
};

const DAMAGE_ENTRY_REPLACEMENTS: Array<[RegExp, string]> = [
  [/\{@atk mw\}/g, "Melee Weapon Attack:"],
  [/\{@atk rw\}/g, "Ranged Weapon Attack:"],
  [/\{@hit (\d+)\}/g, "+$1 to hit"],
  [/\{@h\}/g, "Hit:"],
  [/\{@damage (.+?)\}/g, "$1"],
  [/\{@d (\d+)d(\d+)\}/g, "$1d$2"],
  [/[{}]/g, ""],
];

export const parseDamageEntries = (entries: string[]): string =>
  DAMAGE_ENTRY_REPLACEMENTS.reduce(
    (text, [pattern, replacement]) => text.replace(pattern, replacement),
    entries.join(" "),
  );

const BESTIARY_BASE_PATH = "/data/bestiary";

export const fetchBestiaryIndex = async (): Promise<BestiaryIndex> => {
  const response = await fetch(`${BESTIARY_BASE_PATH}/index.json`);
  return (await response.json()) as BestiaryIndex;
};

export const fetchBestiaryFile = async (filename: string): Promise<Monster[]> => {
  const response = await fetch(`${BESTIARY_BASE_PATH}/${filename}`);
  const data = (await response.json()) as { monster?: Monster[] };
  return data.monster ?? [];
};

export const fetchAllMonsters = async (index: BestiaryIndex): Promise<Monster[]> => {
  const bestiaries = await Promise.all(Object.values(index).map(fetchBestiaryFile));
  return bestiaries.flat();
};

export const isPointInRect = (
  clientX: number,
  clientY: number,
  rect: DOMRect | undefined,
): boolean => {
  if (!rect) return false;
  return (
    clientX >= rect.left && clientX <= rect.right && clientY >= rect.top && clientY <= rect.bottom
  );
};

export function getLevelLabel(level: number): string {
  if (level === 0) return 'Cantrips';
  const suffix = level === 1 ? 'st' : level === 2 ? 'nd' : level === 3 ? 'rd' : 'th';
  return `${level}${suffix} Level`;
}

export function groupByLevel<T extends { level: number }>(
  spells: T[]
): { level: number; label: string; spells: T[] }[] {
  const map = new Map<number, T[]>();
  for (const spell of spells) {
    const list = map.get(spell.level) ?? [];
    list.push(spell);
    map.set(spell.level, list);
  }
  const sortedLevels = [...map.keys()].sort((a, b) => a - b);
  return sortedLevels.map(level => ({
    level,
    label: getLevelLabel(level),
    spells: map.get(level)!
  }));
}

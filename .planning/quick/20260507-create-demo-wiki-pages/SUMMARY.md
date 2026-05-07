---
status: complete
date: 2026-05-07
---

# Summary: Create 20 demo wiki entries

## What was done

Created `packages/core/lib/data/demo_wiki_pages.dart` with 20 diverse `WikiPage` instances covering all 7 page types:

- **3 Creatures**: Goblin Scout (CR 1/4), Vampire Spawn (CR 5), Ancient Red Dragon (CR 24)
- **3 Spells**: Fireball (3rd), Shield (1st), Misty Step (2nd)
- **3 Items**: Sword of Wounding (Rare), Cloak of Protection (Uncommon), Potion of Speed (Very Rare)
- **3 Rules**: Concentration, Advantage/Disadvantage, Death Saving Throws
- **3 Locations**: Neverwinter (City), Undermountain (Dungeon), The Moonlit Forest (Wilderness)
- **3 NPCs**: Lady Seraphine Ashvale (merchant), Korrax Ironteeth (crime lord), Elder Miriam (sage)
- **2 Other**: The Draconic Prophecy (lore), The Order of the Silver Hand (faction)

## Files changed

- `packages/core/lib/data/demo_wiki_pages.dart` — new file, 20 WikiPage entries
- `packages/core/lib/data/data.dart` — added export
- `packages/core/lib/wiki/wiki_provider.dart` — seeds demo pages on first load when storage is empty

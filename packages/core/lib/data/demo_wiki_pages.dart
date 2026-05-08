import '../models/models.dart';

final demoWikiPages = <WikiPage>[
  // ── Creatures ──────────────────────────────────────────────────────────────
  WikiPage(
    title: 'Goblin Scout',
    entityTypeKey: 'creature',
    body:
        'A scrappy goblin who serves as an advance lookout for larger raiding parties. '
        'Cowardly alone but dangerous in numbers, it relies on hit-and-run tactics and '
        'exploiting terrain to ambush unsuspecting travelers.',
    tags: ['goblinoid', 'small', 'common', 'cr-1/4'],
    aliases: ['goblin', 'scout'],
    statBlock: {
      'size': 'Small',
      'creatureType': 'Humanoid (goblinoid)',
      'armorClass': 13,
      'hitPoints': 7,
      'speed': '30 ft.',
      'challengeRating': '1/4',
    },
  ),
  WikiPage(
    title: 'Vampire Spawn',
    entityTypeKey: 'creature',
    body:
        'Slaves to their vampire masters, these creatures retain just enough of their '
        'former humanity to feel the horror of what they have become. They hunger for '
        'blood and cannot enter a dwelling without an invitation.',
    tags: ['undead', 'medium', 'cr-5', 'vampire'],
    aliases: ['spawn', 'thrall'],
    statBlock: {
      'size': 'Medium',
      'creatureType': 'Undead',
      'armorClass': 15,
      'hitPoints': 82,
      'speed': '30 ft.',
      'challengeRating': '5',
    },
  ),
  WikiPage(
    title: 'Ancient Red Dragon',
    entityTypeKey: 'creature',
    body:
        'The most covetous of all true dragons, ancient reds are arrogant tyrants '
        'that consider themselves the apex predators of the world. Their breath weapon '
        'scorches entire hillsides and their scales glow like smoldering coals.',
    tags: ['dragon', 'huge', 'cr-24', 'fire', 'legendary'],
    aliases: ['red dragon', 'flame wyrm'],
    statBlock: {
      'size': 'Huge',
      'creatureType': 'Dragon',
      'armorClass': 22,
      'hitPoints': 546,
      'speed': '40 ft., climb 40 ft., fly 80 ft.',
      'challengeRating': '24',
    },
  ),

  // ── Spells ─────────────────────────────────────────────────────────────────
  WikiPage(
    title: 'Fireball',
    entityTypeKey: 'spell',
    body:
        'A bright streak flashes from your pointing finger to a point you choose and '
        'then blossoms with a low roar into an explosion of flame. Each creature in a '
        '20-foot-radius sphere must make a Dexterity saving throw. Deals 8d6 fire '
        'damage (half on a save).',
    tags: ['evocation', 'area-of-effect', 'fire', 'classic'],
    aliases: ['FB'],
    statBlock: {
      'level': 3,
      'school': 'Evocation',
      'castingTime': '1 action',
      'range': '150 feet',
      'duration': 'Instantaneous',
      'components': 'V, S, M (a tiny ball of bat guano and sulfur)',
    },
  ),
  WikiPage(
    title: 'Shield',
    entityTypeKey: 'spell',
    body:
        'An invisible barrier of magical force appears and protects you. Until the '
        'start of your next turn, you have a +5 bonus to AC, including against the '
        'triggering attack, and you take no damage from magic missile.',
    tags: ['abjuration', 'reaction', 'defense', 'wizard'],
    aliases: ['shield spell'],
    statBlock: {
      'level': 1,
      'school': 'Abjuration',
      'castingTime': '1 reaction, when hit by an attack or targeted by magic missile',
      'range': 'Self',
      'duration': '1 round',
      'components': 'V, S',
    },
  ),
  WikiPage(
    title: 'Misty Step',
    entityTypeKey: 'spell',
    body:
        'Briefly surrounded by silvery mist, you teleport up to 30 feet to an '
        'unoccupied space that you can see. A popular escape and repositioning tool '
        'for spellcasters caught in melee.',
    tags: ['conjuration', 'teleport', 'bonus-action', 'mobility'],
    aliases: ['blink step'],
    statBlock: {
      'level': 2,
      'school': 'Conjuration',
      'castingTime': '1 bonus action',
      'range': 'Self',
      'duration': 'Instantaneous',
      'components': 'V',
    },
  ),

  // ── Items ──────────────────────────────────────────────────────────────────
  WikiPage(
    title: 'Sword of Wounding',
    entityTypeKey: 'item',
    body:
        'Hit points lost to this magic weapon can be regained only through a short or '
        'long rest, rather than by regeneration, magic, or any other means. Once per '
        'turn, when you hit a creature with this weapon, you can wound the target.',
    tags: ['weapon', 'longsword', 'rare', 'cursed-wounds'],
    aliases: ['wounding sword'],
    statBlock: {
      'rarity': 'Rare',
      'itemType': 'Weapon (any sword)',
      'attunement': 'Yes',
      'weight': 3,
      'value': '5,000 gp',
      'properties': 'Wounds dealt cannot be healed by magic until after a rest.',
    },
  ),
  WikiPage(
    title: 'Cloak of Protection',
    entityTypeKey: 'item',
    body:
        'You gain a +1 bonus to AC and saving throws while you wear this cloak. '
        'A simple but highly sought-after defensive item, favored by scouts and '
        'spellcasters who want resilience without heavy armor.',
    tags: ['armor', 'uncommon', 'ac-bonus', 'saves'],
    aliases: ['protection cloak'],
    statBlock: {
      'rarity': 'Uncommon',
      'itemType': 'Wondrous Item',
      'attunement': 'Yes',
      'weight': 1,
      'value': '500 gp',
      'properties': '+1 bonus to AC and saving throws.',
    },
  ),
  WikiPage(
    title: 'Potion of Speed',
    entityTypeKey: 'item',
    body:
        'When you drink this potion, you gain the effect of the haste spell for '
        '1 minute (no concentration required). The potion\'s golden liquid looks '
        'like liquefied sunlight and smells faintly of lightning.',
    tags: ['consumable', 'rare', 'haste', 'combat'],
    aliases: ['haste potion'],
    statBlock: {
      'rarity': 'Very Rare',
      'itemType': 'Potion',
      'attunement': 'No',
      'weight': 0,
      'value': '2,000 gp',
      'properties': 'Grants Haste for 1 minute. No concentration required.',
    },
  ),

  // ── Rules ──────────────────────────────────────────────────────────────────
  WikiPage(
    title: 'Concentration',
    entityTypeKey: 'rule',
    body:
        'Some spells require concentration to maintain their effect. If you cast '
        'another concentration spell or take damage (DC 10 or half damage, whichever '
        'is higher), you must make a Constitution saving throw or lose the spell. '
        'Features like War Caster grant advantage on this check.',
    tags: ['magic', 'core-rule', 'spellcasting'],
    aliases: ['conc', 'concentration check'],
    statBlock: {
      'ruleCategory': 'Magic',
      'appliesTo': 'All spellcasters using concentration spells',
      'sourcebook': 'Player\'s Handbook',
      'pageNumber': 203,
      'summary':
          'One concentration spell at a time. Broken by casting another or by failing a Con save after taking damage.',
    },
  ),
  WikiPage(
    title: 'Advantage and Disadvantage',
    entityTypeKey: 'rule',
    body:
        'When you have advantage, roll two d20s and take the higher result. '
        'With disadvantage, roll two d20s and take the lower. Multiple sources of '
        'advantage or disadvantage don\'t stack — one of each cancels out.',
    tags: ['core-rule', 'dice', 'combat', 'ability-checks'],
    aliases: ['adv', 'disadv', 'advantage', 'disadvantage'],
    statBlock: {
      'ruleCategory': 'Combat',
      'appliesTo': 'Attack rolls, ability checks, saving throws',
      'sourcebook': 'Player\'s Handbook',
      'pageNumber': 173,
      'summary':
          'Roll 2d20, take higher (advantage) or lower (disadvantage). One of each cancels.',
    },
  ),
  WikiPage(
    title: 'Death Saving Throws',
    entityTypeKey: 'rule',
    body:
        'When you drop to 0 HP you are unconscious and must make death saving throws '
        'each turn. Three successes = stable. Three failures = dead. A natural 20 '
        'restores 1 HP. Damage while at 0 HP counts as one failure (two if the source '
        'is within 5 feet).',
    tags: ['core-rule', 'combat', 'death', 'saving-throw'],
    aliases: ['death saves', 'dying'],
    statBlock: {
      'ruleCategory': 'Combat',
      'appliesTo': 'Player characters and some NPCs',
      'sourcebook': 'Player\'s Handbook',
      'pageNumber': 197,
      'summary': '3 successes = stable, 3 failures = dead. Nat 20 restores 1 HP.',
    },
  ),

  // ── Locations ──────────────────────────────────────────────────────────────
  WikiPage(
    title: 'Neverwinter',
    entityTypeKey: 'location',
    body:
        'Known as the City of Skilled Hands and the Jewel of the North, Neverwinter '
        'sits on the Sword Coast and is famed for its warm river and the resilience '
        'of its people following the cataclysm of Mount Hotenow. It is ruled by '
        'Lord Protector Dagult Neverember.',
    tags: ['city', 'sword-coast', 'faerun', 'major-settlement'],
    aliases: ['City of Skilled Hands', 'Jewel of the North'],
    statBlock: {
      'region': 'Sword Coast, Faerûn',
      'locationType': 'City',
      'population': 23000,
      'factionControl': 'Lord Protector Dagult Neverember',
      'notableFeatures': 'Warm Neverwinter River, Hall of Justice, Protector\'s Enclave',
    },
  ),
  WikiPage(
    title: 'Undermountain',
    entityTypeKey: 'location',
    body:
        'The largest dungeon in Faerûn, Undermountain sprawls beneath Waterdeep. '
        'Created by the Mad Mage Halaster Blackcloak, it contains over twenty levels '
        'of tunnels and chambers filled with monsters, traps, and ancient secrets.',
    tags: ['dungeon', 'waterdeep', 'faerun', 'mega-dungeon'],
    aliases: ['Halaster\'s Lair', 'the Dungeon'],
    statBlock: {
      'region': 'Waterdeep, Faerûn',
      'locationType': 'Dungeon',
      'population': 0,
      'factionControl': 'Halaster Blackcloak (The Mad Mage)',
      'notableFeatures': '20+ dungeon levels, planar portals, Halaster\'s warping magic',
    },
  ),
  WikiPage(
    title: 'The Moonlit Forest',
    entityTypeKey: 'location',
    body:
        'An ancient woodland said to be touched by the Feywild. Trees here glow '
        'faintly silver at night and the stars seem closer. Eladrin and fey creatures '
        'make their home here. Travelers who wander off the path may find themselves '
        'hours or even days away from where they started.',
    tags: ['wilderness', 'fey', 'forest', 'dangerous', 'custom'],
    aliases: ['Silver Wood', 'the Feywood'],
    statBlock: {
      'region': 'Heartlands (custom campaign)',
      'locationType': 'Wilderness',
      'population': 0,
      'factionControl': 'Archfey Sylvara the Pale',
      'notableFeatures': 'Glowing trees, time distortion, Feywild crossings',
    },
  ),

  // ── NPCs ───────────────────────────────────────────────────────────────────
  WikiPage(
    title: 'Lady Seraphine Ashvale',
    entityTypeKey: 'npc',
    body:
        'Proprietor of the Gilded Anchor trading company, Lady Ashvale is impeccably '
        'dressed and unfailingly polite. She knows the value of everything and the '
        'price of everyone. Rumors say she bribed half the city council to secure '
        'her shipping monopoly.',
    tags: ['merchant', 'noble', 'lawful-neutral', 'recurring'],
    aliases: ['Lady Ashvale', 'the Merchant Queen'],
    statBlock: {
      'race': 'Human',
      'classOrRole': 'Merchant / Faction Leader',
      'alignment': 'Lawful Neutral',
      'goals': 'Expand the Gilded Anchor trading empire across three kingdoms.',
      'secrets': 'Her fortune was built on stolen elven trade routes. An elven agent is closing in.',
    },
  ),
  WikiPage(
    title: 'Korrax Ironteeth',
    entityTypeKey: 'npc',
    body:
        'Korrax runs the Broken Fang thieves\' guild from the sewers beneath the '
        'market district. Half-orc and twice as clever as anyone gives him credit '
        'for, he has survived three assassination attempts and holds enough dirt on '
        'city officials to bring the whole government down.',
    tags: ['crime', 'thieves-guild', 'chaotic-neutral', 'recurring'],
    aliases: ['the Fang', 'Ironteeth'],
    statBlock: {
      'race': 'Half-Orc',
      'classOrRole': 'Crime Lord / Rogue',
      'alignment': 'Chaotic Neutral',
      'goals': 'Keep the Broken Fang independent — refuses to answer to any kingdom.',
      'secrets': 'He is protecting a young half-elf pickpocket who is the secret heir to the duchy.',
    },
  ),
  WikiPage(
    title: 'Elder Miriam of the Amber Circle',
    entityTypeKey: 'npc',
    body:
        'A gnome archivist and retired adventurer, Elder Miriam is the de facto '
        'keeper of lore for the region. She has three cats, seventeen apprentices, '
        'and a memory that borders on supernatural. She trades information freely '
        'but always expects something equally interesting in return.',
    tags: ['sage', 'gnome', 'neutral-good', 'lore'],
    aliases: ['Miriam', 'the Elder'],
    statBlock: {
      'race': 'Forest Gnome',
      'classOrRole': 'Lore Sage / Retired Wizard',
      'alignment': 'Neutral Good',
      'goals': 'Catalogue every spell, creature, and artifact ever documented.',
      'secrets': 'She knows the location of a lost library that contains a lich\'s phylactery research.',
    },
  ),

  // ── Other ──────────────────────────────────────────────────────────────────
  WikiPage(
    title: 'The Draconic Prophecy',
    entityTypeKey: 'other',
    body:
        'An ancient and ever-shifting set of prophecies recorded in Draconic script '
        'across thousands of stone tablets, cave walls, and dragonscale journals. '
        'Scholars argue whether it predicts the future or merely catalyzes events by '
        'being believed. The party found a fragment that mentions "four who bear no '
        'shadow" standing before the Pillar of Night.',
    tags: ['lore', 'prophecy', 'dragon', 'campaign-arc'],
    aliases: ['Prophecy', 'the Tablets'],
    statBlock: {
      'category': 'Lore / Campaign Arc',
      'reference': 'Session 3 — discovered in the Sunken Citadel vault',
      'notes':
          'Fragment reads: "Four who bear no shadow shall stand before the Pillar of Night when the twin moons align." Party has not identified the Pillar of Night\'s location.',
    },
  ),
  WikiPage(
    title: 'The Order of the Silver Hand',
    entityTypeKey: 'other',
    body:
        'A knightly order dedicated to combating undead and fiends. Headquartered '
        'in the Sunspire Citadel, they accept members of any class but require a '
        'sworn oath of protection toward the innocent. They are currently stretched '
        'thin fighting a vampire uprising in the eastern provinces.',
    tags: ['faction', 'paladin', 'anti-undead', 'ally'],
    aliases: ['Silver Hand', 'the Order'],
    statBlock: {
      'category': 'Faction / Organization',
      'reference': 'Mentioned by Elder Miriam in session 4',
      'notes':
          'Grand Commander: Lady Thessara Vorn. Current strength: ~200 knights. Seeking capable allies. May offer titles or equipment in exchange for help with the vampire threat.',
    },
  ),
];

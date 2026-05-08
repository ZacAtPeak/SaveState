import '../models/models.dart';

final List<Map<String, dynamic>> _npcJsonData = [
  {
    'name': 'Grimjaw the Blacksmith',
    'role': 'Village Blacksmith and Weapons Merchant',
    'size': 'medium',
    'alignment': 'neutralGood',
    'biography': 'A gruff but kind-hearted dwarf who fled his mountain home after a goblin raid. Now runs the only forge in Riverwood, crafting quality weapons and armor for adventurers.',
    'armorClass': 13,
    'armorSource': 'Leather Apron',
    'currentHP': 22,
    'maxHP': 22,
    'hitDice': '4d8+4',
    'speed': {'walk': 25},
    'abilityScores': {'strength': 16, 'dexterity': 10, 'constitution': 14, 'intelligence': 12, 'wisdom': 10, 'charisma': 8},
    'proficiencyBonus': 2,
    'savingThrowProficiencies': {'strength': true, 'constitution': true},
    'skills': [
      {'skill': 'Athletics', 'isProficient': true, 'bonus': 5, 'abilityScore': 'STR'},
      {'skill': 'History', 'isProficient': false, 'bonus': 1, 'abilityScore': 'INT'}
    ],
    'damageResistances': [],
    'damageImmunities': [],
    'conditionImmunities': [],
    'senses': {'darkvision': 60, 'passivePerception': 10},
    'languages': ['Common', 'Dwarvish'],
    'specialAbilities': [],
    'actions': [
      {'id': 'npc1-a1', 'name': 'Warhammer', 'hitBonus': 5, 'reach': '5 ft.', 'damageRoll': '1d8+3', 'damageType': 'bludgeoning'}
    ],
    'knownSpells': [],
  },
  {
    'name': 'Elara Dawnstrider',
    'role': 'Temple High Priestess',
    'size': 'medium',
    'alignment': 'lawfulGood',
    'biography': 'The serene leader of the Temple of Lathander in the city of Dawnspire. She offers healing services and guidance to those seeking to combat the rising undead threat.',
    'armorClass': 14,
    'armorSource': 'Mage Armor',
    'currentHP': 38,
    'maxHP': 38,
    'hitDice': '6d8+6',
    'speed': {'walk': 30},
    'abilityScores': {'strength': 8, 'dexterity': 12, 'constitution': 12, 'intelligence': 14, 'wisdom': 18, 'charisma': 16},
    'proficiencyBonus': 3,
    'savingThrowProficiencies': {'wisdom': true, 'charisma': true},
    'skills': [
      {'skill': 'Medicine', 'isProficient': true, 'bonus': 7, 'abilityScore': 'WIS'},
      {'skill': 'Religion', 'isProficient': true, 'bonus': 5, 'abilityScore': 'INT'},
      {'skill': 'Insight', 'isProficient': true, 'bonus': 7, 'abilityScore': 'WIS'},
      {'skill': 'Persuasion', 'isProficient': true, 'bonus': 6, 'abilityScore': 'CHA'}
    ],
    'damageResistances': [],
    'damageImmunities': [],
    'conditionImmunities': [],
    'senses': {'passivePerception': 14},
    'languages': ['Common', 'Celestial', 'Elvish'],
    'specialAbilities': [
      {'name': 'Divine Healing', 'description': 'Can restore 2d8+4 hit points to a creature as an action (3/day).'}
    ],
    'actions': [],
    'knownSpells': [],
  },
  {
    'name': 'Silas "Quickfingers" Vane',
    'role': 'Thieves Guild Fence',
    'size': 'medium',
    'alignment': 'chaoticNeutral',
    'biography': 'A charming half-elf who operates a front antique shop but secretly runs the largest fencing operation in the city. Knows everyone\'s secrets and trades in stolen goods.',
    'armorClass': 14,
    'armorSource': 'Studded Leather',
    'currentHP': 30,
    'maxHP': 30,
    'hitDice': '5d8+5',
    'speed': {'walk': 30},
    'abilityScores': {'strength': 10, 'dexterity': 16, 'constitution': 12, 'intelligence': 14, 'wisdom': 12, 'charisma': 16},
    'proficiencyBonus': 3,
    'savingThrowProficiencies': {'dexterity': true, 'intelligence': true},
    'skills': [
      {'skill': 'Deception', 'isProficient': true, 'bonus': 6, 'abilityScore': 'CHA'},
      {'skill': 'Persuasion', 'isProficient': true, 'bonus': 6, 'abilityScore': 'CHA'},
      {'skill': 'Sleight of Hand', 'isProficient': true, 'bonus': 6, 'abilityScore': 'DEX'},
      {'skill': 'Stealth', 'isProficient': true, 'bonus': 6, 'abilityScore': 'DEX'},
      {'skill': 'Investigation', 'isProficient': true, 'bonus': 5, 'abilityScore': 'INT'}
    ],
    'damageResistances': [],
    'damageImmunities': [],
    'conditionImmunities': [],
    'senses': {'passivePerception': 11},
    'languages': ['Common', 'Elvish', 'Thieves\' Cant'],
    'specialAbilities': [],
    'actions': [
      {'id': 'npc3-a1', 'name': 'Dagger', 'hitBonus': 6, 'reach': '5 ft.', 'damageRoll': '1d4+3', 'damageType': 'piercing'}
    ],
    'knownSpells': [],
  },
  {
    'name': 'Thorn Ironbark',
    'role': 'Druid of the Ancient Grove',
    'size': 'medium',
    'alignment': 'trueNeutral',
    'biography': 'A centuries-old half-elf druid who serves as guardian of the Whispering Woods. Speaks in riddles and has little patience for those who harm nature.',
    'armorClass': 15,
    'armorSource': 'Hide Armor',
    'currentHP': 45,
    'maxHP': 45,
    'hitDice': '7d8+14',
    'speed': {'walk': 30},
    'abilityScores': {'strength': 12, 'dexterity': 14, 'constitution': 14, 'intelligence': 12, 'wisdom': 18, 'charisma': 10},
    'proficiencyBonus': 3,
    'savingThrowProficiencies': {'intelligence': true, 'wisdom': true},
    'skills': [
      {'skill': 'Nature', 'isProficient': true, 'bonus': 6, 'abilityScore': 'INT'},
      {'skill': 'Survival', 'isProficient': true, 'bonus': 7, 'abilityScore': 'WIS'},
      {'skill': 'Animal Handling', 'isProficient': true, 'bonus': 7, 'abilityScore': 'WIS'},
      {'skill': 'Perception', 'isProficient': true, 'bonus': 7, 'abilityScore': 'WIS'}
    ],
    'damageResistances': [],
    'damageImmunities': [],
    'conditionImmunities': [],
    'senses': {'passivePerception': 17},
    'languages': ['Common', 'Elvish', 'Druidic', 'Sylvan'],
    'specialAbilities': [
      {'name': 'Wild Shape', 'description': 'Can transform into a beast of CR 1 or lower (2/day).'}
    ],
    'actions': [
      {'id': 'npc4-a1', 'name': 'Quarterstaff', 'hitBonus': 4, 'reach': '5 ft.', 'damageRoll': '1d6+1', 'damageType': 'bludgeoning'}
    ],
    'knownSpells': [],
  },
  {
    'name': 'Captain Marcus Steelwind',
    'role': 'City Guard Commander',
    'size': 'medium',
    'alignment': 'lawfulNeutral',
    'biography': 'A veteran human soldier who commands the city guard of Port Valen. Strict but fair, he maintains order in a city plagued by crime and political intrigue.',
    'armorClass': 18,
    'armorSource': 'Plate Armor',
    'currentHP': 55,
    'maxHP': 55,
    'hitDice': '8d10+16',
    'speed': {'walk': 30},
    'abilityScores': {'strength': 16, 'dexterity': 12, 'constitution': 14, 'intelligence': 12, 'wisdom': 14, 'charisma': 14},
    'proficiencyBonus': 3,
    'savingThrowProficiencies': {'strength': true, 'constitution': true},
    'skills': [
      {'skill': 'Athletics', 'isProficient': true, 'bonus': 6, 'abilityScore': 'STR'},
      {'skill': 'Intimidation', 'isProficient': true, 'bonus': 5, 'abilityScore': 'CHA'},
      {'skill': 'Insight', 'isProficient': true, 'bonus': 5, 'abilityScore': 'WIS'},
      {'skill': 'Perception', 'isProficient': true, 'bonus': 5, 'abilityScore': 'WIS'}
    ],
    'damageResistances': [],
    'damageImmunities': [],
    'conditionImmunities': [],
    'senses': {'passivePerception': 15},
    'languages': ['Common'],
    'specialAbilities': [
      {'name': 'Command Presence', 'description': 'Allies within 30 feet have advantage on saving throws against being frightened.'}
    ],
    'actions': [
      {'id': 'npc5-a1', 'name': 'Longsword', 'hitBonus': 6, 'reach': '5 ft.', 'damageRoll': '1d8+3', 'damageType': 'slashing'},
      {'id': 'npc5-a2', 'name': 'Heavy Crossbow', 'hitBonus': 4, 'reach': '100/400 ft.', 'damageRoll': '1d10', 'damageType': 'piercing'}
    ],
    'knownSpells': [],
  },
  {
    'name': 'Mira the Fortune Teller',
    'role': 'Mystic and Information Broker',
    'size': 'medium',
    'alignment': 'chaoticGood',
    'biography': 'A tiefling woman who reads fortunes in the market square. Her predictions are eerily accurate, and she trades information for favors rather than gold.',
    'armorClass': 11,
    'armorSource': '',
    'currentHP': 20,
    'maxHP': 20,
    'hitDice': '4d8+2',
    'speed': {'walk': 30},
    'abilityScores': {'strength': 8, 'dexterity': 12, 'constitution': 12, 'intelligence': 14, 'wisdom': 16, 'charisma': 16},
    'proficiencyBonus': 2,
    'savingThrowProficiencies': {'wisdom': true, 'charisma': true},
    'skills': [
      {'skill': 'Insight', 'isProficient': true, 'bonus': 5, 'abilityScore': 'WIS'},
      {'skill': 'Perception', 'isProficient': true, 'bonus': 5, 'abilityScore': 'WIS'},
      {'skill': 'Deception', 'isProficient': true, 'bonus': 5, 'abilityScore': 'CHA'},
      {'skill': 'Investigation', 'isProficient': true, 'bonus': 4, 'abilityScore': 'INT'}
    ],
    'damageResistances': ['fire'],
    'damageImmunities': [],
    'conditionImmunities': [],
    'senses': {'darkvision': 60, 'passivePerception': 15},
    'languages': ['Common', 'Infernal', 'Abyssal'],
    'specialAbilities': [
      {'name': 'Second Sight', 'description': 'Mira can cast Augury and Divination once per day without material components.'}
    ],
    'actions': [],
    'knownSpells': [],
  },
  {
    'name': 'Borin Stonefist',
    'role': 'Tavern Owner and Former Adventurer',
    'size': 'medium',
    'alignment': 'neutralGood',
    'biography': 'A retired dwarf fighter who now runs The Rusty Tank, a popular adventurer\'s tavern. He knows every rumor in town and always has a quest for those brave enough to ask.',
    'armorClass': 15,
    'armorSource': 'Chain Shirt',
    'currentHP': 40,
    'maxHP': 40,
    'hitDice': '6d10+6',
    'speed': {'walk': 25},
    'abilityScores': {'strength': 16, 'dexterity': 12, 'constitution': 14, 'intelligence': 10, 'wisdom': 12, 'charisma': 14},
    'proficiencyBonus': 3,
    'savingThrowProficiencies': {'strength': true, 'constitution': true},
    'skills': [
      {'skill': 'Athletics', 'isProficient': true, 'bonus': 6, 'abilityScore': 'STR'},
      {'skill': 'Persuasion', 'isProficient': true, 'bonus': 5, 'abilityScore': 'CHA'},
      {'skill': 'Intimidation', 'isProficient': true, 'bonus': 5, 'abilityScore': 'CHA'},
      {'skill': 'History', 'isProficient': false, 'bonus': 0, 'abilityScore': 'INT'}
    ],
    'damageResistances': [],
    'damageImmunities': [],
    'conditionImmunities': [],
    'senses': {'darkvision': 60, 'passivePerception': 11},
    'languages': ['Common', 'Dwarvish'],
    'specialAbilities': [],
    'actions': [
      {'id': 'npc7-a1', 'name': 'Battleaxe', 'hitBonus': 6, 'reach': '5 ft.', 'damageRoll': '1d8+3', 'damageType': 'slashing'},
      {'id': 'npc7-a2', 'name': 'Handaxe', 'hitBonus': 6, 'reach': '5 ft.', 'damageRoll': '1d6+3', 'damageType': 'slashing'}
    ],
    'knownSpells': [],
  },
  {
    'name': 'Lady Seraphina Nightshade',
    'role': 'Noble Patron and Secret Warlock',
    'size': 'medium',
    'alignment': 'neutralEvil',
    'biography': 'A beautiful and wealthy noblewoman who hosts lavish parties at her estate. Unknown to most, she has made a pact with a powerful fiend and uses her influence to manipulate city politics.',
    'armorClass': 13,
    'armorSource': 'Mage Armor',
    'currentHP': 35,
    'maxHP': 35,
    'hitDice': '6d8+6',
    'speed': {'walk': 30},
    'abilityScores': {'strength': 8, 'dexterity': 14, 'constitution': 12, 'intelligence': 14, 'wisdom': 10, 'charisma': 18},
    'proficiencyBonus': 3,
    'savingThrowProficiencies': {'wisdom': true, 'charisma': true},
    'skills': [
      {'skill': 'Deception', 'isProficient': true, 'bonus': 7, 'abilityScore': 'CHA'},
      {'skill': 'Persuasion', 'isProficient': true, 'bonus': 7, 'abilityScore': 'CHA'},
      {'skill': 'Performance', 'isProficient': true, 'bonus': 7, 'abilityScore': 'CHA'},
      {'skill': 'Intimidation', 'isProficient': true, 'bonus': 7, 'abilityScore': 'CHA'},
      {'skill': 'Arcana', 'isProficient': false, 'bonus': 2, 'abilityScore': 'INT'}
    ],
    'damageResistances': [],
    'damageImmunities': [],
    'conditionImmunities': [],
    'senses': {'darkvision': 60, 'passivePerception': 10},
    'languages': ['Common', 'Infernal', 'Elvish'],
    'specialAbilities': [
      {'name': 'Dark Pact', 'description': 'Can cast Hex and Eldritch Blast at will. Once per day can cast Hold Person.'}
    ],
    'actions': [
      {'id': 'npc8-a1', 'name': 'Eldritch Blast', 'hitBonus': 7, 'reach': '120 ft.', 'damageRoll': '2d10', 'damageType': 'force'}
    ],
    'knownSpells': [],
  },
];

List<GameEntity> get demoNpcEntities {
  return _npcJsonData.map((json) {
    return GameEntity(
      entityTypeKey: 'npc',
      data: json,
    );
  }).toList();
}

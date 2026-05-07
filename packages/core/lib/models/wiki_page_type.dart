enum WikiPageType {
  creature,
  spell,
  item,
  rule,
  location,
  npc,
  other,
}

enum WikiFieldInputType {
  text,
  number,
  multiline,
  select,
}

class WikiPageFieldDefinition {
  const WikiPageFieldDefinition({
    required this.key,
    required this.label,
    required this.inputType,
    this.required = false,
    this.hint,
    this.options,
  });

  final String key;
  final String label;
  final WikiFieldInputType inputType;
  final bool required;
  final String? hint;
  final List<String>? options;
}

extension WikiPageTypeExtension on WikiPageType {
  bool get isReferenceType {
    return this == WikiPageType.creature || this == WikiPageType.npc;
  }

  String get displayName {
    switch (this) {
      case WikiPageType.creature:
        return 'Creature';
      case WikiPageType.spell:
        return 'Spell';
      case WikiPageType.item:
        return 'Item';
      case WikiPageType.rule:
        return 'Rule';
      case WikiPageType.location:
        return 'Location';
      case WikiPageType.npc:
        return 'NPC';
      case WikiPageType.other:
        return 'Other';
    }
  }

  List<WikiPageFieldDefinition> get fields {
    switch (this) {
      case WikiPageType.creature:
        return const [
          WikiPageFieldDefinition(key: 'size', label: 'Size', inputType: WikiFieldInputType.select, options: ['Tiny', 'Small', 'Medium', 'Large', 'Huge', 'Gargantuan'], required: true),
          WikiPageFieldDefinition(key: 'creatureType', label: 'Creature Type', inputType: WikiFieldInputType.text, required: true, hint: 'Humanoid, Beast, Fiend...'),
          WikiPageFieldDefinition(key: 'armorClass', label: 'Armor Class', inputType: WikiFieldInputType.number, required: true),
          WikiPageFieldDefinition(key: 'hitPoints', label: 'Hit Points', inputType: WikiFieldInputType.number, required: true),
          WikiPageFieldDefinition(key: 'speed', label: 'Speed', inputType: WikiFieldInputType.text, hint: '30 ft., fly 60 ft.'),
          WikiPageFieldDefinition(key: 'challengeRating', label: 'Challenge Rating', inputType: WikiFieldInputType.text, hint: 'e.g. 1/4, 5, 12'),
        ];
      case WikiPageType.spell:
        return const [
          WikiPageFieldDefinition(key: 'level', label: 'Level', inputType: WikiFieldInputType.number, required: true),
          WikiPageFieldDefinition(key: 'school', label: 'School', inputType: WikiFieldInputType.select, options: ['Abjuration', 'Conjuration', 'Divination', 'Enchantment', 'Evocation', 'Illusion', 'Necromancy', 'Transmutation'], required: true),
          WikiPageFieldDefinition(key: 'castingTime', label: 'Casting Time', inputType: WikiFieldInputType.text, required: true),
          WikiPageFieldDefinition(key: 'range', label: 'Range', inputType: WikiFieldInputType.text, required: true),
          WikiPageFieldDefinition(key: 'duration', label: 'Duration', inputType: WikiFieldInputType.text, required: true),
          WikiPageFieldDefinition(key: 'components', label: 'Components', inputType: WikiFieldInputType.text, hint: 'V, S, M (material)'),
        ];
      case WikiPageType.item:
        return const [
          WikiPageFieldDefinition(key: 'rarity', label: 'Rarity', inputType: WikiFieldInputType.select, options: ['Common', 'Uncommon', 'Rare', 'Very Rare', 'Legendary', 'Artifact'], required: true),
          WikiPageFieldDefinition(key: 'itemType', label: 'Item Type', inputType: WikiFieldInputType.text, required: true, hint: 'Weapon, Armor, Wondrous Item...'),
          WikiPageFieldDefinition(key: 'attunement', label: 'Requires Attunement', inputType: WikiFieldInputType.select, options: ['No', 'Yes'], required: true),
          WikiPageFieldDefinition(key: 'weight', label: 'Weight (lb)', inputType: WikiFieldInputType.number),
          WikiPageFieldDefinition(key: 'value', label: 'Value', inputType: WikiFieldInputType.text, hint: 'e.g. 250 gp'),
          WikiPageFieldDefinition(key: 'properties', label: 'Properties', inputType: WikiFieldInputType.multiline, hint: 'Special properties and effects'),
        ];
      case WikiPageType.rule:
        return const [
          WikiPageFieldDefinition(key: 'ruleCategory', label: 'Rule Category', inputType: WikiFieldInputType.select, options: ['Combat', 'Exploration', 'Social', 'Magic', 'Downtime', 'Optional'], required: true),
          WikiPageFieldDefinition(key: 'appliesTo', label: 'Applies To', inputType: WikiFieldInputType.text, hint: 'Classes, creatures, situations...'),
          WikiPageFieldDefinition(key: 'sourcebook', label: 'Sourcebook', inputType: WikiFieldInputType.text),
          WikiPageFieldDefinition(key: 'pageNumber', label: 'Page Number', inputType: WikiFieldInputType.number),
          WikiPageFieldDefinition(key: 'summary', label: 'Quick Summary', inputType: WikiFieldInputType.multiline, required: true),
        ];
      case WikiPageType.location:
        return const [
          WikiPageFieldDefinition(key: 'region', label: 'Region', inputType: WikiFieldInputType.text, required: true),
          WikiPageFieldDefinition(key: 'locationType', label: 'Location Type', inputType: WikiFieldInputType.select, options: ['City', 'Town', 'Dungeon', 'Wilderness', 'Building', 'Plane'], required: true),
          WikiPageFieldDefinition(key: 'population', label: 'Population', inputType: WikiFieldInputType.number),
          WikiPageFieldDefinition(key: 'factionControl', label: 'Faction Control', inputType: WikiFieldInputType.text),
          WikiPageFieldDefinition(key: 'notableFeatures', label: 'Notable Features', inputType: WikiFieldInputType.multiline),
        ];
      case WikiPageType.npc:
        return const [
          WikiPageFieldDefinition(key: 'race', label: 'Race', inputType: WikiFieldInputType.text, required: true),
          WikiPageFieldDefinition(key: 'classOrRole', label: 'Class / Role', inputType: WikiFieldInputType.text, required: true),
          WikiPageFieldDefinition(key: 'alignment', label: 'Alignment', inputType: WikiFieldInputType.select, options: ['Lawful Good', 'Neutral Good', 'Chaotic Good', 'Lawful Neutral', 'True Neutral', 'Chaotic Neutral', 'Lawful Evil', 'Neutral Evil', 'Chaotic Evil'], required: true),
          WikiPageFieldDefinition(key: 'goals', label: 'Goals', inputType: WikiFieldInputType.multiline),
          WikiPageFieldDefinition(key: 'secrets', label: 'Secrets', inputType: WikiFieldInputType.multiline),
        ];
      case WikiPageType.other:
        return const [
          WikiPageFieldDefinition(key: 'category', label: 'Category', inputType: WikiFieldInputType.text, required: true),
          WikiPageFieldDefinition(key: 'reference', label: 'Reference', inputType: WikiFieldInputType.text),
          WikiPageFieldDefinition(key: 'notes', label: 'Notes', inputType: WikiFieldInputType.multiline),
        ];
    }
  }
}

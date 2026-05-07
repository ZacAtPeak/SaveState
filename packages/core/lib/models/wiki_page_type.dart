enum WikiPageType {
  creature,
  spell,
  item,
  rule,
  location,
  npc,
  other,
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
}

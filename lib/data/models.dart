class Entity {
  final int? id;
  final String name;
  final int? gameSystemId;
  final int hp;
  final int maxHp;
  final int ac;
  final int initiative;
  final bool isBookmarked;
  final DateTime? lastViewedAt;
  final String? fieldLayout;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Entity({
    this.id,
    required this.name,
    this.gameSystemId,
    this.hp = 0,
    this.maxHp = 0,
    this.ac = 10,
    this.initiative = 0,
    this.isBookmarked = false,
    this.lastViewedAt,
    this.fieldLayout,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'gameSystemId': gameSystemId,
      'hp': hp,
      'maxHp': maxHp,
      'ac': ac,
      'initiative': initiative,
      'isBookmarked': isBookmarked ? 1 : 0,
      'lastViewedAt': lastViewedAt?.toIso8601String(),
      'fieldLayout': fieldLayout,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Entity.fromMap(Map<String, dynamic> map) {
    return Entity(
      id: map['id'] as int?,
      name: map['name'] as String,
      gameSystemId: map['gameSystemId'] as int?,
      hp: map['hp'] as int? ?? 0,
      maxHp: map['maxHp'] as int? ?? 0,
      ac: map['ac'] as int? ?? 10,
      initiative: map['initiative'] as int? ?? 0,
      isBookmarked: (map['isBookmarked'] as int?) == 1,
      lastViewedAt: map['lastViewedAt'] != null
          ? DateTime.parse(map['lastViewedAt'] as String)
          : null,
      fieldLayout: map['fieldLayout'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  Entity copyWith({
    int? id,
    String? name,
    int? gameSystemId,
    int? hp,
    int? maxHp,
    int? ac,
    int? initiative,
    bool? isBookmarked,
    DateTime? lastViewedAt,
    String? fieldLayout,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Entity(
      id: id ?? this.id,
      name: name ?? this.name,
      gameSystemId: gameSystemId ?? this.gameSystemId,
      hp: hp ?? this.hp,
      maxHp: maxHp ?? this.maxHp,
      ac: ac ?? this.ac,
      initiative: initiative ?? this.initiative,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      lastViewedAt: lastViewedAt ?? this.lastViewedAt,
      fieldLayout: fieldLayout ?? this.fieldLayout,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class GameSystem {
  final int? id;
  final String name;
  final String? initiativeRule;
  final List<String>? entityFields;

  GameSystem({
    this.id,
    required this.name,
    this.initiativeRule,
    this.entityFields,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'initiativeRule': initiativeRule,
      'entityFields': entityFields?.join(','),
    };
  }

  factory GameSystem.fromMap(Map<String, dynamic> map) {
    return GameSystem(
      id: map['id'] as int?,
      name: map['name'] as String,
      initiativeRule: map['initiativeRule'] as String?,
      entityFields: (map['entityFields'] as String?)?.split(','),
    );
  }
}

class InitiativeEntry {
  final int? id;
  final int entityId;
  final int initiativeValue;
  final int? combatId;
  final int order;

  InitiativeEntry({
    this.id,
    required this.entityId,
    required this.initiativeValue,
    this.combatId,
    this.order = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'entityId': entityId,
      'initiativeValue': initiativeValue,
      'combatId': combatId,
      'order': order,
    };
  }

  factory InitiativeEntry.fromMap(Map<String, dynamic> map) {
    return InitiativeEntry(
      id: map['id'] as int?,
      entityId: map['entityId'] as int,
      initiativeValue: map['initiativeValue'] as int,
      combatId: map['combatId'] as int?,
      order: map['order'] as int? ?? 0,
    );
  }
}

class RollHistory {
  final int? id;
  final int entityId;
  final String rollType;
  final int rollValue;
  final int? target;
  final DateTime? rolledAt;

  RollHistory({
    this.id,
    required this.entityId,
    required this.rollType,
    required this.rollValue,
    this.target,
    this.rolledAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'entityId': entityId,
      'rollType': rollType,
      'rollValue': rollValue,
      'target': target,
      'rolledAt': rolledAt?.toIso8601String(),
    };
  }

  factory RollHistory.fromMap(Map<String, dynamic> map) {
    return RollHistory(
      id: map['id'] as int?,
      entityId: map['entityId'] as int,
      rollType: map['rollType'] as String,
      rollValue: map['rollValue'] as int,
      target: map['target'] as int?,
      rolledAt: map['rolledAt'] != null
          ? DateTime.parse(map['rolledAt'] as String)
          : null,
    );
  }
}

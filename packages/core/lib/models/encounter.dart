import 'package:uuid/uuid.dart';

class EncounterEntry {
  final String id;
  final String name;
  final bool isNpc;
  int currentHp;
  final int maxHp;
  final int armorClass;
  final double initiative;
  final List<String> conditions;
  String notes;

  EncounterEntry({
    String? id,
    required this.name,
    this.isNpc = false,
    required this.currentHp,
    required this.maxHp,
    this.armorClass = 10,
    required this.initiative,
    List<String>? conditions,
    this.notes = '',
  })  : id = id ?? const Uuid().v4(),
        conditions = conditions ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'isNpc': isNpc,
        'currentHp': currentHp,
        'maxHp': maxHp,
        'armorClass': armorClass,
        'initiative': initiative,
        'conditions': conditions,
        'notes': notes,
      };

  factory EncounterEntry.fromJson(Map<String, dynamic> json) => EncounterEntry(
        id: json['id'] as String?,
        name: json['name'] as String,
        isNpc: json['isNpc'] as bool? ?? false,
        currentHp: json['currentHp'] as int,
        maxHp: json['maxHp'] as int,
        armorClass: json['armorClass'] as int? ?? 10,
        initiative: (json['initiative'] as num).toDouble(),
        conditions: (json['conditions'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        notes: json['notes'] as String? ?? '',
      );
}

class EncounterState {
  final String dmId;
  final String sessionName;
  int round;
  int currentTurnIndex;
  final List<EncounterEntry> entries;
  String dmNotes;
  bool isActive;

  EncounterState({
    required this.dmId,
    this.sessionName = 'Encounter',
    this.round = 1,
    this.currentTurnIndex = 0,
    List<EncounterEntry>? entries,
    this.dmNotes = '',
    this.isActive = false,
  }) : entries = entries ?? [];

  Map<String, dynamic> toJson() => {
        'dmId': dmId,
        'sessionName': sessionName,
        'round': round,
        'currentTurnIndex': currentTurnIndex,
        'entries': entries.map((e) => e.toJson()).toList(),
        'dmNotes': dmNotes,
        'isActive': isActive,
      };

  factory EncounterState.fromJson(Map<String, dynamic> json) => EncounterState(
        dmId: json['dmId'] as String,
        sessionName: json['sessionName'] as String? ?? 'Encounter',
        round: json['round'] as int? ?? 1,
        currentTurnIndex: json['currentTurnIndex'] as int? ?? 0,
        entries: (json['entries'] as List<dynamic>?)
                ?.map((e) =>
                    EncounterEntry.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        dmNotes: json['dmNotes'] as String? ?? '',
        isActive: json['isActive'] as bool? ?? false,
      );

  EncounterEntry? get currentTurnEntry =>
      entries.isEmpty ? null : entries[currentTurnIndex % entries.length];
}

class DiceRoll {
  final String expression;
  final List<int> individualDice;
  final int modifier;
  final int total;
  final DateTime timestamp;

  DiceRoll({
    required this.expression,
    required this.individualDice,
    this.modifier = 0,
    required this.total,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'expression': expression,
        'individualDice': individualDice,
        'modifier': modifier,
        'total': total,
        'timestamp': timestamp.toIso8601String(),
      };

  factory DiceRoll.fromJson(Map<String, dynamic> json) => DiceRoll(
        expression: json['expression'] as String,
        individualDice:
            (json['individualDice'] as List<dynamic>).map((e) => e as int).toList(),
        modifier: json['modifier'] as int? ?? 0,
        total: json['total'] as int,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}

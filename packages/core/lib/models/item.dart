import 'package:uuid/uuid.dart';

class Item {
  final String id;
  final String title;
  final String description;
  final List<String> tags;
  final String type;
  final String bonusType;
  final int bonusAmount;
  final String? bonusAbility;

  Item({
    String? id,
    required this.title,
    required this.description,
    required this.tags,
    this.type = 'other',
    this.bonusType = 'addition',
    this.bonusAmount = 0,
    this.bonusAbility,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'tags': tags,
        'type': type,
        'bonusType': bonusType,
        'bonusAmount': bonusAmount,
        'bonusAbility': bonusAbility,
      };

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json['id'] as String?,
        title: json['title'] as String,
        description: json['description'] as String,
        tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
        type: json['type'] as String? ?? 'other',
        bonusType: json['bonusType'] as String? ?? 'addition',
        bonusAmount: json['bonusAmount'] as int? ?? 0,
        bonusAbility: json['bonusAbility'] as String?,
      );
}

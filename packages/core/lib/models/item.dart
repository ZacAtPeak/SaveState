import 'package:uuid/uuid.dart';

import 'enums.dart';

class Item {
  final String id;
  final String title;
  final String description;
  final List<String> tags;
  final ItemType type;
  final BonusType bonusType;
  final int bonusAmount;
  final BonusAbility? bonusAbility;

  Item({
    String? id,
    required this.title,
    required this.description,
    required this.tags,
    this.type = ItemType.other,
    this.bonusType = BonusType.addition,
    this.bonusAmount = 0,
    this.bonusAbility,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'tags': tags,
        'type': type.name,
        'bonusType': bonusType.name,
        'bonusAmount': bonusAmount,
        'bonusAbility': bonusAbility?.name,
      };

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json['id'] as String?,
        title: json['title'] as String,
        description: json['description'] as String,
        tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
        type: ItemType.values.byName(json['type'] as String? ?? 'other'),
        bonusType: BonusType.values.byName(json['bonusType'] as String? ?? 'addition'),
        bonusAmount: json['bonusAmount'] as int? ?? 0,
        bonusAbility: json['bonusAbility'] != null
            ? BonusAbility.values.byName(json['bonusAbility'] as String)
            : null,
      );
}

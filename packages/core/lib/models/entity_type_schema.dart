import 'field_schema.dart';

class EntityTypeSchema {
  const EntityTypeSchema({
    required this.key,
    required this.displayName,
    required this.isWikiPageType,
    required this.fields,
    this.description,
    this.iconKey,
    this.sortOrder = 0,
  });

  final String key;
  final String displayName;
  final bool isWikiPageType;
  final List<FieldSchema> fields;
  final String? description;
  final String? iconKey;
  final int sortOrder;

  Map<String, dynamic> toJson() => {
        'key': key,
        'displayName': displayName,
        'isWikiPageType': isWikiPageType,
        'fields': fields.map((f) => f.toJson()).toList(),
        if (description != null) 'description': description,
        if (iconKey != null) 'iconKey': iconKey,
        'sortOrder': sortOrder,
      };

  factory EntityTypeSchema.fromJson(Map<String, dynamic> json) =>
      EntityTypeSchema(
        key: json['key'] as String,
        displayName: json['displayName'] as String,
        isWikiPageType: json['isWikiPageType'] as bool,
        fields: (json['fields'] as List<dynamic>)
            .map((f) => FieldSchema.fromJson(
                Map<String, dynamic>.from(f as Map)))
            .toList(),
        description: json['description'] as String?,
        iconKey: json['iconKey'] as String?,
        sortOrder: json['sortOrder'] as int? ?? 0,
      );
}

import 'entity_type_schema.dart';

class GameModel {
  const GameModel({
    required this.schemaVersion,
    required this.name,
    required this.entityTypes,
    required this.rulesConfig,
  });

  final int schemaVersion;
  final String name;
  final List<EntityTypeSchema> entityTypes;
  final Map<String, dynamic> rulesConfig;

  Map<String, dynamic> toJson() => {
        'schemaVersion': schemaVersion,
        'name': name,
        'entityTypes': entityTypes.map((e) => e.toJson()).toList(),
        'rulesConfig': rulesConfig,
      };

  factory GameModel.fromJson(Map<String, dynamic> json) => GameModel(
        schemaVersion: json['schemaVersion'] as int,
        name: json['name'] as String,
        entityTypes: (json['entityTypes'] as List<dynamic>)
            .map((e) => EntityTypeSchema.fromJson(
                Map<String, dynamic>.from(e as Map)))
            .toList(),
        rulesConfig: Map<String, dynamic>.from(json['rulesConfig'] as Map),
      );
}

import 'dart:convert';

import 'game_model.dart';

class GameModelParser {
  /// Parses a JSON string into a GameModel with strict validation.
  ///
  /// Throws [FormatException] for:
  /// - Invalid JSON
  /// - Missing schemaVersion
  /// - schemaVersion not an int
  /// - Missing entityTypes
  /// - entityTypes not a list
  /// - Empty entityTypes list
  /// - Duplicate entity type key values
  /// - Missing name
  /// - Missing rulesConfig
  ///
  /// Unknown extra fields are silently ignored (forward-compatibility).
  /// Missing optional fields on entity types default to null/0.
  static GameModel parse(String jsonString) {
    final Map<String, dynamic> json;
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic>) {
        throw FormatException('GameModel JSON root must be an object');
      }
      json = decoded;
    } on FormatException {
      rethrow;
    } catch (e) {
      throw FormatException('GameModel JSON is not valid JSON: $e');
    }

    return _validateAndBuild(json);
  }

  static GameModel _validateAndBuild(Map<String, dynamic> json) {
    // Validate schemaVersion
    if (!json.containsKey('schemaVersion')) {
      throw FormatException(
          'GameModel JSON missing required field: schemaVersion');
    }
    if (json['schemaVersion'] is! int) {
      throw FormatException(
        'GameModel JSON field "schemaVersion" must be an int, got ${json['schemaVersion'].runtimeType}',
      );
    }

    // Validate entityTypes
    if (!json.containsKey('entityTypes')) {
      throw FormatException(
          'GameModel JSON missing required field: entityTypes');
    }
    if (json['entityTypes'] is! List) {
      throw FormatException(
        'GameModel JSON field "entityTypes" must be a list, got ${json['entityTypes'].runtimeType}',
      );
    }
    final entityTypesJson = json['entityTypes'] as List;
    if (entityTypesJson.isEmpty) {
      throw FormatException('GameModel JSON field "entityTypes" must not be empty');
    }

    // Check for duplicate keys
    final seenKeys = <String>{};
    for (final entityJson in entityTypesJson) {
      if (entityJson is! Map) {
        throw FormatException('GameModel JSON entity type entry must be an object');
      }
      final entityMap = Map<String, dynamic>.from(entityJson);
      if (!entityMap.containsKey('key')) {
        throw FormatException('GameModel JSON entity type missing required field: key');
      }
      final key = entityMap['key'] as String;
      if (seenKeys.contains(key)) {
        throw FormatException('GameModel JSON has duplicate entity type key: "$key"');
      }
      seenKeys.add(key);
    }

    // Validate name
    if (!json.containsKey('name')) {
      throw FormatException('GameModel JSON missing required field: name');
    }
    if (json['name'] is! String) {
      throw FormatException(
        'GameModel JSON field "name" must be a String, got ${json['name'].runtimeType}',
      );
    }

    // Validate rulesConfig
    if (!json.containsKey('rulesConfig')) {
      throw FormatException('GameModel JSON missing required field: rulesConfig');
    }
    if (json['rulesConfig'] is! Map) {
      throw FormatException(
        'GameModel JSON field "rulesConfig" must be an object, got ${json['rulesConfig'].runtimeType}',
      );
    }

    return GameModel.fromJson(json);
  }
}

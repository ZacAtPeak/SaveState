import 'dart:convert';

/// Result of validating a GameModel JSON string.
sealed class GameModelValidationResult {
  const GameModelValidationResult();
}

/// Validation passed — contains the JSON string for parsing.
class GameModelValidationSuccess extends GameModelValidationResult {
  final String jsonString;
  const GameModelValidationSuccess(this.jsonString);
}

/// Validation failed — contains the error message.
class GameModelValidationFailure extends GameModelValidationResult {
  final String message;
  const GameModelValidationFailure(this.message);
}

/// Validates an imported GameModel JSON string before parsing.
///
/// Checks:
/// - Valid JSON
/// - schemaVersion present and is an int
/// - entityTypes present and is a non-empty list
/// - Each entity type has a 'key' string field
class GameModelValidator {
  const GameModelValidator();

  GameModelValidationResult validate(String jsonString) {
    // Step 1: Must be valid JSON
    Map<String, dynamic>? json;
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic>) {
        return const GameModelValidationFailure(
          'GameModel JSON root must be an object',
        );
      }
      json = decoded;
    } on FormatException catch (e) {
      return GameModelValidationFailure('Invalid JSON: ${e.message}');
    } catch (e) {
      return GameModelValidationFailure('Failed to parse JSON: $e');
    }

    if (json == null) {
      return const GameModelValidationFailure('Empty JSON object');
    }

    // Step 2: schemaVersion must exist and be int
    if (!json.containsKey('schemaVersion')) {
      return const GameModelValidationFailure(
        'Missing required field: schemaVersion',
      );
    }
    if (json['schemaVersion'] is! int) {
      return GameModelValidationFailure(
        'Field "schemaVersion" must be an integer, got ${json['schemaVersion'].runtimeType}',
      );
    }

    // Step 3: entityTypes must exist, be a list, and be non-empty
    if (!json.containsKey('entityTypes')) {
      return const GameModelValidationFailure(
        'Missing required field: entityTypes',
      );
    }
    if (json['entityTypes'] is! List) {
      return GameModelValidationFailure(
        'Field "entityTypes" must be a list, got ${json['entityTypes'].runtimeType}',
      );
    }
    final entityTypes = json['entityTypes'] as List;
    if (entityTypes.isEmpty) {
      return const GameModelValidationFailure(
        'Field "entityTypes" must not be empty',
      );
    }

    // Step 4: Each entity type must have a 'key' string field
    for (int i = 0; i < entityTypes.length; i++) {
      final entity = entityTypes[i];
      if (entity is! Map) {
        return GameModelValidationFailure(
          'Entity type at index $i must be an object',
        );
      }
      final entityMap = entity as Map;
      if (!entityMap.containsKey('key')) {
        return GameModelValidationFailure(
          'Entity type at index $i missing required field: key',
        );
      }
      if (entityMap['key'] is! String) {
        return GameModelValidationFailure(
          'Entity type at index $i field "key" must be a string',
        );
      }
    }

    // Step 5: name field must exist
    if (!json.containsKey('name')) {
      return const GameModelValidationFailure(
        'Missing required field: name',
      );
    }
    if (json['name'] is! String) {
      return const GameModelValidationFailure(
        'Field "name" must be a string',
      );
    }

    // Step 6: rulesConfig field must exist
    if (!json.containsKey('rulesConfig')) {
      return const GameModelValidationFailure(
        'Missing required field: rulesConfig',
      );
    }

    return GameModelValidationSuccess(jsonString);
  }
}
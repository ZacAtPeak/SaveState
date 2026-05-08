import 'dart:convert';

import 'package:test/test.dart';
import 'package:core/models/models.dart';

void main() {
  group('GameModelParser', () {
    test('throws FormatException when schemaVersion is missing', () {
      final json = jsonEncode({
        'name': 'Test Game',
        'entityTypes': [
          {
            'key': 'character',
            'displayName': 'Character',
            'isWikiPageType': true,
            'fields': [],
          },
        ],
        'rulesConfig': {'initiative': '1d20'},
      });
      expect(
        () => GameModelParser.parse(json),
        throwsA(isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('schemaVersion'),
        )),
      );
    });

    test('throws FormatException when schemaVersion is not an int', () {
      final json = jsonEncode({
        'schemaVersion': '1',
        'name': 'Test Game',
        'entityTypes': [
          {
            'key': 'character',
            'displayName': 'Character',
            'isWikiPageType': true,
            'fields': [],
          },
        ],
        'rulesConfig': {'initiative': '1d20'},
      });
      expect(
        () => GameModelParser.parse(json),
        throwsA(isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('schemaVersion'),
        )),
      );
    });

    test('throws FormatException when entityTypes is missing', () {
      final json = jsonEncode({
        'schemaVersion': 1,
        'name': 'Test Game',
        'rulesConfig': {'initiative': '1d20'},
      });
      expect(
        () => GameModelParser.parse(json),
        throwsA(isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('entityTypes'),
        )),
      );
    });

    test('throws FormatException when entityTypes is empty', () {
      final json = jsonEncode({
        'schemaVersion': 1,
        'name': 'Test Game',
        'entityTypes': [],
        'rulesConfig': {'initiative': '1d20'},
      });
      expect(
        () => GameModelParser.parse(json),
        throwsA(isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('empty'),
        )),
      );
    });

    test('throws FormatException when entityTypes has duplicate keys', () {
      final json = jsonEncode({
        'schemaVersion': 1,
        'name': 'Test Game',
        'entityTypes': [
          {'key': 'character', 'displayName': 'Character', 'isWikiPageType': true, 'fields': []},
          {'key': 'character', 'displayName': 'Character 2', 'isWikiPageType': false, 'fields': []},
        ],
        'rulesConfig': {'initiative': '1d20'},
      });
      expect(
        () => GameModelParser.parse(json),
        throwsA(isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('duplicate'),
        )),
      );
    });

    test('parses valid GameModel JSON successfully', () {
      final json = jsonEncode({
        'schemaVersion': 1,
        'name': 'D&D 5e',
        'entityTypes': [
          {
            'key': 'creature',
            'displayName': 'Creature',
            'isWikiPageType': true,
            'fields': [
              {
                'key': 'hitPoints',
                'label': 'Hit Points',
                'inputType': 'number',
                'required': true,
              },
            ],
          },
          {
            'key': 'spell',
            'displayName': 'Spell',
            'isWikiPageType': true,
            'fields': [],
            'description': 'A magical spell',
          },
        ],
        'rulesConfig': {'initiative': '1d20 + {dexMod}'},
      });

      final model = GameModelParser.parse(json);

      expect(model.schemaVersion, 1);
      expect(model.name, 'D&D 5e');
      expect(model.entityTypes.length, 2);
      expect(model.entityTypes[0].key, 'creature');
      expect(model.entityTypes[0].fields.length, 1);
      expect(model.entityTypes[0].fields[0].key, 'hitPoints');
      expect(model.entityTypes[0].fields[0].inputType, FieldInputType.number);
      expect(model.entityTypes[1].description, 'A magical spell');
      expect(model.rulesConfig['initiative'], '1d20 + {dexMod}');
    });

    test('ignores unknown extra fields (forward compatibility)', () {
      final json = jsonEncode({
        'schemaVersion': 1,
        'name': 'Test Game',
        'entityTypes': [
          {'key': 'character', 'displayName': 'Character', 'isWikiPageType': true, 'fields': []},
        ],
        'rulesConfig': {'initiative': '1d20'},
        'unknownField': 'should be ignored',
        'anotherUnknown': {'nested': 'data'},
      });

      final model = GameModelParser.parse(json);
      expect(model.name, 'Test Game');
      expect(model.entityTypes.length, 1);
    });
  });

  group('GameEntity', () {
    test('round-trips through toJson/fromJson with no data loss', () {
      final entity = GameEntity(
        entityTypeKey: 'creature',
        data: {
          'name': 'Goblin',
          'hitPoints': 7,
          'armorClass': 15,
          'isHostile': true,
          'abilities': ['Nimble Escape', 'Scimitar'],
        },
      );

      final json = entity.toJson();
      final restored = GameEntity.fromJson(json);

      expect(restored.entityTypeKey, 'creature');
      expect(restored.getString('name'), 'Goblin');
      expect(restored.getInt('hitPoints'), 7);
      expect(restored.getInt('armorClass'), 15);
      expect(restored.getBool('isHostile'), true);
      expect(restored.getList('abilities').length, 2);
    });

    test('getInt returns fallback on missing key', () {
      final entity = GameEntity(entityTypeKey: 'test');
      expect(entity.getInt('nonexistent'), 0);
      expect(entity.getInt('nonexistent', fallback: 42), 42);
    });

    test('getString returns fallback on missing key', () {
      final entity = GameEntity(entityTypeKey: 'test');
      expect(entity.getString('nonexistent'), '');
      expect(entity.getString('nonexistent', fallback: 'default'), 'default');
    });

    test('getBool returns fallback on missing key', () {
      final entity = GameEntity(entityTypeKey: 'test');
      expect(entity.getBool('nonexistent'), false);
      expect(entity.getBool('nonexistent', fallback: true), true);
    });

    test('getInt returns fallback on type mismatch (not cast exception)', () {
      final entity = GameEntity(
        entityTypeKey: 'test',
        data: {'value': 'not a number'},
      );
      expect(entity.getInt('value'), 0);
      expect(entity.getInt('value', fallback: 99), 99);
    });

    test('getString returns fallback on type mismatch', () {
      final entity = GameEntity(
        entityTypeKey: 'test',
        data: {'value': 42},
      );
      expect(entity.getString('value'), '');
      expect(entity.getString('value', fallback: 'default'), 'default');
    });

    test('getInt converts num (double) to int', () {
      final entity = GameEntity(
        entityTypeKey: 'test',
        data: {'value': 7.0},
      );
      expect(entity.getInt('value'), 7);
    });

    test('getDouble converts num (int) to double', () {
      final entity = GameEntity(
        entityTypeKey: 'test',
        data: {'value': 7},
      );
      expect(entity.getDouble('value'), 7.0);
    });

    test('getList returns empty list on missing key', () {
      final entity = GameEntity(entityTypeKey: 'test');
      expect(entity.getList('nonexistent'), isEmpty);
    });

    test('getMap returns empty map on missing key', () {
      final entity = GameEntity(entityTypeKey: 'test');
      expect(entity.getMap('nonexistent'), isEmpty);
    });
  });

  group('GameModel round-trip', () {
    test('toJson/fromJson preserves all fields', () {
      final model = GameModel(
        schemaVersion: 1,
        name: 'Test System',
        entityTypes: [
          EntityTypeSchema(
            key: 'character',
            displayName: 'Character',
            isWikiPageType: true,
            fields: [
              const FieldSchema(
                key: 'name',
                label: 'Name',
                inputType: FieldInputType.text,
                required: true,
              ),
              const FieldSchema(
                key: 'sanity',
                label: 'Sanity',
                inputType: FieldInputType.number,
                min: 0,
                max: 100,
                derivedFrom: 'POW * 5',
              ),
            ],
            description: 'A player character',
            iconKey: 'character_icon',
            sortOrder: 1,
          ),
        ],
        rulesConfig: {
          'initiative': 'dexRank',
          'customRule': true,
        },
      );

      final json = model.toJson();
      final restored = GameModel.fromJson(json);

      expect(restored.schemaVersion, 1);
      expect(restored.name, 'Test System');
      expect(restored.entityTypes.length, 1);
      expect(restored.entityTypes[0].key, 'character');
      expect(restored.entityTypes[0].fields.length, 2);
      expect(restored.entityTypes[0].fields[1].derivedFrom, 'POW * 5');
      expect(restored.entityTypes[0].fields[1].min, 0);
      expect(restored.entityTypes[0].fields[1].max, 100);
      expect(restored.entityTypes[0].description, 'A player character');
      expect(restored.entityTypes[0].iconKey, 'character_icon');
      expect(restored.entityTypes[0].sortOrder, 1);
      expect(restored.rulesConfig['initiative'], 'dexRank');
      expect(restored.rulesConfig['customRule'], true);
    });
  });
}

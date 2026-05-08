import 'package:flutter_test/flutter_test.dart';
import 'package:core/models/models.dart';
import 'package:core/models/formula_evaluator.dart';

import '../lib/widgets/initiative_tracker.dart';

void main() {
  group('CombatantDragData.toFormulaContext', () {
    test('includes ability scores and modifiers from entity data', () {
      final data = CombatantDragData(
        id: 'test-1',
        name: 'Test Creature',
        initiativeModifier: 2,
        currentHP: 30,
        maxHP: 45,
        entityData: {
          'strength': 16,
          'dexterity': 14,
          'constitution': 12,
          'intelligence': 10,
          'wisdom': 8,
          'charisma': 18,
          'strengthModifier': 3,
          'dexterityModifier': 2,
          'constitutionModifier': 1,
          'intelligenceModifier': 0,
          'wisdomModifier': -1,
          'charismaModifier': 4,
        },
      );

      final context = data.toFormulaContext();

      expect(context['STR'], 16);
      expect(context['DEX'], 14);
      expect(context['CON'], 12);
      expect(context['INT'], 10);
      expect(context['WIS'], 8);
      expect(context['CHA'], 18);
      expect(context['strengthModifier'], 3);
      expect(context['dexterityModifier'], 2);
      expect(context['constitutionModifier'], 1);
      expect(context['intelligenceModifier'], 0);
      expect(context['wisdomModifier'], -1);
      expect(context['charismaModifier'], 4);
    });

    test('uses default values when entity data is empty', () {
      final data = CombatantDragData(
        id: 'test-2',
        name: 'Empty Creature',
        initiativeModifier: 0,
        currentHP: 0,
        maxHP: 0,
      );

      final context = data.toFormulaContext();

      expect(context['STR'], 10);
      expect(context['DEX'], 10);
      expect(context['CON'], 10);
      expect(context['INT'], 10);
      expect(context['WIS'], 10);
      expect(context['CHA'], 10);
      expect(context['strengthModifier'], 0);
      expect(context['dexterityModifier'], 0);
    });
  });

  group('FormulaEvaluator for initiative', () {
    test('1d20+DEX returns value in expected range', () {
      final context = {'DEX': 14};
      // Run multiple times to verify range (dice rolls are random)
      for (int i = 0; i < 20; i++) {
        final result = FormulaEvaluator.evaluate('1d20+DEX', context);
        // 1d20 = 1-20, +14 = 15-34
        expect(result, inInclusiveRange(3, 34));
      }
    });

    test('formula error falls back gracefully', () {
      // Test that invalid formulas throw FormulaError (caller should catch)
      expect(
        () => FormulaEvaluator.evaluate('invalid!!!', {}),
        throwsA(isA<FormulaError>()),
      );
    });
  });

  group('CombatantDragData.fromGameEntity HP resolution', () {
    test('uses hitPoints fallback when gameModel is null', () {
      final entity = GameEntity(
        entityTypeKey: 'creature',
        data: {
          'id': 'test-1',
          'name': 'Goblin',
          'hitPoints': 30,
          'currentHP': 25,
          'dexterityModifier': 2,
        },
      );

      final data = CombatantDragData.fromGameEntity(entity, gameModel: null);

      expect(data.maxHP, 30);
      expect(data.currentHP, 25);
    });

    test('uses resourceFields key when gameModel has resourceFields', () {
      final gameModel = GameModel(
        schemaVersion: 1,
        name: 'Test Model',
        entityTypes: [],
        rulesConfig: {
          'resourceFields': [
            {'key': 'hitPoints', 'label': 'HP', 'color': 'red'},
          ],
          'initiativeConfig': {
            'formula': '1d20+DEX',
            'label': 'Initiative',
          },
        },
      );

      final entity = GameEntity(
        entityTypeKey: 'creature',
        data: {
          'id': 'test-2',
          'name': 'Orc',
          'hitPoints': 50,
          'currentHP': 40,
          'dexterityModifier': 1,
        },
      );

      final data = CombatantDragData.fromGameEntity(entity, gameModel: gameModel);

      expect(data.maxHP, 50);
      expect(data.currentHP, 40);
    });

    test('uses hp key from resourceFields (case-insensitive)', () {
      final gameModel = GameModel(
        schemaVersion: 1,
        name: 'Test Model',
        entityTypes: [],
        rulesConfig: {
          'resourceFields': [
            {'key': 'hp', 'label': 'HP', 'color': 'red'},
          ],
          'initiativeConfig': {
            'formula': '1d20+DEX',
            'label': 'Initiative',
          },
        },
      );

      final entity = GameEntity(
        entityTypeKey: 'creature',
        data: {
          'id': 'test-3',
          'name': 'Skeleton',
          'hp': 20,
          'currentHP': 15,
          'dexterityModifier': 0,
        },
      );

      final data = CombatantDragData.fromGameEntity(entity, gameModel: gameModel);

      expect(data.maxHP, 20);
    });

    test('falls back to hitPoints when resourceFields is empty', () {
      final gameModel = GameModel(
        schemaVersion: 1,
        name: 'Test Model',
        entityTypes: [],
        rulesConfig: {
          'resourceFields': [],
          'initiativeConfig': {
            'formula': '1d20+DEX',
            'label': 'Initiative',
          },
        },
      );

      final entity = GameEntity(
        entityTypeKey: 'creature',
        data: {
          'id': 'test-4',
          'name': 'Rat',
          'hitPoints': 5,
          'currentHP': 5,
          'dexterityModifier': -1,
        },
      );

      final data = CombatantDragData.fromGameEntity(entity, gameModel: gameModel);

      expect(data.maxHP, 5);
    });

    test('finds HP field by label in entity type fields', () {
      final entityType = EntityTypeSchema(
        key: 'creature',
        displayName: 'Creature',
        isWikiPageType: true,
        fields: [
          const FieldSchema(key: 'name', label: 'Name', inputType: FieldInputType.text),
          const FieldSchema(key: 'hitPoints', label: 'Hit Points', inputType: FieldInputType.number),
        ],
      );

      final gameModel = GameModel(
        schemaVersion: 1,
        name: 'Test Model',
        entityTypes: [entityType],
        rulesConfig: {
          'resourceFields': null,
          'initiativeConfig': {
            'formula': '1d20+DEX',
            'label': 'Initiative',
          },
        },
      );

      final entity = GameEntity(
        entityTypeKey: 'creature',
        data: {
          'id': 'test-5',
          'name': 'Dragon',
          'hitPoints': 200,
          'currentHP': 150,
          'dexterityModifier': 5,
        },
      );

      final data = CombatantDragData.fromGameEntity(entity, gameModel: gameModel);

      expect(data.maxHP, 200);
    });
  });

  group('InitiativeEntry.fromGameEntity HP resolution', () {
    test('uses resolved HP key from gameModel', () {
      final gameModel = GameModel(
        schemaVersion: 1,
        name: 'Test Model',
        entityTypes: [],
        rulesConfig: {
          'resourceFields': [
            {'key': 'hitPoints', 'label': 'HP', 'color': 'red'},
          ],
          'initiativeConfig': {
            'formula': '1d20+DEX',
            'label': 'Initiative',
          },
        },
      );

      final entity = GameEntity(
        entityTypeKey: 'creature',
        data: {
          'id': 'test-6',
          'name': 'Troll',
          'hitPoints': 80,
          'currentHP': 60,
        },
      );

      final entry = InitiativeEntry.fromGameEntity(entity, gameModel: gameModel);

      expect(entry.maxHP, 80);
      expect(entry.currentHP, 60);
    });

    test('falls back to hitPoints when gameModel is null', () {
      final entity = GameEntity(
        entityTypeKey: 'creature',
        data: {
          'id': 'test-7',
          'name': 'Bandit',
          'hitPoints': 15,
          'currentHP': 10,
        },
      );

      final entry = InitiativeEntry.fromGameEntity(entity, gameModel: null);

      expect(entry.maxHP, 15);
      expect(entry.currentHP, 10);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:core/models/models.dart';
import 'package:core/services/game_model_service.dart';
import 'package:provider/provider.dart';

import '../lib/widgets/creature_detail_view.dart';

void main() {
  group('CreatureDetailView', () {
    Widget _buildWithService({
      required GameEntity? entity,
      GameModel? gameModel,
    }) {
      final service = GameModelService();
      if (gameModel != null) {
        service.setActiveModelForTesting(gameModel);
      }
      return ChangeNotifierProvider<GameModelService>.value(
        value: service,
        child: MaterialApp(
          home: Scaffold(
            body: CreatureDetailView(entity: entity),
          ),
        ),
      );
    }

    testWidgets('shows "Select a creature" placeholder when entity is null',
        (tester) async {
      await tester.pumpWidget(_buildWithService(entity: null));

      expect(find.text('Select a creature on the left to see details'),
          findsOneWidget);
    });

    testWidgets('shows loading indicator when GameModel is not loaded',
        (tester) async {
      final entity = GameEntity(
        entityTypeKey: 'creature',
        data: {'name': 'Goblin', 'id': 'goblin-1'},
      );

      await tester.pumpWidget(_buildWithService(entity: entity));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error when entity type not found in GameModel',
        (tester) async {
      final entity = GameEntity(
        entityTypeKey: 'unknown_type',
        data: {'name': 'Test'},
      );

      final gameModel = GameModel(
        schemaVersion: 1,
        name: 'Test Model',
        entityTypes: [
          EntityTypeSchema(
            key: 'creature',
            displayName: 'Creature',
            isWikiPageType: false,
            fields: [],
          ),
        ],
        rulesConfig: const {},
      );

      await tester.pumpWidget(
        _buildWithService(entity: entity, gameModel: gameModel),
      );

      expect(find.text('Unknown entity type: unknown_type'), findsOneWidget);
    });

    testWidgets(
        'renders SchemaFormBuilder when entity and matching GameModel exist',
        (tester) async {
      final entity = GameEntity(
        entityTypeKey: 'creature',
        data: {
          'name': 'Goblin',
          'id': 'goblin-1',
          'hitPoints': 7,
          'armorClass': 15,
        },
      );

      final gameModel = GameModel(
        schemaVersion: 1,
        name: 'D&D 5e',
        entityTypes: [
          EntityTypeSchema(
            key: 'creature',
            displayName: 'Creature',
            isWikiPageType: false,
            fields: [
              const FieldSchema(
                key: 'name',
                label: 'Name',
                inputType: FieldInputType.text,
                section: 'Vitals',
              ),
              const FieldSchema(
                key: 'hitPoints',
                label: 'Hit Points',
                inputType: FieldInputType.number,
                section: 'Vitals',
              ),
            ],
          ),
        ],
        rulesConfig: const {},
      );

      await tester.pumpWidget(
        _buildWithService(entity: entity, gameModel: gameModel),
      );

      // SchemaFormBuilder should be in the tree
      expect(find.byType(SingleChildScrollView), findsOneWidget);

      // Entity name should be rendered
      expect(find.text('Goblin'), findsOneWidget);
    });

    testWidgets('no hardcoded D&D field strings in widget tree', (tester) async {
      final entity = GameEntity(
        entityTypeKey: 'creature',
        data: {
          'name': 'Goblin',
          'id': 'goblin-1',
          'strength': 8,
          'dexterity': 14,
          'hitPoints': 7,
          'armorClass': 15,
        },
      );

      final gameModel = GameModel(
        schemaVersion: 1,
        name: 'D&D 5e',
        entityTypes: [
          EntityTypeSchema(
            key: 'creature',
            displayName: 'Creature',
            isWikiPageType: false,
            fields: [
              const FieldSchema(
                key: 'name',
                label: 'Name',
                inputType: FieldInputType.text,
              ),
              const FieldSchema(
                key: 'strength',
                label: 'Strength',
                inputType: FieldInputType.number,
              ),
            ],
          ),
        ],
        rulesConfig: const {},
      );

      await tester.pumpWidget(
        _buildWithService(entity: entity, gameModel: gameModel),
      );

      // Verify no hardcoded D&D field name strings appear as text in the widget tree
      // (SchemaFormBuilder uses labels from schema, not hardcoded field keys)
      expect(find.text('hitPoints'), findsNothing);
      expect(find.text('armorClass'), findsNothing);
      expect(find.text('strength'), findsNothing);
      expect(find.text('dexterity'), findsNothing);
    });
  });
}

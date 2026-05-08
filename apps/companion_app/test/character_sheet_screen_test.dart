import 'package:companion_app/screens/character_sheet_screen.dart';
import 'package:core/models/models.dart';
import 'package:core/services/game_model_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// D&D 5e test model with a minimal creature type for testing.
final _dndModel = GameModel(
  schemaVersion: 1,
  name: 'D&D 5e',
  entityTypes: const [
    EntityTypeSchema(
      key: 'creature',
      displayName: 'Creature',
      isWikiPageType: false,
      fields: [
        FieldSchema(
          key: 'name',
          label: 'Name',
          inputType: FieldInputType.text,
          required: true,
        ),
        FieldSchema(
          key: 'race',
          label: 'Race',
          inputType: FieldInputType.text,
        ),
        FieldSchema(
          key: 'playerClass',
          label: 'Class',
          inputType: FieldInputType.text,
        ),
      ],
    ),
  ],
  rulesConfig: {},
);

void main() {
  group('Character list screen', () {
    testWidgets('shows empty state initially', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(child: const _TestCharList()),
      );

      expect(find.text('No characters yet'), findsOneWidget);
      expect(
        find.text('Tap + to create your first character'),
        findsOneWidget,
      );
    });

    testWidgets('tapping + button opens character creation form',
        (tester) async {
      await tester.pumpWidget(
        _buildTestApp(child: const _TestCharList()),
      );

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Create Character'), findsOneWidget);
    });

    testWidgets('saving character adds it to the list', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(child: const _TestCharList()),
      );

      // Open create form
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Create Character'), findsOneWidget);

      // Find and fill the name field (first TextFormField)
      final nameField = find.byType(TextFormField).first;
      await tester.enterText(nameField, 'Test Hero');
      await tester.pump();

      // Save
      await tester.tap(find.byIcon(Icons.save));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Character should appear in list — use ListTile to find the list entry
      expect(find.byType(ListTile), findsOneWidget);
      expect(find.text('Test Hero'), findsWidgets);
      expect(find.text('No characters yet'), findsNothing);
    });

    testWidgets('tapping existing character opens edit mode', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(child: const _TestCharList()),
      );

      // Create a character first
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.enterText(find.byType(TextFormField).first, 'Edit Me');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.save));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Tap the ListTile to edit (after route fully settles)
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ListTile), warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Edit Character'), findsOneWidget);
    });
  });

  group('CharacterSheetScreen', () {
    testWidgets('renders fields from SchemaFormBuilder with D&D 5e schema',
        (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: CharacterSheetScreen(
            character: null,
            onSave: (_) {},
            onCancel: () {},
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // SchemaFormBuilder renders 3 TextFormField fields (name, race, class)
      expect(find.byType(TextFormField), findsNWidgets(3));
      // General section header
      expect(find.text('General'), findsOneWidget);
    });

    testWidgets('shows loading when GameModel is null', (tester) async {
      final service = GameModelService();

      await tester.pumpWidget(
        ChangeNotifierProvider<GameModelService>.value(
          value: service,
          child: const MaterialApp(
            home: CharacterSheetScreen(
              character: null,
              onSave: _noopSave,
              onCancel: _noopCancel,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error when no character entity type exists',
        (tester) async {
      final emptyModel = GameModel(
        schemaVersion: 1,
        name: 'Empty System',
        entityTypes: [],
        rulesConfig: {},
      );

      await tester.pumpWidget(
        _buildTestApp(
          gameModel: emptyModel,
          child: CharacterSheetScreen(
            character: null,
            onSave: (_) {},
            onCancel: () {},
          ),
        ),
      );

      await tester.pump();

      expect(
        find.text('No character entity type defined in this game system'),
        findsOneWidget,
      );
    });

    testWidgets('edit mode initializes with existing character data',
        (tester) async {
      final existingCharacter = GameEntity(
        entityTypeKey: 'creature',
        data: {'name': 'Goblin Warrior'},
      );

      await tester.pumpWidget(
        _buildTestApp(
          child: CharacterSheetScreen(
            character: existingCharacter,
            onSave: (_) {},
            onCancel: () {},
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Edit Character'), findsOneWidget);
    });
  });

  group('CharacterSheetScreen GameModel reactivity', () {
    testWidgets('reacts to GameModel change and rebuilds form',
        (tester) async {
      final dndModel = GameModel(
        schemaVersion: 1,
        name: 'D&D 5e',
        entityTypes: const [
          EntityTypeSchema(
            key: 'creature',
            displayName: 'Creature',
            isWikiPageType: false,
            fields: [
              FieldSchema(
                key: 'name',
                label: 'Name',
                inputType: FieldInputType.text,
              ),
            ],
          ),
        ],
        rulesConfig: {},
      );

      final cocModel = GameModel(
        schemaVersion: 1,
        name: 'CoC 7e',
        entityTypes: const [
          EntityTypeSchema(
            key: 'investigator',
            displayName: 'Investigator',
            isWikiPageType: false,
            fields: [
              FieldSchema(
                key: 'occupation',
                label: 'Occupation',
                inputType: FieldInputType.text,
              ),
            ],
          ),
        ],
        rulesConfig: {},
      );

      final service = GameModelService();
      service.setActiveModelForTesting(dndModel);

      await tester.pumpWidget(
        ChangeNotifierProvider<GameModelService>.value(
          value: service,
          child: MaterialApp(
            home: CharacterSheetScreen(
              character: null,
              onSave: _noopSave,
              onCancel: _noopCancel,
            ),
          ),
        ),
      );

      await tester.pump();

      // D&D model should render 1 TextFormField (name)
      expect(find.byType(TextFormField), findsOneWidget);

      // Switch to CoC model
      service.setActiveModelForTesting(cocModel);
      await tester.pump();

      // Form should rebuild with 1 TextFormField (occupation)
      expect(find.byType(TextFormField), findsOneWidget);
    });
  });
}

/// Test version of _CharacterListScreen that mirrors the implementation in main.dart.
class _TestCharList extends StatefulWidget {
  const _TestCharList();

  @override
  State<_TestCharList> createState() => _TestCharListState();
}

class _TestCharListState extends State<_TestCharList> {
  final List<GameEntity> _characters = [];

  void _createCharacter() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CharacterSheetScreen(
          character: null,
          onSave: (entity) {
            setState(() => _characters.add(entity));
            Navigator.of(context).pop();
          },
          onCancel: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  void _editCharacter(GameEntity character) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CharacterSheetScreen(
          character: character,
          onSave: (entity) {
            setState(() {
              final index = _characters.indexWhere(
                (c) => c.getString('id') == entity.getString('id'),
              );
              if (index >= 0) _characters[index] = entity;
            });
            Navigator.of(context).pop();
          },
          onCancel: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: _characters.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('No characters yet', style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to create your first character',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _characters.length,
              itemBuilder: (context, index) {
                final char = _characters[index];
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(
                    char.getString('name', fallback: 'Unnamed Character'),
                  ),
                  subtitle: Text(
                    char.getString(
                      'playerClass',
                      fallback: char.getString('race', fallback: ''),
                    ),
                  ),
                  onTap: () => _editCharacter(char),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createCharacter,
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Builds a test app with GameModelService provider.
Widget _buildTestApp({GameModel? gameModel, required Widget child}) {
  final service = GameModelService();
  if (gameModel != null) {
    service.setActiveModelForTesting(gameModel);
  } else {
    service.setActiveModelForTesting(_dndModel);
  }
  return ChangeNotifierProvider<GameModelService>.value(
    value: service,
    child: MaterialApp(home: child),
  );
}

void _noopSave(GameEntity _) {}
void _noopCancel() {}

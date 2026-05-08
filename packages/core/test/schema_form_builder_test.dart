import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:core/models/models.dart';
import 'package:core/widgets/schema_form_builder.dart';

void main() {
  Widget _buildForm({
    required List<FieldSchema> fields,
    Map<String, dynamic>? data,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SchemaFormBuilder(
          fields: fields,
          data: data ?? {},
          onDataChanged: (_) {},
        ),
      ),
    );
  }

  group('SchemaFormBuilder', () {
    testWidgets('groups fields by section', (tester) async {
      final fields = [
        FieldSchema(key: 'hp', label: 'Hit Points', inputType: FieldInputType.number, section: 'Vitals'),
        FieldSchema(key: 'ac', label: 'Armor Class', inputType: FieldInputType.number, section: 'Vitals'),
        FieldSchema(key: 'speed', label: 'Speed', inputType: FieldInputType.number, section: 'Vitals'),
        FieldSchema(key: 'strength', label: 'Strength', inputType: FieldInputType.number, section: 'Abilities'),
        FieldSchema(key: 'dexterity', label: 'Dexterity', inputType: FieldInputType.number, section: 'Abilities'),
      ];

      await tester.pumpWidget(_buildForm(fields: fields));
      await tester.pumpAndSettle();

      // Both section headers should render
      expect(find.text('Vitals'), findsOneWidget);
      expect(find.text('Abilities'), findsOneWidget);

      // All field labels should render
      expect(find.text('Hit Points'), findsOneWidget);
      expect(find.text('Armor Class'), findsOneWidget);
      expect(find.text('Speed'), findsOneWidget);
      expect(find.text('Strength'), findsOneWidget);
      expect(find.text('Dexterity'), findsOneWidget);
    });

    testWidgets('renders null section fields as General', (tester) async {
      final fields = [
        FieldSchema(key: 'name', label: 'Name', inputType: FieldInputType.text),
        FieldSchema(key: 'lore', label: 'Lore', inputType: FieldInputType.multiline, section: 'Lore'),
      ];

      await tester.pumpWidget(_buildForm(fields: fields));
      await tester.pumpAndSettle();

      expect(find.text('General'), findsOneWidget);
      // "Name" label appears in the TextFormField
      expect(find.text('Name'), findsOneWidget);
      // "Lore" appears as section header AND as field label, so at least 2
      expect(find.text('Lore'), findsWidgets);
    });

    testWidgets('fields with subFields render as grouped blocks', (tester) async {
      final fields = [
        FieldSchema(
          key: 'speed',
          label: 'Movement Speed',
          inputType: FieldInputType.group,
          section: 'Vitals',
          subFields: [
            FieldSchema(key: 'walk', label: 'Walk', inputType: FieldInputType.number),
            FieldSchema(key: 'fly', label: 'Fly', inputType: FieldInputType.number),
          ],
        ),
      ];

      await tester.pumpWidget(_buildForm(fields: fields));
      await tester.pumpAndSettle();

      // Section header
      expect(find.text('Vitals'), findsOneWidget);
      // Group label
      expect(find.text('Movement Speed'), findsOneWidget);
      // Sub-field labels
      expect(find.text('Walk'), findsOneWidget);
      expect(find.text('Fly'), findsOneWidget);
    });

    testWidgets('list fields render with add/remove controls', (tester) async {
      final fields = [
        FieldSchema(
          key: 'attacks',
          label: 'Attacks',
          inputType: FieldInputType.list,
          section: 'Combat',
          itemSchema: FieldSchema(
            key: 'attack',
            label: 'Attack',
            inputType: FieldInputType.group,
            subFields: [
              FieldSchema(key: 'name', label: 'Name', inputType: FieldInputType.text),
              FieldSchema(key: 'damage', label: 'Damage', inputType: FieldInputType.text),
            ],
          ),
        ),
      ];

      await tester.pumpWidget(_buildForm(fields: fields));
      await tester.pumpAndSettle();

      // Section and field labels
      expect(find.text('Combat'), findsOneWidget);
      expect(find.text('Attacks'), findsOneWidget);

      // Add button should be present
      expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);

      // Tap add button
      await tester.tap(find.byIcon(Icons.add_circle_outline));
      await tester.pumpAndSettle();

      // New item card should render with sub-fields
      expect(find.text('Name'), findsWidgets); // appears in the item card
      expect(find.text('Damage'), findsWidgets);

      // Remove button should be present
      expect(find.byIcon(Icons.close), findsWidgets);
    });

    testWidgets('derivedFrom fields show computed values', (tester) async {
      final fields = [
        FieldSchema(key: 'strength', label: 'Strength', inputType: FieldInputType.number, section: 'Abilities'),
        FieldSchema(
          key: 'strengthMod',
          label: 'STR Mod',
          inputType: FieldInputType.number,
          section: 'Abilities',
          derivedFrom: 'floor((strength - 10) / 2)',
        ),
      ];

      await tester.pumpWidget(_buildForm(
        fields: fields,
        data: {'strength': 15},
      ));
      await tester.pumpAndSettle();

      // The computed value should be floor((15-10)/2) = floor(2.5) = 2
      // The derived field renders as a Row with label "STR Mod" and value "2"
      expect(find.text('STR Mod'), findsOneWidget);
      // Check that "2" appears as text (the computed result)
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('empty data map renders all fields with empty values', (tester) async {
      final fields = [
        FieldSchema(key: 'name', label: 'Name', inputType: FieldInputType.text, section: 'General'),
        FieldSchema(key: 'level', label: 'Level', inputType: FieldInputType.number, section: 'Vitals'),
        FieldSchema(
          key: 'race',
          label: 'Race',
          inputType: FieldInputType.select,
          section: 'Vitals',
          enumOptions: ['Human', 'Elf', 'Dwarf'],
        ),
      ];

      await tester.pumpWidget(_buildForm(fields: fields, data: {}));
      await tester.pumpAndSettle();

      // All section headers and labels should render
      expect(find.text('General'), findsOneWidget);
      expect(find.text('Vitals'), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Level'), findsOneWidget);
      expect(find.text('Race'), findsOneWidget);
    });

    testWidgets('populated data map pre-fills field values', (tester) async {
      final fields = [
        FieldSchema(key: 'name', label: 'Name', inputType: FieldInputType.text, section: 'General'),
        FieldSchema(key: 'level', label: 'Level', inputType: FieldInputType.number, section: 'Vitals'),
      ];

      await tester.pumpWidget(_buildForm(
        fields: fields,
        data: {'name': 'Gandalf', 'level': 20},
      ));
      await tester.pumpAndSettle();

      // Vitals section renders before General, so level field is first
      final textFields = tester.widgetList<TextFormField>(find.byType(TextFormField)).toList();
      expect(textFields.any((f) => f.initialValue == 'Gandalf'), isTrue);
      expect(textFields.any((f) => f.initialValue == '20'), isTrue);
    });

    testWidgets('required fields show asterisk in label', (tester) async {
      final fields = [
        FieldSchema(key: 'name', label: 'Name', inputType: FieldInputType.text, required: true, section: 'General'),
        FieldSchema(key: 'description', label: 'Description', inputType: FieldInputType.multiline, section: 'Lore'),
      ];

      await tester.pumpWidget(_buildForm(fields: fields));
      await tester.pumpAndSettle();

      // Required field should show "Name *"
      expect(find.text('Name *'), findsOneWidget);
      // Non-required field should show just "Description"
      expect(find.text('Description'), findsOneWidget);
    });

    testWidgets('checkbox fields render as SwitchListTile', (tester) async {
      final fields = [
        FieldSchema(key: 'isAlive', label: 'Is Alive', inputType: FieldInputType.checkbox, section: 'Vitals'),
      ];

      await tester.pumpWidget(_buildForm(
        fields: fields,
        data: {'isAlive': true},
      ));
      await tester.pumpAndSettle();

      expect(find.text('Is Alive'), findsOneWidget);
      expect(find.byType(SwitchListTile), findsOneWidget);
    });

    testWidgets('select fields render with enumOptions', (tester) async {
      final fields = [
        FieldSchema(
          key: 'alignment',
          label: 'Alignment',
          inputType: FieldInputType.select,
          section: 'Lore',
          enumOptions: ['Lawful Good', 'Chaotic Evil', 'Neutral'],
        ),
      ];

      await tester.pumpWidget(_buildForm(
        fields: fields,
        data: {'alignment': 'Chaotic Evil'},
      ));
      await tester.pumpAndSettle();

      expect(find.text('Alignment'), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    });
  });
}

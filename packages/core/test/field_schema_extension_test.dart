import 'package:test/test.dart';
import 'package:core/models/field_schema.dart';

void main() {
  group('FieldSchema extension', () {
    group('section property', () {
      test('round-trips section through toJson/fromJson', () {
        final schema = FieldSchema(
          key: 'name',
          label: 'Name',
          inputType: FieldInputType.text,
          section: 'Vitals',
        );

        final json = schema.toJson();
        expect(json['section'], 'Vitals');

        final restored = FieldSchema.fromJson(json);
        expect(restored.section, 'Vitals');
      });

      test('returns null when section is missing in JSON', () {
        final json = {
          'key': 'name',
          'label': 'Name',
          'inputType': 'text',
        };

        final schema = FieldSchema.fromJson(json);
        expect(schema.section, isNull);
      });
    });

    group('subFields property', () {
      test('round-trips subFields through toJson/fromJson', () {
        final schema = FieldSchema(
          key: 'speed',
          label: 'Movement Speed',
          inputType: FieldInputType.group,
          subFields: [
            FieldSchema(
              key: 'walk',
              label: 'Walk',
              inputType: FieldInputType.number,
            ),
            FieldSchema(
              key: 'fly',
              label: 'Fly',
              inputType: FieldInputType.number,
            ),
          ],
        );

        final json = schema.toJson();
        expect(json['subFields'], isA<List>());
        expect((json['subFields'] as List).length, 2);
        expect((json['subFields'] as List)[0]['key'], 'walk');
        expect((json['subFields'] as List)[1]['key'], 'fly');

        final restored = FieldSchema.fromJson(json);
        expect(restored.subFields, isNotNull);
        expect(restored.subFields!.length, 2);
        expect(restored.subFields![0].key, 'walk');
        expect(restored.subFields![0].inputType, FieldInputType.number);
        expect(restored.subFields![1].key, 'fly');
      });

      test('returns null when subFields is missing in JSON', () {
        final json = {
          'key': 'name',
          'label': 'Name',
          'inputType': 'text',
        };

        final schema = FieldSchema.fromJson(json);
        expect(schema.subFields, isNull);
      });
    });

    group('itemSchema property', () {
      test('round-trips itemSchema through toJson/fromJson', () {
        final schema = FieldSchema(
          key: 'attacks',
          label: 'Attacks',
          inputType: FieldInputType.list,
          itemSchema: FieldSchema(
            key: 'attackItem',
            label: 'Attack',
            inputType: FieldInputType.text,
            subFields: [
              FieldSchema(
                key: 'name',
                label: 'Name',
                inputType: FieldInputType.text,
              ),
              FieldSchema(
                key: 'damage',
                label: 'Damage',
                inputType: FieldInputType.text,
              ),
            ],
          ),
        );

        final json = schema.toJson();
        expect(json['itemSchema'], isA<Map>());
        expect(json['itemSchema']['key'], 'attackItem');
        expect(json['itemSchema']['subFields'], isA<List>());

        final restored = FieldSchema.fromJson(json);
        expect(restored.itemSchema, isNotNull);
        expect(restored.itemSchema!.key, 'attackItem');
        expect(restored.itemSchema!.subFields, isNotNull);
        expect(restored.itemSchema!.subFields!.length, 2);
        expect(restored.itemSchema!.subFields![0].key, 'name');
      });

      test('returns null when itemSchema is missing in JSON', () {
        final json = {
          'key': 'name',
          'label': 'Name',
          'inputType': 'text',
        };

        final schema = FieldSchema.fromJson(json);
        expect(schema.itemSchema, isNull);
      });
    });

    group('attributeRef property', () {
      test('round-trips attributeRef through toJson/fromJson', () {
        final schema = FieldSchema(
          key: 'strength',
          label: 'Strength',
          inputType: FieldInputType.number,
          attributeRef: 'STR',
        );

        final json = schema.toJson();
        expect(json['attributeRef'], 'STR');

        final restored = FieldSchema.fromJson(json);
        expect(restored.attributeRef, 'STR');
      });

      test('returns null when attributeRef is missing in JSON', () {
        final json = {
          'key': 'name',
          'label': 'Name',
          'inputType': 'text',
        };

        final schema = FieldSchema.fromJson(json);
        expect(schema.attributeRef, isNull);
      });
    });

    group('FieldInputType.group', () {
      test('FieldInputType.group exists and serializes as "group"', () {
        expect(FieldInputType.values.any((t) => t.name == 'group'), isTrue);

        final schema = FieldSchema(
          key: 'group',
          label: 'Group',
          inputType: FieldInputType.group,
        );

        final json = schema.toJson();
        expect(json['inputType'], 'group');

        final restored = FieldSchema.fromJson(json);
        expect(restored.inputType, FieldInputType.group);
      });
    });

    group('all new properties together', () {
      test('FieldSchema with all new properties produces correct JSON', () {
        final schema = FieldSchema(
          key: 'speed',
          label: 'Movement Speed',
          inputType: FieldInputType.group,
          section: 'Vitals',
          subFields: [
            FieldSchema(
              key: 'walk',
              label: 'Walk',
              inputType: FieldInputType.number,
            ),
          ],
          itemSchema: FieldSchema(
            key: 'item',
            label: 'Item',
            inputType: FieldInputType.text,
          ),
          attributeRef: 'SPD',
        );

        final json = schema.toJson();

        expect(json['key'], 'speed');
        expect(json['label'], 'Movement Speed');
        expect(json['inputType'], 'group');
        expect(json['section'], 'Vitals');
        expect(json['subFields'], isA<List>());
        expect((json['subFields'] as List)[0]['key'], 'walk');
        expect(json['itemSchema'], isA<Map>());
        expect(json['itemSchema']['key'], 'item');
        expect(json['attributeRef'], 'SPD');
      });

      test('all new properties round-trip together', () {
        final schema = FieldSchema(
          key: 'speed',
          label: 'Movement Speed',
          inputType: FieldInputType.group,
          section: 'Vitals',
          subFields: [
            FieldSchema(
              key: 'walk',
              label: 'Walk',
              inputType: FieldInputType.number,
            ),
          ],
          itemSchema: FieldSchema(
            key: 'item',
            label: 'Item',
            inputType: FieldInputType.text,
          ),
          attributeRef: 'SPD',
        );

        final json = schema.toJson();
        final restored = FieldSchema.fromJson(json);

        expect(restored.key, 'speed');
        expect(restored.section, 'Vitals');
        expect(restored.subFields!.length, 1);
        expect(restored.subFields![0].key, 'walk');
        expect(restored.itemSchema!.key, 'item');
        expect(restored.attributeRef, 'SPD');
        expect(restored.inputType, FieldInputType.group);
      });
    });

    group('backward compatibility', () {
      test('existing FieldSchema without new properties still works', () {
        final schema = FieldSchema(
          key: 'name',
          label: 'Name',
          inputType: FieldInputType.text,
          required: true,
          hint: 'Enter name',
        );

        final json = schema.toJson();
        expect(json['key'], 'name');
        expect(json['section'], isNull);
        expect(json.containsKey('section'), isFalse);
        expect(json['subFields'], isNull);
        expect(json.containsKey('subFields'), isFalse);
        expect(json['itemSchema'], isNull);
        expect(json.containsKey('itemSchema'), isFalse);
        expect(json['attributeRef'], isNull);
        expect(json.containsKey('attributeRef'), isFalse);

        final restored = FieldSchema.fromJson(json);
        expect(restored.key, 'name');
        expect(restored.section, isNull);
        expect(restored.subFields, isNull);
        expect(restored.itemSchema, isNull);
        expect(restored.attributeRef, isNull);
      });
    });
  });
}

import 'package:test/test.dart';
import 'package:core/models/models.dart';

void main() {
  group('WikiPageType', () {
    test('has 7 values', () {
      expect(WikiPageType.values.length, equals(7));
    });

    test('creature isReferenceType is true', () {
      expect(WikiPageType.creature.isReferenceType, isTrue);
    });

    test('npc isReferenceType is true', () {
      expect(WikiPageType.npc.isReferenceType, isTrue);
    });

    test('spell isReferenceType is false', () {
      expect(WikiPageType.spell.isReferenceType, isFalse);
    });

    test('serialization round-trip', () {
      final name = WikiPageType.spell.name;
      final restored = WikiPageType.values.byName(name);
      expect(restored, equals(WikiPageType.spell));
    });

    test('displayName returns readable labels', () {
      expect(WikiPageType.creature.displayName, equals('Creature'));
      expect(WikiPageType.spell.displayName, equals('Spell'));
      expect(WikiPageType.item.displayName, equals('Item'));
      expect(WikiPageType.rule.displayName, equals('Rule'));
      expect(WikiPageType.location.displayName, equals('Location'));
      expect(WikiPageType.npc.displayName, equals('NPC'));
      expect(WikiPageType.other.displayName, equals('Other'));
    });
  });

  group('WikiPage creation', () {
    test('generates UUID when id not provided', () {
      final page = WikiPage(title: 'Test', pageType: WikiPageType.spell);
      expect(page.id.isNotEmpty, isTrue);
      expect(page.id, hasLength(36));
    });

    test('uses provided id when given', () {
      final page = WikiPage(
        id: 'test-123',
        title: 'Test',
        pageType: WikiPageType.spell,
      );
      expect(page.id, equals('test-123'));
    });

    test('sets default values', () {
      final page = WikiPage(title: 'Test', pageType: WikiPageType.spell);
      expect(page.body, equals(''));
      expect(page.tags, isEmpty);
      expect(page.aliases, isEmpty);
      expect(page.statBlock, isEmpty);
      expect(page.referenceId, isNull);
    });
  });

  group('WikiPage JSON serialization', () {
    test('toJson includes all fields', () {
      final now = DateTime.utc(2026, 1, 1, 12, 0, 0);
      final page = WikiPage(
        id: 'test-id',
        title: 'Fireball',
        pageType: WikiPageType.spell,
        body: 'A fiery explosion',
        tags: ['evocation', 'damage'],
        aliases: ['Fire Ball'],
        createdAt: now,
        updatedAt: now,
        statBlock: {'level': 3, 'school': 'evocation'},
      );

      final json = page.toJson();
      expect(json['id'], equals('test-id'));
      expect(json['title'], equals('Fireball'));
      expect(json['pageType'], equals('spell'));
      expect(json['body'], equals('A fiery explosion'));
      expect(json['tags'], equals(['evocation', 'damage']));
      expect(json['aliases'], equals(['Fire Ball']));
      expect(json['createdAt'], equals(now.toIso8601String()));
      expect(json['updatedAt'], equals(now.toIso8601String()));
      expect(json['referenceId'], isNull);
      expect(json['statBlock'], equals({'level': 3, 'school': 'evocation'}));
    });

    test('fromJson reconstructs identical page', () {
      final now = DateTime.utc(2026, 1, 1, 12, 0, 0);
      final original = WikiPage(
        id: 'test-id',
        title: 'Fireball',
        pageType: WikiPageType.spell,
        body: 'A fiery explosion',
        tags: ['evocation', 'damage'],
        aliases: ['Fire Ball'],
        createdAt: now,
        updatedAt: now,
        statBlock: {'level': 3, 'school': 'evocation'},
      );

      final restored = WikiPage.fromJson(original.toJson());
      expect(restored.id, equals(original.id));
      expect(restored.title, equals(original.title));
      expect(restored.pageType, equals(original.pageType));
      expect(restored.body, equals(original.body));
      expect(restored.tags, equals(original.tags));
      expect(restored.aliases, equals(original.aliases));
      expect(restored.createdAt, equals(original.createdAt));
      expect(restored.updatedAt, equals(original.updatedAt));
      expect(restored.referenceId, equals(original.referenceId));
      expect(restored.statBlock, equals(original.statBlock));
    });

    test('serializes pageType as enum name', () {
      final page = WikiPage(title: 'Test', pageType: WikiPageType.creature);
      final json = page.toJson();
      expect(json['pageType'], equals('creature'));
    });

    test('serializes DateTime as ISO string', () {
      final now = DateTime.utc(2026, 1, 1, 12, 0, 0);
      final page = WikiPage(
        title: 'Test',
        pageType: WikiPageType.spell,
        createdAt: now,
        updatedAt: now,
      );
      final json = page.toJson();
      expect(json['createdAt'], equals(now.toIso8601String()));
      expect(json['updatedAt'], equals(now.toIso8601String()));
    });

    test('deserializes pageType from enum name', () {
      final json = {
        'id': 'test-id',
        'title': 'Test',
        'pageType': 'spell',
        'body': '',
        'tags': [],
        'aliases': [],
        'createdAt': '2026-01-01T12:00:00.000Z',
        'updatedAt': '2026-01-01T12:00:00.000Z',
        'referenceId': null,
        'statBlock': {},
      };
      final page = WikiPage.fromJson(json);
      expect(page.pageType, equals(WikiPageType.spell));
    });

    test('handles nullable referenceId', () {
      final page = WikiPage(title: 'Test', pageType: WikiPageType.spell);
      final json = page.toJson();
      expect(json['referenceId'], isNull);

      final restored = WikiPage.fromJson(json);
      expect(restored.referenceId, isNull);
    });

    test('handles referenceId for creature pages', () {
      final page = WikiPage(
        title: 'Goblin',
        pageType: WikiPageType.creature,
        referenceId: 'monster-123',
      );
      final json = page.toJson();
      expect(json['referenceId'], equals('monster-123'));

      final restored = WikiPage.fromJson(json);
      expect(restored.referenceId, equals('monster-123'));
    });

    test('handles statBlock map', () {
      final page = WikiPage(
        title: 'Fireball',
        pageType: WikiPageType.spell,
        statBlock: {'level': 3, 'school': 'evocation'},
      );
      final json = page.toJson();
      expect(json['statBlock'], equals({'level': 3, 'school': 'evocation'}));

      final restored = WikiPage.fromJson(json);
      expect(restored.statBlock, equals({'level': 3, 'school': 'evocation'}));
    });
  });
}

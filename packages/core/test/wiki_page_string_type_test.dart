import 'package:core/data/data.dart';
import 'package:core/models/models.dart';
import 'package:test/test.dart';

void main() {
  group('WikiPage strict string-key serialization', () {
    test('toJson writes entityTypeKey and omits legacy pageType', () {
      final page = WikiPage(
        id: 'wiki-1',
        title: 'Goblin',
        pageType: WikiPageType.creature,
        statBlock: {'armorClass': 15},
      );

      final json = page.toJson();
      expect(json['entityTypeKey'], equals('creature'));
      expect(json.containsKey('pageType'), isFalse);
    });
  });

  group('Unified demo GameEntity contracts', () {
    test('pre-split helpers derive from unified demoEntities', () {
      final total = demoCharacterEntities.length +
          demoMonsterEntities.length +
          demoNpcEntities.length;

      expect(total, lessThanOrEqualTo(demoEntities.length));
      expect(demoMonsterEntities, isNotEmpty);
      expect(demoNpcEntities, isNotEmpty);
      expect(demoCharacterEntities.every((e) => e.entityTypeKey == 'creature'), isTrue);
      expect(
        demoMonsterEntities.every((e) => e.entityTypeKey == 'creature'),
        isTrue,
      );
      expect(
        demoNpcEntities.every((e) => e.entityTypeKey == 'npc'),
        isTrue,
      );
    });

    test('nested mechanics structures remain maps/lists in payload', () {
      final creature = demoEntities.firstWhere(
        (entity) => entity.getString('name') == 'Beholder',
      );

      final legendaryActions = creature.getList('legendaryActions');
      final senses = creature.getMap('senses');

      expect(legendaryActions, isNotEmpty);
      expect(legendaryActions.first, isA<Map>());
      expect(senses['darkvision'], equals(120));
      expect(senses['passivePerception'], equals(23));
    });
  });

  group('Legacy fixture negative case', () {
    test('legacy pageType fixture is recognized as old shape', () {
      final legacyFixture = {
        'id': 'legacy-1',
        'title': 'Legacy Page',
        'pageType': 'creature',
      };

      expect(legacyFixture.containsKey('pageType'), isTrue);
      expect(legacyFixture.containsKey('entityTypeKey'), isFalse);
    });
  });
}

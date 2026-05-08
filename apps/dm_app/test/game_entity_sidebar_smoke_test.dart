import 'package:flutter_test/flutter_test.dart';
import 'package:core/data/data.dart';
import 'package:core/models/models.dart';
import 'package:dm_app/widgets/initiative_tracker.dart';
import 'package:dm_app/widgets/creature_detail_view.dart';

void main() {
  group('CombatantDragData.fromGameEntity', () {
    test('creates drag data from a monster GameEntity', () {
      final entity = demoMonsterEntities.first;
      final drag = CombatantDragData.fromGameEntity(entity);

      expect(drag.id, isNotEmpty);
      expect(drag.name, isNotEmpty);
      expect(drag.isPlayer, isFalse);
      expect(drag.currentHP, isA<int>());
      expect(drag.maxHP, greaterThan(0));
    });

    test('creates drag data from a character GameEntity', () {
      final entity = demoCharacterEntities.first;
      final drag = CombatantDragData.fromGameEntity(entity);

      expect(drag.id, isNotEmpty);
      expect(drag.name, isNotEmpty);
      expect(drag.isPlayer, isTrue);
    });

    test('creates drag data from an NPC GameEntity', () {
      final entity = demoNpcEntities.first;
      final drag = CombatantDragData.fromGameEntity(entity);

      expect(drag.id, isNotEmpty);
      expect(drag.name, isNotEmpty);
      expect(drag.isPlayer, isFalse);
    });

    test('uses safe fallback defaults for missing fields', () {
      final minimalEntity = GameEntity(
        entityTypeKey: 'creature',
        data: {'name': 'Minimal Creature'},
      );
      final drag = CombatantDragData.fromGameEntity(minimalEntity);

      expect(drag.name, 'Minimal Creature');
      expect(drag.currentHP, 0); // fallback default
      expect(drag.maxHP, 0); // fallback default
      expect(drag.initiativeModifier, 0); // fallback default
    });
  });

  group('InitiativeEntry.fromGameEntity', () {
    test('creates entry from monster GameEntity', () {
      final entity = demoMonsterEntities.first;
      final entry = InitiativeEntry.fromGameEntity(entity);

      expect(entry.name, isNotEmpty);
      expect(entry.sourceId, isNotEmpty);
      expect(entry.isPlayer, isFalse);
    });

    test('creates entry from character GameEntity with isPlayer=true', () {
      final entity = demoCharacterEntities.first;
      final entry = InitiativeEntry.fromGameEntity(entity);

      expect(entry.isPlayer, isTrue);
    });
  });

  group('CreatureDetail.fromGameEntity', () {
    test('creates detail from monster GameEntity', () {
      final entity = demoMonsterEntities.first;
      final detail = CreatureDetail.fromGameEntity(entity);

      expect(detail.name, isNotEmpty);
      expect(detail.id, isNotEmpty);
      expect(detail.typeLabel, isNotEmpty);
    });

    test('creates detail from character GameEntity', () {
      final entity = demoCharacterEntities.first;
      final detail = CreatureDetail.fromGameEntity(entity);

      expect(detail.name, isNotEmpty);
      expect(detail.isPlayer, isTrue);
    });

    test('uses safe fallback defaults for missing fields', () {
      final minimalEntity = GameEntity(
        entityTypeKey: 'creature',
        data: {'name': 'Test Creature'},
      );
      final detail = CreatureDetail.fromGameEntity(minimalEntity);

      expect(detail.name, 'Test Creature');
      expect(detail.armorClass, 10); // D&D default AC
    });
  });

  group('DM sidebar from GameEntity demos', () {
    test('demoCharacterEntities are non-empty and all creature type', () {
      expect(demoCharacterEntities, isNotEmpty);
      expect(
        demoCharacterEntities.every((e) => e.entityTypeKey == 'creature'),
        isTrue,
      );
    });

    test('demoMonsterEntities are non-empty and all creature type', () {
      expect(demoMonsterEntities, isNotEmpty);
      expect(
        demoMonsterEntities.every((e) => e.entityTypeKey == 'creature'),
        isTrue,
      );
    });

    test('demoNpcEntities are non-empty and all npc type', () {
      expect(demoNpcEntities, isNotEmpty);
      expect(
        demoNpcEntities.every((e) => e.entityTypeKey == 'npc'),
        isTrue,
      );
    });

    test('total split entities do not exceed unified demoEntities', () {
      final total = demoCharacterEntities.length +
          demoMonsterEntities.length +
          demoNpcEntities.length;
      expect(total, lessThanOrEqualTo(demoEntities.length));
    });
  });
}

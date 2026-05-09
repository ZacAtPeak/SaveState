import 'package:flutter_test/flutter_test.dart';
import 'package:savestate/data/models.dart';

void main() {
  group('Entity Model', () {
    test('creates entity with default values', () {
      final entity = Entity(name: 'Goblin');
      expect(entity.name, 'Goblin');
      expect(entity.hp, 0);
      expect(entity.maxHp, 0);
      expect(entity.ac, 10);
      expect(entity.initiative, 0);
      expect(entity.isBookmarked, false);
    });

    test('serializes to map correctly', () {
      final entity = Entity(
        id: 1,
        name: 'Orc',
        gameSystemId: 1,
        hp: 15,
        maxHp: 15,
        ac: 13,
        initiative: 12,
        isBookmarked: true,
      );
      final map = entity.toMap();
      expect(map['id'], 1);
      expect(map['name'], 'Orc');
      expect(map['hp'], 15);
      expect(map['ac'], 13);
      expect(map['isBookmarked'], 1);
    });

    test('deserializes from map correctly', () {
      final map = {
        'id': 2,
        'name': 'Dragon',
        'gameSystemId': 1,
        'hp': 100,
        'maxHp': 100,
        'ac': 20,
        'initiative': 15,
        'isBookmarked': 0,
        'lastViewedAt': null,
        'fieldLayout': null,
        'createdAt': null,
        'updatedAt': null,
      };
      final entity = Entity.fromMap(map);
      expect(entity.id, 2);
      expect(entity.name, 'Dragon');
      expect(entity.hp, 100);
      expect(entity.ac, 20);
      expect(entity.isBookmarked, false);
    });

    test('copyWith creates modified copy', () {
      final original = Entity(name: 'Goblin', hp: 10, maxHp: 10);
      final modified = original.copyWith(hp: 8);
      expect(modified.name, 'Goblin');
      expect(modified.hp, 8);
      expect(modified.maxHp, 10);
    });
  });

  group('GameSystem Model', () {
    test('creates game system', () {
      final system = GameSystem(
        id: 1,
        name: 'D&D 5e',
        initiativeRule: 'd20 + DEX',
      );
      expect(system.name, 'D&D 5e');
      expect(system.initiativeRule, 'd20 + DEX');
    });

    test('serializes to map correctly', () {
      final system = GameSystem(
        name: 'Pathfinder',
        entityFields: ['hp', 'ac', 'attack'],
      );
      final map = system.toMap();
      expect(map['name'], 'Pathfinder');
      expect(map['entityFields'], 'hp,ac,attack');
    });
  });

  group('InitiativeEntry Model', () {
    test('creates initiative entry', () {
      final entry = InitiativeEntry(
        entityId: 1,
        initiativeValue: 15,
        order: 0,
      );
      expect(entry.entityId, 1);
      expect(entry.initiativeValue, 15);
      expect(entry.order, 0);
    });

    test('serializes to map correctly', () {
      final entry = InitiativeEntry(
        entityId: 2,
        initiativeValue: 18,
        combatId: 1,
        order: 1,
      );
      final map = entry.toMap();
      expect(map['entityId'], 2);
      expect(map['initiativeValue'], 18);
      expect(map['combatId'], 1);
      expect(map['order'], 1);
    });
  });

  group('RollHistory Model', () {
    test('creates roll history entry', () {
      final roll = RollHistory(
        entityId: 1,
        rollType: 'initiative',
        rollValue: 17,
        target: 0,
      );
      expect(roll.entityId, 1);
      expect(roll.rollType, 'initiative');
      expect(roll.rollValue, 17);
    });
  });
}

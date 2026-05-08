import '../models/models.dart';
import 'demo_monsters.dart';
import 'demo_npcs.dart';
import 'demo_player_characters.dart';

final demoEntities = <GameEntity>[
  ...demoCharacterEntities,
  ...demoMonsterEntities,
  ...demoNpcEntities,
];

final demoCharacterEntitiesFiltered = demoEntities
    .where((entity) =>
        entity.entityTypeKey == 'creature' &&
        entity.getString('playerClass').isNotEmpty)
    .toList(growable: false);

final demoMonsterEntitiesFiltered = demoEntities
    .where((entity) =>
        entity.entityTypeKey == 'creature' &&
        entity.getDouble('challengeRating') > 0 &&
        entity.getString('playerClass').isEmpty)
    .toList(growable: false);

final demoNpcEntitiesFiltered = demoEntities
    .where((entity) => entity.entityTypeKey == 'npc')
    .toList(growable: false);

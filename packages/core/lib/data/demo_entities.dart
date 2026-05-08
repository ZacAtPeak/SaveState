import '../models/models.dart';
import 'demo_monsters.dart';
import 'demo_npcs.dart';
import 'demo_player_characters.dart';

final demoEntities = <GameEntity>[
  ...demoPlayerCharacters.map(
    (character) => GameEntity(
      entityTypeKey: 'creature',
      data: character.toJson(),
    ),
  ),
  ...demoMonsters.map(
    (monster) => monster,
  ),
  ...demoNPCs.map(
    (npc) => npc,
  ),
];

final demoCharacterEntities = demoEntities
    .where((entity) =>
        entity.entityTypeKey == 'creature' &&
        entity.getString('playerClass').isNotEmpty)
    .toList(growable: false);

final demoMonsterEntities = demoEntities
    .where((entity) =>
        entity.entityTypeKey == 'creature' &&
        entity.getDouble('challengeRating') > 0 &&
        entity.getString('playerClass').isEmpty)
    .toList(growable: false);

final demoNpcEntities = demoEntities
    .where((entity) => entity.entityTypeKey == 'npc')
    .toList(growable: false);

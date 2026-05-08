import 'package:flutter/material.dart';
import 'package:core/models/models.dart';
import 'package:core/widgets/schema_form_builder.dart';
import 'package:core/services/game_model_service.dart';
import 'package:provider/provider.dart';

// Kept for backwards compatibility with sidebar (D-16 bridge).
// Will be fully removed in cleanup phase once CombatantDragData is updated.
@Deprecated('Use GameEntity directly with schema-driven rendering')
class CreatureDetail {
  final String id;
  final String name;
  final String typeLabel;
  final String? levelLabel;
  final int armorClass;
  final String armorSource;
  final MovementSpeed speed;
  final Senses senses;
  final AbilityScores abilityScores;
  final List<SkillProficiency> skills;
  final List<Attack> actions;
  final List<SpellSlot> spellSlots;
  final List<String> knownSpells;
  final String? loreText;
  final List<SpecialAbility> specialAbilities;
  final bool isPlayer;

  const CreatureDetail({
    required this.id,
    required this.name,
    required this.typeLabel,
    required this.levelLabel,
    required this.armorClass,
    required this.armorSource,
    required this.speed,
    required this.senses,
    required this.abilityScores,
    required this.skills,
    required this.actions,
    required this.spellSlots,
    required this.knownSpells,
    required this.loreText,
    required this.specialAbilities,
    this.isPlayer = false,
  });

  /// Create from a GameEntity map with safe fallback defaults (per D-16).
  factory CreatureDetail.fromGameEntity(GameEntity entity) {
    final isPlayer = entity.entityTypeKey == 'creature' &&
        entity.getString('playerClass').isNotEmpty;
    final size = entity.getString('size', fallback: 'Medium');
    final creatureType = entity.getString('creatureType', fallback: 'Unknown');
    final cr = entity.getDouble('challengeRating', fallback: 0);
    final playerClass = entity.getString('playerClass', fallback: '');
    final race = entity.getString('race', fallback: '');
    final level = entity.getInt('level', fallback: 0);

    String typeLabel;
    String? levelLabel;
    if (isPlayer) {
      typeLabel = '$race $playerClass';
      levelLabel = 'Level $level';
    } else if (cr > 0) {
      typeLabel = '${_titleCase(size)} ${_titleCase(creatureType)}';
      levelLabel = 'CR ${_formatCR(cr)}';
    } else {
      typeLabel = entity.getString('classOrRole', fallback: creatureType);
      levelLabel = null;
    }

    return CreatureDetail(
      id: entity.getString('id', fallback: entity.entityTypeKey),
      name: entity.getString('name', fallback: 'Unknown'),
      typeLabel: typeLabel,
      levelLabel: levelLabel,
      armorClass: entity.getInt('armorClass', fallback: 10),
      armorSource: entity.getString('armorSource', fallback: 'natural'),
      speed: MovementSpeed(
        walk: entity.getInt('speedWalk', fallback: 30),
        fly: entity.getInt('speedFly', fallback: 0) > 0
            ? entity.getInt('speedFly', fallback: 0)
            : null,
        swim: entity.getInt('speedSwim', fallback: 0) > 0
            ? entity.getInt('speedSwim', fallback: 0)
            : null,
        climb: entity.getInt('speedClimb', fallback: 0) > 0
            ? entity.getInt('speedClimb', fallback: 0)
            : null,
        burrow: entity.getInt('speedBurrow', fallback: 0) > 0
            ? entity.getInt('speedBurrow', fallback: 0)
            : null,
        hover: entity.getBool('hover', fallback: false),
      ),
      senses: Senses(
        darkvision: entity.getInt('darkvision', fallback: 0) > 0
            ? entity.getInt('darkvision', fallback: 0)
            : null,
        blindsight: entity.getInt('blindsight', fallback: 0) > 0
            ? entity.getInt('blindsight', fallback: 0)
            : null,
        tremorsense: entity.getInt('tremorsense', fallback: 0) > 0
            ? entity.getInt('tremorsense', fallback: 0)
            : null,
        truesight: entity.getInt('truesight', fallback: 0) > 0
            ? entity.getInt('truesight', fallback: 0)
            : null,
        passivePerception: entity.getInt('passivePerception', fallback: 10),
      ),
      abilityScores: AbilityScores(
        strength: entity.getInt('strength', fallback: 10),
        dexterity: entity.getInt('dexterity', fallback: 10),
        constitution: entity.getInt('constitution', fallback: 10),
        intelligence: entity.getInt('intelligence', fallback: 10),
        wisdom: entity.getInt('wisdom', fallback: 10),
        charisma: entity.getInt('charisma', fallback: 10),
      ),
      skills: const [],
      actions: const [],
      spellSlots: const [],
      knownSpells: const [],
      loreText: entity.getString('body', fallback: null),
      specialAbilities: const [],
      isPlayer: isPlayer,
    );
  }
}

// Kept helper functions for sidebar compatibility.
String _titleCase(String s) =>
    s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

String _formatCR(double cr) {
  if (cr == 0.125) return '1/8';
  if (cr == 0.25) return '1/4';
  if (cr == 0.5) return '1/2';
  return cr == cr.truncateToDouble() ? cr.toInt().toString() : cr.toString();
}

/// Schema-driven creature detail view using SchemaFormBuilder.
/// Reads creature data from GameEntity and renders fields from the active GameModel.
class CreatureDetailView extends StatelessWidget {
  const CreatureDetailView({super.key, required this.entity});

  final GameEntity? entity;

  @override
  Widget build(BuildContext context) {
    if (entity == null) {
      final theme = Theme.of(context);
      return Center(
        child: Text(
          'Select a creature on the left to see details',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return Selector<GameModelService, GameModel?>(
      selector: (_, service) => service.activeModel,
      builder: (context, gameModel, child) {
        if (gameModel == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final entityType = gameModel.entityTypes
            .where((t) => t.key == entity!.entityTypeKey)
            .firstOrNull;

        if (entityType == null) {
          final theme = Theme.of(context);
          return Center(
            child: Text(
              'Unknown entity type: ${entity!.entityTypeKey}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          );
        }

        final data = Map<String, dynamic>.from(
          entity!.toJson()['data'] as Map,
        );

        return SchemaFormBuilder(
          fields: entityType.fields,
          data: data,
          onDataChanged: (_) {}, // Read-only view — no editing in DM app detail
          gameModel: gameModel,
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:core/models/models.dart';

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

String _titleCase(String s) =>
    s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

String _formatCR(double cr) {
  if (cr == 0.125) return '1/8';
  if (cr == 0.25) return '1/4';
  if (cr == 0.5) return '1/2';
  return cr == cr.truncateToDouble() ? cr.toInt().toString() : cr.toString();
}

String _formatSpeed(MovementSpeed s) {
  final parts = <String>['${s.walk} ft.'];
  if (s.fly != null) parts.add('fly ${s.fly} ft.${s.hover ? ' (hover)' : ''}');
  if (s.swim != null) parts.add('swim ${s.swim} ft.');
  if (s.climb != null) parts.add('climb ${s.climb} ft.');
  if (s.burrow != null) parts.add('burrow ${s.burrow} ft.');
  return parts.join(', ');
}

String _formatSenses(Senses s) {
  final parts = <String>[];
  if (s.darkvision != null) parts.add('darkvision ${s.darkvision} ft.');
  if (s.blindsight != null) parts.add('blindsight ${s.blindsight} ft.');
  if (s.tremorsense != null) parts.add('tremorsense ${s.tremorsense} ft.');
  if (s.truesight != null) parts.add('truesight ${s.truesight} ft.');
  parts.add('passive Perception ${s.passivePerception}');
  return parts.join(', ');
}

String _modifierLabel(int mod) => mod >= 0 ? '+$mod' : '$mod';

const _allSkills = <(String, String)>[
  ('Acrobatics', 'dexterity'),
  ('Animal Handling', 'wisdom'),
  ('Arcana', 'intelligence'),
  ('Athletics', 'strength'),
  ('Deception', 'charisma'),
  ('History', 'intelligence'),
  ('Insight', 'wisdom'),
  ('Intimidation', 'charisma'),
  ('Investigation', 'intelligence'),
  ('Medicine', 'wisdom'),
  ('Nature', 'intelligence'),
  ('Perception', 'wisdom'),
  ('Performance', 'charisma'),
  ('Persuasion', 'charisma'),
  ('Religion', 'intelligence'),
  ('Sleight of Hand', 'dexterity'),
  ('Stealth', 'dexterity'),
  ('Survival', 'wisdom'),
];

String _abbrev(String ability) => switch (ability.toLowerCase()) {
      'strength' => 'STR',
      'dexterity' => 'DEX',
      'constitution' => 'CON',
      'intelligence' => 'INT',
      'wisdom' => 'WIS',
      'charisma' => 'CHA',
      _ => ability.toUpperCase(),
    };

class CreatureDetailView extends StatelessWidget {
  const CreatureDetailView({super.key, required this.detail});

  final CreatureDetail? detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final d = detail;

    if (d == null) {
      return Center(
        child: Text(
          'Select a creature on the left to see details',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(d.name, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text(
                  [d.typeLabel, if (d.levelLabel != null) d.levelLabel!]
                      .where((s) => s.isNotEmpty)
                      .join(' • '),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Divider(height: 24),
                _StatRow(
                    label: 'AC', value: '${d.armorClass} (${d.armorSource})'),
                _StatRow(label: 'Speed', value: _formatSpeed(d.speed)),
                _StatRow(label: 'Senses', value: _formatSenses(d.senses)),
                if (d.spellSlots.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _SpellSlotsBlock(spellSlots: d.spellSlots),
                ],
                const SizedBox(height: 12),
                Text('Ability Scores', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                _AbilityScoresRow(scores: d.abilityScores),
              ],
            ),
          ),
          Material(
            color: theme.colorScheme.surface,
            child: TabBar(
              isScrollable: false,
              tabs: const [
                Tab(text: 'Skills'),
                Tab(text: 'Actions'),
                Tab(text: 'Spells'),
                Tab(text: 'Inventory'),
                Tab(text: 'Lore'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _SkillsTab(
                  skills: d.skills,
                  abilityScores: d.abilityScores,
                ),
                _ActionsTab(actions: d.actions),
                _SpellsTab(spellSlots: d.spellSlots, knownSpells: d.knownSpells),
                const _EmptyTab(message: 'No inventory tracked yet'),
                _LoreTab(
                  loreText: d.loreText,
                  specialAbilities: d.specialAbilities,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: RichText(
        text: TextSpan(
          style: theme.textTheme.bodyMedium,
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

class _AbilityScoresRow extends StatelessWidget {
  const _AbilityScoresRow({required this.scores});

  final AbilityScores scores;

  @override
  Widget build(BuildContext context) {
    final entries = [
      ('STR', scores.strength, scores.strMod),
      ('DEX', scores.dexterity, scores.dexMod),
      ('CON', scores.constitution, scores.conMod),
      ('INT', scores.intelligence, scores.intMod),
      ('WIS', scores.wisdom, scores.wisMod),
      ('CHA', scores.charisma, scores.chaMod),
    ];
    return Row(
      children: entries
          .map((e) => Expanded(
                child: _AbilityCard(label: e.$1, score: e.$2, modifier: e.$3),
              ))
          .toList(),
    );
  }
}

class _AbilityCard extends StatelessWidget {
  const _AbilityCard({
    required this.label,
    required this.score,
    required this.modifier,
  });

  final String label;
  final int score;
  final int modifier;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text('$score', style: theme.textTheme.titleMedium),
          Text(
            _modifierLabel(modifier),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

const _romanNumerals = ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX'];

String _toRoman(int level) =>
    (level >= 1 && level <= 9) ? _romanNumerals[level - 1] : '$level';

class _SpellSlotsBlock extends StatefulWidget {
  const _SpellSlotsBlock({required this.spellSlots});

  final List<SpellSlot> spellSlots;

  @override
  State<_SpellSlotsBlock> createState() => _SpellSlotsBlockState();
}

class _SpellSlotsBlockState extends State<_SpellSlotsBlock> {
  late List<SpellSlot> _slots;

  @override
  void initState() {
    super.initState();
    _slots = [...widget.spellSlots]..sort((a, b) => a.level.compareTo(b.level));
  }

  @override
  void didUpdateWidget(_SpellSlotsBlock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.spellSlots != widget.spellSlots) {
      _slots = [...widget.spellSlots]..sort((a, b) => a.level.compareTo(b.level));
    }
  }

  void _toggleSlot(int slotIndex, int circleIndex) {
    setState(() {
      final slot = _slots[slotIndex];
      final wasFilled = circleIndex < slot.available;
      final newAvailable = wasFilled ? circleIndex : circleIndex + 1;
      _slots[slotIndex] = SpellSlot(
        level: slot.level,
        max: slot.max,
        available: newAvailable,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Spell Slots',
          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 8.0;
            const minColumnWidth = 200.0;
            const maxColumns = 3;
            final available = constraints.maxWidth;
            var columns =
                ((available + spacing) / (minColumnWidth + spacing)).floor();
            columns = columns.clamp(1, maxColumns);
            final cellWidth =
                (available - spacing * (columns - 1)) / columns;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: _slots
                  .asMap()
                  .entries
                  .map((e) => SizedBox(
                        width: cellWidth,
                        child: _SpellSlotCell(
                          slot: e.value,
                          onToggle: (i) => _toggleSlot(e.key, i),
                        ),
                      ))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _SpellSlotCell extends StatelessWidget {
  const _SpellSlotCell({required this.slot, required this.onToggle});

  final SpellSlot slot;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _toRoman(slot.level),
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: List.generate(slot.max, (i) {
              final filled = i < slot.available;
              return GestureDetector(
                onTap: () => onToggle(i),
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled
                        ? theme.colorScheme.primary
                        : Colors.transparent,
                    border: Border.all(
                      color: theme.colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      );
  }
}

class _SkillsTab extends StatelessWidget {
  const _SkillsTab({required this.skills, required this.abilityScores});

  final List<SkillProficiency> skills;
  final AbilityScores abilityScores;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final byName = {
      for (final s in skills) s.skill.toLowerCase(): s,
    };

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 8.0;
        const minColumnWidth = 200.0;
        const maxColumns = 3;
        final available = constraints.maxWidth - 16;
        var columns =
            ((available + spacing) / (minColumnWidth + spacing)).floor();
        columns = columns.clamp(1, maxColumns);
        final itemWidth =
            (available - spacing * (columns - 1)) / columns;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: _allSkills.map((entry) {
              final skillName = entry.$1;
              final abilityKey = entry.$2;
              final existing = byName[skillName.toLowerCase()];
              final isProficient = existing?.isProficient ?? false;
              final bonus =
                  existing?.bonus ?? abilityScores.modifierFor(abilityKey);
              return SizedBox(
                width: itemWidth,
                child: _SkillRow(
                  skill: skillName,
                  ability: _abbrev(abilityKey),
                  bonus: bonus,
                  isProficient: isProficient,
                  theme: theme,
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _SkillRow extends StatelessWidget {
  const _SkillRow({
    required this.skill,
    required this.ability,
    required this.bonus,
    required this.isProficient,
    required this.theme,
  });

  final String skill;
  final String ability;
  final int bonus;
  final bool isProficient;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isProficient
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.35)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isProficient
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isProficient ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
            color: isProficient
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  skill,
                  style: theme.textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  ability,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _modifierLabel(bonus),
            style: theme.textTheme.titleSmall,
          ),
        ],
      ),
    );
  }
}

class _ActionsTab extends StatelessWidget {
  const _ActionsTab({required this.actions});

  final List<Attack> actions;

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) {
      return const _EmptyTab(message: 'No actions');
    }
    final theme = Theme.of(context);
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: actions.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final a = actions[i];
        final hit = _modifierLabel(a.hitBonus);
        return ListTile(
          dense: true,
          title: Text(a.name),
          subtitle: Text(
            '$hit to hit • ${a.reach} • ${a.damageRoll} ${a.damageType}'
            '${a.saveDC != null ? ' • DC ${a.saveDC}' : ''}',
            style: theme.textTheme.bodySmall,
          ),
          trailing: a.maxUses != null
              ? Text('${a.remainingUses ?? a.maxUses}/${a.maxUses}')
              : null,
        );
      },
    );
  }
}

class _SpellsTab extends StatelessWidget {
  const _SpellsTab({required this.spellSlots, required this.knownSpells});

  final List<SpellSlot> spellSlots;
  final List<String> knownSpells;

  @override
  Widget build(BuildContext context) {
    if (spellSlots.isEmpty && knownSpells.isEmpty) {
      return const _EmptyTab(message: 'No spells');
    }
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        if (spellSlots.isNotEmpty) ...[
          Text('Spell Slots', style: theme.textTheme.titleSmall),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: spellSlots
                .map((s) => Chip(
                      label: Text('L${s.level}: ${s.available}/${s.max}'),
                      visualDensity: VisualDensity.compact,
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
        ],
        if (knownSpells.isNotEmpty) ...[
          Text('Known Spells', style: theme.textTheme.titleSmall),
          const SizedBox(height: 6),
          ...knownSpells.map(
            (name) => ListTile(
              dense: true,
              leading: const Icon(Icons.auto_awesome, size: 18),
              title: Text(name),
            ),
          ),
        ],
      ],
    );
  }
}

class _LoreTab extends StatelessWidget {
  const _LoreTab({required this.loreText, required this.specialAbilities});

  final String? loreText;
  final List<SpecialAbility> specialAbilities;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasLore = loreText != null && loreText!.trim().isNotEmpty;
    if (!hasLore && specialAbilities.isEmpty) {
      return const _EmptyTab(message: 'No lore available');
    }
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        if (hasLore) ...[
          Text(
            loreText!,
            style: theme.textTheme.bodyMedium,
          ),
          if (specialAbilities.isNotEmpty) const SizedBox(height: 16),
        ],
        if (specialAbilities.isNotEmpty) ...[
          Text('Traits', style: theme.textTheme.titleSmall),
          const SizedBox(height: 6),
          ...specialAbilities.map(
            (a) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: RichText(
                text: TextSpan(
                  style: theme.textTheme.bodyMedium,
                  children: [
                    TextSpan(
                      text: '${a.name}. ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: a.description),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _EmptyTab extends StatelessWidget {
  const _EmptyTab({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Text(
        message,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

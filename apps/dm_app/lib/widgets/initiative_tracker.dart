import 'dart:math';

import 'package:flutter/material.dart';
import 'package:core/models/models.dart';

class RollHistoryEntry {
  final String combatantName;
  final int d20;
  final int modifier;
  final DateTime timestamp;

  const RollHistoryEntry({
    required this.combatantName,
    required this.d20,
    required this.modifier,
    required this.timestamp,
  });

  int get total => d20 + modifier;
}

class CombatantDragData {
  final String id;
  final String name;
  final int initiativeModifier;
  final int currentHP;
  final int maxHP;
  final List<String> statusConditions;
  final bool isPlayer;

  const CombatantDragData({
    required this.id,
    required this.name,
    required this.initiativeModifier,
    required this.currentHP,
    required this.maxHP,
    this.statusConditions = const [],
    this.isPlayer = false,
  });

  factory CombatantDragData.fromPlayerCharacter(PlayerCharacter pc) =>
      CombatantDragData(
        id: pc.id,
        name: pc.name,
        initiativeModifier: pc.abilityScores.dexMod,
        currentHP: pc.currentHP,
        maxHP: pc.maxHP,
        statusConditions: pc.status?.map((s) => s.name).toList() ?? const [],
        isPlayer: true,
      );

  factory CombatantDragData.fromMonster(Monster m) => CombatantDragData(
        id: m.id,
        name: m.name,
        initiativeModifier: m.abilityScores.dexMod,
        currentHP: m.currentHP,
        maxHP: m.maxHP,
        statusConditions: m.status?.map((s) => s.name).toList() ?? const [],
      );

  factory CombatantDragData.fromNPC(NPC npc) => CombatantDragData(
        id: npc.id,
        name: npc.name,
        initiativeModifier: npc.abilityScores.dexMod,
        currentHP: npc.currentHP,
        maxHP: npc.maxHP,
        statusConditions: npc.status?.map((s) => s.name).toList() ?? const [],
      );
}

class InitiativeEntry {
  final String id;
  final String sourceId;
  final String name;
  final double initiative;
  final int currentHP;
  final int maxHP;
  final List<String> statusConditions;
  final bool isPlayer;

  const InitiativeEntry({
    required this.id,
    required this.sourceId,
    required this.name,
    required this.initiative,
    required this.currentHP,
    required this.maxHP,
    this.statusConditions = const [],
    this.isPlayer = false,
  });

  factory InitiativeEntry.fromPlayerCharacter(PlayerCharacter pc) => InitiativeEntry(
        id: pc.id,
        sourceId: pc.id,
        name: pc.name,
        initiative: pc.initiative,
        currentHP: pc.currentHP,
        maxHP: pc.maxHP,
        statusConditions: pc.status?.map((s) => s.name).toList() ?? [],
        isPlayer: true,
      );

  factory InitiativeEntry.fromNPC(NPC npc) => InitiativeEntry(
        id: npc.id,
        sourceId: npc.id,
        name: npc.name,
        initiative: npc.initiative,
        currentHP: npc.currentHP,
        maxHP: npc.maxHP,
        statusConditions: npc.status?.map((s) => s.name).toList() ?? [],
      );

  factory InitiativeEntry.fromMonster(Monster m) => InitiativeEntry(
        id: m.id,
        sourceId: m.id,
        name: m.name,
        initiative: m.initiative,
        currentHP: m.currentHP,
        maxHP: m.maxHP,
        statusConditions: m.status?.map((s) => s.name).toList() ?? [],
      );

  double get hpPercent => maxHP > 0 ? currentHP / maxHP : 0;

  InitiativeEntry copyWith({
    String? id,
    String? sourceId,
    String? name,
    double? initiative,
    int? currentHP,
    int? maxHP,
    List<String>? statusConditions,
    bool? isPlayer,
  }) =>
      InitiativeEntry(
        id: id ?? this.id,
        sourceId: sourceId ?? this.sourceId,
        name: name ?? this.name,
        initiative: initiative ?? this.initiative,
        currentHP: currentHP ?? this.currentHP,
        maxHP: maxHP ?? this.maxHP,
        statusConditions: statusConditions ?? this.statusConditions,
        isPlayer: isPlayer ?? this.isPlayer,
      );
}

class InitiativeTracker extends StatefulWidget {
  final List<InitiativeEntry> entries;
  final ValueChanged<List<InitiativeEntry>>? onEntriesChanged;
  final ValueChanged<int>? onActiveIndexChanged;
  final ValueChanged<RollHistoryEntry>? onRoll;
  final ValueChanged<InitiativeEntry>? onEntryTap;
  final int activeIndex;

  const InitiativeTracker({
    super.key,
    required this.entries,
    this.onEntriesChanged,
    this.onActiveIndexChanged,
    this.onRoll,
    this.onEntryTap,
    this.activeIndex = -1,
  });

  @override
  State<InitiativeTracker> createState() => _InitiativeTrackerState();
}

class _InitiativeTrackerState extends State<InitiativeTracker> {
  static final _rng = Random();
  late List<InitiativeEntry> _sortedEntries;
  late int _activeIndex;
  String? _lastRollMessage;

  @override
  void initState() {
    super.initState();
    _sortedEntries = _sortEntries(widget.entries);
    _activeIndex = widget.activeIndex;
  }

  @override
  void didUpdateWidget(InitiativeTracker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entries != widget.entries) {
      _sortedEntries = _sortEntries(widget.entries);
    }
    if (oldWidget.activeIndex != widget.activeIndex) {
      _activeIndex = widget.activeIndex;
    }
  }

  List<InitiativeEntry> _sortEntries(List<InitiativeEntry> entries) {
    final sorted = List<InitiativeEntry>.from(entries);
    sorted.sort((a, b) => b.initiative.compareTo(a.initiative));
    return sorted;
  }

  void _nextTurn() {
    if (_sortedEntries.isEmpty) return;
    setState(() {
      _activeIndex = (_activeIndex + 1) % _sortedEntries.length;
    });
    widget.onActiveIndexChanged?.call(_activeIndex);
  }

  void _previousTurn() {
    if (_sortedEntries.isEmpty) return;
    setState(() {
      _activeIndex = (_activeIndex - 1 + _sortedEntries.length) % _sortedEntries.length;
    });
    widget.onActiveIndexChanged?.call(_activeIndex);
  }

  void _adjustHP(int index, int delta) {
    setState(() {
      final entry = _sortedEntries[index];
      final newHP = (entry.currentHP + delta).clamp(0, entry.maxHP);
      _sortedEntries[index] = entry.copyWith(currentHP: newHP);
    });
    widget.onEntriesChanged?.call(_sortedEntries);
  }

  void _onCombatantDropped(CombatantDragData data) {
    final roll = _rng.nextInt(20) + 1;
    final initiative = (roll + data.initiativeModifier).toDouble();
    widget.onRoll?.call(RollHistoryEntry(
      combatantName: data.name,
      d20: roll,
      modifier: data.initiativeModifier,
      timestamp: DateTime.now(),
    ));
    final instanceId =
        '${data.id}_${DateTime.now().millisecondsSinceEpoch}_$roll';
    final entry = InitiativeEntry(
      id: instanceId,
      sourceId: data.id,
      name: data.name,
      initiative: initiative,
      currentHP: data.currentHP,
      maxHP: data.maxHP,
      statusConditions: data.statusConditions,
      isPlayer: data.isPlayer,
    );

    final next = List<InitiativeEntry>.from(_sortedEntries)..add(entry);

    final modSign = data.initiativeModifier >= 0 ? '+' : '';
    setState(() {
      _sortedEntries = _sortEntries(next);
      _lastRollMessage =
          '${data.name}: $roll $modSign${data.initiativeModifier} = ${initiative.toStringAsFixed(0)}';
    });
    widget.onEntriesChanged?.call(_sortedEntries);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 160,
      color: theme.colorScheme.surfaceContainerLow,
      child: Column(
        children: [
          _buildControlBar(theme),
          Expanded(
            child: DragTarget<CombatantDragData>(
              onAcceptWithDetails: (details) => _onCombatantDropped(details.data),
              builder: (context, candidate, rejected) {
                final highlighted = candidate.isNotEmpty;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  decoration: BoxDecoration(
                    color: highlighted
                        ? theme.colorScheme.primaryContainer.withValues(alpha: 0.35)
                        : Colors.transparent,
                    border: Border.all(
                      color: highlighted
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: _sortedEntries.isEmpty
                      ? Center(
                          child: Text(
                            highlighted
                                ? 'Drop to roll initiative'
                                : 'Drag combatants here to roll initiative',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          itemCount: _sortedEntries.length,
                          itemBuilder: (context, index) => _buildEntryCard(index, theme),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlBar(ThemeData theme) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Text(
            'INITIATIVE',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (_lastRollMessage != null) ...[
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                'Rolled $_lastRollMessage',
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 18),
            onPressed: _previousTurn,
            tooltip: 'Previous Turn',
          ),
          Text(
            _activeIndex >= 0 && _activeIndex < _sortedEntries.length
                ? '${_sortedEntries[_activeIndex].name}\'s Turn'
                : 'No Active Turn',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 18),
            onPressed: _nextTurn,
            tooltip: 'Next Turn',
          ),
        ],
      ),
    );
  }

  Widget _buildEntryCard(int index, ThemeData theme) {
    final entry = _sortedEntries[index];
    final isActive = index == _activeIndex;
    final hpPercent = entry.hpPercent;
    final hpColor = hpPercent > 0.5
        ? Colors.green
        : hpPercent > 0.25
            ? Colors.orange
            : Colors.red;

    return GestureDetector(
      onTap: () => widget.onEntryTap?.call(entry),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 140,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (entry.isPlayer)
                  Icon(Icons.person, size: 14, color: theme.colorScheme.primary)
                else
                  Icon(Icons.shield, size: 14, color: theme.colorScheme.error),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    entry.name,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'Init: ${entry.initiative.toStringAsFixed(0)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove, size: 16),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _adjustHP(index, -1),
                ),
                Expanded(
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        value: hpPercent,
                        minHeight: 4,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(hpColor),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${entry.currentHP}/${entry.maxHP}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 16),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _adjustHP(index, 1),
                ),
              ],
            ),
            if (entry.statusConditions.isNotEmpty) ...[
              const SizedBox(height: 2),
              Wrap(
                spacing: 2,
                children: entry.statusConditions
                    .map((s) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.errorContainer,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            s,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 8,
                              color: theme.colorScheme.onErrorContainer,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

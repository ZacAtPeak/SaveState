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
  final Map<String, dynamic> _entityData;

  CombatantDragData({
    required this.id,
    required this.name,
    required this.initiativeModifier,
    required this.currentHP,
    required this.maxHP,
    this.statusConditions = const [],
    this.isPlayer = false,
    Map<String, dynamic>? entityData,
  }) : _entityData = entityData ?? {};

  /// Create from a GameEntity map with safe fallback defaults (per D-16).
  factory CombatantDragData.fromGameEntity(GameEntity entity, {GameModel? gameModel}) {
    final hpKey = _resolveHPFieldKey(gameModel, entity.entityTypeKey);
    final currentHPKey = 'currentHP';

    final isPlayer = entity.entityTypeKey == 'creature' &&
        entity.getString('playerClass').isNotEmpty;
    final dexMod = entity.getInt('dexterityModifier', fallback: 0);
    final statusList = entity.getList('status');
    final statusConditions = statusList
        .whereType<Map>()
        .map((s) => s['name']?.toString() ?? '')
        .where((s) => s.isNotEmpty)
        .toList();

    final maxHP = entity.getInt(hpKey, fallback: entity.getInt(currentHPKey, fallback: 0));
    final currentHP = entity.getInt(currentHPKey, fallback: maxHP);

    return CombatantDragData(
      id: entity.getString('id', fallback: entity.entityTypeKey),
      name: entity.getString('name', fallback: 'Unknown'),
      initiativeModifier: dexMod,
      currentHP: currentHP,
      maxHP: maxHP,
      statusConditions: statusConditions,
      isPlayer: isPlayer,
      entityData: Map<String, dynamic>.from(entity.toJson()['data'] as Map),
    );
  }

  /// Build a context map for FormulaEvaluator from entity data.
  /// Includes ability scores (STR, DEX, etc.) and modifiers.
  /// D-41: CoC uses 'dex' (lowercase) instead of 'dexterity' — include both keys.
  Map<String, dynamic> toFormulaContext() {
    return {
      'STR': _entityData['strength'] ?? 10,
      'DEX': _entityData['dexterity'] ?? _entityData['dex'] ?? 10,
      'CON': _entityData['constitution'] ?? 10,
      'INT': _entityData['intelligence'] ?? 10,
      'WIS': _entityData['wisdom'] ?? 10,
      'CHA': _entityData['charisma'] ?? 10,
      'strength': _entityData['strength'] ?? 10,
      'dexterity': _entityData['dexterity'] ?? _entityData['dex'] ?? 10,
      'dex': _entityData['dex'] ?? _entityData['dexterity'] ?? 10,
      'constitution': _entityData['constitution'] ?? 10,
      'intelligence': _entityData['intelligence'] ?? 10,
      'wisdom': _entityData['wisdom'] ?? 10,
      'charisma': _entityData['charisma'] ?? 10,
      'strengthModifier': _entityData['strengthModifier'] ?? 0,
      'dexterityModifier': _entityData['dexterityModifier'] ?? 0,
      'constitutionModifier': _entityData['constitutionModifier'] ?? 0,
      'intelligenceModifier': _entityData['intelligenceModifier'] ?? 0,
      'wisdomModifier': _entityData['wisdomModifier'] ?? 0,
      'charismaModifier': _entityData['charismaModifier'] ?? 0,
    };
  }
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

  /// Create from a GameEntity map with safe fallback defaults (per D-16).
  factory InitiativeEntry.fromGameEntity(GameEntity entity,
      {double initiative = 0, GameModel? gameModel}) {
    final hpKey = _resolveHPFieldKey(gameModel, entity.entityTypeKey);
    final currentHPKey = 'currentHP';

    final isPlayer = entity.entityTypeKey == 'creature' &&
        entity.getString('playerClass').isNotEmpty;
    final statusList = entity.getList('status');
    final statusConditions = statusList
        .whereType<Map>()
        .map((s) => s['name']?.toString() ?? '')
        .where((s) => s.isNotEmpty)
        .toList();

    final maxHP = entity.getInt(hpKey, fallback: entity.getInt(currentHPKey, fallback: 0));
    final currentHP = entity.getInt(currentHPKey, fallback: maxHP);

    return InitiativeEntry(
      id: entity.getString('id', fallback: entity.entityTypeKey),
      sourceId: entity.getString('id', fallback: entity.entityTypeKey),
      name: entity.getString('name', fallback: 'Unknown'),
      initiative: initiative,
      currentHP: currentHP,
      maxHP: maxHP,
      statusConditions: statusConditions,
      isPlayer: isPlayer,
    );
  }

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

/// Resolve the HP field key from the active GameModel's adversary entity schema.
/// Falls back to 'hitPoints' if not found.
String _resolveHPFieldKey(GameModel? gameModel, String entityTypeKey) {
  if (gameModel == null) return 'hitPoints';

  // First try resourceFields in rulesConfig
  final resourceFields = gameModel.rulesConfig['resourceFields'] as List<dynamic>?;
  if (resourceFields != null) {
    for (final rf in resourceFields) {
      if (rf is Map) {
        final key = rf['key'] as String?;
        final label = rf['label'] as String?;
        if (key != null && (key.toLowerCase().contains('hit') || key.toLowerCase().contains('hp'))) {
          return key;
        }
        if (label != null && label.toUpperCase() == 'HP') {
          return key ?? 'hitPoints';
        }
      }
    }
  }

  // Fallback: find entity type and look for HP-related field
  final entityType = gameModel.entityTypes
      .where((t) => t.key == entityTypeKey)
      .firstOrNull;
  if (entityType != null) {
    for (final field in entityType.fields) {
      final label = field.label.toLowerCase();
      if (label.contains('hit point') || label == 'hp') {
        return field.key;
      }
    }
  }

  return 'hitPoints';
}

class InitiativeTracker extends StatefulWidget {
  final List<InitiativeEntry> entries;
  final ValueChanged<List<InitiativeEntry>>? onEntriesChanged;
  final ValueChanged<int>? onActiveIndexChanged;
  final ValueChanged<RollHistoryEntry>? onRoll;
  final ValueChanged<InitiativeEntry>? onEntryTap;
  final int activeIndex;
  final GameModel? gameModel;

  const InitiativeTracker({
    super.key,
    required this.entries,
    this.onEntriesChanged,
    this.onActiveIndexChanged,
    this.onRoll,
    this.onEntryTap,
    this.activeIndex = -1,
    this.gameModel,
  });

  @override
  State<InitiativeTracker> createState() => _InitiativeTrackerState();
}

class _InitiativeTrackerState extends State<InitiativeTracker> {
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
    // D-41: Check isRolled flag — when false, use DEX-rank sort (CoC-style, no dice roll)
    final initiativeConfig = widget.gameModel?.rulesConfig['initiativeConfig'] as Map<String, dynamic>?;
    final isRolled = initiativeConfig?['isRolled'] as bool? ?? true; // default: roll dice
    // D-41: label available for UI display if needed in future
    // ignore: unused_local_variable
    final label = initiativeConfig?['label'] as String? ?? 'Initiative';

    num initiative;
    String rollDetail;

    if (isRolled) {
      // D&D-style: roll dice formula
      final formula = initiativeConfig?['formula'] as String? ?? '1d20+DEX';
      final context = data.toFormulaContext();
      try {
        initiative = FormulaEvaluator.evaluate(formula, context);
        rollDetail = '$formula = ${initiative.toStringAsFixed(0)}';
      } on FormulaError catch (_) {
        // Fallback: simple d20 roll if formula fails
        initiative = (data.initiativeModifier + 1).toDouble();
        rollDetail = 'formula error, using modifier';
      }
    } else {
      // D-42: CoC-style: DEX-rank sort — no dice, use raw DEX value
      // D-43: display raw DEX value for tie negotiation
      final dex = _entityDataFor(data, 'dex');
      initiative = dex.toDouble();
      rollDetail = 'DEX = ${initiative.toStringAsFixed(0)} (no roll)';
    }

    widget.onRoll?.call(RollHistoryEntry(
      combatantName: data.name,
      d20: initiative.toInt(),
      modifier: data.initiativeModifier,
      timestamp: DateTime.now(),
    ));

    final instanceId = '${data.id}_${DateTime.now().millisecondsSinceEpoch}';
    final entry = InitiativeEntry(
      id: instanceId,
      sourceId: data.id,
      name: data.name,
      initiative: initiative.toDouble(),
      currentHP: data.currentHP,
      maxHP: data.maxHP,
      statusConditions: data.statusConditions,
      isPlayer: data.isPlayer,
    );

    final next = List<InitiativeEntry>.from(_sortedEntries)..add(entry);

    setState(() {
      _sortedEntries = _sortEntries(next);
      _lastRollMessage = '${data.name}: $rollDetail';
    });
    widget.onEntriesChanged?.call(_sortedEntries);
  }

  /// Helper to safely extract a numeric field from CombatantDragData._entityData.
  int _entityDataFor(CombatantDragData data, String key) {
    final val = data._entityData[key];
    if (val is int) return val;
    if (val is double) return val.toInt();
    if (val is String) return int.tryParse(val) ?? 10;
    return 10;
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

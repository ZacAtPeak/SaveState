import 'dart:math';
import 'package:flutter/material.dart';
import '../data/app_settings.dart';
import '../data/database.dart';
import '../data/models.dart';
import 'initiative_card.dart';

class InitiativeStripWidget extends StatefulWidget {
  final Function(Entity)? onEntitySelected;

  const InitiativeStripWidget({super.key, this.onEntitySelected});

  @override
  State<InitiativeStripWidget> createState() => _InitiativeStripWidgetState();
}

class _InitiativeStripWidgetState extends State<InitiativeStripWidget> {
  List<InitiativeEntry> _initiativeEntries = [];
  int? _selectedEntityId;

  @override
  void initState() {
    super.initState();
    appSettings.addListener(_onSettingsChanged);
    _loadInitiativeEntries();
  }

  @override
  void dispose() {
    appSettings.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    _loadInitiativeEntries();
  }

  Future<void> _loadInitiativeEntries() async {
    final entries = await DatabaseHelper.instance.getInitiativeEntries();
    final selectedSystem = appSettings.selectedGameSystem;
    final systemId = selectedSystem?.id;

    final filteredEntries = systemId != null
        ? entries.where((e) {
            // We'll filter when we fetch entities
            return true;
          }).toList()
        : entries;

    final entities = await DatabaseHelper.instance.getAllEntities();
    final entityMap = {for (var e in entities) e.id: e};

    final filtered = filteredEntries.where((entry) {
      final entity = entityMap[entry.entityId];
      return entity != null && entity.gameSystemId == systemId;
    }).toList();

    setState(() {
      _initiativeEntries = filtered;
    });
  }

  Future<void> addToInitiative(Entity entity) async {
    // Roll initiative based on entity's value
    final initiativeValue = entity.initiative;

    final entry = InitiativeEntry(
      entityId: entity.id!,
      initiativeValue: initiativeValue,
      order: _initiativeEntries.length,
    );

    await DatabaseHelper.instance.addToInitiative(entry);
    await _loadInitiativeEntries();
  }

  Future<void> removeFromInitiative(int entityId) async {
    await DatabaseHelper.instance.removeFromInitiative(entityId);
    setState(() {
      if (_selectedEntityId == entityId) {
        _selectedEntityId = null;
      }
    });
    await _loadInitiativeEntries();
  }

  Future<void> reorderInitiative(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final entry = _initiativeEntries.removeAt(oldIndex);
    _initiativeEntries.insert(newIndex, entry);

    // Update order in database
    for (int i = 0; i < _initiativeEntries.length; i++) {
      await DatabaseHelper.instance.reorderInitiative(
        _initiativeEntries[i].entityId,
        i,
      );
    }

    await _loadInitiativeEntries();
  }

  Future<void> adjustHp(int entityId, int delta) async {
    final entity = await DatabaseHelper.instance.getEntity(entityId);
    if (entity != null) {
      final newHp = (entity.hp + delta).clamp(0, entity.maxHp);
      await DatabaseHelper.instance.updateEntity(
        entity.copyWith(hp: newHp),
      );
      await _loadInitiativeEntries();
    }
  }

  void _selectEntity(Entity entity) {
    setState(() {
      _selectedEntityId = entity.id;
    });
    widget.onEntitySelected?.call(entity);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and add button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                Icon(
                  Icons.sort,
                  size: 18,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  'Initiative',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                _AddEntityButton(onAdd: addToInitiative),
              ],
            ),
          ),
          const Divider(height: 1),
          // Horizontal scrolling list of initiative cards
          Expanded(
            child: _initiativeEntries.isEmpty
                ? Center(
                    child: Text(
                      'No entities in initiative\nTap + to add',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme.onSurfaceVariant,
                          ),
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: _initiativeEntries.length,
                    itemBuilder: (context, index) {
                      return _buildInitiativeCard(index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitiativeCard(int index) {
    return FutureBuilder<Entity?>(
      future: DatabaseHelper.instance.getEntity(
        _initiativeEntries[index].entityId,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox.shrink();
        }
        final entity = snapshot.data!;
        return InitiativeCard(
          entity: entity,
          isSelected: _selectedEntityId == entity.id,
          onTap: () => _selectEntity(entity),
          onRemove: () => removeFromInitiative(entity.id!),
          onHpAdjust: (delta) => adjustHp(entity.id!, delta),
        );
      },
    );
  }
}

class _AddEntityButton extends StatelessWidget {
  final Function(Entity) onAdd;

  const _AddEntityButton({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Entity>(
      icon: Icon(
        Icons.add_circle,
        color: Theme.of(context).colorScheme.primary,
      ),
      tooltip: 'Add to initiative',
      onSelected: onAdd,
      itemBuilder: (context) => [
        PopupMenuItem<Entity>(
          child: const Text('Select entity...'),
          onTap: () => _showEntityPicker(context),
        ),
      ],
    );
  }

  void _showEntityPicker(BuildContext context) async {
    final selectedSystem = appSettings.selectedGameSystem;
    List<Entity> entities;

    if (selectedSystem != null) {
      entities = await DatabaseHelper.instance.getEntitiesByGameSystem(selectedSystem.id!);
    } else {
      entities = await DatabaseHelper.instance.getAllEntities();
    }

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => _EntityPickerDialog(
        entities: entities,
        onSelect: (entity) {
          onAdd(entity);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

class _EntityPickerDialog extends StatefulWidget {
  final List<Entity> entities;
  final Function(Entity) onSelect;

  const _EntityPickerDialog({
    required this.entities,
    required this.onSelect,
  });

  @override
  State<_EntityPickerDialog> createState() => _EntityPickerDialogState();
}

class _EntityPickerDialogState extends State<_EntityPickerDialog> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.entities.where((e) {
      return e.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return AlertDialog(
      title: const Text('Add to Initiative'),
      content: SizedBox(
        width: 300,
        height: 400,
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search entities...',
                prefixIcon: Icon(Icons.search),
                isDense: true,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final entity = filtered[index];
                  return ListTile(
                    title: Text(entity.name),
                    subtitle: Text('HP: ${entity.hp}/${entity.maxHp}'),
                    trailing: Text('AC: ${entity.ac}'),
                    onTap: () => widget.onSelect(entity),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

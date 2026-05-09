import 'package:flutter/material.dart';
import '../data/database.dart';
import '../data/models.dart';
import 'detail_view.dart';

class EntityBrowserSheet extends StatelessWidget {
  const EntityBrowserSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.92,
          width: MediaQuery.of(context).size.width * 0.75,
          child: const EntityBrowserContent(),
        ),
      ),
    );
  }
}

void showEntityBrowserSheet(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) =>
        const EntityBrowserSheet(),
  );
}

class EntityBrowserContent extends StatefulWidget {
  const EntityBrowserContent({super.key});

  @override
  State<EntityBrowserContent> createState() => _EntityBrowserContentState();
}

class _EntityBrowserContentState extends State<EntityBrowserContent> {
  List<Entity> _entities = [];
  List<Entity> _filteredEntities = [];
  Entity? _selectedEntity;
  String _searchQuery = '';
  String _filterType = 'All';

  @override
  void initState() {
    super.initState();
    _loadEntities();
  }

  Future<void> _loadEntities() async {
    final entities = await DatabaseHelper.instance.getAllEntities();
    setState(() {
      _entities = entities;
      _filteredEntities = entities;
    });
  }

  void _filterEntities() {
    setState(() {
      _filteredEntities = _entities.where((entity) {
        final matchesSearch =
            entity.name.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesFilter = _filterType == 'All' ||
            (_filterType == 'Players' && entity.gameSystemId == 1) ||
            (_filterType == 'NPCs' && entity.gameSystemId == 2);
        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Entities'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _FilterOption(
              label: 'All',
              isSelected: _filterType == 'All',
              onTap: () {
                setState(() => _filterType = 'All');
                _filterEntities();
                Navigator.pop(context);
              },
            ),
            _FilterOption(
              label: 'Players',
              isSelected: _filterType == 'Players',
              onTap: () {
                setState(() => _filterType = 'Players');
                _filterEntities();
                Navigator.pop(context);
              },
            ),
            _FilterOption(
              label: 'NPCs',
              isSelected: _filterType == 'NPCs',
              onTap: () {
                setState(() => _filterType = 'NPCs');
                _filterEntities();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Row(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.33,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search entities...',
                                prefixIcon: const Icon(Icons.search),
                                isDense: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onChanged: (value) {
                                _searchQuery = value;
                                _filterEntities();
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.filter_list),
                            onPressed: _showFilterDialog,
                            tooltip: 'Filter',
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _entities.isEmpty
                          ? const Center(child: Text('No entities found'))
                          : ListView.builder(
                              itemCount: _filteredEntities.length,
                              itemBuilder: (context, index) {
                                final entity = _filteredEntities[index];
                                final isSelected =
                                    _selectedEntity?.id == entity.id;
                                return ListTile(
                                  selected: isSelected,
                                  selectedTileColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  title: Text(entity.name),
                                  subtitle: Text(
                                    'HP: ${entity.hp}/${entity.maxHp}',
                                  ),
                                  trailing: Text('AC: ${entity.ac}'),
                                  onTap: () {
                                    setState(() {
                                      _selectedEntity = entity;
                                    });
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: DetailViewWidget(
                  selectedEntity: _selectedEntity,
                  onEntityChanged: (entity) {
                    setState(() {
                      _selectedEntity = entity;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FilterOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: isSelected ? const Icon(Icons.check) : null,
      onTap: onTap,
    );
  }
}
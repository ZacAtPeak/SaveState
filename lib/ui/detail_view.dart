import 'package:flutter/material.dart';
import '../data/models.dart';

class DetailViewWidget extends StatefulWidget {
  final Entity? selectedEntity;
  final Function(Entity)? onEntityChanged;

  const DetailViewWidget({
    super.key,
    this.selectedEntity,
    this.onEntityChanged,
  });

  @override
  State<DetailViewWidget> createState() => _DetailViewWidgetState();
}

class _DetailViewWidgetState extends State<DetailViewWidget> {
  Entity? _entity;
  bool _isEditMode = false;

  @override
  void didUpdateWidget(DetailViewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedEntity != oldWidget.selectedEntity) {
      setState(() {
        _entity = widget.selectedEntity;
        _isEditMode = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_entity == null) {
      return Container(
        color: Theme.of(context).colorScheme.surface,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_outline,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'Select an entity to view details',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with name and edit toggle
            _buildHeader(context),
            const SizedBox(height: 24),
            // Stats cards
            _buildStatsSection(context),
            const SizedBox(height: 24),
            // Placeholder for full character sheet (Phase 2)
            _buildCharacterSheetPlaceholder(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        // Entity avatar
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              _entity!.name.isNotEmpty ? _entity!.name[0].toUpperCase() : '?',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Name and edit button
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _entity!.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                'Game System ID: ${_entity!.gameSystemId ?? "None"}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
        // Edit mode toggle
        IconButton(
          onPressed: () {
            setState(() {
              _isEditMode = !_isEditMode;
            });
          },
          icon: Icon(
            _isEditMode ? Icons.check : Icons.edit,
            color: _isEditMode
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          tooltip: _isEditMode ? 'Done editing' : 'Edit mode',
        ),
      ],
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    return Row(
      children: [
        _StatCard(
          label: 'HP',
          value: '${_entity!.hp}',
          maxValue: _entity!.maxHp,
          color: _getHpColor(_entity!.hp, _entity!.maxHp),
          icon: Icons.favorite,
          isEditMode: _isEditMode,
        ),
        const SizedBox(width: 12),
        _StatCard(
          label: 'AC',
          value: '${_entity!.ac}',
          color: Theme.of(context).colorScheme.primary,
          icon: Icons.shield,
          isEditMode: _isEditMode,
        ),
        const SizedBox(width: 12),
        _StatCard(
          label: 'Initiative',
          value: '${_entity!.initiative}',
          color: Theme.of(context).colorScheme.secondary,
          icon: Icons.sort,
          isEditMode: _isEditMode,
        ),
      ],
    );
  }

  Widget _buildCharacterSheetPlaceholder(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.description_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            'Character Sheet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Full character sheet editing coming in Phase 2',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
          ),
        ],
      ),
    );
  }

  Color _getHpColor(int hp, int maxHp) {
    if (maxHp <= 0) return Colors.grey;
    final ratio = hp / maxHp;
    if (ratio <= 0.25) return Colors.red;
    if (ratio <= 0.5) return Colors.orange;
    return Colors.green;
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final int? maxValue;
  final Color color;
  final IconData icon;
  final bool isEditMode;

  const _StatCard({
    required this.label,
    required this.value,
    this.maxValue,
    required this.color,
    required this.icon,
    required this.isEditMode,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              maxValue != null ? '$value / $maxValue' : value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

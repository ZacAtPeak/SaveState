import 'package:flutter/material.dart';
import '../data/models.dart';

class InitiativeCard extends StatelessWidget {
  final Entity entity;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final Function(int) onHpAdjust;
  final bool isDraggable;

  const InitiativeCard({
    super.key,
    required this.entity,
    required this.isSelected,
    required this.onTap,
    required this.onRemove,
    required this.onHpAdjust,
    this.isDraggable = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hpColor = _getHpColor(entity.hp, entity.maxHp);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with name and remove button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Row(
                children: [
                  if (isDraggable)
                    Icon(
                      Icons.drag_handle,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  Expanded(
                    child: Text(
                      entity.name,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  GestureDetector(
                    onTap: onRemove,
                    child: Icon(
                      Icons.close,
                      size: 14,
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // HP display with adjustment buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildHpButton(context, -1, Icons.remove),
                  const SizedBox(width: 4),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${entity.hp}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: hpColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '/ ${entity.maxHp}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  _buildHpButton(context, 1, Icons.add),
                ],
              ),
            ),
            // AC and Initiative values
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatBadge(context, 'AC', entity.ac.toString()),
                  _buildStatBadge(
                      context, 'INIT', entity.initiative.toString()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHpButton(BuildContext context, int delta, IconData icon) {
    return GestureDetector(
      onTap: () => onHpAdjust(delta),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 14),
      ),
    );
  }

  Widget _buildStatBadge(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 9,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 10,
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

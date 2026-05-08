import 'package:core/models/models.dart';
import 'package:flutter/material.dart';

class WikiTypePicker extends StatelessWidget {
  const WikiTypePicker({
    super.key,
    this.entityTypes,
    required this.onTypeSelected,
    required this.onCancel,
  });

  final List<EntityTypeSchema>? entityTypes;
  final ValueChanged<EntityTypeSchema> onTypeSelected;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final List<EntityTypeSchema> wikiTypes;
    if (entityTypes != null) {
      wikiTypes = entityTypes!
          .where((e) => e.isWikiPageType)
          .toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    } else {
      // Fallback: derive from WikiPageType enum for backward compatibility
      wikiTypes = WikiPageType.values.map(_entityFromPageType).toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Cancel',
                onPressed: onCancel,
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 8),
              Text('Choose page type', style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
            ),
            itemCount: wikiTypes.length,
            itemBuilder: (context, index) {
              final entity = wikiTypes[index];
              return Card(
                child: InkWell(
                  onTap: () => onTypeSelected(entity),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_iconForEntity(entity), size: 24),
                        const SizedBox(height: 8),
                        Text(entity.displayName, textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _iconForEntity(EntityTypeSchema entity) {
    switch (entity.key) {
      case 'creature':
        return Icons.pets;
      case 'spell':
        return Icons.auto_awesome;
      case 'item':
        return Icons.gavel;
      case 'rule':
        return Icons.menu_book;
      case 'location':
        return Icons.location_on;
      case 'npc':
        return Icons.person;
      case 'other':
        return Icons.article;
      default:
        return Icons.help_outline;
    }
  }

  /// Creates a synthetic EntityTypeSchema from a WikiPageType for backward compatibility.
  static EntityTypeSchema _entityFromPageType(WikiPageType type) {
    return EntityTypeSchema(
      key: type.name,
      displayName: type.displayName,
      isWikiPageType: true,
      fields: const [],
      sortOrder: type.index,
    );
  }
}

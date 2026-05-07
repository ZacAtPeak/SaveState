import 'package:core/models/models.dart';
import 'package:flutter/material.dart';

class WikiTypePicker extends StatelessWidget {
  const WikiTypePicker({
    super.key,
    required this.onTypeSelected,
    required this.onCancel,
  });

  final ValueChanged<WikiPageType> onTypeSelected;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final types = WikiPageType.values;
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
            itemCount: 8,
            itemBuilder: (context, index) {
              if (index >= types.length) return const SizedBox.shrink();
              final type = types[index];
              return Card(
                child: InkWell(
                  onTap: () => onTypeSelected(type),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_iconForType(type), size: 24),
                        const SizedBox(height: 8),
                        Text(type.displayName, textAlign: TextAlign.center),
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

  IconData _iconForType(WikiPageType type) {
    switch (type) {
      case WikiPageType.creature:
        return Icons.pets;
      case WikiPageType.spell:
        return Icons.auto_awesome;
      case WikiPageType.item:
        return Icons.gavel;
      case WikiPageType.rule:
        return Icons.menu_book;
      case WikiPageType.location:
        return Icons.location_on;
      case WikiPageType.npc:
        return Icons.person;
      case WikiPageType.other:
        return Icons.article;
    }
  }
}

import 'package:flutter/material.dart';

class WikiStatBlock extends StatelessWidget {
  const WikiStatBlock({super.key, required this.statBlock});

  final Map<String, dynamic> statBlock;

  @override
  Widget build(BuildContext context) {
    if (statBlock.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline,
                    size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('Stat Block', style: theme.textTheme.titleSmall),
              ],
            ),
            const Divider(),
            ...statBlock.entries.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        e.key,
                        style: theme.textTheme.labelMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(e.value.toString(),
                          style: theme.textTheme.bodyMedium),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

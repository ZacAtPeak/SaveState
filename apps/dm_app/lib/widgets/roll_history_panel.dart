import 'package:flutter/material.dart';

import 'initiative_tracker.dart';

class RollHistoryPanel extends StatelessWidget {
  const RollHistoryPanel({
    super.key,
    required this.history,
    required this.onClear,
  });

  final List<RollHistoryEntry> history;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
              child: Row(
                children: [
                  const Icon(Icons.casino),
                  const SizedBox(width: 8),
                  Text('Dice Rolls', style: theme.textTheme.titleMedium),
                  const Spacer(),
                  if (history.isNotEmpty)
                    TextButton(
                      onPressed: onClear,
                      child: const Text('Clear'),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: history.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'No rolls yet.\nDrag a combatant onto the initiative strip to roll.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                  : ListView.separated(
                      reverse: false,
                      itemCount: history.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final entry = history[history.length - 1 - i];
                        return _RollTile(entry: entry);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RollTile extends StatelessWidget {
  const _RollTile({required this.entry});

  final RollHistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final modSign = entry.modifier >= 0 ? '+' : '';
    return ListTile(
      dense: true,
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Text(
          '${entry.total}',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(entry.combatantName),
      subtitle: Text(
        'd20: ${entry.d20}  $modSign${entry.modifier}  →  ${entry.total}',
        style: theme.textTheme.bodySmall,
      ),
      trailing: Text(
        _formatTime(entry.timestamp),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  static String _formatTime(DateTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(t.hour)}:${two(t.minute)}:${two(t.second)}';
  }
}

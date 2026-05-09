import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:core/services/services.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameModelService = context.watch<GameModelService>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Game System Section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Game System',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          ...GameModelService.bundledSystems.map((system) {
            final (key, displayName, _) = system;
            final isSelected = gameModelService.activeSystemKey == key;
            return RadioListTile<String>(
              title: Text(displayName),
              value: key,
              groupValue: gameModelService.activeSystemKey,
              onChanged: (value) async {
                if (value == null) return;
                // Show migration dialog
                final shouldSwitch = await _showMigrationDialog(context, displayName);
                if (shouldSwitch) {
                  await gameModelService.switchToSystem(value);
                }
              },
            );
          }),
          const Divider(),
          // About section
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About SaveState'),
            subtitle: const Text('Version 1.0'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'SaveState',
                applicationVersion: '1.0.0',
                applicationLegalese: 'A TTRPG companion app',
              );
            },
          ),
        ],
      ),
    );
  }

  Future<bool> _showMigrationDialog(BuildContext context, String systemName) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Switch to $systemName?'),
        content: const Text(
          'Switching game systems may affect how your wiki entries are displayed. '
          'Existing wiki data will be preserved.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Switch'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
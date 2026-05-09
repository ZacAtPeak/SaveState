import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:core/services/services.dart';

/// Settings screen with game system selector and import functionality.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gameModelService = context.watch<GameModelService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Bundled Systems Section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Game System',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          ...gameModelService.bundledSystems.map((system) {
            final (key, displayName, assetPath) = system;
            return RadioListTile<String>(
              title: Text(displayName),
              subtitle: Text(key),
              value: key,
              groupValue: gameModelService.activeSystemKey ?? 'dnd5e',
              onChanged: (value) async {
                if (value != null) {
                  await gameModelService.loadFromAsset(assetPath);
                }
              },
            );
          }),

          const Divider(),

          // Custom Systems Section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Custom Systems',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Import Game System'),
            subtitle: const Text('Load a .json GameModel file'),
            onTap: () => _importCustomSystem(context),
          ),

          // Show imported systems if any
          ...gameModelService.availableSystems
              .where((s) => s.assetPath == null) // imported systems have null assetPath
              .map((system) {
            final (key, displayName, _) = system;
            return ListTile(
              leading: const Icon(Icons.folder_open),
              title: Text(displayName),
              subtitle: Text('Imported: $key'),
              onTap: () async {
                await gameModelService.loadFromDocumentsDirectory(key);
              },
            );
          }),
        ],
      ),
    );
  }

  Future<void> _importCustomSystem(BuildContext context) async {
    final gameModelService = context.read<GameModelService>();

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      if (file.path == null) return;

      // Read file contents
      final jsonString = await File(file.path!).readAsString();

      // Import and store
      final filename = await gameModelService.importExternalFile(
        jsonString,
        file.name,
      );

      // Load it
      await gameModelService.loadFromDocumentsDirectory(filename);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Imported ${file.name} successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on FormatException catch (e) {
      // Validation/parse error — show AlertDialog per D-40
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Import Failed'),
            content: Text(e.message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Import Failed'),
            content: Text('An unexpected error occurred: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }
}
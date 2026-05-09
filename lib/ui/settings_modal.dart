import 'package:flutter/material.dart';
import '../data/app_settings.dart';
import '../data/models.dart';

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: const SettingsContent(),
        ),
      ),
    );
  }
}

void showSettingsSheet(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) =>
        const SettingsSheet(),
  );
}

class SettingsContent extends StatefulWidget {
  const SettingsContent({super.key});

  @override
  State<SettingsContent> createState() => _SettingsContentState();
}

class _SettingsContentState extends State<SettingsContent> {
  GameSystem? _selectedSystem;

  @override
  void initState() {
    super.initState();
    _selectedSystem = appSettings.selectedGameSystem;
  }

  @override
  Widget build(BuildContext context) {
    final gameSystems = appSettings.gameSystems;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Icon(
                Icons.settings,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Text(
                'Settings',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Game System',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ),
                ...gameSystems.map((system) {
                  final isSelected = _selectedSystem?.id == system.id;
                  return ListTile(
                    title: Text(system.name),
                    subtitle: system.initiativeRule != null
                        ? Text(
                            system.initiativeRule!,
                            style: Theme.of(context).textTheme.bodySmall,
                          )
                        : null,
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                    onTap: () {
                      appSettings.setGameSystem(system);
                      setState(() {
                        _selectedSystem = system;
                      });
                    },
                  );
                }),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
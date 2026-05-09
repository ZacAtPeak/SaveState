import 'package:flutter/material.dart';
import '../data/models.dart';
import 'initiative_strip.dart';
import 'settings_modal.dart';
import 'sidebar.dart';
import 'detail_view.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  Entity? _selectedEntity;

  void _onEntitySelected(Entity entity) {
    setState(() {
      _selectedEntity = entity;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 56,
        title: Row(
          children: [
            Icon(
              Icons.shield,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'DM Screen',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        actions: [
          _TopBarButton(icon: Icons.casino, tooltip: 'Dice', onTap: () {}),
          _TopBarButton(icon: Icons.search, tooltip: 'Search', onTap: () {}),
          _TopBarButton(icon: Icons.settings, tooltip: 'Settings', onTap: () => showSettingsSheet(context)),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 768) {
            return const Center(
              child: Text('Minimum window width is 768px'),
            );
          }

          return Row(
            children: [
              SizedBox(
                width: 250,
                child: SidebarWidget(onEntitySelected: _onEntitySelected),
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: Column(
                  children: [
                    SizedBox(
                      height: 180,
                      child: InitiativeStripWidget(
                        onEntitySelected: _onEntitySelected,
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: DetailViewWidget(
                        selectedEntity: _selectedEntity,
                        onEntityChanged: _onEntitySelected,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TopBarButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _TopBarButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Tooltip(
            message: tooltip,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(icon, size: 22),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../data/models.dart';
import '../data/database.dart';
import 'initiative_strip.dart';
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Minimum window width: 768px
          if (constraints.maxWidth < 768) {
            return const Center(
              child: Text('Minimum window width is 768px'),
            );
          }

          return Row(
            children: [
              // Left: Sidebar (~250px fixed)
              SizedBox(
                width: 250,
                child: SidebarWidget(onEntitySelected: _onEntitySelected),
              ),
              const VerticalDivider(width: 1),
              // Right: Column with initiative strip + detail view
              Expanded(
                child: Column(
                  children: [
                    // Initiative strip (~120px high, ~1/3 of remaining)
                    SizedBox(
                      height: 120,
                      child: InitiativeStripWidget(
                        onEntitySelected: _onEntitySelected,
                      ),
                    ),
                    const Divider(height: 1),
                    // Detail view (expanded, ~2/3 of remaining)
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

import 'package:flutter/material.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

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
              const SizedBox(
                width: 250,
                child: SidebarWidget(),
              ),
              const VerticalDivider(width: 1),
              // Right: Column with initiative strip + detail view
              Expanded(
                child: Column(
                  children: [
                    // Initiative strip (~120px high, ~1/3 of remaining)
                    const SizedBox(
                      height: 120,
                      child: InitiativeStripWidget(),
                    ),
                    const Divider(height: 1),
                    // Detail view (expanded, ~2/3 of remaining)
                    const Expanded(
                      child: DetailViewWidget(),
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

// Placeholder widgets - implemented in subsequent tasks
class SidebarWidget extends StatelessWidget {
  const SidebarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Center(
        child: Text('Sidebar'),
      ),
    );
  }
}

class InitiativeStripWidget extends StatelessWidget {
  const InitiativeStripWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: const Center(
        child: Text('Initiative Strip'),
      ),
    );
  }
}

class DetailViewWidget extends StatelessWidget {
  const DetailViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: const Center(
        child: Text('Detail View'),
      ),
    );
  }
}

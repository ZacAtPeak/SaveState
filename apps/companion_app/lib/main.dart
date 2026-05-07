import 'dart:io';

import 'package:flutter/material.dart';
import 'package:core/services/services.dart';
import 'package:core/wiki/wiki.dart';
import 'package:companion_app/widgets/generic_tab_view.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const CompanionApp());
}

class CompanionApp extends StatefulWidget {
  const CompanionApp({super.key});

  @override
  State<CompanionApp> createState() => _CompanionAppState();
}

class _CompanionAppState extends State<CompanionApp> {
  late final WikiProvider _wikiProvider;

  @override
  void initState() {
    super.initState();
    _wikiProvider = WikiProvider(
      storage: WikiStorageService(baseDirectory: Directory.current),
    );
    _wikiProvider.loadAll();
  }

  @override
  void dispose() {
    _wikiProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<WikiProvider>.value(
      value: _wikiProvider,
      child: MaterialApp(
        title: 'SaveState Companion',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SaveState Companion'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book),
            tooltip: 'Wiki',
            onPressed: () {
              final wikiProvider = context.read<WikiProvider>();
              WikiModalShell.show(
                context,
                provider: WikiModalProvider(),
                pages: wikiProvider.pages,
              );
            },
          ),
        ],
      ),
      body: GenericTabView(
        tabs: [
          TabData(
            label: 'Characters',
            icon: const Icon(Icons.people),
            content: const Center(child: Text('Characters Screen')),
          ),
          TabData(
            label: 'Inventory',
            icon: const Icon(Icons.inventory),
            content: const Center(child: Text('Inventory Screen')),
          ),
          TabData(
            label: 'Spells',
            icon: const Icon(Icons.auto_awesome),
            content: const Center(child: Text('Spells Screen')),
          ),
        ],
      ),
    );
  }
}

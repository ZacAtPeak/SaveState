import 'dart:async';
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
  late final GameModelService _gameModelService;

  @override
  void initState() {
    super.initState();
    _gameModelService = GameModelService();
    _gameModelService.loadFromAsset('packages/core/assets/game_models/dnd5e.json');
    _wikiProvider = WikiProvider(
      storage: WikiStorageService(baseDirectory: Directory.current),
    );
    unawaited(_initializeWiki());
  }

  Future<void> _initializeWiki() async {
    // Run startup migration before first wiki load.
    await _wikiProvider.runStartupMigration();
    await _wikiProvider.loadAll();
  }

  @override
  void dispose() {
    _gameModelService.dispose();
    _wikiProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _gameModelService),
        ChangeNotifierProxyProvider<GameModelService, WikiProvider>(
          create: (_) => _wikiProvider,
          update: (_, gameModelService, wikiProvider) {
            wikiProvider!.updateGameModel(gameModelService.activeModel);
            return wikiProvider;
          },
        ),
      ],
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
              final gameModel = context.read<GameModelService>().activeModel;
              WikiModalShell.show(
                context,
                provider: WikiModalProvider(),
                pages: wikiProvider.pages,
                gameModel: gameModel,
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

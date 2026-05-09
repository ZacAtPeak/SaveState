import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:core/models/models.dart';
import 'package:core/services/services.dart';
import 'package:core/wiki/wiki.dart';
import 'package:companion_app/widgets/generic_tab_view.dart';
import 'package:companion_app/screens/character_sheet_screen.dart';
import 'package:companion_app/screens/settings_screen.dart';
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
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
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
            content: const _CharacterListScreen(),
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

class _CharacterListScreen extends StatefulWidget {
  const _CharacterListScreen();

  @override
  State<_CharacterListScreen> createState() => _CharacterListScreenState();
}

class _CharacterListScreenState extends State<_CharacterListScreen> {
  final List<GameEntity> _characters = [];

  void _createCharacter() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CharacterSheetScreen(
          character: null,
          onSave: (entity) {
            setState(() => _characters.add(entity));
            Navigator.of(context).pop();
          },
          onCancel: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  void _editCharacter(GameEntity character) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CharacterSheetScreen(
          character: character,
          onSave: (entity) {
            setState(() {
              final index = _characters.indexWhere(
                (c) => c.getString('id') == entity.getString('id'),
              );
              if (index >= 0) _characters[index] = entity;
            });
            Navigator.of(context).pop();
          },
          onCancel: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: _characters.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('No characters yet', style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to create your first character',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _characters.length,
              itemBuilder: (context, index) {
                final char = _characters[index];
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(
                    char.getString('name', fallback: 'Unnamed Character'),
                  ),
                  subtitle: Text(
                    char.getString(
                      'playerClass',
                      fallback: char.getString('race', fallback: ''),
                    ),
                  ),
                  onTap: () => _editCharacter(char),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createCharacter,
        child: const Icon(Icons.add),
      ),
    );
  }
}

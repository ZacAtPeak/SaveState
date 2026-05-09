import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_model.dart';
import '../models/game_model_parser.dart';

class GameModelService extends ChangeNotifier {
  GameModel? _activeModel;
  String _activeSystemKey = 'dnd5e';
  static const String _prefsKey = 'activeGameSystem';

  GameModel? get activeModel => _activeModel;
  bool get isLoaded => _activeModel != null;
  String get activeSystemKey => _activeSystemKey;

  /// List of bundled game systems available.
  static const bundledSystems = [
    ('dnd5e', 'D&D 5e', 'packages/core/assets/game_models/dnd5e.json'),
    ('coc7e', 'Call of Cthulhu 7e', 'packages/core/assets/game_models/coc7e.json'),
  ];

  GameModelService() {
    _loadPersistedSystem();
  }

  Future<void> _loadPersistedSystem() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_prefsKey);
      if (stored != null) {
        _activeSystemKey = stored;
      }
      // Load the persisted (or default) system
      await loadFromAsset(_assetPathForSystem(_activeSystemKey));
    } catch (e) {
      debugPrint('GameModelService: failed to load persisted system: $e');
      // Fallback to default
      await loadFromAsset('packages/core/assets/game_models/dnd5e.json');
    }
  }

  String _assetPathForSystem(String systemKey) {
    switch (systemKey) {
      case 'coc7e':
        return 'packages/core/assets/game_models/coc7e.json';
      default:
        return 'packages/core/assets/game_models/dnd5e.json';
    }
  }

  Future<void> loadFromAsset(String assetPath) async {
    try {
      final jsonString = await rootBundle.loadString(assetPath);
      _activeModel = GameModelParser.parse(jsonString);
      // Derive system key from asset path
      if (assetPath.contains('coc7e')) {
        _activeSystemKey = 'coc7e';
      } else {
        _activeSystemKey = 'dnd5e';
      }
      notifyListeners();
    } on FormatException catch (e) {
      debugPrint('GameModelService: failed to parse $assetPath: $e');
    }
  }

  /// Switch to a different bundled system by its key ('dnd5e' or 'coc7e').
  Future<void> switchToSystem(String systemKey) async {
    if (systemKey == _activeSystemKey) return;
    final path = _assetPathForSystem(systemKey);
    await loadFromAsset(path);
    // Persist
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, systemKey);
    } catch (e) {
      debugPrint('GameModelService: failed to persist system: $e');
    }
  }

  /// Sets the active model directly (for testing).
  void setActiveModelForTesting(GameModel model) {
    _activeModel = model;
    notifyListeners();
  }
}
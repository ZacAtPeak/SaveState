import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_model.dart';
import '../models/game_model_parser.dart';
import 'game_model_validator.dart';

class GameModelService extends ChangeNotifier {
  GameModel? _activeModel;
  String _activeSystemKey = 'dnd5e';
  static const String _prefsKey = 'activeGameSystem';

  GameModel? get activeModel => _activeModel;
  bool get isLoaded => _activeModel != null;
  String get activeSystemKey => _activeSystemKey;

  /// Map of imported (non-bundled) system keys to their file paths in documents directory.
  final Map<String, String> _importedSystems = {};

  /// Get all available systems: bundled + imported.
  List<(String key, String displayName, String? assetPath)> get availableSystems {
    final imported = _importedSystems.entries
        .map((e) => (e.key, e.key, null as String?)) // displayName = key for imported
        .toList();
    return [...bundledSystems, ...imported];
  }

  /// Bundled systems (D&D 5e and Call of Cthulhu 7e).
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

  /// Load a GameModel from a file in the app documents directory.
  Future<void> loadFromDocumentsDirectory(String filename) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File(path.join(directory.path, filename));
      if (!await file.exists()) {
        debugPrint('GameModelService: file not found $filename');
        return;
      }
      final jsonString = await file.readAsString();
      _activeModel = GameModelParser.parse(jsonString);
      _activeSystemKey = path.basenameWithoutExtension(filename);
      notifyListeners();
    } on FormatException catch (e) {
      debugPrint('GameModelService: failed to parse $filename: $e');
      rethrow;
    }
  }

  /// Import and persist an external JSON file to documents directory.
  /// Returns the system key (filename without extension).
  Future<String> importExternalFile(String jsonString, String originalFilename) async {
    // Validate first
    final result = GameModelValidator().validate(jsonString);
    if (result is GameModelValidationFailure) {
      throw FormatException(result.message);
    }

    // Generate filename: sanitize original filename, use timestamp to avoid collisions
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final baseName = path.basenameWithoutExtension(originalFilename)
        .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')
        .toLowerCase();
    final filename = '${baseName}_$timestamp.json';

    // Store in documents directory
    final directory = await getApplicationDocumentsDirectory();
    final file = File(path.join(directory.path, filename));
    await file.writeAsString(jsonString);

    // Track it
    _importedSystems[filename] = filename;

    return filename;
  }

  /// Sets the active model directly (for testing).
  void setActiveModelForTesting(GameModel model) {
    _activeModel = model;
    notifyListeners();
  }
}
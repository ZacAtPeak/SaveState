import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/game_model.dart';
import '../models/game_model_parser.dart';

class GameModelService extends ChangeNotifier {
  GameModel? _activeModel;
  GameModel? get activeModel => _activeModel;
  bool get isLoaded => _activeModel != null;

  Future<void> loadFromAsset(String assetPath) async {
    try {
      final jsonString = await rootBundle.loadString(assetPath);
      _activeModel = GameModelParser.parse(jsonString);
      notifyListeners();
    } on FormatException catch (e) {
      debugPrint('GameModelService: failed to parse $assetPath: $e');
    }
  }

  /// Sets the active model directly (for testing).
  void setActiveModelForTesting(GameModel model) {
    _activeModel = model;
    notifyListeners();
  }
}

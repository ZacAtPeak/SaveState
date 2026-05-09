import 'package:flutter/material.dart';
import '../data/database.dart';
import '../data/models.dart';

class AppSettings extends ChangeNotifier {
  GameSystem? _selectedGameSystem;
  List<GameSystem> _gameSystems = [];

  GameSystem? get selectedGameSystem => _selectedGameSystem;
  List<GameSystem> get gameSystems => _gameSystems;

  Future<void> initialize() async {
    _gameSystems = await DatabaseHelper.instance.getAllGameSystems();
    if (_gameSystems.isNotEmpty) {
      _selectedGameSystem = _gameSystems.firstWhere(
        (s) => s.name == 'D&D 5e',
        orElse: () => _gameSystems.first,
      );
    }
    notifyListeners();
  }

  void setGameSystem(GameSystem system) {
    _selectedGameSystem = system;
    notifyListeners();
  }
}

final appSettings = AppSettings();
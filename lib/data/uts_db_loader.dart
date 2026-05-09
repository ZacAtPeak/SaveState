import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'database.dart';
import 'models.dart';

class UtsDbLoader {
  static Database? _utsDb;

  static Future<void> loadDemoData() async {
    final db = await DatabaseHelper.instance.database;

    // Check if demo data already loaded
    final existingEntities = await db.query('entities', limit: 1);
    if (existingEntities.isNotEmpty) {
      return; // Demo data already loaded
    }

    // Try to open UTS.db
    try {
      final utsDbPath = join('lib', 'UTS.db');
      if (!await File(utsDbPath).exists()) {
        // Graceful degradation: UTS.db doesn't exist
        await _loadBuiltInDemoData(db);
        return;
      }

      final dbPath = await getDatabasesPath();
      final utsFullPath = join(dbPath, 'UTS.db');

      // Copy UTS.db to app's database directory if not already there
      if (!await File(utsFullPath).exists()) {
        await File(utsDbPath).copy(utsFullPath);
      }

      _utsDb = await openDatabase(utsFullPath, readOnly: true);

      // Query tables to understand schema
      final tables = await _queryTables();

      // Load data based on detected schema
      await _loadFromUtsDb(db, tables);

      await _utsDb?.close();
    } catch (e) {
      // Graceful degradation on any error
      await _loadBuiltInDemoData(db);
    }
  }

  static Future<List<Map<String, dynamic>>> _queryTables() async {
    if (_utsDb == null) return [];

    try {
      return await _utsDb!.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
      );
    } catch (e) {
      return [];
    }
  }

  static Future<void> _loadFromUtsDb(
    Database appDb,
    List<Map<String, dynamic>> tables,
  ) async {
    if (_utsDb == null) return;

    // Load game systems
    final gameSystems = await _loadGameSystems();
    for (final system in gameSystems) {
      await appDb.insert('game_systems', system.toMap());
    }

    // Load entities from each detected table
    for (final table in tables) {
      final tableName = table['name'] as String;
      if (!_isEntityTable(tableName)) continue;

      final entities = await _loadEntitiesFromTable(tableName);
      for (final entity in entities) {
        await appDb.insert('entities', entity.toMap());
      }
    }
  }

  static bool _isEntityTable(String tableName) {
    final excluded = ['game_systems', 'initiative_entries', 'roll_history'];
    return !excluded.contains(tableName);
  }

  static Future<List<GameSystem>> _loadGameSystems() async {
    if (_utsDb == null) return [];

    // Default game systems for D&D style games
    return [
      GameSystem(name: 'D&D 5e', initiativeRule: 'd20 + DEX'),
      GameSystem(name: 'Pathfinder 2e', initiativeRule: 'd20 + DEX'),
      GameSystem(name: 'Call of Cthulhu', initiativeRule: 'flat'),
      GameSystem(name: 'Warhammer Fantasy', initiativeRule: 'flat'),
      GameSystem(name: 'Starfinder', initiativeRule: 'd20 + DEX'),
      GameSystem(name: 'Basic Role Playing', initiativeRule: 'd100'),
    ];
  }

  static Future<List<Entity>> _loadEntitiesFromTable(String tableName) async {
    if (_utsDb == null) return [];

    try {
      // Try generic loading - adapt based on actual schema
      final rows = await _utsDb!.query(tableName, limit: 20);

      return rows.map((row) {
        // Try to map common field names
        return Entity(
          name: _extractField(row, ['name', 'Name', 'NAME', 'entity_name']) ?? 'Unknown',
          gameSystemId: 1, // Default to first game system
          hp: _extractIntField(row, ['hp', 'HP', 'health', 'Health']) ?? 0,
          maxHp: _extractIntField(row, ['max_hp', 'maxHp', 'HP_max', 'max_health']) ??
              _extractIntField(row, ['hp', 'HP', 'health', 'Health']) ??
              0,
          ac: _extractIntField(row, ['ac', 'AC', 'armor', 'Armor']) ?? 10,
          initiative: _extractIntField(row, ['initiative', 'Initiative', 'init']) ?? 0,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  static String? _extractField(Map<String, dynamic> row, List<String> keys) {
    for (final key in keys) {
      if (row.containsKey(key) && row[key] != null) {
        return row[key].toString();
      }
    }
    return null;
  }

  static int? _extractIntField(Map<String, dynamic> row, List<String> keys) {
    for (final key in keys) {
      if (row.containsKey(key) && row[key] != null) {
        if (row[key] is int) return row[key];
        return int.tryParse(row[key].toString());
      }
    }
    return null;
  }

  static Future<void> _loadBuiltInDemoData(Database db) async {
    // Insert default game systems
    final gameSystems = [
      GameSystem(name: 'D&D 5e', initiativeRule: 'd20 + DEX'),
      GameSystem(name: 'Pathfinder 2e', initiativeRule: 'd20 + DEX'),
      GameSystem(name: 'Call of Cthulhu', initiativeRule: 'flat'),
      GameSystem(name: 'Warhammer Fantasy', initiativeRule: 'flat'),
      GameSystem(name: 'Starfinder', initiativeRule: 'd20 + DEX'),
      GameSystem(name: 'Basic Role Playing', initiativeRule: 'd100'),
    ];

    for (final system in gameSystems) {
      await db.insert('game_systems', system.toMap());
    }

    // Insert sample entities for demo
    final demoEntities = [
      Entity(
        name: 'Goblin',
        gameSystemId: 1,
        hp: 7,
        maxHp: 7,
        ac: 15,
        initiative: 14,
      ),
      Entity(
        name: 'Orc Warrior',
        gameSystemId: 1,
        hp: 15,
        maxHp: 15,
        ac: 13,
        initiative: 12,
      ),
      Entity(
        name: 'Dragon (Young Red)',
        gameSystemId: 1,
        hp: 178,
        maxHp: 178,
        ac: 18,
        initiative: 12,
      ),
      Entity(
        name: 'Troll',
        gameSystemId: 1,
        hp: 84,
        maxHp: 84,
        ac: 15,
        initiative: 11,
      ),
      Entity(
        name: 'Displacer Beast',
        gameSystemId: 1,
        hp: 52,
        maxHp: 52,
        ac: 13,
        initiative: 15,
      ),
      Entity(
        name: 'Lich',
        gameSystemId: 1,
        hp: 135,
        maxHp: 135,
        ac: 17,
        initiative: 16,
      ),
    ];

    for (final entity in demoEntities) {
      await db.insert('entities', entity.toMap());
    }
  }
}

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('savestate.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE entities (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        gameSystemId INTEGER,
        hp INTEGER DEFAULT 0,
        maxHp INTEGER DEFAULT 0,
        ac INTEGER DEFAULT 10,
        initiative INTEGER DEFAULT 0,
        isBookmarked INTEGER DEFAULT 0,
        lastViewedAt TEXT,
        fieldLayout TEXT,
        createdAt TEXT,
        updatedAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE game_systems (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        initiativeRule TEXT,
        entityFields TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE initiative_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entityId INTEGER NOT NULL,
        initiativeValue INTEGER NOT NULL,
        combatId INTEGER,
        `order` INTEGER DEFAULT 0,
        FOREIGN KEY (entityId) REFERENCES entities(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE roll_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entityId INTEGER NOT NULL,
        rollType TEXT NOT NULL,
        rollValue INTEGER NOT NULL,
        target INTEGER,
        rolledAt TEXT,
        FOREIGN KEY (entityId) REFERENCES entities(id)
      )
    ''');
  }

  // Entity CRUD
  Future<int> insertEntity(Entity entity) async {
    final db = await database;
    return await db.insert('entities', entity.toMap());
  }

  Future<List<Entity>> getAllEntities() async {
    final db = await database;
    final result = await db.query('entities');
    return result.map((map) => Entity.fromMap(map)).toList();
  }

  Future<Entity?> getEntity(int id) async {
    final db = await database;
    final result = await db.query(
      'entities',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return Entity.fromMap(result.first);
  }

  Future<int> updateEntity(Entity entity) async {
    final db = await database;
    return await db.update(
      'entities',
      entity.toMap(),
      where: 'id = ?',
      whereArgs: [entity.id],
    );
  }

  Future<int> deleteEntity(int id) async {
    final db = await database;
    return await db.delete(
      'entities',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Entity>> getBookmarkedEntities() async {
    final db = await database;
    final result = await db.query(
      'entities',
      where: 'isBookmarked = 1',
    );
    return result.map((map) => Entity.fromMap(map)).toList();
  }

  Future<List<Entity>> getRecentEntities({int limit = 10}) async {
    final db = await database;
    final result = await db.query(
      'entities',
      where: 'lastViewedAt IS NOT NULL',
      orderBy: 'lastViewedAt DESC',
      limit: limit,
    );
    return result.map((map) => Entity.fromMap(map)).toList();
  }

  Future<void> markEntityViewed(int entityId) async {
    final db = await database;
    await db.update(
      'entities',
      {'lastViewedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [entityId],
    );
  }

  Future<void> toggleBookmark(int entityId) async {
    final db = await database;
    final entity = await getEntity(entityId);
    if (entity != null) {
      await db.update(
        'entities',
        {'isBookmarked': entity.isBookmarked ? 0 : 1},
        where: 'id = ?',
        whereArgs: [entityId],
      );
    }
  }

  // Initiative CRUD
  Future<int> addToInitiative(InitiativeEntry entry) async {
    final db = await database;
    return await db.insert('initiative_entries', entry.toMap());
  }

  Future<List<InitiativeEntry>> getInitiativeEntries({int? combatId}) async {
    final db = await database;
    final result = await db.query(
      'initiative_entries',
      where: combatId != null ? 'combatId = ?' : null,
      whereArgs: combatId != null ? [combatId] : null,
      orderBy: '`order` ASC',
    );
    return result.map((map) => InitiativeEntry.fromMap(map)).toList();
  }

  Future<int> removeFromInitiative(int entityId) async {
    final db = await database;
    return await db.delete(
      'initiative_entries',
      where: 'entityId = ?',
      whereArgs: [entityId],
    );
  }

  Future<void> reorderInitiative(int entityId, int newOrder) async {
    final db = await database;
    await db.update(
      'initiative_entries',
      {'order': newOrder},
      where: 'entityId = ?',
      whereArgs: [entityId],
    );
  }

  // Game System CRUD
  Future<int> insertGameSystem(GameSystem system) async {
    final db = await database;
    return await db.insert('game_systems', system.toMap());
  }

  Future<List<GameSystem>> getAllGameSystems() async {
    final db = await database;
    final result = await db.query('game_systems');
    return result.map((map) => GameSystem.fromMap(map)).toList();
  }

  // Roll History
  Future<int> insertRollHistory(RollHistory roll) async {
    final db = await database;
    return await db.insert('roll_history', roll.toMap());
  }

  Future<List<RollHistory>> getRollHistoryForEntity(int entityId) async {
    final db = await database;
    final result = await db.query(
      'roll_history',
      where: 'entityId = ?',
      whereArgs: [entityId],
      orderBy: 'rolledAt DESC',
    );
    return result.map((map) => RollHistory.fromMap(map)).toList();
  }
}

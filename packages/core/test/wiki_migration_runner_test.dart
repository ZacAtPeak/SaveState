import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:core/migrations/wiki_migration_runner.dart';

void main() {
  late Directory tempDir;
  late Directory pagesDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('wiki_migration_test_');
    pagesDir = Directory(path.join(tempDir.path, 'wiki', 'pages'));
    pagesDir.createSync(recursive: true);
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  /// Helper: write a raw JSON fixture to wiki/pages/
  void _writeFixture(String filename, Map<String, dynamic> data) {
    final file = File(path.join(pagesDir.path, filename));
    file.writeAsStringSync(jsonEncode(data));
  }

  /// Helper: read back raw JSON from wiki/pages/
  Map<String, dynamic> _readFixture(String filename) {
    final file = File(path.join(pagesDir.path, filename));
    return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  }

  group('WikiMigrationRunner legacy pageType -> entityTypeKey', () {
    test('rewrites legacy pageType to entityTypeKey for known type', () async {
      // Fixture: legacy file with pageType: creature
      _writeFixture('page-1.json', {
        'id': 'page-1',
        'title': 'Goblin',
        'pageType': 'creature',
        'body': 'A small humanoid creature.',
        'tags': ['monster'],
        'aliases': [],
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'statBlock': {},
      });

      final runner = WikiMigrationRunner(pagesDirectory: pagesDir);
      final result = await runner.run();

      // D-01: entityTypeKey present, pageType removed
      final migrated = _readFixture('page-1.json');
      expect(migrated['entityTypeKey'], equals('creature'),
          reason: 'entityTypeKey should be set to "creature"');
      expect(migrated.containsKey('pageType'), isFalse,
          reason: 'pageType key should be removed after migration');

      // Should report 1 migrated
      expect(result.migratedCount, equals(1));
      expect(result.warningCount, equals(0));
    });

    test('skips unknown legacy type with warning count increment', () async {
      // D-03: unknown type skipped with warning, no crash
      _writeFixture('page-unknown.json', {
        'id': 'page-unknown',
        'title': 'Unknown Thing',
        'pageType': 'totallyUnknownType',
        'body': 'Something weird.',
        'tags': [],
        'aliases': [],
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'statBlock': {},
      });

      final runner = WikiMigrationRunner(pagesDirectory: pagesDir);
      final result = await runner.run();

      // File should be untouched
      final unchanged = _readFixture('page-unknown.json');
      expect(unchanged['pageType'], equals('totallyUnknownType'),
          reason: 'Unknown type file should remain unchanged');
      expect(unchanged.containsKey('entityTypeKey'), isFalse,
          reason: 'entityTypeKey should NOT be added for unknown types');

      // Warning count incremented
      expect(result.warningCount, equals(1));
      expect(result.migratedCount, equals(0));
    });

    test('migration is idempotent: second run produces 0 migrations', () async {
      // D-06: idempotent, runs each launch without marker gating
      _writeFixture('page-idem.json', {
        'id': 'page-idem',
        'title': 'Fireball',
        'pageType': 'spell',
        'body': 'A spell.',
        'tags': ['evocation'],
        'aliases': [],
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'statBlock': {},
      });

      final runner = WikiMigrationRunner(pagesDirectory: pagesDir);

      // First run: migrates
      final firstResult = await runner.run();
      expect(firstResult.migratedCount, equals(1));

      final afterFirst = _readFixture('page-idem.json');
      expect(afterFirst['entityTypeKey'], equals('spell'));
      expect(afterFirst.containsKey('pageType'), isFalse);

      // Second run: already migrated, should do nothing
      final secondResult = await runner.run();
      expect(secondResult.migratedCount, equals(0),
          reason: 'Second run should find nothing to migrate');
      expect(secondResult.warningCount, equals(0));

      // File content unchanged after second run
      final afterSecond = _readFixture('page-idem.json');
      expect(afterSecond, equals(afterFirst),
          reason: 'File content should be identical after second run');
    });

    test('skips malformed JSON files with warning', () async {
      // T-08-01: per-file decode errors caught, skipped, continued
      final malformedFile = File(path.join(pagesDir.path, 'bad.json'));
      malformedFile.writeAsStringSync('{invalid json content');

      final runner = WikiMigrationRunner(pagesDirectory: pagesDir);
      final result = await runner.run();

      expect(result.warningCount, equals(1));
      expect(result.migratedCount, equals(0));
    });

    test('migrates all known legacy types', () async {
      final knownTypes = ['creature', 'spell', 'item', 'rule', 'location', 'npc', 'other'];

      for (final type in knownTypes) {
        _writeFixture('page-$type.json', {
          'id': 'page-$type',
          'title': 'Test $type',
          'pageType': type,
          'body': '',
          'tags': [],
          'aliases': [],
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
          'statBlock': {},
        });
      }

      final runner = WikiMigrationRunner(pagesDirectory: pagesDir);
      final result = await runner.run();

      expect(result.migratedCount, equals(knownTypes.length));
      expect(result.warningCount, equals(0));

      for (final type in knownTypes) {
        final migrated = _readFixture('page-$type.json');
        expect(migrated['entityTypeKey'], equals(type),
            reason: '$type should be migrated to entityTypeKey');
        expect(migrated.containsKey('pageType'), isFalse,
            reason: 'pageType should be removed for $type');
      }
    });
  });
}

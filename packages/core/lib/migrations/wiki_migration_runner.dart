import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

/// Result of a single WikiMigrationRunner execution.
class MigrationResult {
  const MigrationResult({
    required this.migratedCount,
    required this.warningCount,
  });

  /// Number of files successfully migrated from pageType to entityTypeKey.
  final int migratedCount;

  /// Number of warnings (unknown types, malformed files, write errors).
  final int warningCount;

  @override
  String toString() =>
      'MigrationResult(migrated: $migratedCount, warnings: $warningCount)';
}

/// Legacy pageType values that map directly to entityTypeKey.
/// These are the known D&D 5e entity type keys from the GameModel.
const _knownLegacyTypes = {
  'creature',
  'spell',
  'item',
  'rule',
  'location',
  'npc',
  'other',
};

/// Idempotent in-place migration runner that rewrites persisted wiki JSON
/// files from legacy `pageType` to canonical `entityTypeKey`.
///
/// Scans only `wiki/pages/*.json` (D-08), rewrites in place (D-04),
/// skips unknown types with warnings (D-03), and continues on write
/// errors without blocking startup (D-07).
class WikiMigrationRunner {
  final Directory _pagesDirectory;

  WikiMigrationRunner({required Directory pagesDirectory})
      : _pagesDirectory = pagesDirectory;

  /// Run the migration. Returns a [MigrationResult] with counts.
  ///
  /// Idempotent: if a file already has `entityTypeKey` and no `pageType`,
  /// it is considered migrated and skipped (D-06).
  Future<MigrationResult> run() async {
    int migrated = 0;
    int warnings = 0;

    if (!await _pagesDirectory.exists()) {
      return const MigrationResult(migratedCount: 0, warningCount: 0);
    }

    final entities = await _pagesDirectory.list().toList();
    for (final entity in entities) {
      if (entity is! File || !entity.path.endsWith('.json')) {
        continue;
      }

      try {
        final result = await _migrateFile(entity);
        if (result == _FileResult.migrated) {
          migrated++;
        } else if (result == _FileResult.warning) {
          warnings++;
        }
        // _FileResult.skipped means already-migrated or not a wiki page
      } catch (_) {
        // T-08-01: per-file errors caught, file skipped, migration continues
        warnings++;
      }
    }

    return MigrationResult(migratedCount: migrated, warningCount: warnings);
  }

  Future<_FileResult> _migrateFile(File file) async {
    String content;
    try {
      content = await file.readAsString();
    } catch (_) {
      return _FileResult.warning;
    }

    Map<String, dynamic> jsonMap;
    try {
      final decoded = jsonDecode(content);
      if (decoded is! Map<String, dynamic>) {
        return _FileResult.skipped;
      }
      jsonMap = decoded;
    } catch (_) {
      // Malformed JSON — skip with warning (T-08-01)
      return _FileResult.warning;
    }

    // Already migrated: has entityTypeKey, no pageType
    if (jsonMap.containsKey('entityTypeKey') && !jsonMap.containsKey('pageType')) {
      return _FileResult.skipped;
    }

    // No legacy key to migrate
    if (!jsonMap.containsKey('pageType')) {
      return _FileResult.skipped;
    }

    final legacyType = jsonMap['pageType'];
    if (legacyType is! String) {
      return _FileResult.warning;
    }

    // D-03: unknown legacy type — skip with warning, do not crash
    if (!_knownLegacyTypes.contains(legacyType)) {
      return _FileResult.warning;
    }

    // Rewrite: replace pageType with entityTypeKey
    jsonMap['entityTypeKey'] = legacyType;
    jsonMap.remove('pageType');

    // D-04: in-place rewrite
    try {
      await file.writeAsString(jsonEncode(jsonMap));
    } catch (_) {
      // D-07: write failure surfaces warning, doesn't block startup
      return _FileResult.warning;
    }

    return _FileResult.migrated;
  }
}

int _warningsCounter = 0;

void warningsIncrement() {
  _warningsCounter++;
}

enum _FileResult {
  migrated,
  warning,
  skipped,
}

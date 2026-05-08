import 'dart:convert';
import 'dart:io';

import 'package:core/migrations/wiki_migration_runner.dart';
import 'package:path/path.dart' as path;
import 'package:core/models/models.dart';

class WikiCreateSubmission {
  const WikiCreateSubmission({
    required this.title,
    required this.body,
    required this.tags,
    required this.aliases,
    required this.statBlock,
  });

  final String title;
  final String body;
  final List<String> tags;
  final List<String> aliases;
  final Map<String, dynamic> statBlock;
}

abstract class WikiCreateTarget {
  List<WikiPage> get pages;
  WikiPage? get selectedPage;
  bool get isCreating;
  String? get pendingEntityKey;
  @Deprecated('Use pendingEntityKey instead')
  WikiPageType? get pendingType => null;
  void onPageCreated(WikiPage page);
  void onCreateComplete();
}

class InMemoryWikiCreateTarget implements WikiCreateTarget {
  final List<WikiPage> _pages = [];
  WikiPage? _selectedPage;
  bool _isCreating = true;
  String? _pendingEntityKey;

  @override
  List<WikiPage> get pages => List.unmodifiable(_pages);

  @override
  WikiPage? get selectedPage => _selectedPage;

  @override
  bool get isCreating => _isCreating;

  @override
  String? get pendingEntityKey => _pendingEntityKey;

  @override
  @Deprecated('Use pendingEntityKey instead')
  WikiPageType? get pendingType => null;

  @override
  void onPageCreated(WikiPage page) {
    _pages.add(page);
    _selectedPage = page;
  }

  @override
  void onCreateComplete() {
    _isCreating = false;
    _pendingEntityKey = null;
  }
}

class WikiCreateSubmitFlow {
  WikiCreateSubmitFlow({required this.storage, required this.target});

  final WikiStorageService storage;
  final WikiCreateTarget target;

  /// Submit using EntityTypeSchema — converts to WikiPageType internally for backward compat.
  Future<WikiPage> submitFromSchema({
    required EntityTypeSchema entitySchema,
    required WikiCreateSubmission draft,
  }) async {
    final wikiPageType = WikiPageType.values.byName(entitySchema.key);
    final normalizedStatBlock = <String, dynamic>{};
    final schemaKeys = entitySchema.fields.map((field) => field.key).toSet();
    for (final entry in draft.statBlock.entries) {
      if (!schemaKeys.contains(entry.key)) continue;
      final value = entry.value;
      if (value == null) continue;
      if (value is String) {
        final trimmed = value.trim();
        if (trimmed.isEmpty) continue;
        normalizedStatBlock[entry.key] = trimmed;
      } else {
        normalizedStatBlock[entry.key] = value;
      }
    }

    final page = WikiPage(
      title: draft.title.trim(),
      pageType: wikiPageType,
      body: draft.body.trim(),
      tags: _normalizeCsvList(draft.tags),
      aliases: _normalizeCsvList(draft.aliases),
      statBlock: normalizedStatBlock,
    );

    await storage.savePage(page);
    target.onPageCreated(page);
    target.onCreateComplete();
    return page;
  }

  Future<WikiPage> submit({
    required WikiPageType selectedType,
    required WikiCreateSubmission draft,
  }) async {
    final title = draft.title.trim();
    if (title.isEmpty) {
      throw ArgumentError('Title is required');
    }

    final normalizedStatBlock = <String, dynamic>{};
    final keysByType = selectedType.fields.map((field) => field.key).toSet();
    for (final entry in draft.statBlock.entries) {
      if (!keysByType.contains(entry.key)) continue;
      final value = entry.value;
      if (value == null) continue;
      if (value is String) {
        final trimmed = value.trim();
        if (trimmed.isEmpty) continue;
        normalizedStatBlock[entry.key] = trimmed;
      } else {
        normalizedStatBlock[entry.key] = value;
      }
    }

    final page = WikiPage(
      title: title,
      pageType: selectedType,
      body: draft.body.trim(),
      tags: _normalizeCsvList(draft.tags),
      aliases: _normalizeCsvList(draft.aliases),
      statBlock: normalizedStatBlock,
    );

    await storage.savePage(page);
    target.onPageCreated(page);
    target.onCreateComplete();
    return page;
  }

  List<String> _normalizeCsvList(List<String> values) {
    return values
        .map((entry) => entry.trim())
        .where((entry) => entry.isNotEmpty)
        .toSet()
        .toList();
  }
}

class WikiStorageService {
  final Directory _baseDirectory;

  WikiStorageService({required Directory baseDirectory})
      : _baseDirectory = baseDirectory {
    _ensureDirectory();
  }

  Directory get _pagesDir =>
      Directory(path.join(_baseDirectory.path, 'wiki', 'pages'));

  void _ensureDirectory() {
    _pagesDir.createSync(recursive: true);
  }

  Future<MigrationResult> runStartupMigration() async {
    final runner = WikiMigrationRunner(pagesDirectory: _pagesDir);
    return runner.run();
  }

  Future<void> savePage(WikiPage page) async {
    final filePath = path.join(_pagesDir.path, '${page.id}.json');
    final file = File(filePath);
    final jsonString = jsonEncode(page.toJson());
    await file.writeAsString(jsonString);
  }

  Future<WikiPage?> loadPage(String pageId) async {
    final filePath = path.join(_pagesDir.path, '$pageId.json');
    final file = File(filePath);
    if (!await file.exists()) {
      return null;
    }
    final content = await file.readAsString();
    final jsonMap = jsonDecode(content) as Map<String, dynamic>;
    return WikiPage.fromJson(jsonMap);
  }

  Future<List<WikiPage>> loadAllPages() async {
    final pages = <WikiPage>[];
    final entities = await _pagesDir.list().toList();
    for (final entity in entities) {
      if (entity is File && entity.path.endsWith('.json')) {
        try {
          final content = await entity.readAsString();
          final jsonMap = jsonDecode(content) as Map<String, dynamic>;
          pages.add(WikiPage.fromJson(jsonMap));
        } catch (_) {
          // Skip malformed files
        }
      }
    }
    return pages;
  }

  Future<void> deletePage(String pageId) async {
    final filePath = path.join(_pagesDir.path, '$pageId.json');
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}

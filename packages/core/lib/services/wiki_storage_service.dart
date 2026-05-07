import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:core/models/models.dart';

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

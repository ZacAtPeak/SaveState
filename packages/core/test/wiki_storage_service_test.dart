import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:core/models/models.dart';
import 'package:core/services/services.dart';

void main() {
  late Directory tempDir;
  late WikiStorageService service;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('wiki_test_');
    service = WikiStorageService(baseDirectory: tempDir);
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  WikiPage _createPage({
    String? id,
    required String title,
    String entityTypeKey = 'spell',
    String body = '',
    List<String> tags = const [],
  }) {
    return WikiPage(
      id: id,
      title: title,
      entityTypeKey: entityTypeKey,
      body: body,
      tags: tags,
    );
  }

  group('savePage', () {
    test('saves page as JSON file', () async {
      final page = _createPage(id: 'test-123', title: 'Fireball');
      await service.savePage(page);

      final file = File('${tempDir.path}/wiki/pages/test-123.json');
      expect(file.existsSync(), isTrue);
    });

    test('saved file contains valid JSON', () async {
      final page = _createPage(id: 'test-456', title: 'Magic Missile');
      await service.savePage(page);

      final file = File('${tempDir.path}/wiki/pages/test-456.json');
      final content = file.readAsStringSync();
      final json = jsonDecode(content) as Map<String, dynamic>;
      expect(json['title'], equals('Magic Missile'));
    });
  });

  group('loadPage', () {
    test('loads a saved page with identical data', () async {
      final original = _createPage(
        id: 'test-789',
        title: 'Shield',
        entityTypeKey: 'spell',
        body: 'An invisible barrier',
        tags: ['abjuration'],
      );
      await service.savePage(original);

      final loaded = await service.loadPage('test-789');
      expect(loaded, isNotNull);
      expect(loaded!.title, equals('Shield'));
      expect(loaded.entityTypeKey, equals('spell'));
      expect(loaded.body, equals('An invisible barrier'));
      expect(loaded.tags, equals(['abjuration']));
      expect(loaded.id, equals('test-789'));
    });

    test('returns null for non-existent page', () async {
      final loaded = await service.loadPage('nonexistent-id');
      expect(loaded, isNull);
    });
  });

  group('loadAllPages', () {
    test('returns all saved pages', () async {
      final page1 = _createPage(id: 'page-1', title: 'Fireball');
      final page2 = _createPage(id: 'page-2', title: 'Shield');
      final page3 = _createPage(id: 'page-3', title: 'Magic Missile');

      await service.savePage(page1);
      await service.savePage(page2);
      await service.savePage(page3);

      final pages = await service.loadAllPages();
      expect(pages.length, equals(3));
    });

    test('returns empty list when no pages exist', () async {
      final pages = await service.loadAllPages();
      expect(pages, isEmpty);
    });
  });

  group('deletePage', () {
    test('removes the page file', () async {
      final page = _createPage(id: 'delete-me', title: 'To Delete');
      await service.savePage(page);

      final file = File('${tempDir.path}/wiki/pages/delete-me.json');
      expect(file.existsSync(), isTrue);

      await service.deletePage('delete-me');
      expect(file.existsSync(), isFalse);
    });

    test('page not in loadAllPages after delete', () async {
      final page1 = _createPage(id: 'keep-1', title: 'Keep Me');
      final page2 = _createPage(id: 'delete-2', title: 'Delete Me');

      await service.savePage(page1);
      await service.savePage(page2);

      await service.deletePage('delete-2');

      final pages = await service.loadAllPages();
      expect(pages.length, equals(1));
      expect(pages.first.title, equals('Keep Me'));
    });
  });
}

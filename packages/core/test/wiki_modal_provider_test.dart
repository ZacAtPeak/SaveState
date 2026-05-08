import 'package:test/test.dart';
import 'package:core/models/models.dart';
import 'package:core/wiki/wiki_modal_provider.dart';

WikiPage _page({String? id, required String title}) {
  return WikiPage(id: id ?? 'test-$title', title: title, entityTypeKey: 'spell');
}

void main() {
  late WikiModalProvider provider;

  setUp(() {
    provider = WikiModalProvider();
  });

  group('selection', () {
    test('selectPage sets selectedPage', () {
      final page = _page(title: 'Fireball');
      provider.selectPage(page);
      expect(provider.selectedPage, equals(page));
    });

    test('selectPage with null clears selection', () {
      provider.selectPage(_page(title: 'Fireball'));
      provider.selectPage(null);
      expect(provider.selectedPage, isNull);
    });
  });

  group('create flow', () {
    test('startCreate sets isCreating to true', () {
      provider.startCreate();
      expect(provider.isCreating, isTrue);
    });

    test('cancelCreate resets isCreating and pendingEntityKey', () {
      provider.startCreate();
      final entity = EntityTypeSchema(key: 'spell', displayName: 'Spell', isWikiPageType: true, fields: const [], sortOrder: 1);
      provider.selectCreateType(entity);
      provider.cancelCreate();
      expect(provider.isCreating, isFalse);
      expect(provider.pendingEntityKey, isNull);
    });

    test('cancelCreate is safe to call when not creating', () {
      expect(provider.isCreating, isFalse);
      provider.cancelCreate();
      expect(provider.isCreating, isFalse);
    });
  });

  group('dismissal behavior', () {
    test('cancelCreate preserves selectedPage', () {
      final page = _page(title: 'Fireball');
      provider.selectPage(page);
      provider.startCreate();
      provider.cancelCreate();
      expect(provider.selectedPage, equals(page));
    });

    test('reset clears selectedPage (explicit full reset)', () {
      final page = _page(title: 'Fireball');
      provider.selectPage(page);
      provider.reset();
      expect(provider.selectedPage, isNull);
    });
  });

  group('page management', () {
    test('addPage sets selectedPage to the new page', () {
      final page = _page(title: 'Fireball');
      provider.addPage(page);
      expect(provider.selectedPage, equals(page));
      expect(provider.pages, hasLength(1));
    });

    test('setPages replaces existing pages', () {
      final pageA = _page(id: 'a', title: 'Page A');
      final pageB = _page(id: 'b', title: 'Page B');
      provider.setPages([pageA]);
      provider.setPages([pageB]);
      expect(provider.pages, hasLength(1));
      expect(provider.pages.first.title, equals('Page B'));
    });
  });

  group('layout mode', () {
    test('setLayoutMode updates isTwoPanel', () {
      provider.setLayoutMode(true);
      expect(provider.isTwoPanel, isTrue);
      provider.setLayoutMode(false);
      expect(provider.isTwoPanel, isFalse);
    });
  });
}

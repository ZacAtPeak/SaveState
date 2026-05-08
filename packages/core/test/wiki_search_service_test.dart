import 'package:test/test.dart';
import 'package:core/models/models.dart';
import 'package:core/services/services.dart';

WikiPage _page({
  String? id,
  required String title,
  String body = '',
  List<String> tags = const [],
  String entityTypeKey = 'spell',
}) {
  return WikiPage(
    id: id,
    title: title,
    entityTypeKey: entityTypeKey,
    body: body,
    tags: tags,
  );
}

void main() {
  late WikiSearchService service;

  setUp(() {
    service = WikiSearchService();
  });

  group('indexing', () {
    test('index replaces existing pages', () {
      final pageA = _page(id: 'a', title: 'Page A');
      final pageB = _page(id: 'b', title: 'Page B');

      service.addPage(pageA);
      service.index([pageB]);

      final results = service.search('');
      expect(results.length, equals(1));
      expect(results.first.page.title, equals('Page B'));
    });

    test('addPage adds to index', () {
      final pageA = _page(id: 'a', title: 'Page A');
      final pageB = _page(id: 'b', title: 'Page B');

      service.index([pageA]);
      service.addPage(pageB);

      final results = service.search('');
      expect(results.length, equals(2));
    });

    test('removePage removes from index', () {
      final pageA = _page(id: 'a', title: 'Page A');
      final pageB = _page(id: 'b', title: 'Page B');

      service.index([pageA, pageB]);
      service.removePage('a');

      final results = service.search('');
      expect(results.length, equals(1));
      expect(results.first.page.title, equals('Page B'));
    });

    test('clear empties index', () {
      final pageA = _page(id: 'a', title: 'Page A');
      final pageB = _page(id: 'b', title: 'Page B');

      service.index([pageA, pageB]);
      service.clear();

      final results = service.search('');
      expect(results, isEmpty);
    });
  });

  group('search scoring', () {
    test('title match scores higher than body match', () {
      final titlePage = _page(
        id: 'title',
        title: 'Fireball',
        body: 'a spell',
      );
      final bodyPage = _page(
        id: 'body',
        title: 'Spells',
        body: 'fireball description',
      );

      service.index([titlePage, bodyPage]);

      final titleResults = service.search('fireball');
      final titleScore = titleResults.firstWhere(
        (r) => r.page.id == 'title',
      ).score;
      final bodyScore = titleResults.firstWhere(
        (r) => r.page.id == 'body',
      ).score;

      expect(titleScore, greaterThan(bodyScore));
    });

    test('returns results sorted by score', () {
      final pageA = _page(id: 'a', title: 'Fireball', body: 'fire damage');
      final pageB = _page(id: 'b', title: 'Flame Strike', body: 'fire spell');
      final pageC = _page(id: 'c', title: 'Ice Storm', body: 'fire resistance');

      service.index([pageA, pageB, pageC]);

      final results = service.search('fire');
      expect(results.length, equals(3));
      expect(results[0].score, greaterThanOrEqualTo(results[1].score));
      expect(results[1].score, greaterThanOrEqualTo(results[2].score));
    });

    test('empty query returns all pages', () {
      final pageA = _page(id: 'a', title: 'Page A');
      final pageB = _page(id: 'b', title: 'Page B');
      final pageC = _page(id: 'c', title: 'Page C');

      service.index([pageA, pageB, pageC]);

      final results = service.search('');
      expect(results.length, equals(3));
    });

    test('non-matching query returns empty', () {
      final page = _page(id: 'a', title: 'Fireball', body: 'a spell');
      service.index([page]);

      final results = service.search('xyznonexistent');
      expect(results, isEmpty);
    });

    test('case-insensitive matching', () {
      final page = _page(id: 'a', title: 'Fireball');
      service.index([page]);

      expect(service.search('fireball').length, equals(1));
      expect(service.search('FIREBALL').length, equals(1));
      expect(service.search('FireBall').length, equals(1));
    });

    test('multi-word query accumulates scores', () {
      final page = _page(id: 'a', title: 'Fire Bolt');
      service.index([page]);

      final singleResults = service.search('fire');
      final multiResults = service.search('fire bolt');

      expect(multiResults.first.score, greaterThan(singleResults.first.score));
    });

    test('tag matches contribute to score', () {
      final page = _page(
        id: 'a',
        title: 'Some Spell',
        body: 'nothing here',
        tags: ['evocation'],
      );
      service.index([page]);

      final results = service.search('evocation');
      expect(results.length, equals(1));
      expect(results.first.score, greaterThan(0));
    });
  });
}

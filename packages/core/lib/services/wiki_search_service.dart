import 'package:core/models/models.dart';

class WikiSearchResult {
  final WikiPage page;
  final int score;

  const WikiSearchResult({required this.page, required this.score});
}

class WikiSearchService {
  final Map<String, WikiPage> _index = {};

  void index(List<WikiPage> pages) {
    _index.clear();
    for (final page in pages) {
      _index[page.id] = page;
    }
  }

  void addPage(WikiPage page) {
    _index[page.id] = page;
  }

  void removePage(String pageId) {
    _index.remove(pageId);
  }

  void clear() {
    _index.clear();
  }

  List<WikiSearchResult> search(String query) {
    final normalizedQuery = query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      return _index.values
          .map((page) => WikiSearchResult(page: page, score: 0))
          .toList();
    }

    final queryWords = normalizedQuery.split(RegExp(r'\s+'));
    final results = <WikiSearchResult>[];

    for (final page in _index.values) {
      int score = 0;
      final titleLower = page.title.toLowerCase();
      final bodyLower = page.body.toLowerCase();
      final tagLowers = page.tags.map((t) => t.toLowerCase()).toList();

      for (final word in queryWords) {
        if (titleLower.contains(word)) {
          score += 10;
        }
        if (bodyLower.contains(word)) {
          score += 1;
        }
        for (final tag in tagLowers) {
          if (tag.contains(word)) {
            score += 5;
          }
        }
      }

      if (score > 0) {
        results.add(WikiSearchResult(page: page, score: score));
      }
    }

    results.sort((a, b) => b.score.compareTo(a.score));
    return results;
  }
}

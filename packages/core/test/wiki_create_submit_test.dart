import 'dart:io';

import 'package:core/models/models.dart';
import 'package:core/services/services.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;
  late WikiStorageService storage;
  late InMemoryWikiCreateTarget target;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('wiki_create_submit_');
    storage = WikiStorageService(baseDirectory: tempDir);
    target = InMemoryWikiCreateTarget();
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  group('WikiCreateSubmitFlow', () {
    test('persists a created page with expected common fields', () async {
      final flow = WikiCreateSubmitFlow(storage: storage, target: target);

      await flow.submit(
        selectedType: WikiPageType.spell,
        draft: const WikiCreateSubmission(
          title: 'Magic Missile',
          body: 'A dart of magical force',
          tags: ['evocation', 'damage'],
          aliases: ['MM'],
          statBlock: {'level': 1, 'school': 'Evocation'},
        ),
      );

      final pages = await storage.loadAllPages();
      expect(pages, hasLength(1));
      final saved = pages.single;
      expect(saved.title, 'Magic Missile');
      expect(saved.body, 'A dart of magical force');
      expect(saved.tags, ['evocation', 'damage']);
      expect(saved.aliases, ['MM']);
      expect(saved.pageType, WikiPageType.spell);
    });

    test('maps structured fields into statBlock keys', () async {
      final flow = WikiCreateSubmitFlow(storage: storage, target: target);

      await flow.submit(
        selectedType: WikiPageType.creature,
        draft: const WikiCreateSubmission(
          title: 'Goblin',
          body: 'Small green humanoid',
          tags: ['humanoid'],
          aliases: ['gobbo'],
          statBlock: {
            'size': 'Small',
            'armorClass': 15,
            'hitPoints': 7,
            'speed': '30 ft.',
          },
        ),
      );

      final saved = (await storage.loadAllPages()).single;
      expect(saved.statBlock['size'], 'Small');
      expect(saved.statBlock['armorClass'], 15);
      expect(saved.statBlock['hitPoints'], 7);
      expect(saved.statBlock['speed'], '30 ft.');
    });

    test('updates modal pages and auto-selects the newly created page', () async {
      final flow = WikiCreateSubmitFlow(storage: storage, target: target);

      await flow.submit(
        selectedType: WikiPageType.item,
        draft: const WikiCreateSubmission(
          title: 'Bag of Holding',
          body: 'A magical storage item',
          tags: ['wondrous'],
          aliases: [],
          statBlock: {'rarity': 'Uncommon'},
        ),
      );

      expect(target.pages, hasLength(1));
      expect(target.selectedPage, isNotNull);
      expect(target.selectedPage!.title, 'Bag of Holding');
      expect(target.selectedPage!.id, target.pages.single.id);
      expect(target.isCreating, isFalse);
      expect(target.pendingType, isNull);
    });
  });
}

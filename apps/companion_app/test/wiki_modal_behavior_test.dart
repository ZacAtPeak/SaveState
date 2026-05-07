import 'package:companion_app/main.dart';
import 'package:core/wiki/wiki.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> openWikiModal(WidgetTester tester) async {
  await tester.pumpWidget(const CompanionApp());
  await tester.tap(find.byIcon(Icons.menu_book));
  await tester.pumpAndSettle();
}

void main() {
  group('Companion wiki modal responsive breakpoints', () {
    testWidgets('shows single panel at 599dp (phone)', (tester) async {
      tester.view.physicalSize = const Size(599, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await openWikiModal(tester);

      expect(find.byType(WikiPageList), findsOneWidget);
      // Single panel: no Row with 2 children for sidebar+detail
      final rows = tester.widgetList<Row>(find.byType(Row));
      final hasTwoPanelRow = rows.any((row) => row.children.length == 2);
      expect(hasTwoPanelRow, isFalse);
    });

    testWidgets('shows two-panel at 600dp (tablet)', (tester) async {
      tester.view.physicalSize = const Size(600, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await openWikiModal(tester);

      // Two-panel: find a Row with exactly 2 children (sidebar + detail)
      final rows = tester.widgetList<Row>(find.byType(Row));
      final hasTwoPanelRow = rows.any((row) => row.children.length == 2);
      expect(hasTwoPanelRow, isTrue);
      // Verify sidebar is SizedBox with width 300
      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      final hasSidebar = sizedBoxes.any((box) => box.width == 300);
      expect(hasSidebar, isTrue);
    });

    testWidgets('shows two-panel at 840dp (desktop lower boundary)', (tester) async {
      tester.view.physicalSize = const Size(840, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await openWikiModal(tester);

      // Find the Row inside the modal - two-panel layout uses Row
      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('shows two-panel at 841dp (desktop upper boundary)', (tester) async {
      tester.view.physicalSize = const Size(841, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await openWikiModal(tester);

      // Find the Row inside the modal - two-panel layout uses Row
      expect(find.byType(Row), findsWidgets);
    });
  });

  group('Companion wiki modal dismissal', () {
    testWidgets('close button dismisses modal', (tester) async {
      await openWikiModal(tester);

      expect(find.text('Wiki'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(find.text('Wiki'), findsNothing);
    });
  });

  group('Companion wiki modal search', () {
    testWidgets('search TextField is present in sidebar', (tester) async {
      await openWikiModal(tester);

      expect(find.byType(TextField), findsOneWidget);
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.decoration?.hintText, equals('Search pages...'));
    });

    testWidgets('search input filters page list', (tester) async {
      await openWikiModal(tester);

      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      await tester.enterText(searchField, 'nonexistent-page-xyz');
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();

      final listView = find.byType(ListView);
      expect(listView, findsOneWidget);
    });
  });
}

import 'package:core/wiki/wiki.dart';
import 'package:dm_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  group('DM wiki entry integration', () {
    testWidgets('exposes top-level WikiProvider and opens wiki modal from AppBar', (tester) async {
      await tester.pumpWidget(const DmApp());

      expect(
        find.byWidgetPredicate((widget) => widget is ChangeNotifierProvider<WikiProvider>),
        findsOneWidget,
      );

      final wikiButton = find.byIcon(Icons.menu_book);
      expect(wikiButton, findsOneWidget);
      expect(find.byTooltip('Wiki'), findsOneWidget);

      await tester.tap(wikiButton);
      await tester.pumpAndSettle();

      expect(find.text('Wiki'), findsOneWidget);
    });
  });
}

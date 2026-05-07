import 'package:companion_app/main.dart';
import 'package:core/wiki/wiki.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  group('Companion wiki entry integration', () {
    testWidgets('exposes top-level WikiProvider and opens wiki modal from AppBar', (tester) async {
      await tester.pumpWidget(const CompanionApp());

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

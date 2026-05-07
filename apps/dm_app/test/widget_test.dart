import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dm_app/main.dart';

void main() {
  testWidgets('DM app loads with blank scaffold', (WidgetTester tester) async {
    await tester.pumpWidget(const DmApp());
    expect(find.byType(Scaffold), findsOneWidget);
  });
}

# Testing Patterns

**Analysis Date:** 2026-05-09

## Test Framework

**Runner:**
- Flutter Test (`flutter_test` package)
- Part of Flutter SDK, included in `dev_dependencies` via `flutter_test: sdk: flutter`

**Assertion Library:**
- `flutter_test` built-in matchers
- Standard `expect()` function

**Run Commands:**
```bash
flutter test                    # Run all tests
flutter test test/widget_test.dart  # Run specific test file
flutter test --reporter expanded     # Detailed output
```

## Test File Organization

**Location:**
- `test/` directory at project root
- Mirror structure of `lib/` (co-located not required for Flutter)

**Naming:**
- `*_test.dart` suffix: `widget_test.dart`
- One test file per feature/unit

## Test Structure

**Basic widget test pattern:**
```dart
void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
```

**Patterns:**
- `WidgetTester` for widget testing
- `pumpWidget()` to render widget
- `pump()` to advance animation/frames
- `find.byX()` for widget finding
- `expect()` with matchers for assertions

## Test Types

**Widget Tests:**
- Primary test type in this project
- Uses `WidgetTester` and `testWidgets()`
- Tests UI components in isolation
- Located in `test/widget_test.dart`

**Unit Tests:**
- Not present in current project
- Would use standard Dart `test()` function
- Import `package:flutter_test/flutter_test.dart`

**Integration Tests:**
- Not present in current project
- Would use `integration_test` package
- Run with `flutter test integration_test/`

## Mocking

**Framework:** No mocking framework currently in use

**Common Flutter mocking approaches:**
- `MockBuilder` for widget mocking
- `Mock classes` for service mocking
- `when()` from `mockito` package (not installed)

**Current test does not mock any dependencies**

## Fixtures and Factories

**Test Data:**
- No dedicated fixture files
- Data sourced from `lib/*.sql` files for integration testing
- In-line test data in test files

**Location:**
- `test/` - All test files
- `lib/ttrpg_data/*.sql` - TTRPG game data

## Coverage

**Requirements:** None enforced

**View Coverage:**
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

**Coverage tools available:**
- `coverage` package (dev dependency not currently listed)
- `lcov` for coverage report generation

## Common Patterns

**Async Testing:**
```dart
await tester.pumpWidget(const MyApp());
await tester.pump();
// For futures:
await tester.pumpAndSettle();
```

**Widget Finding:**
- `find.text('string')` - Find by text
- `find.byIcon(Icons.add)` - Find by icon
- `find.byType(Text)` - Find by widget type
- `find.byKey(Key('key'))` - Find by key

**Interaction:**
- `tester.tap(find)` - Tap gesture
- `tester.enterText(find, 'text')` - Text input
- `tester.drag(find, offset)` - Drag gesture

## Current Test State

**Single test file:** `test/widget_test.dart` (30 lines)
**Single test:** Smoke test for counter increment
**Quality:** Basic Flutter template test, no custom assertions

---

*Testing analysis: 2026-05-09*
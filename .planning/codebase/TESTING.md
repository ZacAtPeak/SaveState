# Testing Patterns

**Analysis Date:** 2026-05-07

## Current State

**No test files, test configuration, or test dependencies exist in this workspace.** All three packages (`core`, `dm_app`, `companion_app`) contain only `pubspec.yaml` and `.dart_tool/` directories. No `.dart` source files have been committed.

The guidance below describes the **recommended testing approach** for this Dart/Flutter workspace based on ecosystem standards and the project's architecture.

## Test Framework

**Runner:**
- `dart test` for the `core` package (pure Dart)
- `flutter test` for `dm_app` and `companion_app` (Flutter apps)

**Assertion Library:**
- `package:test` (built-in, included with Dart SDK)
- Flutter tests use the same `test` package with Flutter-specific matchers

**Recommended dev_dependencies to add:**

For `packages/core/pubspec.yaml`:
```yaml
dev_dependencies:
  test: ^1.25.0
  mockito: ^5.4.0
  build_runner: ^2.4.0
```

For `apps/dm_app/pubspec.yaml` and `apps/companion_app/pubspec.yaml`:
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.0
  build_runner: ^2.4.0
```

**Run Commands:**
```bash
# Run all tests in workspace
dart test                        # In packages/core
flutter test                     # In apps/dm_app or apps/companion_app

# Run specific test file
dart test test/network_test.dart
flutter test test/widget_test.dart

# Watch mode
dart test --watch
flutter test --watch

# Coverage
dart test --coverage=coverage/
flutter test --coverage
```

## Test File Organization

**Location:**
- `test/` directory within each package (Dart standard)

**Expected structure:**
```
packages/core/
├── lib/
│   └── src/
│       ├── models/
│       └── services/
└── test/
    ├── src/
    │   ├── models/
    │   │   └── player_model_test.dart
    │   └── services/
    │       └── network_service_test.dart
    └── helpers/
        └── test_fixtures.dart

apps/dm_app/
├── lib/
└── test/
    ├── unit/
    ├── widget/
    └── integration/

apps/companion_app/
├── lib/
└── test/
    ├── unit/
    └── widget/
```

**Naming:**
- Test files: `<source_file_name>_test.dart`
- Example: `network_service.dart` → `network_service_test.dart`

## Test Structure

**Unit test pattern (core package):**
```dart
import 'package:test/test.dart';
import 'package:core/core.dart';

void main() {
  group('NetworkService', () {
    late NetworkService service;

    setUp(() {
      service = NetworkService();
    });

    tearDown(() {
      service.dispose();
    });

    test('should discover services on local network', () async {
      // Arrange
      final serviceName = '_http._tcp';

      // Act
      final services = await service.discover(serviceName);

      // Assert
      expect(services, isNotEmpty);
      expect(services.first.name, isNotNull);
    });

    test('should throw TimeoutException when no services found', () async {
      expect(
        () => service.discover('_nonexistent._tcp', timeout: Duration(seconds: 1)),
        throwsA(isA<TimeoutException>()),
      );
    });
  });
}
```

**Widget test pattern (Flutter apps):**
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:dm_app/main.dart';

void main() {
  testWidgets('should display game board on launch', (tester) async {
    // Arrange
    await tester.pumpWidget(const MyApp());

    // Act
    await tester.pumpAndSettle();

    // Assert
    expect(find.byType(GameBoard), findsOneWidget);
  });
}
```

## Mocking

**Framework:** `mockito` (recommended)

**Pattern with code generation:**
```dart
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

@GenerateMocks([NetworkService])
import 'network_service_test.mocks.dart';

void main() {
  group('GameController', () {
    late MockNetworkService mockNetwork;
    late GameController controller;

    setUp(() {
      mockNetwork = MockNetworkService();
      controller = GameController(network: mockNetwork);
    });

    test('should connect to discovered service', () async {
      // Arrange
      when(mockNetwork.discover(any))
          .thenAnswer((_) async => [DiscoveredService(name: 'host')]);

      // Act
      await controller.connect();

      // Assert
      verify(mockNetwork.discover('_dnd._tcp')).called(1);
      expect(controller.isConnected, isTrue);
    });
  });
}
```

**What to Mock:**
- External services (network, file I/O, platform channels)
- `nsd` discovery callbacks in core package
- Provider/inherited widget dependencies in widget tests

**What NOT to Mock:**
- Value objects and models (use real instances)
- Pure utility functions
- Core business logic (test directly)

## Fixtures and Factories

**Test Data:**
```dart
// test/helpers/test_fixtures.dart
class TestFixtures {
  static DiscoveredService localHost() => DiscoveredService(
        name: 'Test Host',
        host: '127.0.0.1',
        port: 8080,
      );

  static GameState emptyGame() => GameState(
        players: [],
        currentTurn: 0,
        phase: GamePhase.setup,
      );
}
```

**Location:**
- `test/helpers/` or `test/fixtures/` within each package
- Shared fixtures for core package can live in `test/helpers/`

## Coverage

**Requirements:** None enforced (no coverage configuration detected).

**Recommended target:** 80%+ for `core` package, 60%+ for app packages.

**View Coverage:**
```bash
# Generate coverage
dart test --coverage=coverage/
dart pub global run coverage:format_coverage --packages=.dart_tool/package_config.json --report-on=lib --lcov -o coverage/lcov.info -i coverage/

# View HTML report (Flutter)
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Test Types

**Unit Tests:**
- Scope: Individual classes, functions, and business logic
- Location: `test/` in each package
- Framework: `package:test` (core), `flutter_test` (apps)
- Approach: Test pure functions directly, mock external dependencies

**Widget Tests:**
- Scope: Individual Flutter widgets and UI components
- Location: `test/widget/` in app packages
- Framework: `flutter_test`
- Approach: Use `tester.pumpWidget()`, verify widget tree and interactions

**Integration Tests:**
- Framework: Not yet configured
- Recommended: `integration_test` package for Flutter
- Location: `integration_test/` directory in app packages
- Scope: End-to-end flows (e.g., DM creates game → companion connects)

**E2E Tests:**
- Not used
- Consider `patrol` or `integration_test` for cross-app testing

## Common Patterns

**Async Testing:**
```dart
test('should emit events when state changes', () async {
  final controller = GameController();
  final events = <GameEvent>[];
  controller.eventStream.listen(events.add);

  await controller.startGame();

  expect(events, contains(isA<GameStartedEvent>()));
});
```

**Error Testing:**
```dart
test('should throw ConnectionException when host unreachable', () async {
  final service = NetworkService();

  expect(
    () => service.connect('192.168.1.999', 9999),
    throwsA(
      isA<ConnectionException>().having(
        (e) => e.host,
        'host',
        '192.168.1.999',
      ),
    ),
  );
});
```

**Golden Tests (Flutter):**
```dart
testWidgets('game board matches golden', (tester) async {
  await tester.pumpWidget(const MaterialApp(home: GameBoard()));
  await expectLater(
    find.byType(GameBoard),
    matchesGoldenFile('goldens/game_board.png'),
  );
});
```

## CI Testing

**No CI configuration detected.**

**Recommended GitHub Actions workflow (`.github/workflows/test.yml`):**
```yaml
name: Test
on: [push, pull_request]
jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: cd packages/core && dart test
      - run: cd apps/dm_app && flutter test
      - run: cd apps/companion_app && flutter test
```

---

*Testing analysis: 2026-05-07*

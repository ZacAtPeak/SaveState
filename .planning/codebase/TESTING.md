# Testing Patterns

**Analysis Date:** 2026-05-07

## Test Framework

**Runner:**
- `flutter_test` (bundled with Flutter SDK)
- No separate test runner configuration detected

**Assertion Library:**
- `flutter_test` built-in `expect()` matchers

**Run Commands:**
```bash
dart test                        # Run all tests in workspace
cd apps/companion_app && flutter test  # Run companion app tests
cd apps/dm_app && flutter test          # Run DM app tests
cd packages/core && dart test           # Run core package tests
```

## Test File Organization

**Location:**
- Co-located per-package under `test/` directory
- `apps/companion_app/test/widget_test.dart`
- `apps/dm_app/test/widget_test.dart`
- `packages/core/` has **no test directory**

**Naming:**
- Single `widget_test.dart` per app (default Flutter scaffold)
- No domain-specific test files exist (e.g., no `monster_test.dart`, `player_character_test.dart`)

**Structure:**
```
apps/
├── companion_app/
│   └── test/
│       └── widget_test.dart       # Default counter smoke test
└── dm_app/
    └── test/
        └── widget_test.dart       # Minimal app load test
packages/
└── core/
    └── (no test directory)        # No tests for shared models/services
```

## Test Structure

**Suite Organization:**
```dart
// apps/dm_app/test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dm_app/main.dart';

void main() {
  testWidgets('DM app loads with blank scaffold', (WidgetTester tester) async {
    await tester.pumpWidget(const DmApp());
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
```

**Patterns:**
- Single `void main()` entry point per test file
- `testWidgets()` for widget tests
- No `setUp()` or `tearDown()` observed
- No `group()` blocks for organizing related tests

## Mocking

**Framework:** None used

**Patterns:**
- No mocking observed in existing tests
- Tests are too minimal to require mocking

**What to Mock:**
- Not yet established — no patterns exist

**What NOT to Mock:**
- Not yet established — no patterns exist

## Fixtures and Factories

**Test Data:**
- No test fixtures or factories exist
- Demo data available in `packages/core/lib/data/` (e.g., `demoMonsters`, `demoPlayerCharacters`, `demoNPCs`, `demoAssets`) — these could serve as test fixtures but are not currently used in tests

**Location:**
- Demo data lives in `packages/core/lib/data/`
- No dedicated `test/fixtures/` or `test/factories/` directory

## Coverage

**Requirements:** None enforced

**Configuration:**
- No `lcov.info` or coverage configuration detected
- No coverage badges or thresholds in any config file

**View Coverage:**
```bash
flutter test --coverage        # Generate coverage/lcov.info
genhtml coverage/lcov.info -o coverage/html  # Generate HTML report
```

## Test Types

**Unit Tests:**
- **Not present.** No unit tests exist for:
  - Model serialization (`toJson()`/`fromJson()`) in `packages/core/lib/models/`
  - Value type calculations (e.g., `AbilityScores._modifier()`, `AbilityScores.modifierFor()`)
  - Encounter state logic (`EncounterState.currentTurnEntry`)
  - Data factory functions (`demoMonsters`, `demoPlayerCharacters`)

**Widget Tests:**
- **Minimal.** Two widget tests exist:
  - `apps/dm_app/test/widget_test.dart` — verifies `DmApp` renders a `Scaffold` (1 assertion)
  - `apps/companion_app/test/widget_test.dart` — default Flutter counter smoke test (references counter UI that no longer exists in current `main.dart`)

**Integration Tests:**
- **Not used.** No `integration_test/` directory in either app

**E2E Tests:**
- **Not used.** No end-to-end testing framework configured

## Common Patterns

**Async Testing:**
```dart
// Pattern from existing tests
testWidgets('description', (WidgetTester tester) async {
  await tester.pumpWidget(const WidgetUnderTest());
  expect(find.byType(ExpectedType), findsOneWidget);
});
```

**Error Testing:**
- No error testing patterns observed

## Gaps and Observations

**Critical Untested Areas:**
- `packages/core/lib/models/` — 7 model files with complex serialization logic, zero test coverage
- `packages/core/lib/models/value_types.dart` — calculation logic (`_modifier()`, `modifierFor()`) untested
- `packages/core/lib/models/encounter.dart` — state management logic (`currentTurnEntry` getter) untested
- `apps/dm_app/lib/widgets/` — 3 widget files with interactive logic, only 1 trivial test
- `apps/companion_app/lib/widgets/` — `GenericTabView` with tab controller logic, untested

**Stale Test:**
- `apps/companion_app/test/widget_test.dart` tests a counter increment pattern that does not exist in the current `main.dart` (which uses `GenericTabView` with Characters/Inventory/Spells tabs). This test will fail if run.

**No CI/CD:**
- No `.github/workflows/` directory
- No pre-commit hooks (`.pre-commit-config.yaml` absent)
- No quality gates enforced

---

*Testing analysis: 2026-05-07*

# Coding Conventions

**Analysis Date:** 2026-05-09

## Language

**Primary:**
- Dart 3.11.5 - All application code in `lib/`
- SQL - Data files in `lib/ttrpg_data/` and `lib/*.sql`

## Code Style

**Tool:** Dart analyzer with `flutter_lints` (from `analysis_options.yaml`)

**Key rules from `package:flutter_lints/flutter.yaml`:**
- Prefer `const` constructors where possible
- Prefer single quotes for strings
- Avoid `print` statements (commented out rule)
- Use trailing commas for better formatting
- Prefer type annotations for variables

**Formatting:**
- 2-space indentation (Dart standard)
- No semicolons (Dart style)
- Function parameters: prefer `required` named parameters
- Widgets: `const` constructor where applicable

## Naming Patterns

**Classes:**
- PascalCase: `MyApp`, `MyHomePage`, `_MyHomePageState`
- Private classes prefixed with underscore: `_MyHomePageState`
- Descriptive names reflecting functionality

**Variables:**
- camelCase: `_counter`, `seedColor`, `context`
- Private fields prefixed with underscore: `_counter`
- Boolean variables often prefixed with auxiliary verb: `isEnabled`, `hasValue`

**Files:**
- lowercase_with_underscores.dart: `widget_test.dart`
- One class per file (Dart convention)

**Constants:**
- camelCase or PascalCase depending on scope
- `final` for runtime constants

## Import Organization

**Order ( Dart convention):**
1. SDK imports: `import 'dart:xxx'`
2. Package imports: `import 'package:flutter/material.dart'`
3. Relative imports: `import 'package:savestate/main.dart'`

**Example from `lib/main.dart`:**
```dart
import 'package:flutter/material.dart';
```

## Error Handling

**Patterns observed:**
- No explicit error handling in starter code
- Flutter's built-in error boundary via `MaterialApp`
- State updates via `setState()` wrapped in callbacks

**Recommended patterns for future code:**
- Use `try-catch` for async operations
- Use `FutureBuilder` or `StreamBuilder` for async data
- Leverage Flutter's `Builder` widget for context-dependent errors

## Documentation

**Comments:**
- Dart doc comments (`///`) for public APIs
- Single-line `//` for inline notes
- Extensive in-file comments explaining Flutter patterns

**Example from `lib/main.dart` (lines 10-30):**
```dart
// This widget is the root of your application.
// TRY THIS: Try running your application with "flutter run". You'll see...
```

## Function Design

**Size:** Small, focused functions typical in Flutter

**Parameters:**
- Named parameters with `required` keyword
- `super.key` for widget key passthrough

**Return Values:**
- Explicit return types for public methods
- `Widget build(BuildContext context)` for all StatefulWidget/StatelessWidget

## Module Design

**Structure:**
- `lib/` - Main Dart source code
- `lib/ttrpg_data/` - SQL data files
- `lib/*.sql` - Database schema files
- `test/` - Test files

**Exports:** No barrel files (single-file-per-class pattern)

## Flutter-Specific Conventions

**State Management:**
- `StatefulWidget` with private `_State` class
- `setState()` for state mutations
- `widget.` prefix to access StatefulWidget properties

**Widget Construction:**
- `const` constructors for stateless widgets where possible
- Named parameters for optional widget properties
- Builder pattern for context-dependent widgets

## Configuration

**Linting:**
- Config file: `analysis_options.yaml`
- Includes `package:flutter_lints/flutter.yaml`
- Custom rules can be added in `linter.rules` section

---

*Convention analysis: 2026-05-09*
# Coding Conventions

**Analysis Date:** 2026-05-07

## Overview

This is an early-stage Dart workspace with no source code committed yet. The workspace structure is defined but all packages (`core`, `dm_app`, `companion_app`) contain only `pubspec.yaml` and `.dart_tool/` directories. The conventions below describe what **should be followed** as code is added, based on the project's established tooling choices and Dart/Flutter ecosystem standards.

## Language & Runtime

**Primary Language:**
- Dart 3.11.5 (workspace-level constraint: `^3.11.5`)
- Flutter 3.41.9 (installed at `/opt/homebrew/share/flutter`)

**Package Manager:**
- `pub` with Dart workspace resolution
- Lockfile: `pubspec.lock` present at workspace root

## Workspace Structure

**Root workspace:** `pubspec.yaml` declares workspace members:
- `packages/core` — shared core library
- `apps/dm_app` — Dungeon Master Flutter app
- `apps/companion_app` — Player companion Flutter app

Each package uses `resolution: workspace` in its `pubspec.yaml`.

## Naming Conventions (Dart Standard)

**Files:**
- Use `snake_case` for file names: `network_service.dart`, `player_model.dart`
- Test files: `<source>_test.dart` co-located or in `test/` directory

**Classes & Types:**
- Use `PascalCase`: `PlayerService`, `NetworkManager`, `GameState`

**Functions & Variables:**
- Use `camelCase`: `getPlayer()`, `isConnected`, `updateState()`

**Constants:**
- Use `lowerCamelCase` for constants (Dart convention): `maxPlayers`, `defaultPort`

**Directories:**
- Use `snake_case`: `network_services/`, `game_models/`

## Code Style

**Formatting:**
- Tool: `dart format` (built-in Dart formatter)
- No custom `dart_format` config file detected
- Line length: default 80 characters (Dart standard)
- Line endings: LF normalized (`.gitattributes`: `* text=auto`)

**Linting:**
- **No `analysis_options.yaml` detected** in any package or workspace root
- **Recommendation:** Add `analysis_options.yaml` at workspace root with `package:lints` or `package:flutter_lints` as the base

**Recommended analysis_options.yaml (workspace root):**
```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    - prefer_const_constructors
    - prefer_const_declarations
    - avoid_print
    - prefer_single_quotes
```

## Import Organization

**Order (Dart standard):**
1. `dart:` imports (e.g., `dart:async`, `dart:convert`)
2. `package:` imports (e.g., `package:flutter/material.dart`, `package:core/...`)
3. Relative imports (e.g., `import '../models/player.dart'`)

**Path Aliases:**
- No custom path aliases detected
- Cross-package imports use relative paths: `package:core/...`

## Dependency Patterns

**Core package (`packages/core/pubspec.yaml`):**
- `nsd: ^5.0.1` — Network Service Discovery for local network peer finding

**App packages (`apps/*/pubspec.yaml`):**
- `flutter` (SDK dependency)
- `core` (path dependency: `../../packages/core`)

**Transitive dependencies of note:**
- `provider: 6.1.5+1` — State management (available transitively)
- `uuid: 4.5.3` — UUID generation
- `crypto: 3.0.7` — Cryptographic utilities

## Error Handling

**No source code present** — conventions not yet established.

**Recommended patterns (Dart standard):**
- Use custom exception classes extending `Exception`
- Use `Result` or `Either` types for recoverable errors
- Throw descriptive exceptions with context
- Use `try/catch` with specific exception types

## Logging

**No logging framework configured.**

**Recommended:**
- Use `dart:developer` for Flutter DevTools logging
- Consider `logger` package for structured logging
- Avoid `print()` in production code (lint rule: `avoid_print`)

## Comments & Documentation

**No source code present** — conventions not yet established.

**Recommended (Dart standard):**
- Use `///` doc comments for public APIs
- Use `//` for implementation notes
- Document all public classes, methods, and properties

## Module Design

**Exports:**
- Core package should use barrel exports: `lib/core.dart` exporting all public APIs
- Apps should import from `package:core/` not relative paths into core

**Barrel Files:**
- Recommended pattern for `packages/core/lib/core.dart`:
```dart
export 'src/models/...';
export 'src/services/...';
export 'src/utils/...';
```

## CI/CD

**No CI/CD configuration detected.**
- No `.github/workflows/` directory
- No `Makefile` or build scripts
- No `.gitignore` file

**Recommended:**
- Add `.gitignore` for Dart/Flutter projects
- Add GitHub Actions for `dart analyze`, `dart format --set-exit-if-changed`, and `dart test`

## Platform Requirements

**Development:**
- Dart SDK >= 3.11.5
- Flutter SDK >= 3.41.0
- macOS development environment (Flutter installed via Homebrew)

**Target Platforms:**
- Flutter apps (iOS, Android, macOS, Windows, Linux — not yet configured)
- Core package is pure Dart (cross-platform)

---

*Convention analysis: 2026-05-07*

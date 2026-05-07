# SaveState — AGENTS.md

## Project Overview

SaveState is a Dart workspace monorepo containing two Flutter apps and a shared core package for D&D (Dungeons & Dragons) game management.

## Workspace Structure

```
SaveState/
├── pubspec.yaml              # Workspace root (name: dnd_workspace)
├── packages/
│   └── core/                 # Shared package
│       ├── pubspec.yaml      # name: core
│       └── lib/              # Shared code (models, services, utils)
│           ├── models/       # DnD domain models (characters, items, spells, etc.)
│           ├── services/     # Shared services (network, storage, NSD discovery)
│           └── utils/        # Shared utilities and helpers
├── apps/
│   ├── companion_app/        # Player companion app (Flutter)
│   │   ├── pubspec.yaml      # name: companion_app (depends on core)
│   │   └── lib/              # App-specific Flutter UI and logic
│   │       ├── main.dart     # App entry point
│   │       ├── models/       # UI-specific models (if any)
│   │       ├── screens/      # Flutter screens/pages
│   │       ├── widgets/      # Reusable Flutter widgets
│   │       └── providers/    # State management
│   └── dm_app/               # Dungeon Master app (Flutter)
│       ├── pubspec.yaml      # name: dm_app (depends on core)
│       └── lib/              # App-specific Flutter UI and logic
│           ├── main.dart     # App entry point
│           ├── models/       # UI-specific models (if any)
│           ├── screens/      # Flutter screens/pages
│           ├── widgets/      # Reusable Flutter widgets
│           └── providers/    # State management
```

## Package Placement Rules

| Code Type | Location |
|-----------|----------|
| DnD domain models (Character, Item, Spell, etc.) | `packages/core/lib/models/` |
| Shared services (networking, storage, NSD) | `packages/core/lib/services/` |
| Shared utilities | `packages/core/lib/utils/` |
| Flutter UI for companion app | `apps/companion_app/lib/` |
| Flutter UI for DM app | `apps/dm_app/lib/` |
| App-specific state management | `apps/<app_name>/lib/providers/` |
| App-specific screens | `apps/<app_name>/lib/screens/` |
| App-specific widgets | `apps/<app_name>/lib/widgets/` |

## Key Dependencies

- **core**: `nsd ^5.0.1` (Network Service Discovery for local device discovery)
- **companion_app**: `flutter` (SDK), `core` (path dependency)
- **dm_app**: `flutter` (SDK), `core` (path dependency)

## Commands

```bash
# Run pub get for entire workspace
dart pub get

# Run pub get for a specific package
cd packages/core && dart pub get
cd apps/companion_app && flutter pub get
cd apps/dm_app && flutter pub get

# Run tests for entire workspace
dart test

# Run tests for a specific package
cd packages/core && dart test
cd apps/companion_app && flutter test
cd apps/dm_app && flutter test
```

## Conventions

- All packages use `resolution: workspace`
- Domain models go in `core` — never duplicate models across apps
- Apps depend on `core`, never on each other
- SDK constraint: `^3.11.5` (root and apps), `^3.5.0` (core)
- No packages are published (`publish_to: none`)

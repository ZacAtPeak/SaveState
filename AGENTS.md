# SaveState — AGENTS.md

## Project Overview

SaveState is a Dart workspace monorepo containing two Flutter apps and a shared core package for D&D (Dungeons & Dragons) game management. The project features a Wiki system for managing game content (monsters, NPCs, items, player characters) with local storage, search, and migration capabilities.

## Workspace Structure

```
SaveState/
├── pubspec.yaml              # Workspace root (name: dnd_workspace)
├── packages/
│   └── core/                 # Shared package
│       ├── pubspec.yaml      # name: core
│       ├── assets/
│       │   └── game_models/  # JSON game model definitions (e.g. dnd5e.json)
│       ├── lib/
│       │   ├── data/         # Demo/sample entity data
│       │   ├── migrations/   # Data migration runners
│       │   ├── models/       # DnD domain models (game_entity, item, wiki_page, etc.)
│       │   ├── services/     # Shared services (game_model, wiki_storage, wiki_search, NSD)
│       │   ├── utils/        # Shared utilities (debounce, etc.)
│       │   └── wiki/         # Wiki feature (provider, pages, modals, forms, stat blocks)
│       └── test/             # Core unit and integration tests
├── apps/
│   ├── companion_app/        # Player companion app (Flutter)
│   │   ├── pubspec.yaml      # name: companion_app (depends on core)
│   │   ├── lib/
│   │   │   ├── main.dart     # App entry point
│   │   │   └── widgets/      # Reusable Flutter widgets
│   │   ├── wiki/
│   │   │   └── pages/        # Wiki page content
│   │   └── test/             # Companion app tests
│   └── dm_app/               # Dungeon Master app (Flutter)
│       ├── pubspec.yaml      # name: dm_app (depends on core)
│       ├── lib/
│       │   ├── main.dart     # App entry point
│       │   └── widgets/      # Reusable Flutter widgets
│       ├── wiki/
│       │   └── pages/        # Wiki page content
│       └── test/             # DM app tests
```

## Package Placement Rules

| Code Type | Location |
|-----------|----------|
| DnD domain models (GameEntity, Item, WikiPage, etc.) | `packages/core/lib/models/` |
| Demo/sample data | `packages/core/lib/data/` |
| Shared services (game_model, wiki_storage, wiki_search, NSD) | `packages/core/lib/services/` |
| Wiki feature (provider, pages, modals, forms) | `packages/core/lib/wiki/` |
| Data migrations | `packages/core/lib/migrations/` |
| Shared utilities | `packages/core/lib/utils/` |
| Game model JSON definitions | `packages/core/assets/game_models/` |
| Flutter UI for companion app | `apps/companion_app/lib/` |
| Flutter UI for DM app | `apps/dm_app/lib/` |
| Wiki page content | `apps/<app_name>/wiki/pages/` |

## Key Dependencies

### core
| Package | Version | Purpose |
|---------|---------|---------|
| `nsd` | ^5.0.1 | Network Service Discovery for local device discovery |
| `uuid` | ^4.5.1 | UUID generation |
| `shelf` | ^1.4.2 | HTTP server framework |
| `http` | ^1.2.2 | HTTP client |
| `path` | ^1.9.0 | Path manipulation |
| `flutter_markdown` | ^0.7.0 | Markdown rendering |
| `provider` | ^6.1.2 | State management |

### companion_app / dm_app
| Package | Version | Purpose |
|---------|---------|---------|
| `flutter` | SDK | Flutter framework |
| `core` | path | Shared core package |
| `provider` | ^6.1.2 | State management |

## Platform Support

| App | macOS | iOS | Android | Linux | Windows | Web |
|-----|-------|-----|---------|-------|---------|-----|
| companion_app | ✅ | ✅ | ❌ | ✅ | ✅ | ✅ |
| dm_app | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

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
- SDK constraint: `^3.11.5` (root, companion_app), `^3.5.0` (core, dm_app)
- No packages are published (`publish_to: none`)
- State management uses `provider` across all packages
- Wiki content is stored as markdown pages in `apps/<app>/wiki/pages/`
- Demo data for testing lives in `packages/core/lib/data/`

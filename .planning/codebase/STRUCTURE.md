# Codebase Structure

**Analysis Date:** 2026-05-07

## Directory Layout

```
SaveState/                          # Workspace root (dnd_workspace)
├── pubspec.yaml                    # Workspace definition
├── pubspec.lock                    # Resolved dependency lockfile
├── README.md                       # Project readme (minimal)
├── .gitattributes                  # Git text normalization
├── .dart_tool/                     # Dart tooling cache
│   └── pub/                        # Package resolution data
│
├── packages/
│   └── core/                       # Shared core package
│       ├── pubspec.yaml            # Core package manifest
│       ├── .dart_tool/             # Dart tooling cache
│       └── lib/                    # [NOT YET CREATED] Shared code
│           ├── core.dart           # [PLANNED] Barrel export
│           └── src/
│               ├── models/         # [PLANNED] Shared data models
│               ├── services/       # [PLANNED] Shared services (NSD, etc.)
│               ├── protocol/       # [PLANNED] Communication protocol
│               └── utils/          # [PLANNED] Shared utilities
│
├── apps/
│   ├── dm_app/                     # Dungeon Master application
│   │   ├── pubspec.yaml            # DM app manifest
│   │   ├── .dart_tool/             # Dart tooling cache
│   │   └── lib/                    # [NOT YET CREATED] App source
│   │       ├── main.dart           # [PLANNED] Entry point
│   │       ├── app.dart            # [PLANNED] App widget
│   │       ├── screens/            # [PLANNED] Page/screen widgets
│   │       ├── widgets/            # [PLANNED] Reusable UI components
│   │       ├── providers/          # [PLANNED] Provider/state classes
│   │       └── services/           # [PLANNED] DM-specific services
│   │
│   └── companion_app/              # Player companion application
│       ├── pubspec.yaml            # Companion app manifest
│       ├── .dart_tool/             # Dart tooling cache
│       └── lib/                    # [NOT YET CREATED] App source
│           ├── main.dart           # [PLANNED] Entry point
│           ├── app.dart            # [PLANNED] App widget
│           ├── screens/            # [PLANNED] Page/screen widgets
│           ├── widgets/            # [PLANNED] Reusable UI components
│           ├── providers/          # [PLANNED] Provider/state classes
│           └── services/           # [PLANNED] Player-specific services
```

## Directory Purposes

### Workspace Root (`/`)
- **Purpose:** Dart workspace definition and shared configuration
- **Contains:** `pubspec.yaml` (workspace), `pubspec.lock`, top-level tooling
- **Key files:** `pubspec.yaml` - defines workspace members and SDK constraint

### Core Package (`packages/core/`)
- **Purpose:** Shared code between DM and companion apps
- **Contains:** Data models, network protocol, service abstractions, utilities
- **Key files:** `pubspec.yaml` - declares `nsd` dependency
- **Planned structure:**
  - `lib/core.dart` - barrel export for all public APIs
  - `lib/src/models/` - D&D game data models (characters, sessions, etc.)
  - `lib/src/services/` - NSD discovery service, connection management
  - `lib/src/protocol/` - message types for app-to-app communication
  - `lib/src/utils/` - shared helper functions

### DM App (`apps/dm_app/`)
- **Purpose:** Dungeon Master-facing Flutter application
- **Contains:** UI, DM-specific business logic, session hosting
- **Key files:** `pubspec.yaml` - depends on `flutter` (sdk) and `core` (path)
- **SDK constraint:** ^3.5.0
- **Planned structure:**
  - `lib/main.dart` - app entry point
  - `lib/screens/` - full-page views (session setup, game management, etc.)
  - `lib/widgets/` - reusable UI components
  - `lib/providers/` - state management via Provider
  - `lib/services/` - DM-specific services (hosting, game master tools)

### Companion App (`apps/companion_app/`)
- **Purpose:** Player-facing Flutter companion application
- **Contains:** UI, player-specific business logic, session joining
- **Key files:** `pubspec.yaml` - depends on `flutter` (sdk) and `core` (path)
- **SDK constraint:** ^3.11.5 (newer than dm_app)
- **Planned structure:**
  - `lib/main.dart` - app entry point
  - `lib/screens/` - full-page views (session browser, character sheet, etc.)
  - `lib/widgets/` - reusable UI components
  - `lib/providers/` - state management via Provider
  - `lib/services/` - player-specific services (discovery, joining)

## Key File Locations

### Entry Points
- `apps/dm_app/lib/main.dart` - DM app entry (not yet created)
- `apps/companion_app/lib/main.dart` - Companion app entry (not yet created)

### Configuration
- `pubspec.yaml` - Workspace root, defines 3 workspace members
- `packages/core/pubspec.yaml` - Core package with `nsd ^5.0.1` dependency
- `apps/dm_app/pubspec.yaml` - DM app, depends on flutter + core
- `apps/companion_app/pubspec.yaml` - Companion app, depends on flutter + core
- `pubspec.lock` - Resolved dependency versions (Flutter 3.41.9, Dart 3.11.5)

### Core Logic
- `packages/core/lib/` - Shared package (not yet created)

### Testing
- No test directories or test configuration detected
- Expected: `packages/core/test/`, `apps/dm_app/test/`, `apps/companion_app/test/`

## Naming Conventions

**Files:**
- Dart files: `snake_case.dart` (standard Dart convention)
- Entry point: `main.dart`
- Barrel exports: `<package_name>.dart` (e.g., `core.dart`)

**Directories:**
- `snake_case` for all directories (e.g., `dm_app`, `companion_app`, `core`)
- Feature directories: plural nouns (`screens/`, `widgets/`, `providers/`, `services/`)

**Packages:**
- Package names: `snake_case` (`dm_app`, `companion_app`, `core`)

## Dependency Resolution

**Workspace pattern:** All packages use `resolution: workspace` for unified dependency resolution from the workspace root.

**Path dependencies:**
```yaml
# In apps/dm_app/pubspec.yaml and apps/companion_app/pubspec.yaml
dependencies:
  core:
    path: ../../packages/core
```

## Where to Add New Code

### New Shared Model/Type
- **Location:** `packages/core/lib/src/models/<model_name>.dart`
- **Export from:** `packages/core/lib/core.dart`
- **Tests:** `packages/core/test/src/models/<model_name>_test.dart`

### New Shared Service
- **Location:** `packages/core/lib/src/services/<service_name>.dart`
- **Export from:** `packages/core/lib/core.dart`
- **Tests:** `packages/core/test/src/services/<service_name>_test.dart`

### New Screen (DM App)
- **Location:** `apps/dm_app/lib/screens/<screen_name>_screen.dart`
- **If needs state:** Add provider to `apps/dm_app/lib/providers/`

### New Screen (Companion App)
- **Location:** `apps/companion_app/lib/screens/<screen_name>_screen.dart`
- **If needs state:** Add provider to `apps/companion_app/lib/providers/`

### New Reusable Widget
- **App-specific:** `apps/<app_name>/lib/widgets/<widget_name>.dart`
- **Shared between apps:** `packages/core/lib/src/widgets/<widget_name>.dart`

### New Protocol Message
- **Location:** `packages/core/lib/src/protocol/<message_type>.dart`
- **Export from:** `packages/core/lib/core.dart`

## Special Directories

### `.dart_tool/`
- **Purpose:** Dart SDK tooling cache (package resolution, build artifacts)
- **Generated:** Yes, by `dart pub get` / `flutter pub get`
- **Committed:** No (should be in `.gitignore`)
- **Contains:** `pub/workspace_ref.json` per package, `package_config.json` at root

### `.planning/`
- **Purpose:** GSD planning documents and codebase analysis
- **Generated:** Yes, by GSD tooling
- **Contains:** `codebase/` directory with architecture and structure docs

## Platform-Sirectories (Expected for Flutter)

When Flutter projects are fully initialized, each app will also contain:
- `android/` - Android platform code
- `ios/` - iOS platform code
- `macos/` - macOS platform code
- `windows/` - Windows platform code
- `linux/` - Linux platform code (optional)
- `web/` - Web platform code (optional)
- `assets/` - Static assets (images, fonts, etc.)
- `test/` - Test files

These directories are not yet present - the apps are in pre-initialization state.

---

*Structure analysis: 2026-05-07*

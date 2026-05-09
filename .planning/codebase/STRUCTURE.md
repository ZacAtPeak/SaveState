# Codebase Structure

**Analysis Date:** 2026-05-09

## Directory Layout

```
SaveState/
├── lib/                    # Dart source code
│   ├── main.dart           # Application entry point
│   └── ttrpg_data/         # TTRPG data SQL files (future use)
├── test/                   # Flutter widget tests
├── web/                    # Web platform files
├── macos/                  # macOS platform files
├── ios/                    # iOS platform files
├── android/                # Android platform files
├── linux/                  # Linux platform files
├── windows/                # Windows platform files
├── .planning/              # GSD planning artifacts
├── pubspec.yaml            # Flutter dependencies manifest
├── pubspec.lock            # Dependency lock file
└── analysis_options.yaml   # Dart linting rules
```

## Directory Purposes

**lib/:**
- Purpose: Contains all Dart source code for the application
- Contains: main.dart, ttrpg_data/ subdirectory
- Key files: `lib/main.dart` (single file currently)

**test/:**
- Purpose: Flutter widget and integration tests
- Contains: `widget_test.dart` (default template test)

**lib/ttrpg_data/:**
- Purpose: TTRPG (Tabletop Role-Playing Game) data SQL files for future database features
- Contains: call_of_cthulhu.sql, cyberpunk_red.sql, dnd5e.sql, pathfinder2e.sql, vampire_masquerade.sql, warhammer_fantasy.sql

## Key File Locations

**Entry Points:**
- `lib/main.dart`: Application entry point (122 lines)

**Configuration:**
- `pubspec.yaml`: Flutter project manifest with SDK requirements and dependencies
- `analysis_options.yaml`: Dart linting configuration

**Testing:**
- `test/widget_test.dart`: Default Flutter widget test

## Naming Conventions

**Files:**
- Dart source files: `snake_case.dart`
- SQL data files: `snake_case.sql`
- Test files: `snake_case_test.dart` or `snake_case_spec.dart`

**Directories:**
- All directories use `snake_case`: `lib/`, `ttrpg_data/`, `.planning/`

**Classes:**
- Flutter widgets: PascalCase (e.g., `MyApp`, `MyHomePage`)
- State classes: PascalCase with `State` suffix (e.g., `_MyHomePageState`)
- Private classes: Prefix with underscore `_MyHomePageState`

**Variables:**
- Private variables: Prefix with underscore `_counter`
- Public variables: camelCase `someVariable`

## Where to Add New Code

**New Feature:**
- Primary code: Add to `lib/` directory, create new `.dart` file per feature
- Tests: Add to `test/` directory following `_test.dart` naming

**New Widget/Component:**
- Implementation: Create new `.dart` file in `lib/`
- Associated tests: Create `test/{feature}_test.dart`

**Utilities:**
- Shared helpers: Create `lib/utils/` directory for utility classes
- Constants: Create `lib/constants/` directory

**Data Layer (future):**
- Database code: Create `lib/data/` or `lib/database/` directory
- Models: Create `lib/models/` directory
- Repositories: Create `lib/repositories/` directory

## Special Directories

**.planning/:**
- Purpose: GSD planning artifacts for codebase mapping and phase planning
- Contains: `codebase/` (this analysis), `quick/` directory
- Generated: Yes (by GSD workflow)
- Committed: Yes

**ttrpg_data/:**
- Purpose: Store TTRPG system data as SQL files
- Contains: 6 SQL files for different tabletop RPG systems
- Generated: No (pre-existing data files)
- Committed: Yes

**Platform directories (macos/, ios/, android/, linux/, windows/):**
- Purpose: Platform-specific Flutter runner code
- Generated: Yes (flutter create bootstrap)
- Committed: Yes (except ephemeral build artifacts)

---

*Structure analysis: 2026-05-09*
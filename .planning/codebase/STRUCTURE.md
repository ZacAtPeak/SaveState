# Codebase Structure

**Analysis Date:** 2026-05-07

## Directory Layout

```
SaveState/
├── pubspec.yaml              # Workspace root (name: dnd_workspace)
├── pubspec.lock              # Resolved dependency lockfile
├── AGENTS.md                 # Agent instructions
├── CLAUDE.md                 # Claude-specific project context
├── README.md                 # Project readme (minimal)
├── packages/
│   └── core/                 # Shared domain package
│       ├── pubspec.yaml      # name: core, resolution: workspace
│       └── lib/
│           ├── data/         # Demo/fixture data
│           │   ├── data.dart           # Barrel export
│           │   ├── demo_monsters.dart  # 15 demo monsters as JSON → Monster
│           │   ├── demo_npcs.dart      # 8 demo NPCs as JSON → NPC
│           │   └── demo_player_characters.dart  # 5 demo PCs as constructors
│           └── models/       # D&D domain models
│               ├── models.dart         # Barrel export (excludes encounter.dart)
│               ├── enums.dart          # All enums (CreatureSize, CreatureType, etc.)
│               ├── value_types.dart    # Composite value types (AbilityScores, etc.)
│               ├── player_character.dart  # PlayerCharacter model
│               ├── monster.dart        # Monster model
│               ├── npc.dart            # NPC model
│               ├── item.dart           # Item model
│               └── encounter.dart      # EncounterState, EncounterEntry, DiceRoll (NOT exported)
├── apps/
│   ├── companion_app/        # Player companion Flutter app
│   │   ├── pubspec.yaml      # name: companion_app, depends on core + provider
│   │   ├── analysis_options.yaml  # Uses flutter_lints (default config)
│   │   ├── lib/
│   │   │   ├── main.dart     # Entry point + CompanionApp + HomeScreen (tab shell)
│   │   │   └── widgets/
│   │   │       └── generic_tab_view.dart  # Reusable tab bar widget
│   │   └── test/
│   │       └── widget_test.dart  # Default Flutter smoke test (references MyApp — broken)
│   └── dm_app/               # Dungeon Master Flutter app
│       ├── pubspec.yaml      # name: dm_app, depends on core + provider
│       ├── analysis_options.yaml  # Uses flutter_lints (default config)
│       ├── lib/
│       │   ├── main.dart     # Entry point + DmApp + HomeScreen (sidebar + tracker + detail)
│       │   └── widgets/
│       │       ├── creature_detail_view.dart  # CreatureDetail + CreatureDetailView (757 lines)
│       │       ├── initiative_tracker.dart    # InitiativeTracker + DTOs (481 lines)
│       │       └── roll_history_panel.dart    # RollHistoryPanel drawer (111 lines)
│       └── test/
│           └── widget_test.dart  # Basic scaffold load test
```

## Directory Purposes

**`packages/core/lib/models/`:**
- Purpose: All D&D domain models and supporting types
- Contains: Model classes with `toJson`/`fromJson`, enums, value types
- Key files: `player_character.dart`, `monster.dart`, `npc.dart`, `item.dart`, `encounter.dart`
- Barrel: `models.dart` exports all except `encounter.dart`

**`packages/core/lib/data/`:**
- Purpose: Demo/fixture data for development and testing
- Contains: Hardcoded monster/NPC/PC data as JSON maps or direct constructors
- Barrel: `data.dart` exports all four demo files

**`apps/companion_app/lib/`:**
- Purpose: Player-facing Flutter UI
- Contains: Entry point, screens, widgets
- Current state: Skeleton with tab shell only

**`apps/dm_app/lib/`:**
- Purpose: DM-facing Flutter UI
- Contains: Entry point, combat tracker, creature detail, roll history
- Current state: Functional initiative tracker with drag-and-drop

**`apps/<app>/lib/widgets/`:**
- Purpose: Reusable Flutter widget components
- Contains: Self-contained widgets with their own state logic
- Note: No `screens/` or `providers/` directories yet — all UI lives in `widgets/` or `main.dart`

## Key File Locations

**Entry Points:**
- `apps/dm_app/lib/main.dart`: DM app root widget and stateful home screen
- `apps/companion_app/lib/main.dart`: Companion app root widget and tab shell

**Configuration:**
- `pubspec.yaml`: Workspace root — defines workspace members and SDK constraint
- `packages/core/pubspec.yaml`: Core package — declares nsd, uuid, shelf, http
- `apps/companion_app/pubspec.yaml`: Companion app — declares flutter, core, provider
- `apps/dm_app/pubspec.yaml`: DM app — declares flutter, core, provider

**Core Logic:**
- `packages/core/lib/models/`: Domain models (immutable, JSON-serializable)
- `packages/core/lib/data/`: Demo data factories

**Testing:**
- `apps/companion_app/test/widget_test.dart`: Default smoke test (broken — references `MyApp`)
- `apps/dm_app/test/widget_test.dart`: Scaffold load test

## Naming Conventions

**Files:**
- Models: `snake_case.dart` (e.g., `player_character.dart`, `value_types.dart`)
- Widgets: `snake_case.dart` (e.g., `creature_detail_view.dart`, `initiative_tracker.dart`)
- Barrel exports: `plural.dart` (e.g., `models.dart`, `data.dart`)
- Demo data: `demo_<plural>.dart` (e.g., `demo_monsters.dart`)

**Classes:**
- Models: `PascalCase` (e.g., `PlayerCharacter`, `Monster`, `AbilityScores`)
- Widgets: `PascalCase` ending in type (e.g., `CreatureDetailView`, `InitiativeTracker`)
- Private widgets: `_PascalCase` (e.g., `_Sidebar`, `_SidebarSection`, `_AbilityCard`)
- DTOs: `PascalCase` with `Data` suffix (e.g., `CombatantDragData`)

**Variables/Functions:**
- camelCase for local variables and methods
- `_leadingUnderscore` for private members
- Factory constructors: `from<SourceType>` (e.g., `fromPlayerCharacter`, `fromMonster`)

## Where to Add New Code

**New Domain Model:**
- Implementation: `packages/core/lib/models/<model_name>.dart`
- Export: Add to `packages/core/lib/models/models.dart` barrel
- Demo data: Add to `packages/core/lib/data/demo_<model_name>.dart` + export in `data.dart`

**New DM App Feature (screen/widget):**
- Implementation: `apps/dm_app/lib/widgets/<feature_name>.dart`
- Integration: Import in `apps/dm_app/lib/main.dart` and wire into `HomeScreen`

**New Companion App Feature (screen/widget):**
- Implementation: `apps/companion_app/lib/widgets/<feature_name>.dart`
- Integration: Import in `apps/companion_app/lib/main.dart` and add as `TabData` to `GenericTabView`

**New Shared Service (networking, storage):**
- Implementation: `packages/core/lib/services/<service_name>.dart`
- Export: Create `packages/core/lib/services/services.dart` barrel

**New State Management (Provider):**
- Provider class: `apps/<app>/lib/providers/<feature>_provider.dart`
- Integration: Wrap relevant subtree in `ChangeNotifierProvider`

**New Utility/Helper:**
- Shared: `packages/core/lib/utils/<helper_name>.dart`
- App-specific: `apps/<app>/lib/utils/<helper_name>.dart`

## Special Directories

**`apps/<app>/android/`, `ios/`, `linux/`, `macos/`, `web/`, `windows/`:**
- Purpose: Platform-specific Flutter build configurations
- Generated: Yes — by `flutter create`
- Committed: Yes — standard Flutter project structure
- Modification: Rarely touched directly; configured via Flutter tooling

**`.dart_tool/`:**
- Purpose: Dart build cache and package resolution artifacts
- Generated: Yes — by `dart pub get` and `flutter run`
- Committed: No — in `.gitignore`

**`packages/core/lib/models/encounter.dart`:**
- Purpose: Encounter state and dice roll models
- Status: **Not exported** in barrel file — currently orphaned
- Contains: `EncounterEntry`, `EncounterState`, `DiceRoll`

---

*Structure analysis: 2026-05-07*

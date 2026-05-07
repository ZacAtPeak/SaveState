# SaveState — CLAUDE.md

SaveState is a Dart workspace monorepo for D&D campaign management. It contains two Flutter apps (`companion_app` for players, `dm_app` for Dungeon Masters) and a shared `core` package for all domain models and data.

See `AGENTS.md` for the authoritative package placement rules, workspace structure, and common commands.

## Tech Stack

- **Dart SDK**: `^3.11.5` (workspace root and apps), `^3.5.0` (core)
- **Flutter**: `>=3.41.0`
- **State management**: `provider ^6.1.2` (declared but not wired up yet — current code uses `StatefulWidget`/`setState`)
- **Network discovery**: `nsd ^5.0.1` (for LAN-based DM↔player sync)
- **HTTP client/server**: `http ^1.2.2`, `shelf ^1.4.2` (declared but not yet used)
- **Design system**: Material 3 (`useMaterial3: true`, deep purple seed color)

## Architecture

All D&D domain models live exclusively in `packages/core/lib/models/`. Apps only contain Flutter UI, screens, widgets, and app-specific state. Apps never depend on each other.

**Core model hierarchy:**
- `PlayerCharacter` — PC stat block (abilities, HP, AC, skills, spells, initiative)
- `Monster` — Creature stat block (CR, XP, legendary actions, lair actions)
- `NPC` — Non-player character (role, biography, no CR/XP)
- `EncounterEntry` / `EncounterState` — Combat tracker state
- `DiceRoll` — Roll result with metadata

All models support `toJson`/`fromJson`. Value types (ability scores, movement, senses, attacks, etc.) are in `value_types.dart`. Enums are in `enums.dart`.

Demo/fixture data is in `packages/core/lib/data/` — three files for PCs, monsters, and NPCs.

## Current Implementation Status

| Area | Status |
|------|--------|
| Core domain models | Complete |
| Demo fixture data | Complete (~1100 lines) |
| DM app initiative tracker | Functional (HP tracking, turn order, status conditions) |
| Companion app | Skeleton only (tab shell with placeholder content) |
| Networking (NSD/shelf/http) | Declared, not yet implemented |
| Provider state management | Declared, not yet wired |

## Key Conventions

- **No model duplication**: If a model belongs in `core`, put it there. Apps may have UI-specific models only.
- **Barrel exports**: Each package/directory uses a `*.dart` barrel file (e.g., `models.dart`, `data.dart`).
- **No cross-app imports**: `companion_app` and `dm_app` must not import each other.
- **JSON serialization**: New models need `toJson`/`fromJson` factories following the existing pattern in `models/`.
- **Provider pattern**: New stateful features should use Provider (already a dependency) rather than adding more `setState` usage.
- **Analysis options**: No `analysis_options.yaml` exists yet — don't assume strict lint rules are enforced.

## Development Commands

```bash
# From workspace root
dart pub get          # resolve all packages
dart test             # run all tests

# App-specific (run flutter commands from the app directory)
cd apps/dm_app && flutter run
cd apps/companion_app && flutter run
cd apps/dm_app && flutter test
cd apps/companion_app && flutter test
```

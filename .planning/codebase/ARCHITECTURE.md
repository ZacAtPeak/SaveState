# Architecture

**Analysis Date:** 2026-05-07

## Pattern Overview

**Overall:** Multi-app Flutter workspace with shared core package, designed for peer-to-peer local network communication between a Dungeon Master (DM) app and a Player Companion app.

**Key Characteristics:**
- Dart workspace resolution (`resolution: workspace`) for unified dependency management
- Shared `core` package for common models, services, and utilities
- Network Service Discovery (NSD) for local network peer discovery and communication
- Provider-based state management (resolved dependency)
- Two independent Flutter apps with distinct roles sharing a common protocol layer

## Project: SaveState

A D&D (Dungeons & Dragons) tooling system consisting of two apps that communicate over a local network:
- **DM App** (`dm_app`) - Run by the Dungeon Master, likely hosts the game session
- **Companion App** (`companion_app`) - Run by players, connects to the DM's session

## Layers

### Shared Core Layer
- **Purpose:** Common types, models, protocols, and services shared between both apps
- **Location:** `packages/core/`
- **Contains:** Data models, network protocol definitions, shared utilities, NSD service wrappers
- **Depends on:** `nsd` (Network Service Discovery), `uuid`, `crypto`
- **Used by:** Both `dm_app` and `companion_app`

### Application Layer (DM App)
- **Purpose:** Dungeon Master-facing Flutter application
- **Location:** `apps/dm_app/`
- **Contains:** UI widgets, screens, DM-specific business logic, session hosting
- **Depends on:** `flutter`, `core`
- **Used by:** End user (Dungeon Master)

### Application Layer (Companion App)
- **Purpose:** Player-facing Flutter companion application
- **Location:** `apps/companion_app/`
- **Contains:** UI widgets, screens, player-specific business logic, session joining
- **Depends on:** `flutter`, `core`
- **Used by:** End user (Player)

## Data Flow

### Session Discovery and Connection Flow (Intended)

1. **DM App** starts and registers a network service via NSD (service type likely `_savestate._tcp`)
2. **Companion App** scans for available NSD services on the local network
3. **Companion App** discovers the DM's service and initiates a connection
4. **Peer-to-peer communication** established between the two apps for game state sync

**State Management:**
- `provider` (v6.1.5+) is resolved as a transitive dependency, indicating Provider pattern will be used
- State likely flows through `ChangeNotifier` or `Riverpod`-style providers
- Game state synchronization happens over the NSD-discovered connection

### Network Communication

**Discovery Layer:**
- `nsd` package (v5.0.1) provides cross-platform Network Service Discovery
- Platform implementations resolved: `nsd_android` (2.2.0), `nsd_ios` (3.0.1), `nsd_macos` (3.0.1), `nsd_windows` (3.0.1)
- All route through `nsd_platform_interface` (2.2.0)

**Identity & Security:**
- `uuid` (v4.5.3) for generating unique session/player identifiers
- `crypto` (v3.0.7) for cryptographic operations (likely session tokens, message signing)

## Key Abstractions

### Network Service (NSD)
- **Purpose:** Local network peer discovery without requiring internet or central server
- **Expected location in core:** `packages/core/lib/src/services/discovery_service.dart` (not yet created)
- **Pattern:** Service wrapper around `nsd` package providing app-specific service registration and discovery

### Game Session
- **Purpose:** Represent an active D&D game session with state, players, and DM
- **Expected location in core:** `packages/core/lib/src/models/` (not yet created)
- **Pattern:** Likely immutable data classes with serialization support

### Communication Protocol
- **Purpose:** Define message types and serialization between DM and companion apps
- **Expected location in core:** `packages/core/lib/src/protocol/` (not yet created)
- **Pattern:** Message types with JSON or binary serialization

## Entry Points

### DM App
- **Location:** `apps/dm_app/lib/main.dart` (not yet created)
- **Triggers:** User launches the app
- **Responsibilities:** Initialize NSD service registration, present DM UI, host game session

### Companion App
- **Location:** `apps/companion_app/lib/main.dart` (not yet created)
- **Triggers:** User launches the app
- **Responsibilities:** Scan for DM services, present player UI, join game session

### Core Package
- **Location:** `packages/core/lib/core.dart` (barrel export, not yet created)
- **Triggers:** Imported by both apps
- **Responsibilities:** Export shared models, services, and utilities

## Error Handling

**Strategy:** Not yet implemented - project is in scaffolding phase.

**Expected Patterns (based on Flutter conventions):**
- Result/Either types for network operations
- Exception classes in `packages/core/lib/src/exceptions/`
- UI-level error display via Provider state

## Cross-Cutting Concerns

**Logging:** Not yet configured. Expected to use `debugPrint` or a logging package added to core.

**Validation:** Not yet implemented. Expected model-level validation in core package.

**Authentication:** Not required - local network communication with NSD-based discovery. Session identity handled via UUID tokens.

**Serialization:** Not yet implemented. Expected JSON serialization for network messages, likely using `json_serializable` or manual `toJson`/`fromJson` methods.

## Platform Support

**Target Platforms (inferred from NSD platform plugins):**
- Android (nsd_android 2.2.0)
- iOS (nsd_ios 3.0.1)
- macOS (nsd_macos 3.0.1)
- Windows (nsd_windows 3.0.1)

**Flutter Version:** 3.41.9
**Dart SDK:** ^3.11.5 (workspace), ^3.5.0 (core, dm_app), ^3.11.5 (companion_app)

## Dependency Graph

```
dnd_workspace (workspace root)
├── core
│   ├── nsd ^5.0.1
│   │   ├── nsd_android ^2.2.0
│   │   ├── nsd_ios ^3.0.1
│   │   ├── nsd_macos ^3.0.1
│   │   ├── nsd_windows ^3.0.1
│   │   └── nsd_platform_interface ^2.2.0
│   ├── uuid (transitive) ^4.5.3
│   └── crypto (transitive) ^3.0.7
├── dm_app
│   ├── flutter (sdk)
│   ├── core (path dependency)
│   └── provider (transitive) ^6.1.5+1
└── companion_app
    ├── flutter (sdk)
    ├── core (path dependency)
    └── provider (transitive) ^6.1.5+1
```

---

*Architecture analysis: 2026-05-07*

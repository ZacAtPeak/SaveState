# External Integrations

**Analysis Date:** 2026-05-07

## APIs & External Services

**Network Service Discovery (NSD):**
- `nsd` ^5.0.1 — Local network device discovery for app-to-app communication
  - Platform implementations: `nsd_android` 2.2.0, `nsd_ios` 3.0.1, `nsd_macos` 3.0.1, `nsd_windows` 3.0.1
  - Registered in macOS `GeneratedPluginRegistrant.swift` for both apps
  - Purpose: Enable companion_app and dm_app to discover each other on local network
  - Declared in: `packages/core/pubspec.yaml`

**HTTP Client:**
- `http` ^1.6.0 — HTTP client for network requests
  - Declared in: `packages/core/pubspec.yaml`
  - Current usage: Not actively imported in any `.dart` files (dependency present but unused)

**HTTP Server:**
- `shelf` ^1.4.2 — Lightweight HTTP server framework
  - Declared in: `packages/core/pubspec.yaml`
  - Current usage: Not actively imported in any `.dart` files (dependency present but unused)

## Data Storage

**Databases:**
- None — No database integration detected

**File Storage:**
- Local filesystem only — No cloud storage integration

**Serialization:**
- Manual JSON serialization — All domain models implement `toJson()` / `fromJson()`
  - `PlayerCharacter` (`packages/core/lib/models/player_character.dart`)
  - `Monster` (`packages/core/lib/models/monster.dart`)
  - `NPC` (`packages/core/lib/models/npc.dart`)
  - `Item` (`packages/core/lib/models/item.dart`)
  - `EncounterEntry`, `EncounterState`, `DiceRoll` (`packages/core/lib/models/encounter.dart`)
  - Value types: `AbilityScores`, `MovementSpeed`, `Senses`, `SkillProficiency`, `SpecialAbility`, `Attack`, `LegendaryAction`, `SpellSlot`, `StatusCondition` (`packages/core/lib/models/value_types.dart`)

**Caching:**
- None detected

## Authentication & Identity

**Auth Provider:**
- None — No authentication system implemented

**Entity Identification:**
- `uuid` ^4.5.1 (locked: 4.5.3) — UUID v4 generation
  - Used for auto-generating IDs on all domain entities when not provided
  - Pattern: `id = id ?? const Uuid().v4()` in constructors

## Monitoring & Observability

**Error Tracking:**
- None

**Logs:**
- None — No logging framework in use

## CI/CD & Deployment

**Hosting:**
- Not configured — No deployment target detected

**CI Pipeline:**
- None — No `.github/workflows/`, `.gitlab-ci.yml`, or equivalent

**Build Automation:**
- None — No Makefile, shell scripts, or build automation

## Environment Configuration

**Required env vars:**
- None detected — No environment variable usage

**Secrets location:**
- None — No secret management

## Webhooks & Callbacks

**Incoming:**
- None detected

**Outgoing:**
- None detected

## Inter-App Communication (Planned)

**Local Network Discovery:**
- NSD (`nsd` package) is the intended mechanism for companion_app ↔ dm_app communication
- Both apps declare NSD as a transitive dependency via the `core` package
- Platform plugins are registered for macOS, Android, iOS, and Windows
- **Current state:** NSD is declared but not actively used in any Dart source files — no `import 'package:nsd/...'` found in `.dart` files
- `shelf` and `http` are also declared in core but not actively imported — likely reserved for future local HTTP server/client communication between apps

## State Management Integration

**Provider:**
- `provider` ^6.1.2 (locked: 6.1.5+1) — Declared in both apps
- **Current state:** Not actively used — no `import 'package:provider/...'` found in any `.dart` files
- Both apps currently use `StatefulWidget` / `setState` for local state management

## Third-Party Package Summary

| Package | Version | Declared In | Actively Used | Purpose |
|---------|---------|-------------|---------------|---------|
| `nsd` | 5.0.1 | core | No (platform plugins registered) | Local device discovery |
| `uuid` | 4.5.3 | core | Yes | Entity ID generation |
| `shelf` | 1.4.2 | core | No | HTTP server (reserved) |
| `http` | 1.6.0 | core | No | HTTP client (reserved) |
| `provider` | 6.1.5+1 | apps | No | State management (reserved) |
| `flutter` | SDK | apps | Yes | UI framework |
| `flutter_test` | SDK | apps (dev) | Yes | Widget testing |
| `flutter_lints` | transitive | apps | Yes | Lint rules |

---

*Integration audit: 2026-05-07*

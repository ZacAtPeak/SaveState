# Technology Stack

**Analysis Date:** 2026-05-07

## Languages

**Primary:**
- Dart 3.11.5+ — All application code across workspace (core package, companion_app, dm_app)

**Secondary:**
- Swift — macOS platform code for both apps (AppDelegate, MainFlutterWindow, GeneratedPluginRegistrant)

## Runtime

**Environment:**
- Flutter SDK >=3.41.0 — UI framework for both mobile/desktop apps
- Dart SDK >=3.11.5 <4.0.0 — Language runtime (root workspace constraint)
  - Core package uses looser constraint: `^3.5.0`

**Package Manager:**
- `dart pub` with workspace resolution
- Lockfile: `pubspec.lock` present (workspace-level)

## Frameworks

**Core:**
- Flutter (SDK) — Cross-platform UI framework for companion_app and dm_app
- Material 3 — Both apps use `useMaterial3: true` with `ColorScheme.fromSeed()` theming

**State Management:**
- Provider 6.1.5+1 — Declared dependency in both apps (`companion_app`, `dm_app`)

**Testing:**
- flutter_test (SDK) — Widget testing framework (bundled with Flutter SDK)

**Build/Dev:**
- Dart workspace resolution — All packages use `resolution: workspace`
- flutter_lints — Lint rules via `analysis_options.yaml` in both apps

## Key Dependencies

**Direct (core package):**

| Package | Version | Purpose |
|---------|---------|---------|
| `nsd` | ^5.0.1 | Network Service Discovery — local device discovery for app-to-app communication |
| `uuid` | ^4.5.1 | UUID generation — entity ID creation (PlayerCharacter, Monster, NPC, Item, EncounterEntry) |
| `shelf` | ^1.4.2 | HTTP server — likely for local API serving between apps |
| `http` | ^1.6.0 | HTTP client — network requests |

**Direct (apps):**

| Package | Version | Purpose |
|---------|---------|---------|
| `provider` | ^6.1.2 | State management — declared in both apps |
| `core` | path: ../../packages/core | Shared domain models and data |

**Transitive (locked versions):**

| Package | Version | Notes |
|---------|---------|-------|
| `nsd_android` | 2.2.0 | NSD Android platform implementation |
| `nsd_ios` | 3.0.1 | NSD iOS platform implementation |
| `nsd_macos` | 3.0.1 | NSD macOS platform implementation (actively imported in GeneratedPluginRegistrant) |
| `nsd_windows` | 3.0.1 | NSD Windows platform implementation |
| `nsd_platform_interface` | 2.2.0 | NSD platform interface |

## Configuration

**Environment:**
- No `.env` files detected — no environment variable configuration
- All configuration is code-level (hardcoded demo data, theme seeds)

**Linting:**
- `analysis_options.yaml` in `apps/companion_app/` and `apps/dm_app/`
- Both include `package:flutter_lints/flutter.yaml` with no custom rules enabled

**Build:**
- No CI/CD pipeline detected (no `.github/`, `.gitlab-ci.yml`, Makefile, Dockerfile)
- No custom build configuration beyond Flutter defaults

## Platform Support

**Confirmed:**
- macOS — Full platform directories present for both apps (`macos/Runner/`, `macos/Flutter/`)
- NSD plugins registered for macOS in both apps

**Declared (via NSD platform plugins):**
- Android (`nsd_android`)
- iOS (`nsd_ios`)
- Windows (`nsd_windows`)

**Not detected:**
- Linux platform directories
- Web platform configuration

## Package Placement

| Code Type | Location |
|-----------|----------|
| DnD domain models | `packages/core/lib/models/` |
| Demo data | `packages/core/lib/data/` |
| Companion app UI | `apps/companion_app/lib/` |
| DM app UI | `apps/dm_app/lib/` |
| Tests | `apps/<app>/test/` |

## SDK Constraints

```yaml
# Root workspace
sdk: '^3.11.5'

# Core package (more permissive)
sdk: ^3.5.0

# Both apps
sdk: ^3.11.5
```

## Version Summary

```
Dart SDK:       >=3.11.5 <4.0.0
Flutter SDK:    >=3.41.0
nsd:            5.0.1
uuid:           4.5.3
shelf:          1.4.2
http:           1.6.0
provider:       6.1.5+1
```

---

*Stack analysis: 2026-05-07*

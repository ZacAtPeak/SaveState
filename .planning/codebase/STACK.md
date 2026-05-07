# Technology Stack

**Analysis Date:** 2026-05-07

## Languages

**Primary:**
- Dart 3.11.5 - All application code across workspace packages

## Runtime

**Environment:**
- Flutter 3.41.9 - UI framework and runtime for both apps
- Dart SDK 3.11.5 - Language runtime

**Package Manager:**
- pub (Dart package manager)
- Lockfile: `pubspec.lock` present with fully resolved dependency tree
- Pub cache: `/Users/zacharyreyes/.pub-cache`

**Flutter Root:** `/opt/homebrew/share/flutter` (Homebrew installation on macOS ARM)

## Frameworks

**Core:**
- Flutter 3.41.9 - Cross-platform UI framework for both `dm_app` and `companion_app`

**State Management:**
- Provider 6.1.5+1 - Available transitively via `nsd_platform_interface` dependency

## Workspace Structure

**Root Workspace:** `dnd_workspace` (`pubspec.yaml`)
- Uses Dart workspace resolution (`resolution: workspace`)
- Three member packages:
  - `packages/core` - Shared core library (v0.0.1)
  - `apps/dm_app` - Dungeon Master application (v1.0.0+1)
  - `apps/companion_app` - Player companion application (v1.0.0+1)

## Key Dependencies

### Direct Dependencies

| Package | Version | Where | Purpose |
|---------|---------|-------|---------|
| `flutter` | SDK | `apps/dm_app/pubspec.yaml:8`, `apps/companion_app/pubspec.yaml:8` | UI framework |
| `core` | path | `apps/dm_app/pubspec.yaml:10`, `apps/companion_app/pubspec.yaml:10` | Shared library (local) |
| `nsd` | ^5.0.1 | `packages/core/pubspec.yaml:8` | Network Service Discovery |

### Transitive Dependencies (Resolved)

**Flutter Core:**
- `characters` 1.4.1 - String/grapheme handling
- `collection` 1.19.1 - Extended collection types
- `material_color_utilities` 0.13.0 - Material Design color system
- `meta` 1.17.0 - Annotations and metadata
- `vector_math` 2.2.0 - Vector/matrix math
- `sky_engine` - Flutter engine bindings

**NSD (Network Service Discovery):**
- `nsd` 5.0.1 - Main NSD API
- `nsd_android` 2.2.0 - Android platform implementation
- `nsd_ios` 3.0.1 - iOS platform implementation
- `nsd_macos` 3.0.1 - macOS platform implementation
- `nsd_windows` 3.0.1 - Windows platform implementation
- `nsd_platform_interface` 2.2.0 - Platform interface contract

**NSD Transitive:**
- `provider` 6.1.5+1 - State management (used by NSD platform interface)
- `plugin_platform_interface` 2.1.8 - Flutter plugin base
- `nested` 1.0.0 - Nested widget support
- `uuid` 4.5.3 - UUID generation
- `crypto` 3.0.7 - Cryptographic utilities
- `fixnum` 1.1.1 - Fixed-size integers
- `typed_data` 1.4.0 - Typed data lists

## Configuration

**Environment:**
- Dart SDK constraint: `^3.11.5` (workspace root, `pubspec.yaml:7`)
- Package-level SDK constraints: `^3.5.0` for `core` and `dm_app`, `^3.11.5` for `companion_app`
- No `analysis_options.yaml` detected - no linting rules configured yet
- No `.gitignore` detected
- `.gitattributes` present with `text=auto` for LF normalization

**Build:**
- No platform directories created yet (no `android/`, `ios/`, `macos/`, `web/`, `windows/`, `linux/`)
- No `Makefile` or build scripts detected
- No CI/CD configuration (no `.github/` directory)

## Platform Requirements

**Development:**
- Dart SDK >= 3.11.5
- Flutter SDK >= 3.41.0
- macOS ARM development environment (Homebrew Flutter installation)

**Production:**
- No platform targets configured yet
- NSD plugin supports: Android, iOS, macOS, Windows
- Both apps are Flutter applications (no web target detected)

## SDK Constraints Matrix

| Package | Dart SDK | Flutter SDK |
|---------|----------|-------------|
| `dnd_workspace` (root) | ^3.11.5 | - |
| `core` | ^3.5.0 | - |
| `dm_app` | ^3.5.0 | via SDK |
| `companion_app` | ^3.11.5 | via SDK |

---

*Stack analysis: 2026-05-07*

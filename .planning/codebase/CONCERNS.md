# Codebase Concerns

**Analysis Date:** 2026-05-07

## Overview

This is a freshly bootstrapped Dart/Flutter workspace at the scaffolding stage. The project has directory structure and package manifests in place but **zero source code files**. All concerns below are preemptive — they identify missing infrastructure, configuration gaps, and structural risks that should be addressed before or during initial development.

---

## HIGH Severity

### Missing `.gitignore` File

- **Issue:** No `.gitignore` exists at the workspace root
- **Files:** Root directory
- **Impact:** Generated files (`.dart_tool/`, `pubspec.lock` conflicts, IDE configs, build artifacts) may be accidentally committed. The `.dart_tool/` directories are already present in all three packages but not yet tracked — this will cause noise in every commit until ignored.
- **Fix approach:** Add a standard Flutter/Dart `.gitignore` covering `.dart_tool/`, `build/`, `*.iml`, `.idea/`, `.vscode/`, `*.log`, `coverage/`, and platform-specific build directories.

### No `analysis_options.yaml` (Static Analysis)

- **Issue:** No Dart static analysis configuration exists at any level
- **Files:** Root and all packages
- **Impact:** No linting, no code quality enforcement, no consistent style rules. Developers will write code with no automated feedback on errors, warnings, or style violations.
- **Fix approach:** Add `analysis_options.yaml` at the workspace root (inherited by all packages) using `package:flutter_lints/flutter.yaml` as the base. Enable strict rules early to prevent tech debt accumulation.

### No Source Code — Empty Packages

- **Issue:** All three packages (`packages/core`, `apps/dm_app`, `apps/companion_app`) contain only `pubspec.yaml` with no `lib/`, `test/`, or any Dart source files
- **Files:**
  - `packages/core/pubspec.yaml`
  - `apps/dm_app/pubspec.yaml`
  - `apps/companion_app/pubspec.yaml`
- **Impact:** Project is non-functional. No architecture, no logic, no UI exists yet.
- **Fix approach:** Bootstrap each package with standard Flutter/Dart directory structure: `lib/`, `lib/src/`, `test/`, entry points (`lib/main.dart` for apps, `lib/core.dart` for core package).

### Missing Test Infrastructure

- **Issue:** No test directories, no test files, no test configuration anywhere
- **Files:** All packages
- **Impact:** Zero test coverage from day one. No framework for writing unit, widget, or integration tests.
- **Fix approach:** Add `test/` directories to each package. Include `flutter_test` in app pubspecs and `test` in core pubspec. Establish testing conventions early.

---

## MEDIUM Severity

### SDK Version Inconsistency

- **Issue:** Root workspace requires `sdk: '^3.11.5'` but `packages/core` and `apps/dm_app` specify `sdk: ^3.5.0`, while `apps/companion_app` specifies `sdk: ^3.11.5`
- **Files:**
  - `pubspec.yaml:7` (root: `^3.11.5`)
  - `packages/core/pubspec.yaml:6` (`^3.5.0`)
  - `apps/dm_app/pubspec.yaml:6` (`^3.5.0`)
  - `apps/companion_app/pubspec.yaml:6` (`^3.11.5`)
- **Impact:** Inconsistent SDK constraints across packages can cause confusion about minimum supported version. The `^3.5.0` constraint is significantly looser than the workspace's `^3.11.5`, potentially allowing packages to be used with older SDKs that lack features the workspace depends on.
- **Fix approach:** Align all package SDK constraints to `^3.11.5` (or whatever the actual minimum is) for consistency.

### Single Direct Dependency (`nsd`) with No Abstraction

- **Issue:** The `core` package has only one dependency: `nsd: ^5.0.1` (Network Service Discovery). This is the sole external library in the entire workspace.
- **Files:** `packages/core/pubspec.yaml:8`
- **Impact:** The project appears to be a D&D dungeon master + companion app using network discovery for local multiplayer. With no networking abstraction layer, no state management library, and no data persistence library planned, the architecture is underspecified.
- **Fix approach:** Before writing code, define the full dependency surface: state management (Provider is in lockfile but not declared), networking protocol, data models, persistence strategy. Add these as explicit dependencies.

### Provider in Lockfile but Not Declared

- **Issue:** `provider: 6.1.5+1` appears in `pubspec.lock` as a transitive dependency but is not declared in any package's `pubspec.yaml`
- **Files:**
  - `pubspec.lock:121-128` (provider listed as transitive)
  - No pubspec.yaml declares it directly
- **Impact:** Provider is pulled in transitively (likely via another package). If the apps intend to use Provider for state management, it should be a direct dependency so version is controlled explicitly.
- **Fix approach:** Add `provider` as a direct dependency to whichever apps use it, or choose a different state management approach and declare it explicitly.

### No CI/CD Pipeline

- **Issue:** No `.github/workflows/`, no CI configuration of any kind
- **Files:** Root directory
- **Impact:** No automated testing, no linting checks, no build verification on PRs. Code quality relies entirely on local developer discipline.
- **Fix approach:** Add GitHub Actions workflow for `dart analyze`, `dart test`, and `flutter test` on push/PR.

### No Documentation

- **Issue:** `README.md` contains only `# SaveState` with no project description, setup instructions, architecture overview, or development guide
- **Files:** `README.md:1-2`
- **Impact:** New developers (or future you) will have no context for what this project does, how to run it, or how the packages relate.
- **Fix approach:** Expand README with project description, prerequisites, setup steps, run commands, and architecture diagram.

### No `.env` or Configuration Strategy

- **Issue:** No configuration file pattern established (no `.env.example`, no config classes, no settings management)
- **Files:** All packages
- **Impact:** If the app needs any runtime configuration (API endpoints, feature flags, service names for NSD), there's no pattern for managing it.
- **Fix approach:** Decide on configuration strategy early — environment variables, config files, or runtime settings — and document it.

---

## LOW Severity

### No `.editorconfig`

- **Issue:** No editor configuration for consistent indentation, line endings, or file encoding across IDEs
- **Files:** Root directory
- **Impact:** Developers using different editors may produce inconsistent formatting.
- **Fix approach:** Add `.editorconfig` with `indent_size = 2`, `end_of_line = lf`, `charset = utf-8`, `trim_trailing_whitespace = true`.

### No Platform-Specific Configuration

- **Issue:** Neither `dm_app` nor `companion_app` have platform directories (`android/`, `ios/`, `macos/`, `web/`, `windows/`, `linux/`)
- **Files:**
  - `apps/dm_app/`
  - `apps/companion_app/`
- **Impact:** These are Flutter apps without platform bootstrapping. They cannot be built or run until `flutter create` platform scaffolding is added.
- **Fix approach:** Run `flutter create .` in each app directory to generate platform-specific code, or decide which platforms to support and generate only those.

### `uuid` and `crypto` in Lockfile Without Direct Usage

- **Issue:** `uuid: 4.5.3` and `crypto: 3.0.7` appear in `pubspec.lock` as transitive dependencies but no source code exists to use them
- **Files:**
  - `pubspec.lock:142-149` (uuid)
  - `pubspec.lock:20-27` (crypto)
- **Impact:** These are likely transitive deps from `nsd` or `provider`. If the apps plan to use UUIDs or crypto directly, they should be declared explicitly.
- **Fix approach:** Review transitive dependencies and promote any that will be used directly to explicit dependencies.

### Git Submodule Reference

- **Issue:** `.git` at the root is a file (74 bytes), indicating this directory is a git submodule or worktree, not a standalone repository
- **Files:** `.git` (file, not directory)
- **Impact:** Git operations depend on the parent repository. Cloning, branching, and CI may behave differently than expected.
- **Fix approach:** Verify this is intentional. If this should be a standalone repo, convert from submodule to independent repository.

---

## Summary

| Severity | Count | Key Theme |
|----------|-------|-----------|
| HIGH | 4 | Missing foundational infrastructure (gitignore, linting, source code, tests) |
| MEDIUM | 7 | Configuration gaps, undeclared dependencies, no CI/CD, no docs |
| LOW | 4 | Editor config, platform scaffolding, transitive deps, git structure |

**Priority actions before writing code:**
1. Add `.gitignore`
2. Add `analysis_options.yaml` with strict lint rules
3. Align SDK versions across all packages
4. Bootstrap `lib/` and `test/` directories in each package
5. Expand `README.md` with setup instructions
6. Decide on and declare state management, networking, and persistence dependencies

---

*Concerns audit: 2026-05-07*

# Phase 8: Typed Model Replacement & Migration - Research

**Researched:** 2026-05-08
**Domain:** Dart/Flutter model migration (typed classes → `GameEntity`) + persisted wiki JSON migration
**Confidence:** HIGH

## User Constraints

No phase-local `CONTEXT.md` exists yet; constraints are taken from roadmap/requirements/state artifacts. [VERIFIED: .planning/ROADMAP.md] [VERIFIED: .planning/REQUIREMENTS.md] [VERIFIED: .planning/STATE.md]

### Locked Inputs
- Must satisfy `MIGRATE-01`, `MIGRATE-02`, `MIGRATE-03`. [VERIFIED: .planning/REQUIREMENTS.md]
- Migration order constraint: run wiki JSON migration before removing `WikiPageType`. [VERIFIED: .planning/STATE.md]
- End state: delete `player_character.dart`, `monster.dart`, `npc.dart`, and `enums.dart`; both apps still launch and wiki create flow still works. [VERIFIED: .planning/ROADMAP.md]

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| MIGRATE-01 | Delete `PlayerCharacter`/`Monster`/`NPC`; migrate demo data to `List<GameEntity>` | Identified all current typed-model consumers and field-shape mapping points (`dm_app/main.dart`, `initiative_tracker.dart`, `creature_detail_view.dart`, `core/data/*`). [VERIFIED: codebase grep/read] |
| MIGRATE-02 | Delete `WikiPageType`; migrate persisted wiki JSON `pageType` strings via `WikiMigrationRunner` | Verified current JSON serialization/deserialization is enum-based and will break after enum removal unless files are rewritten first. [VERIFIED: `wiki_page.dart`, `wiki_storage_service.dart`] |
| MIGRATE-03 | Delete `enums.dart`; replace with String/GameModel-derived values | Verified enum dependencies in `item.dart`, `value_types.dart` (`DamageType`), typed models, demos, and DM widgets; these are required compile-fix targets. [VERIFIED: codebase grep/read] |

</phase_requirements>

## Summary

Phase 8 is a **destructive compatibility migration** (code + persisted state), not just a refactor. The biggest planning risk is deleting enum/model types before replacing all callsites and before rewriting persisted wiki page files. Current `WikiPage` persistence stores `pageType` as enum `name` and parses with `WikiPageType.values.byName(...)`; that parse path becomes invalid immediately after enum deletion unless migration rewrites old JSON first. [VERIFIED: `packages/core/lib/models/wiki_page.dart`] [VERIFIED: `.planning/STATE.md`]

The DM app is still heavily typed-model-driven (`demoPlayerCharacters`, `demoMonsters`, `demoNPCs`, plus conversion factories in initiative/detail widgets). Plan tasks must introduce a temporary adapter layer (or equivalent direct `GameEntity` constructors) **before** deleting typed models; otherwise compile breaks will be wide and hard to isolate. [VERIFIED: `apps/dm_app/lib/main.dart`] [VERIFIED: `apps/dm_app/lib/widgets/initiative_tracker.dart`] [VERIFIED: `apps/dm_app/lib/widgets/creature_detail_view.dart`]

Primary recommendation: execute in strict sequence — (1) add `WikiMigrationRunner` + run path, (2) migrate demos/consumers to `GameEntity` + String-backed fields, (3) remove legacy files/APIs/fallbacks, (4) run cross-package tests and both app smoke launches. [VERIFIED: roadmap + current code dependencies]

**Primary recommendation:** Treat Phase 8 as a two-track migration (runtime JSON + compile-time types) with an explicit compatibility window between introduction and deletion. [VERIFIED: codebase + requirements]

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Persisted wiki JSON migration (`pageType`) | API / Backend (core service layer) | Database / Storage (file storage) | Migration logic belongs where files are read/written (`WikiStorageService` + model parse). [VERIFIED: `wiki_storage_service.dart`] |
| Typed model replacement for demo datasets | Database / Storage (in-repo seed data) | API / Backend (core data types) | Source datasets live in `packages/core/lib/data`; model wrapper is `GameEntity`. [VERIFIED: `core/lib/data/*.dart`, `game_entity.dart`] |
| DM app rendering after typed model deletion | Browser / Client (Flutter UI tier) | API / Backend (core model APIs) | UI currently uses typed constructors and must switch to `GameEntity` read patterns. [VERIFIED: `dm_app/main.dart`, `initiative_tracker.dart`, `creature_detail_view.dart`] |
| Enum removal (`WikiPageType`, `enums.dart`) | API / Backend | Browser / Client | Enums are declared in core models, but many UI callsites compile against them. [VERIFIED: grep results across core/apps/tests] |

## Project Constraints (from AGENTS.md)

- Domain models must live in `packages/core/lib/models/`; do not duplicate across apps. [VERIFIED: AGENTS.md]
- Shared services in `packages/core/lib/services/`; app-specific UI/state in app folders. [VERIFIED: AGENTS.md]
- Apps depend on `core`; apps must not depend on each other. [VERIFIED: AGENTS.md]
- Workspace uses `resolution: workspace`; SDK constraints are `^3.11.5` root/apps and `^3.5.0` core. [VERIFIED: AGENTS.md] [VERIFIED: pubspec files]

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Dart SDK | 3.11.5 | Language/runtime for migration code and tests | Workspace is Dart-first and toolchain already present. [VERIFIED: `dart --version`] |
| Flutter SDK | 3.41.9 (Dart 3.11.5) | App-level compile/smoke verification | Both apps are Flutter apps and must launch post-migration. [VERIFIED: `flutter --version`] |
| provider | ^6.1.2 | Existing state wiring (`GameModelService`, `WikiProvider`) | Current architecture already uses Provider extensively. [VERIFIED: pubspec + app/core code] |
| path | ^1.9.0 | Safe path handling for wiki file rewrites | `WikiStorageService` already uses it for persisted JSON paths. [VERIFIED: `wiki_storage_service.dart`, core pubspec] |

### Supporting
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| test | ^1.25.0 | Core package migration tests | Add/adjust unit tests for migration runner and JSON compatibility. [VERIFIED: core pubspec + tests/] |
| flutter_test | SDK | App smoke/widget checks post-deletion | Validate both apps still launch and wiki flow works. [VERIFIED: app pubspec files + existing tests] |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| One-shot destructive rewrite | Two-phase compat shim (recommended) | Slightly more code now, much lower migration risk. [VERIFIED: dependency surface in grep/read] |
| Runtime lazy migration only | Eager batch migration at startup | Lazy reduces startup time but leaves mixed-format files longer. [ASSUMED] |

**Installation:**
```bash
dart pub get
```

## Architecture Patterns

### System Architecture Diagram
```text
Legacy wiki JSON files (pageType enum string)
            |
            v
   WikiMigrationRunner (scan/parse/transform/write)
            |
            v
Migrated wiki JSON files (entity type key string)
            |
            v
   WikiStorageService.load* -> WikiPage.fromJson (string-based type)

Legacy typed demo models -> Adapter/mapper -> List<GameEntity>
                                         |
                                         v
                           DM UI view models (initiative/detail/sidebar)
```

### Recommended Project Structure
```text
packages/core/lib/
├── migrations/                 # WikiMigrationRunner + migration helpers
├── models/                     # GameEntity, WikiPage (string key based)
├── services/                   # WikiStorageService migration hook
└── data/                       # demo_* now as List<GameEntity>
apps/dm_app/lib/
└── widgets/                    # consume GameEntity or adapter DTOs
```

### Pattern 1: Compatibility Window Migration
**What:** Introduce new parse/write path and migration runner while old structures still compile; remove legacy types only after data + callsites are converted. [VERIFIED: phase ordering + current code]
**When to use:** Any phase removing serialized enums/classes that are already persisted. [VERIFIED: `wiki_page.dart` storage format]

### Pattern 2: Edge Adapter for UI
**What:** Convert `GameEntity` to UI-facing DTOs at app boundary (initiative/detail/sidebar) instead of spreading key-string lookups through widgets. [ASSUMED]
**When to use:** When many UI constructors currently require strongly-typed models. [VERIFIED: DM widget factories]

### Anti-Patterns to Avoid
- **Delete-first migration:** Removing enums/models before migration runner and adapters exist causes both runtime and compile breakage. [VERIFIED: current enum/type coupling]
- **Mixed key vocabularies:** Using ad-hoc keys instead of D&D 5e model keys in demo `GameEntity` will break future model-driven UI work. [VERIFIED: MIGRATE-01 + dnd5e.json keys]

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| JSON path string concatenation | Custom path joins | `path.join(...)` | Existing service already uses it; avoids cross-platform path bugs. [VERIFIED: `wiki_storage_service.dart`] |
| Type-casting from dynamic maps | Scattered `as T` casts in widgets | `GameEntity` typed accessors + centralized mapping | Reduces cast exceptions and keeps migration logic consistent. [VERIFIED: `game_entity.dart`] |
| Migration orchestration in UI widgets | Widget-level file rewrite logic | Core migration runner invoked from service/startup boundary | Keeps I/O and mutation out of presentation tier. [ASSUMED] |

## Runtime State Inventory

| Category | Items Found | Action Required |
|----------|-------------|------------------|
| Stored data | Wiki pages persisted as JSON files under `<base>/wiki/pages/*.json` via `WikiStorageService`; each file stores `pageType` enum-name string today. [VERIFIED: `wiki_storage_service.dart`, `wiki_page.dart`] | **Data migration required**: rewrite legacy `pageType` strings to D&D 5e entity type keys before enum removal. [VERIFIED: MIGRATE-02] |
| Live service config | None found in repo; no external config-backed services for wiki type mapping were identified. [VERIFIED: codebase scan] | None (verified by repository analysis). [VERIFIED: codebase scan] |
| OS-registered state | None — no launchd/systemd/task scheduler registrations in repo for this feature. [VERIFIED: repository structure] | None. [VERIFIED: repository structure] |
| Secrets/env vars | None found related to typed model/wiki type naming. [VERIFIED: codebase scan] | None. [VERIFIED: codebase scan] |
| Build artifacts | Generated/test temp wiki JSON files may exist in local run directories because storage base is `Directory.current`. [VERIFIED: app main files + storage service] | For local validation, run migration in the same cwd where existing wiki files were written. [ASSUMED] |

## Common Pitfalls

### Pitfall 1: Enum-name parse crash after enum deletion
**What goes wrong:** `WikiPage.fromJson` no longer can parse old files if it still expects `WikiPageType.values.byName(...)`. [VERIFIED: `wiki_page.dart`]
**Why it happens:** Persisted files outlive code changes. [VERIFIED: file-based storage behavior]
**How to avoid:** Run migration runner first, then switch parser to string/entity-key representation, then delete enum. [VERIFIED: requirement/order constraints]
**Warning signs:** `StateError`/parse exceptions while loading existing pages and missing pages in list after update. [ASSUMED]

### Pitfall 2: Hidden compile surface for deleted models
**What goes wrong:** Deleting typed models breaks DM constructors/factories and tests in many files. [VERIFIED: grep matches]
**Why it happens:** Current app code passes `PlayerCharacter/Monster/NPC` deeply into widget factory constructors. [VERIFIED: `initiative_tracker.dart`, `creature_detail_view.dart`]
**How to avoid:** Add migration adapters or rewrite factory signatures first, then remove model files. [VERIFIED: dependency surface]
**Warning signs:** Cascading analyzer errors in `dm_app/widgets/*` and `core/data/*`. [VERIFIED: code structure]

## Code Examples

### Minimal WikiMigrationRunner rewrite pattern
```dart
// Source: derived from current storage+model code
Future<int> migrateWikiPageTypes(Directory baseDir, Map<String, String> map) async {
  final pagesDir = Directory(path.join(baseDir.path, 'wiki', 'pages'));
  if (!await pagesDir.exists()) return 0;

  var updated = 0;
  await for (final e in pagesDir.list()) {
    if (e is! File || !e.path.endsWith('.json')) continue;
    final raw = await e.readAsString();
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final oldType = json['pageType'];
    if (oldType is String && map.containsKey(oldType)) {
      json['pageType'] = map[oldType];
      await e.writeAsString(jsonEncode(json));
      updated++;
    }
  }
  return updated;
}
```

### GameEntity demo row shape pattern
```dart
// Source: GameEntity API + MIGRATE-01 requirement
final demoCharacters = <GameEntity>[
  GameEntity(
    entityTypeKey: 'creature',
    data: {
      'name': 'Thorin Ironforge',
      'armorClass': 18,
      'hitPoints': 52,
      'size': 'Medium',
      'creatureType': 'Humanoid',
    },
  ),
];
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Hardcoded typed models + enums (`PlayerCharacter`, `Monster`, `NPC`, `WikiPageType`) | GameModel/GameEntity-driven runtime schema | Introduced in Phases 5-7 | Phase 8 is the irreversible cleanup/migration gate. [VERIFIED: ROADMAP + core model files] |

**Deprecated/outdated:**
- `WikiCreateSubmitFlow.submit(...)` and `pendingType` compatibility path are explicitly transitional and intended for removal in Phase 8. [VERIFIED: `07-02-SUMMARY.md`, `wiki_storage_service.dart`, `wiki_modal_provider.dart`]

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | Lazy migration could be acceptable vs eager startup migration | Standard Stack alternatives | Medium — may leave mixed-format files longer than desired |
| A2 | Adapter-at-edge is the best UI migration pattern for this codebase | Architecture Patterns | Medium — team may prefer full widget rewrite now |
| A3 | Parse failures will surface as StateError/parse exceptions | Common Pitfalls | Low — exact error type/message may differ |
| A4 | Local validation must run in cwd containing prior persisted wiki files | Runtime State Inventory | Medium — depends on how apps are launched in practice |

## Open Questions (RESOLVED)

1. **Exact legacy->new wiki type mapping table**
   - **Outcome:** Phase 8 migration uses a D&D-locked 1:1 mapping table where legacy enum-name values are rewritten to canonical D&D entity-type keys (`creature`, `spell`, `item`, `rule`, `location`, `npc`, `other`) per D-01/D-11 and MIGRATE-02.
   - **Decision record:** generalized/custom-system mapping is explicitly deferred to later schema-generalization phases; Phase 8 must not introduce dynamic mapping sources.

2. **Where to invoke migration runner**
   - **Outcome:** `WikiMigrationRunner` is invoked during app startup before any normal wiki page loading path (D-05), executes every launch without marker gating (D-06), and remains non-blocking on write failures with warning surfacing (D-07).
   - **Decision record:** startup execution is required to prevent mixed-format reads in the same session.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Dart SDK | core migration code/tests | ✓ | 3.11.5 | — |
| Flutter SDK | app compile + launch smoke checks | ✓ | 3.41.9 | — |
| `dart test` tooling | core verification loop | ✓ | bundled with Dart SDK | — |
| `flutter test` tooling | app verification loop | ✓ | bundled with Flutter SDK | — |

**Missing dependencies with no fallback:**
- None. [VERIFIED: tool availability check]

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | `package:test` (^1.25.0) in core, `flutter_test` in apps |
| Config file | none (defaults) |
| Quick run command | `cd packages/core && dart test` |
| Full suite command | `dart test && cd apps/companion_app && flutter test && cd ../dm_app && flutter test` |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| MIGRATE-01 | demo data switched to `List<GameEntity>` and app consumers compile | unit + app smoke | `cd packages/core && dart test` + app `flutter test` | ❌ Wave 0 (targeted migration tests absent) |
| MIGRATE-02 | persisted wiki JSON rewritten before enum removal | unit/integration (file I/O) | `cd packages/core && dart test` | ❌ Wave 0 (`WikiMigrationRunner` tests absent) |
| MIGRATE-03 | `enums.dart` removed and references replaced cleanly | compile + regression tests | `dart test` + both app tests | ❌ Wave 0 (no compile-gate test specifically for enum deletion) |

### Sampling Rate
- **Per task commit:** impacted package test command (`dart test` or `flutter test`) [VERIFIED: AGENTS.md]
- **Per wave merge:** full workspace test sweep
- **Phase gate:** both apps launch and wiki create flow manual smoke passes

### Wave 0 Gaps
- [ ] `packages/core/test/wiki_migration_runner_test.dart` — covers MIGRATE-02
- [ ] `packages/core/test/wiki_page_string_type_test.dart` — covers post-enum JSON parse/write behavior
- [ ] `apps/dm_app/test/game_entity_sidebar_smoke_test.dart` — covers MIGRATE-01 consumer path

## Security Domain

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | no | N/A (local file migration only in this phase) |
| V3 Session Management | no | N/A |
| V4 Access Control | no | N/A |
| V5 Input Validation | yes | Validate JSON shape before rewrite; skip malformed files safely. [VERIFIED: storage already skips malformed on load] |
| V6 Cryptography | no | N/A |

### Known Threat Patterns for this stack

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Malformed local JSON causing migration crash | Denial of Service | Catch parse errors per file and continue; log/report migrated vs skipped count. [VERIFIED: current load pattern catches malformed files] |
| Partial rewrite leaves corrupted file | Tampering | Write atomically via temp file + rename, or backup before overwrite. [ASSUMED] |

## Sources

### Primary (HIGH confidence)
- `.planning/REQUIREMENTS.md` — MIGRATE requirements and traceability
- `.planning/ROADMAP.md` — phase goal, success criteria, planned task order
- `.planning/STATE.md` — explicit migration-before-deletion decision
- `packages/core/lib/models/wiki_page.dart` — enum-name serialization/parsing behavior
- `packages/core/lib/services/wiki_storage_service.dart` — file storage path and submit compatibility methods
- `packages/core/lib/models/game_entity.dart` — typed accessors and JSON wrapper
- `packages/core/assets/game_models/dnd5e.json` — canonical D&D key vocabulary
- `apps/dm_app/lib/main.dart`, `apps/dm_app/lib/widgets/initiative_tracker.dart`, `apps/dm_app/lib/widgets/creature_detail_view.dart` — typed-model UI dependency surface
- `packages/core/lib/models/enums.dart`, `packages/core/lib/models/item.dart`, `packages/core/lib/models/value_types.dart` — enum dependency surface for MIGRATE-03
- `dart --version`, `flutter --version` — environment availability

### Secondary (MEDIUM confidence)
- None.

### Tertiary (LOW confidence)
- None.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — derived from installed toolchain + repo pubspecs
- Architecture: HIGH — directly based on existing dependency graph in code
- Pitfalls: HIGH — directly tied to current parse/enum/type coupling

**Research date:** 2026-05-08
**Valid until:** 2026-06-07

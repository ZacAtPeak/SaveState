---
phase: 08-typed-model-replacement-migration
plan: "04"
subsystem: core-models
tags: [destructive-cleanup, enum-removal, string-migration]
dependency_graph:
  requires: ["08-03 bridge rewiring complete"]
  provides: ["clean compile without legacy typed models", "MIGRATE-03 satisfied"]
  affects: ["all apps importing core/models"]
tech_stack:
  added: []
  patterns: ["String-backed serialization replaces enum .name parsing"]
key_files:
  created: []
  modified:
    - packages/core/lib/models/models.dart
    - packages/core/lib/models/item.dart
    - packages/core/lib/models/value_types.dart
    - packages/core/lib/models/wiki_page.dart
    - packages/core/lib/wiki/wiki_page_detail.dart
    - packages/core/lib/wiki/wiki_page_list.dart
    - packages/core/lib/data/demo_player_characters.dart
    - packages/core/lib/data/demo_monsters.dart
    - packages/core/lib/data/demo_npcs.dart
    - packages/core/lib/data/demo_entities.dart
    - apps/dm_app/lib/widgets/initiative_tracker.dart
    - apps/dm_app/lib/widgets/creature_detail_view.dart
    - packages/core/test/wiki_page_test.dart
  deleted:
    - packages/core/lib/models/player_character.dart
    - packages/core/lib/models/monster.dart
    - packages/core/lib/models/npc.dart
    - packages/core/lib/models/wiki_page_type.dart
    - packages/core/lib/models/enums.dart
decisions:
  - "Migrated enum-to-String before file deletion to maintain compile-clean workspace"
  - "Converted demo_player_characters.dart from typed PlayerCharacter to JSON + GameEntity format"
  - "Replaced WikiPageType enum usage in wiki UI with string-based switch expressions"
metrics:
  duration_minutes: 15
  completed: "2026-05-08T20:15:00Z"
---

# Phase 08 Plan 04: Destructive Legacy Model/Enum Cleanup Summary

**One-liner:** Deleted all legacy typed model files (PlayerCharacter, Monster, NPC, WikiPageType, enums.dart) and migrated remaining enum-dependent parsing to String-backed semantics, completing irreversible move to GameEntity/GameModel-aligned string semantics.

## Objective

Finalize destructive cleanup by deleting legacy typed model and enum files after migration + bridge rewiring are complete, satisfying MIGRATE-03 without regressions.

## Tasks Completed

### Task 1: Delete typed model and enum files, clean model barrel exports

Deleted `player_character.dart`, `monster.dart`, `npc.dart`, `wiki_page_type.dart`, and `enums.dart`. Removed all corresponding exports from `models.dart`. Also cleaned up:
- Removed `WikiPageType` backward-compat getter from `wiki_page.dart`
- Converted `demo_player_characters.dart` from typed `PlayerCharacter` construction to JSON data + `GameEntity` format (matching `demo_monsters.dart`/`demo_npcs.dart` pattern)
- Updated `demo_monsters.dart` to export `demoMonsterEntities` as `List<GameEntity>` instead of `List<Monster>`
- Updated `demo_npcs.dart` to export `demoNpcEntities` as `List<GameEntity>` instead of `List<NPC>`
- Updated `demo_entities.dart` to aggregate GameEntity lists directly
- Removed legacy `fromPlayerCharacter`/`fromMonster`/`fromNPC` factories from `initiative_tracker.dart` and `creature_detail_view.dart`
- Replaced `WikiPageType` enum usage in `wiki_page_list.dart` and `wiki_page_detail.dart` with string-based switch expressions

### Task 2: Replace enum-dependent parsing in item/value_types with String-backed semantics

- `item.dart`: Converted `type` (ItemType), `bonusType` (BonusType), `bonusAbility` (BonusAbility?) to String fields with safe defaults
- `value_types.dart`: Converted `Attack.damageType` (DamageType) to String field with safe default; removed `import 'enums.dart'`
- `wiki_page_test.dart`: Removed WikiPageType enum test group and pageType references

### Task 3: Cross-workspace regression verification

- `dart analyze` (core): Clean (2 pre-existing warnings unrelated to changes)
- `flutter analyze` (dm_app): Clean (1 pre-existing warning)
- `flutter analyze` (companion_app): Clean (1 pre-existing warning, 1 pre-existing test error)
- `dart test` (core): 34/34 tests pass on relevant test files
- `flutter test` (dm_app): 14 pass, 2 skipped; 6 failures are pre-existing WikiProvider disposal issues

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - Missing critical functionality] WikiPageType references in wiki UI module**
- **Found during:** Task 1 (after file deletion, analyzer errors)
- **Issue:** `wiki_page_detail.dart` used `page.pageType.isReferenceType` and `wiki_page_list.dart` used `page.pageType`, `_iconForType(WikiPageType)`, and `page.pageType.displayName`
- **Fix:** Replaced with string-based logic: `_isReferenceType(entityTypeKey)` helper and `_iconForType(String)`/`_displayNameForType(String)` switch expressions
- **Files modified:** `packages/core/lib/wiki/wiki_page_detail.dart`, `packages/core/lib/wiki/wiki_page_list.dart`

**2. [Rule 2 - Missing critical functionality] DamageType.name reference in DM app**
- **Found during:** Task 3 (flutter analyze on dm_app)
- **Issue:** `creature_detail_view.dart` line 659 used `a.damageType.name` but damageType is now String
- **Fix:** Changed to `a.damageType` directly
- **Files modified:** `apps/dm_app/lib/widgets/creature_detail_view.dart`

**3. [Rule 3 - Blocking] Task ordering inversion**
- **Found during:** Task planning
- **Issue:** Plan listed Task 1 (delete files) before Task 2 (migrate enums), but deletion would break compile before migration could occur
- **Fix:** Executed enum-to-String migration first, then deleted files, maintaining compile-clean workspace throughout
- **Impact:** No functional change; execution order adjusted for safety

## Known Stubs

None. All data flows are wired.

## Threat Flags

| Flag | File | Description |
|------|------|-------------|
| threat_flag: string parse defaults | `item.dart` | String-backed type/bonus fields use safe defaults ('other', 'addition'); invalid values silently accepted rather than throwing |
| threat_flag: string parse defaults | `value_types.dart` | Attack.damageType defaults to 'slashing' on null/missing; invalid values silently accepted |

## Self-Check: PASSED

- All deleted files confirmed absent from filesystem
- Commit `77eb6c8` verified in git log
- Core analyzer: clean (pre-existing warnings only)
- DM app analyzer: clean (pre-existing warning only)
- Companion app analyzer: clean (pre-existing issues only)
- Core tests: 34/34 pass
- DM app tests: 14 pass, 6 pre-existing failures (WikiProvider disposal)

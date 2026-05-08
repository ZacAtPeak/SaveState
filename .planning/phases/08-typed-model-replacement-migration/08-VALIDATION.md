---
phase: 08
slug: typed-model-replacement-migration
status: ready
nyquist_compliant: true
wave_0_complete: true
created: 2026-05-08
updated: 2026-05-08
---

# Phase 08 — Validation Strategy

Per-phase validation contract for migration safety and regression control.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | `package:test` (core) + `flutter_test` (apps) |
| **Config file** | none (default runner configuration) |
| **Quick run command** | `cd packages/core && dart test` |
| **Full suite command** | `cd packages/core && dart test && cd ../../apps/companion_app && flutter test && cd ../dm_app && flutter test` |
| **Estimated runtime** | ~90-180 seconds (machine dependent) |

---

## Sampling Rate

- **After every task commit:** run package-local quick command for touched package(s)
- **After every plan wave:** run full suite command
- **Before `/gsd-verify-work`:** full suite must be green
- **Max feedback latency target:** < 180 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 08-01-01 | 08-01 | 1 | MIGRATE-02 | T-08-01/T-08-02 | malformed/unknown legacy JSON is skipped safely; valid rows rewritten in place | unit | `cd packages/core && dart test test/wiki_migration_runner_test.dart` | ✅ | ⬜ pending |
| 08-01-02 | 08-01 | 1 | MIGRATE-02 | T-08-01/T-08-03 | `WikiPage` serializes/deserializes strict `entityTypeKey` path only | unit | `cd packages/core && dart test test/wiki_migration_runner_test.dart && dart test` | ✅ | ⬜ pending |
| 08-01-03 | 08-01 | 1 | MIGRATE-02 | T-08-03 | startup migration runs before wiki load, every launch, non-blocking on write failures | integration/regression | `cd packages/core && dart test && cd ../../apps/companion_app && flutter test && cd ../dm_app && flutter test` | ✅ | ⬜ pending |
| 08-02-01 | 08-02 | 2 | MIGRATE-01 | T-08-05 | strict key schema + demo helper behavior stays contract-locked | unit | `cd packages/core && dart test test/wiki_page_string_type_test.dart` | ✅ | ⬜ pending |
| 08-02-02 | 08-02 | 2 | MIGRATE-01 | T-08-05 | unified `demoEntities` source preserves fields/nested mechanics | unit/regression | `cd packages/core && dart test` | ✅ | ⬜ pending |
| 08-03-01 | 08-03 | 3 | MIGRATE-02 | T-08-08 | enum fallback paths removed from wiki flow; entity path only | analyze + unit | `cd packages/core && dart analyze && dart test` | ✅ | ⬜ pending |
| 08-03-02 | 08-03 | 3 | MIGRATE-01 | T-08-09 | DM bridge consumes `GameEntity` directly with safe defaults | widget/regression | `cd apps/dm_app && flutter test test/game_entity_sidebar_smoke_test.dart && flutter test` | ✅ | ⬜ pending |
| 08-03-03 | 08-03 | 3 | MIGRATE-01/MIGRATE-02 | T-08-07 | post-rewire app launch + wiki create flow remains functional | regression + human verify | `cd packages/core && dart test && cd ../../apps/companion_app && flutter test && cd ../dm_app && flutter test` | ✅ | ⬜ pending |
| 08-04-01 | 08-04 | 4 | MIGRATE-03 | T-08-10/T-08-12 | typed model + enum files removed with no residual exports/imports | analyze | `cd packages/core && dart analyze` | ✅ | ⬜ pending |
| 08-04-02 | 08-04 | 4 | MIGRATE-03 | T-08-11 | enum-dependent parsing replaced by string-backed semantics | unit | `cd packages/core && dart test` | ✅ | ⬜ pending |
| 08-04-03 | 08-04 | 4 | MIGRATE-03 | T-08-10 | full workspace regression green after destructive cleanup | regression | `cd packages/core && dart test && cd ../../apps/companion_app && flutter test && cd ../dm_app && flutter test` | ✅ | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

Existing infrastructure and planned tests cover phase requirements. No additional framework/bootstrap Wave 0 tasks are required.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Both apps launch and wiki create flow works against migrated storage | MIGRATE-01, MIGRATE-02 | End-to-end runtime behavior (interactive app launch + modal flow) is not fully represented by current automated suite | 1) `cd apps/dm_app && flutter run`; 2) create wiki page from picker and verify list render; 3) `cd ../companion_app && flutter run`; verify launch + wiki modal open; 4) relaunch DM app and confirm created page persists/loads |

---

## Validation Sign-Off

- [x] All tasks have `<automated>` verify commands
- [x] Sampling continuity: no 3 consecutive tasks without automated verify
- [x] Wave 0 is satisfied (no missing test infrastructure placeholders)
- [x] No watch-mode flags in commands
- [x] Feedback latency target documented and bounded
- [x] `nyquist_compliant: true` set in frontmatter

**Approval:** pending

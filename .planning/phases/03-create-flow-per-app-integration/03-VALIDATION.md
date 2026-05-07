---
phase: 03
slug: create-flow-per-app-integration
status: ready
nyquist_compliant: true
wave_0_complete: true
created: 2026-05-07
---

# Phase 03 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Dart test + Flutter test (workspace monorepo) |
| **Config file** | `pubspec.yaml` (workspace root), `packages/core/pubspec.yaml`, `apps/companion_app/pubspec.yaml`, `apps/dm_app/pubspec.yaml` |
| **Quick run command** | `cd packages/core && dart test test/wiki_create_submit_test.dart -r compact` |
| **Full suite command** | `dart test && cd apps/companion_app && flutter test && cd ../dm_app && flutter test` |
| **Estimated runtime** | ~120–240 seconds |

---

## Sampling Rate

- **After every task commit:** Run `cd packages/core && dart analyze` plus the task-specific automated command from the map below
- **After every plan wave:** Run `dart test && cd apps/companion_app && flutter test && cd ../dm_app && flutter test`
- **Before `/gsd-verify-work`:** Full suite must be green
- **Max feedback latency:** 240 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 03-01-01 | 03-01 | 1 | CREATE-01, CREATE-02, CREATE-03 | T-03-01 | Centralized schema metadata constrains field keys/types and prevents ad-hoc widget-side schema tampering | unit/analyze | `cd packages/core && dart analyze && dart test test/wiki_page_test.dart` | ✅ | ⬜ pending |
| 03-01-02 | 03-01 | 1 | CREATE-01, CREATE-02 | T-03-02, T-03-03 | Bounded enum-driven picker and explicit cancel/back transitions reduce UI-state abuse and route confusion | analyze | `cd packages/core && dart analyze` | ✅ | ⬜ pending |
| 03-01-03 | 03-01 | 1 | CREATE-03 | T-03-01 | Schema-based required validation and typed input contracts enforced before submit path | analyze | `cd packages/core && dart analyze` | ✅ | ⬜ pending |
| 03-02-01 | 03-02 | 2 | CREATE-04, CREATE-03 | T-03-04, T-03-06 | Failing tests define secure expected persistence/statBlock/select behavior before implementation | unit | `cd packages/core && dart test test/wiki_create_submit_test.dart -r compact` | ✅ | ⬜ pending |
| 03-02-02 | 03-02 | 2 | CREATE-04 | T-03-04, T-03-05 | Submit flow validates/normalizes inputs, writes structured values by schema keys, and controls async save path | unit | `cd packages/core && dart test test/wiki_create_submit_test.dart -r compact` | ✅ | ⬜ pending |
| 03-02-03 | 03-02 | 2 | CREATE-03, CREATE-04 | T-03-05, T-03-06 | Provider-owned canonical list and startup load path ensure deterministic state after save | analyze/integration | `cd packages/core && dart analyze` (smoke) + `cd packages/core && dart test` (wave/phase gate) | ✅ | ⬜ pending |
| 03-03-01 | 03-03 | 3 | CREATE-01 | T-03-09 | Failing app-level tests lock in book-icon entrypoint and provider-root wiring for both apps | widget/integration | `cd apps/companion_app && flutter test test/wiki_entry_integration_test.dart && cd ../dm_app && flutter test test/wiki_entry_integration_test.dart` | ✅ | ⬜ pending |
| 03-03-02 | 03-03 | 3 | CREATE-01 | T-03-07, T-03-08 | Both app shells wire trusted modal entry + one-time provider startup load | widget/integration | `cd apps/companion_app && flutter test test/wiki_entry_integration_test.dart && cd ../dm_app && flutter test test/wiki_entry_integration_test.dart` | ✅ | ⬜ pending |
| 03-03-03 | 03-03 | 3 | CREATE-01 | T-03-07, T-03-08, T-03-09 | Workspace-level regression check confirms core/app integration remains secure and stable | workspace | `cd apps/companion_app && flutter test test/wiki_entry_integration_test.dart` (smoke) + `dart test && cd apps/companion_app && flutter test && cd ../dm_app && flutter test` (wave/phase gate) | ✅ | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

None. Existing `dart test` / `flutter test` infrastructure and task-specific test files already exist in this workspace and in the phase plans; no missing `<automated>` verify entries require Wave 0 scaffolding.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Responsive create-flow placement: two-panel uses right panel; single-panel uses Navigator route | CREATE-01, CREATE-02 | Layout breakpoint behavior and visual placement are device-width dependent; automated tests assert behavior contracts but not final responsive UX fidelity | 1) Run each app on narrow width (phone emulator) and wide width (tablet/desktop). 2) Tap `Icons.menu_book`, then tap `+`. 3) On narrow width confirm type picker/form opens as pushed route and back/cancel returns to previous view. 4) On wide width confirm picker/form renders in right panel slot while list remains visible. |
| AppBar book-icon visibility/interaction parity across companion and DM shells | CREATE-01 | Ensures product-level consistency (icon placement, discoverability, tooltip copy) beyond pass/fail widget assertions | 1) Launch `apps/companion_app` and `apps/dm_app`. 2) Verify `Icons.menu_book` appears in AppBar in both apps with matching tooltip text. 3) Tap icon and confirm shared wiki modal opens without visual regressions. |

*If none: "All phase behaviors have automated verification."*

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [x] Feedback latency < 240s
- [x] `nyquist_compliant: true` set in frontmatter

**Approval:** approved 2026-05-07

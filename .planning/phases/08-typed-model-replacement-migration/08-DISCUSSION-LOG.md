# Phase 8: typed-model-replacement-migration - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-05-08
**Phase:** 08-typed-model-replacement-migration
**Areas discussed:** Wiki JSON migration, Migration runner timing, Demo data shape, DM app bridge strategy

---

## Wiki JSON migration

| Option | Description | Selected |
|--------|-------------|----------|
| Keep `pageType` | Lowest-risk Phase 8 approach; keep field name while migrating values. | |
| Rename to `entityTypeKey` | Cleaner long-term naming with broader updates now. | ✓ |
| Dual-write both keys | Temporary bridge with later cleanup. | |

**User's choice:** Rename to `entityTypeKey`
**Notes:** User chose strict migration toward generic naming over compatibility-first retention.

| Option | Description | Selected |
|--------|-------------|----------|
| Read both keys | Accept legacy + new key during transition; write new only. | |
| Read new key only | Strict cutover after migration. | ✓ |
| Keep legacy forever | Long-term dual parsing. | |

**User's choice:** Read new key only
**Notes:** User prefers explicit migration completion over ongoing compatibility parsing.

| Option | Description | Selected |
|--------|-------------|----------|
| Skip file + log | Preserve app startup and surface invalid legacy file. | ✓ |
| Map to `other` | Force coercion into fallback category. | |
| Fail whole migration | Hard-stop on invalid value. | |

**User's choice:** Skip file + log
**Notes:** User accepted partial migration with warnings instead of coercion or global failure.

| Option | Description | Selected |
|--------|-------------|----------|
| In-place rewrite | Overwrite source files directly. | ✓ |
| Backup then rewrite | Safer recovery via `.bak` files. | |
| Write to new folder | Keep originals untouched and emit migrated copies. | |

**User's choice:** In-place rewrite
**Notes:** User prioritized direct conversion workflow.

---

## Migration runner timing

| Option | Description | Selected |
|--------|-------------|----------|
| At app startup | Migrate before normal page loads. | ✓ |
| On first wiki open | Delay migration until wiki interaction. | |
| Manual trigger only | Execute only through explicit user action. | |

**User's choice:** At app startup
**Notes:** Aligns with existing migration-before-deletion sequencing.

| Option | Description | Selected |
|--------|-------------|----------|
| Idempotent every launch | Re-scan safely each startup. | ✓ |
| Run once + marker | Skip later scans after success marker. | |
| Versioned re-run | Re-run only on migration-version change. | |

**User's choice:** Idempotent every launch
**Notes:** User chose repeat-safe startup behavior over marker gates.

| Option | Description | Selected |
|--------|-------------|----------|
| Continue + warn | Startup proceeds, failures surfaced. | ✓ |
| Block startup | Require migration success before app runs. | |
| Continue silently | No user-facing warning. | |

**User's choice:** Continue + warn
**Notes:** User wants resilience with visibility.

| Option | Description | Selected |
|--------|-------------|----------|
| Only wiki/pages | Limit scope to persisted wiki page storage. | ✓ |
| All JSON under base dir | Broad scan with higher risk/time. | |
| Configurable paths | Custom path list scan. | |

**User's choice:** Only wiki/pages
**Notes:** Explicitly constrained migration blast radius.

---

## Demo data shape

| Option | Description | Selected |
|--------|-------------|----------|
| Keep 3 typed lists | Maintain old list variables with `GameEntity` values. | |
| One unified list | Canonical `demoEntities` source with filtering/grouping. | ✓ |
| Both unified + helpers | Unified source plus convenience getters. | |

**User's choice:** One unified list
**Notes:** Chose canonical single source model.

| Option | Description | Selected |
|--------|-------------|----------|
| Preserve all fields | Carry forward complete typed payload. | ✓ |
| UI-critical subset only | Keep only fields currently rendered/used. | |
| Hybrid by type | Vary preservation depth by entity type. | |

**User's choice:** Preserve all fields
**Notes:** No intentional data reduction in migration.

| Option | Description | Selected |
|--------|-------------|----------|
| Lowercase keys | Schema-aligned string values. | ✓ |
| Human-readable labels | Store display labels in payloads. | |
| Mixed by field | Keep existing inconsistencies. | |

**User's choice:** Lowercase keys
**Notes:** Align enum replacement values to schema conventions.

| Option | Description | Selected |
|--------|-------------|----------|
| Keep nested objects | Preserve structured maps/lists. | ✓ |
| Flatten to strings | Convert complex values into display strings. | |
| Selective flattening | Mixed representation strategy. | |

**User's choice:** Keep nested objects
**Notes:** Supports richer downstream behavior in Phase 9.

---

## DM app bridge strategy

| Option | Description | Selected |
|--------|-------------|----------|
| Thin adapter layer | Build DTO adapters from `GameEntity` to minimize widget churn. | |
| Direct map reads in UI | Read `GameEntity` fields directly in widget/data-transform paths. | ✓ |
| Partial schema-driven UI | Start generalized rendering now. | |

**User's choice:** Direct map reads in UI
**Notes:** User accepted direct field access bridge for this phase.

| Option | Description | Selected |
|--------|-------------|----------|
| Filter by `entityTypeKey` | Group sections directly in UI from unified list. | |
| Pre-split in data layer | Supply grouped helpers to UI. | ✓ |
| Single mixed section | Collapse combatants into one list. | |

**User's choice:** Pre-split in data layer
**Notes:** Keeps current sectioned UX while retaining unified source.

| Option | Description | Selected |
|--------|-------------|----------|
| Keep d20 + DEX roll | Preserve current initiative behavior in Phase 8. | ✓ |
| Use stored initiative only | No roll at drop time. | |
| Hybrid mode | Roll/fallback mixed strategy. | |

**User's choice:** Keep d20 + DEX roll
**Notes:** Full rules-config initiative generalization remains Phase 9.

| Option | Description | Selected |
|--------|-------------|----------|
| Fallback defaults | Use safe defaults for missing expected fields. | ✓ |
| Skip invalid entity | Drop broken entries from UI. | |
| Throw hard error | Crash/fail fast on bad payloads. | |

**User's choice:** Fallback defaults
**Notes:** Runtime resilience preferred over hard failures.

---

## the agent's Discretion

- Naming, placement, and internal structure of migration/helper code, provided locked decisions remain intact.
- Warning/log message wording and presentation mechanics.

## Deferred Ideas

- Full schema-driven DM rendering and mechanics extraction from FieldSchema in this phase (deferred to Phase 9).

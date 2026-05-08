# Phase 8: typed-model-replacement-migration - Context

**Gathered:** 2026-05-08
**Status:** Ready for planning

<domain>
## Phase Boundary

Phase 8 removes hardcoded D&D typed model classes and migrates persisted/wiki/demo data to `GameEntity`-compatible structures so both apps continue to run without data loss.

This phase delivers migration and replacement safety, not full schema-driven UI generalization (that remains Phase 9).

</domain>

<spec_lock>
## Requirements (locked via SPEC.md)

**0 requirements are locked.** See `08-UI-SPEC.md` for the phase contract artifact currently present in this phase directory.

Downstream agents MUST read `08-UI-SPEC.md` before planning or implementing.

**In scope (for this phase):**
- Delete `PlayerCharacter`, `Monster`, `NPC`, `WikiPageType`, and `enums.dart` with compile-clean replacements.
- Migrate legacy wiki JSON type storage from enum-era values to GameModel entity keys.
- Migrate demo character/monster/NPC data to `GameEntity`-based structures used by both apps.
- Keep both apps launching and wiki/create flow functional after removals.

**Out of scope (for this phase):**
- Full schema-driven character sheet and encounter tracker generalization (Phase 9).
- New game systems, system picker UX, and external file import UX (Phase 10).

</spec_lock>

<decisions>
## Implementation Decisions

### Wiki JSON migration
- **D-01:** Canonical persisted key is renamed from `pageType` to `entityTypeKey`.
- **D-02:** Runtime deserialization is strict post-migration: read the new key only.
- **D-03:** If a legacy file contains an unknown legacy type value, skip that file and log a warning (do not crash whole migration).
- **D-04:** Migration rewrites files in place (no backup file or parallel output directory).

### Migration runner timing and behavior
- **D-05:** `WikiMigrationRunner` executes at app startup before normal wiki page loading.
- **D-06:** Runner is idempotent and runs each launch (no one-time marker gating).
- **D-07:** On write failures, startup continues with warnings surfaced (no hard block).
- **D-08:** Migration scan scope is limited to persisted wiki page files (`wiki/pages` storage path) only.

### Demo data migration shape
- **D-09:** Demo entities are stored as one unified list (`demoEntities`) rather than separate typed-class lists.
- **D-10:** Migrated `GameEntity` payload preserves all prior typed-model fields (not a reduced subset).
- **D-11:** Former enum-like values are encoded as schema-key strings aligned with GameModel conventions.
- **D-12:** Complex mechanics structures remain nested (maps/lists), not flattened to display strings.

### DM app bridge strategy
- **D-13:** Phase 8 DM UI bridge reads `GameEntity` maps directly in widget/data-transform paths (no dedicated adapter layer as primary strategy).
- **D-14:** Despite unified source storage, DM sidebar sections are provided via pre-split helpers from the data layer.
- **D-15:** Initiative behavior remains current D&D-style drop roll (`d20 + DEX`) in this phase.
- **D-16:** Missing expected D&D fields in migrated entities must use safe fallback defaults to avoid runtime crashes.

### the agent's Discretion
- Naming/location details for migration utilities and helper functions, as long as decisions D-01 through D-16 are preserved.
- Exact warning text and logging mechanics for skipped/failed migration files.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Phase scope and requirements
- `.planning/ROADMAP.md` — Phase 8 goal, success criteria, and plan placeholders (`08-01` to `08-03`).
- `.planning/REQUIREMENTS.md` — `MIGRATE-01`, `MIGRATE-02`, `MIGRATE-03` requirement definitions.
- `.planning/PROJECT.md` — v2 GameModel constraints, out-of-scope boundaries, and replacement rationale.
- `.planning/STATE.md` — carry-forward sequencing decision: migration before enum deletion.
- `.planning/phases/08-typed-model-replacement-migration/08-UI-SPEC.md` — current phase contract artifact.

### Prior phase decisions to carry forward
- `.planning/phases/06-service-layer-d-d-5e-asset/06-CONTEXT.md` — GameModel service and provider-wiring assumptions that must keep working.
- `.planning/phases/05-core-data-layer/05-CONTEXT.md` — `GameEntity` structure and parser strictness conventions.
- `.planning/phases/04-polish-testing/04-CONTEXT.md` — quality/robustness expectations and regression discipline.

### Current migration-critical code
- `packages/core/lib/models/wiki_page.dart` — current enum-based `pageType` serialization/deserialization to replace.
- `packages/core/lib/models/wiki_page_type.dart` — enum/type schema implementation targeted for removal.
- `packages/core/lib/models/enums.dart` — D&D enums targeted for removal.
- `packages/core/lib/models/models.dart` — barrel exports that currently expose typed models/enums.
- `packages/core/lib/services/wiki_storage_service.dart` — create/load paths currently converting through `WikiPageType`.
- `packages/core/lib/wiki/wiki_provider.dart` — wiki load/create integration point and pending enum compatibility residue.
- `packages/core/lib/wiki/wiki_modal_provider.dart` — deprecated `pendingType` compatibility path called out for Phase 8 removal.
- `packages/core/lib/wiki/wiki_type_picker.dart` — enum fallback branch to remove or replace.

### Typed models and demo data to replace
- `packages/core/lib/models/player_character.dart` — typed model to delete.
- `packages/core/lib/models/monster.dart` — typed model to delete.
- `packages/core/lib/models/npc.dart` — typed model to delete.
- `packages/core/lib/data/demo_player_characters.dart` — migrate to `GameEntity` representation.
- `packages/core/lib/data/demo_monsters.dart` — migrate to `GameEntity` representation.
- `packages/core/lib/data/demo_npcs.dart` — migrate to `GameEntity` representation.
- `packages/core/lib/data/data.dart` — export surface to update for unified demo entity source.

### DM app integration points impacted by typed-model deletion
- `apps/dm_app/lib/main.dart` — currently builds sidebar/detail state from typed demo lists.
- `apps/dm_app/lib/widgets/initiative_tracker.dart` — typed constructors and D&D initiative assumptions.
- `apps/dm_app/lib/widgets/creature_detail_view.dart` — typed factories and D&D-specific field reads.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `GameEntity` + typed accessor helpers from Phase 5 can be reused for migrated demo payload reads.
- Existing DM view DTOs (`CombatantDragData`, `InitiativeEntry`, `CreatureDetail`) can remain as UI-facing shapes while input source changes.
- Existing `WikiStorageService` file traversal/load-save flow is a natural insertion point for migration execution ordering.

### Established Patterns
- Core models/services use manual JSON serialization and explicit field mapping (no codegen).
- Providers are already wired through `GameModelService` and must keep live behavior unchanged after migration.
- Prior phases favor low-regression transitions with explicit deprecation cleanup over broad architecture rewrites.

### Integration Points
- Wiki file migration + strict deserialization touch `WikiPage` model and wiki storage/load entrypoints.
- Typed model deletions cascade through `models.dart`, demo data exports, and DM app widget constructors.
- Unified demo entity source plus pre-split helpers must satisfy existing DM sidebar section UX.

</code_context>

<specifics>
## Specific Ideas

- Migration order is fixed: run wiki JSON migration before deleting `WikiPageType` references.
- Post-migration storage naming should reflect generic model semantics (`entityTypeKey`) instead of enum-era terminology.
- Direct map-read bridge in Phase 8 is acceptable even though a stronger schema-driven UI pass is deferred to Phase 9.

</specifics>

<deferred>
## Deferred Ideas

- Full schema-driven DM UI/detail rendering from `FieldSchema` definitions rather than D&D-oriented bridge behavior — defer to Phase 9.

</deferred>

---

*Phase: 08-typed-model-replacement-migration*
*Context gathered: 2026-05-08*

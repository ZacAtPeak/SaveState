# Phase 1: Core Infrastructure - Context

**Gathered:** 2026-05-07
**Status:** Ready for planning

<domain>
## Phase Boundary

Foundation data layer for the wiki system. WikiPage model, WikiPageType enum with per-type field schemas, file-based JSON persistence, and in-memory search service with title-prioritized scoring. No UI work — UI is Phase 2. DM app is single source of truth for wiki content. Create-only for this milestone (no edit/delete).

</domain>

<decisions>
## Implementation Decisions

### Stat block field schemas
- **D-01:** WikiPageType enum with 7 types: creature, spell, item, rule, location, npc, other
- **D-02:** Creature and NPC wiki pages tie to existing `Monster` and `NPC` domain models in core — wiki stores a reference to the model, not a duplicate copy
- **D-03:** Item, spell, rule, location, and other page types use wiki-specific field schemas (not tied to existing domain models)
- **D-04:** Each page has core fields: title, tags, aliases, markdown body, page type, UUID
- **D-05:** Stat block fields are structured per type — creatures get AC/HP/speed/etc from Monster model, other types define their own schema

### Storage file structure
- **D-06:** One JSON file per page, named by UUID (e.g., `{uuid}.json`)
- **D-07:** Files stored in a dedicated wiki pages directory (location to be determined by planner — likely within app-specific storage or a shared directory)
- **D-08:** File-based JSON persistence layer — `WikiStorageService` handles save/load/delete operations

### Search scoring algorithm
- **D-09:** Simple weighted scoring — title matches scored higher than body matches
- **D-10:** In-memory search service — `WikiSearchService` indexes pages loaded from storage
- **D-11:** Search returns pages ranked by relevance score, no external search library needed

### Service architecture
- **D-12:** Two separate services: `WikiStorageService` (disk I/O) and `WikiSearchService` (in-memory indexing and query)
- **D-13:** Storage service feeds pages to search service — search service maintains an in-memory index
- **D-14:** Services live in `packages/core/lib/services/` (new directory, does not exist yet)

### the agent's Discretion
- Exact wiki storage directory path
- Specific weighted point values for search scoring (e.g., title=10, body=1)
- Error handling approach for malformed JSON (existing models use direct casts — planner should decide whether to add validation)
- Whether to create `analysis_options.yaml` for core package (identified as a concern)

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Core infrastructure
- `.planning/ROADMAP.md` §Phase 1 — Phase goal, requirements (CORE-01 through CORE-04), success criteria
- `.planning/REQUIREMENTS.md` §Core Infrastructure — CORE-01 through CORE-04 requirements definitions
- `.planning/PROJECT.md` — Key Decisions table, Constraints section, Current concerns (model duplication, missing persistence, no core tests)

### Codebase conventions
- `.planning/codebase/CONVENTIONS.md` — Model design patterns (serialization, factory methods, immutability), naming conventions, barrel export patterns
- `.planning/codebase/STACK.md` — Dependency versions, SDK constraints, package placement rules
- `.planning/codebase/STRUCTURE.md` — Directory layout, where to add new code (models, services, tests)
- `.planning/codebase/CONCERNS.md` — Model duplication concern, no persistence layer, no core tests, no analysis_options.yaml in core

### Existing models
- `packages/core/lib/models/models.dart` — Barrel export file (new wiki model must be added here)
- `packages/core/lib/models/enums.dart` — Existing enum patterns (CreatureSize, CreatureType, etc.)
- `packages/core/lib/models/monster.dart` — Monster model (referenced by creature wiki pages)
- `packages/core/lib/models/npc.dart` — NPC model (referenced by NPC wiki pages)

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `uuid` package (v4.5.1) — already in core dependencies, use for page ID generation
- Existing enum serialization pattern in `enums.dart` — use `.name` for output, `EnumType.values.byName()` for input
- Existing `toJson`/`fromJson` pattern across all models — follow same approach for WikiPage
- Barrel export pattern in `models.dart` — add new wiki exports here

### Established Patterns
- All model fields are `final` (immutable) — wiki models should follow this
- Factory constructors use `from<SourceType>` pattern
- Named parameters with `required` keyword for mandatory fields
- Enum serialization via `.name` / `values.byName()`
- 2-space indentation, trailing commas in multi-line constructors

### Integration Points
- New `packages/core/lib/services/` directory does not exist yet — needs creation with barrel export
- WikiPage model goes in `packages/core/lib/models/` with export in `models.dart`
- WikiPageType enum goes in `packages/core/lib/models/` (likely new file or added to enums.dart)
- Core package has no tests directory — `packages/core/test/` needs creation
- Core package has no `analysis_options.yaml` — should be added

</code_context>

<specifics>
## Specific Ideas

- Creature and NPC wiki pages should reference existing domain models, not duplicate their data
- "Item was something I wanted to prototype the wiki with" — item type is important as a starting point
- One file per page keeps things simple and avoids merge conflicts

</specifics>

<deferred>
## Deferred Ideas

- Alias-based search (LIST-05) — v2 requirement
- Page type filter chips in sidebar (LIST-06) — v2 requirement
- Edit/delete existing pages — out of scope for this milestone
- NSD sync from DM to companion — next milestone
- Cross-linking from app text into wiki — next milestone

None — discussion stayed within phase scope

</deferred>

---

*Phase: 01-core-infrastructure*
*Context gathered: 2026-05-07*

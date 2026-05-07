# Phase 1: Core Infrastructure - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-05-07
**Phase:** 01-core-infrastructure
**Areas discussed:** Stat block field schemas, Storage file structure, Search scoring algorithm, Service architecture

---

## Stat block field schemas

| Option | Description | Selected |
|--------|-------------|----------|
| Reuse existing models | Creature wiki pages store Monster/NPC as stat block | ✓ |
| Define wiki-specific schemas | Separate field sets for reference/display | |
| Hybrid | Core fields shared, type-specific per page type | |

**User's choice:** Creature and NPC pages tie to existing `Monster` and `NPC` models. Item, spell, rule, location, and other types use wiki-specific schemas. Item stays as a wiki page type (user initially said remove, then corrected to keep).

**Notes:** User wants to prototype with item type. Creature/NPC pages reference existing domain models rather than duplicating data.

---

## Storage file structure

| Option | Description | Selected |
|--------|-------------|----------|
| One file per page | `{uuid}.json`, easy add/delete, no merge conflicts | ✓ |
| Single JSON file | All pages in one array, simpler load | |
| Type-based directories | Organized by type, complicates cross-type ops | |

**User's choice:** One file per page.

---

## Search scoring algorithm

| Option | Description | Selected |
|--------|-------------|----------|
| Simple weighted scoring | Title=high, body=low, sort by total | ✓ |
| TF-IDF style | Term frequency-inverse document frequency | |
| Simple + tag bonus | Weighted scoring plus tag match bonus | |

**User's choice:** Simple weighted scoring.

---

## Service architecture

| Option | Description | Selected |
|--------|-------------|----------|
| Separate services | WikiStorageService + WikiSearchService | ✓ |
| Single WikiService | One class for both storage and search | |
| Repository pattern | Abstract storage, index from repository | |

**User's choice:** Separate services.

---

## the agent's Discretion

- Exact wiki storage directory path
- Specific weighted point values for search scoring
- Error handling approach for malformed JSON
- Whether to create `analysis_options.yaml` for core package

## Deferred Ideas

- Alias-based search — v2
- Page type filter chips — v2
- Edit/delete pages — out of scope for milestone
- NSD sync — next milestone
- Cross-linking from app text — next milestone

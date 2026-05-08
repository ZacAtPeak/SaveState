# Phase 5: Core Data Layer - Discussion Log

**Date:** 2026-05-08
**Mode:** discuss (default)

## Area 1: FieldSchema Type System

**Question:** How should FieldSchema handle input types?

**Options presented:**
1. Minimal types, rich validation (text, number, multiline, select, checkbox, list, dice — percentile/range from validation rules)
2. Expanded type set (add percentile, derived, checkbox, list, dice, reference as first-class types)
3. Bare minimum (text, number, multiline, select, checkbox only)

**Selection:** Option 1 — Minimal types, rich validation

**Follow-up:** Which validation constraints should FieldSchema carry?

**Options presented:**
1. Full constraint set (min, max, pattern, enumOptions, derivedFrom, defaultValue)
2. Core constraints only (min, max, enumOptions, required)

**Selection:** Option 1 — Full constraint set

**Notes:**
- `derivedFrom` is stored as a string formula — evaluation deferred to Phase 9
- CoC Sanity expressed as: number field with `derivedFrom: "POW * 5"`
- CoC percentile skills: number field with `min: 0, max: 100`
- CoC characteristics: number field with `min: 15, max: 90`

## Area 2: GameModel JSON Structure

**Question:** How should the GameModel JSON file be organized at the top level?

**Options presented:**
1. Flat top-level keys (schemaVersion, name, entityTypes[], rulesConfig{})
2. Grouped sections (schemaVersion, meta{}, entities{}, rules{}, wiki{})

**Selection:** Option 1 — Flat top-level keys

**Follow-up:** What metadata should each entity type carry?

**Options presented:**
1. Full metadata (key, displayName, isWikiPageType, fields[], description, iconKey, sortOrder)
2. Minimal — schema only (key, displayName, isWikiPageType, fields[])

**Selection:** Option 1 — Full metadata

**Notes:**
- `isWikiPageType` flag on entity types (decided at project init, confirmed)
- `rulesConfig` must contain `initiative` key; rest is flexible
- D&D initiative: `"1d20 + {dexMod}"`, CoC initiative: `"dexRank"` (special token)

## Area 3: GameEntity Accessor Depth

**Question:** How deep should GameEntity's accessor helpers go?

**Options presented:**
1. Explicit typed accessors (getInt, getString, getBool, getDouble, getList, getMap)
2. Core three + generic get<T>
3. Minimum — SCHEMA-03 only (getInt, getString, getBool)

**Selection:** Option 1 — Explicit typed accessors

**Notes:**
- Each accessor: `(String key, {dynamic fallback})` — never throws, returns fallback
- No schema validation in accessors — raw typed values only
- Validation happens at form/UI layer (Phase 7+)

## Area 4: Parsing Strictness

**Question:** How should GameModelParser handle parsing errors beyond schemaVersion?

**Options presented:**
1. Strict on required, lenient on unknowns (fail on missing required, type mismatches, duplicates; ignore unknown fields)
2. Fail-fast on everything
3. Lenient — only schemaVersion is hard

**Selection:** Option 1 — Strict on required, lenient on unknowns

**Notes:**
- FormatException for: missing schemaVersion, wrong type, missing entityTypes, empty entityTypes, duplicate keys
- Unknown extra fields silently ignored (forward-compatibility)
- FormatException messages must identify the problematic field

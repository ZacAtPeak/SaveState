# Phase 10: CoC 7e, System Picker & File Import — Context

**Gathered:** 2026-05-08
**Status:** Ready for planning

<domain>
## Phase Boundary

Users can pick any bundled game system or import their own. CoC 7e works end-to-end, proving true TTRPG agnosticism. Both companion and DM apps get a system picker with persistence, coc7e.json loads correctly, initiative and encounter tracker work with CoC rules, and external JSON import with validation is supported.
</domain>

<decisions>
## Implementation Decisions

### CoC 7e Schema
- **D-28:** Keep same FieldSchema pattern as D&D 5e — CoC uses the same inputType/section/subFields/itemSchema structure
- **D-29:** CoC doesn't use `derivedFrom` for modifiers — attribute fields store values directly, no formula evaluation needed
- **D-30:** CoC entity types: `investigator` (full CoC 7e stat block: 8 characteristics STR/CON/SIZ/DEX/APP/INT/POW/EDU 15–90, derived Sanity/Luck/MP/Build, percentile skills) + `creature` (adversary: no CR/XP/class/spell slots) + `location` + `item` + `rule`
- **D-31:** CoC investigator fields include: 8 characteristics (STR/CON/SIZ/DEX/APP/INT/POW/EDU), derived fields (Sanity, Luck, Magic Points, Build), hp, mp, sanityCurrent, luckCurrent, skills (percentile), description, backstory
- **D-32:** CoC creature fields include: name, hp, armor, attacks (list), specialAbilities (list), sanityEffects — no CR/XP/legendary actions

### System Picker UI & Persistence
- **D-33:** System picker lives in a dedicated settings screen (not a dropdown in app bar)
- **D-34:** Both companion_app and dm_app get the settings screen — not companion-only
- **D-35:** Selected game system persisted via `SharedPreferences` — app reads on startup and loads the appropriate game model asset
- **D-36:** Switching game system shows a migration dialog with options to clear existing wiki data or keep it (user choice)

### File Import UX
- **D-37:** `file_picker` package placed in `apps/companion_app` and `apps/dm_app` only — core stays platform-agnostic. Apps pass parsed JSON string to GameModelService, which calls `GameModelParser.parse()`
- **D-38:** Imported GameModel files stored in app documents directory — survives app restart and is accessible via Files app
- **D-39:** A dedicated `GameModelValidator` class validates imported files before parsing — checks schemaVersion present, entityTypes array not empty, required fields exist
- **D-40:** Malformed import attempts show an AlertDialog with title + specific error message + 'OK' button to dismiss

### CoC 7e Initiative
- **D-41:** CoC 7e initiative represented with `isRolled: false` flag in initiativeConfig — tracker checks this instead of evaluating a dice formula. When `isRolled: false`, combatants are sorted by their DEX value (higher first), no dice roll occurs
- **D-42:** No tiebreaker for same-DEX combatants — unstable sort, DM manually handles ties
- **D-43:** For DEX-rank initiative, tracker displays the raw DEX value (not just sorted position) — players can reference the value during tie negotiation

### Agent's Discretion
- Implementation patterns for settings screen UI (Flutter ListTile + RadioListTile or similar Material pattern) — standard approach
- Specific storage key naming for SharedPreferences (e.g., `activeGameSystem` as string key)
- AlertDialog styling (title, message, button text) — follow Material 3 conventions
- coc7e.json field ordering and grouping within sections — mirror D&D 5e pattern
- Error message format in GameModelValidator output — include field path for debugging
</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

- `packages/core/assets/game_models/dnd5e.json` — Reference for FieldSchema structure, rulesConfig format, entity type definition patterns
- `packages/core/lib/models/game_model.dart` — GameModel data class definition (schemaVersion, entityTypes, rulesConfig)
- `packages/core/lib/services/game_model_service.dart` — GameModelService (ChangeNotifier with loadFromAsset method)
- `.planning/phases/09-character-sheet-encounter-tracker-generalization/09-CONTEXT.md` — D-17 through D-27: FieldSchema extensions (section, subFields, itemSchema, attributeRef), FormulaEvaluator, rulesConfig schema, initiativeConfig formula-driven approach, resourceFields, statusConditions
- `.planning/phases/08-typed-model-replacement-migration/08-CONTEXT.md` — Migration patterns, entityTypeKey serialization
- `.planning/REQUIREMENTS.md` — Phase 10 requirements: SYSTEM-02, SYSTEM-03, UX-01, UX-02, UX-03
- `.planning/ROADMAP.md` — Phase 10 scope: coc7e.json, system picker UI, file import, end-to-end agnosticism demo
- `packages/core/lib/models/game_model_parser.dart` — GameModelParser.parse() signature and FormatException behavior

### Prior Phase Decisions (carry forward)
- [Phase 5] FieldSchema input types: text, number, multiline, select, checkbox, list, group, dice
- [Phase 5] Validation constraints: min, max, pattern, enumOptions, derivedFrom, defaultValue, required
- [Phase 5] GameModel JSON has flat top-level keys; entity types carry key, displayName, isWikiPageType, fields
- [Phase 9] section property on FieldSchema for visual grouping
- [Phase 9] subFields for nested objects, itemSchema for list items
- [Phase 9] FormulaEvaluator supports arithmetic + dice notation
- [Phase 9] initiativeConfig.formula drives initiative computation; DM can override
- [Phase 9] rulesConfig.resourceFields defines combat resources
- [Phase 9] rulesConfig.statusConditions defines system-specific defaults with custom option
- [Phase 9] rulesConfig.attributes defines system attribute list with label and abbreviation

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `GameModelService` — already a ChangeNotifier; needs new method `loadFromExternalFile(String jsonString)` and `loadFromPath(String path)`
- `GameModelParser.parse()` — already throws `FormatException` with readable messages; validator should use same pattern
- `dnd5e.json` — comprehensive reference for section grouping, subFields usage, itemSchema pattern, rulesConfig structure
- InitiativeTracker in dm_app — already has DragTarget<CombatantDragData>; needs formula evaluation for D&D and rank-sort for CoC

### Established Patterns
- SharedPreferences for lightweight persistence (used for wiki state in prior phases)
- file_picker follows standard Flutter pattern for external file access
- AlertDialog for error display in both apps (ModalUI pattern from Phase 2)
- Settings screen pattern in Flutter (ListTile + navigation)

### Integration Points
- GameModelService needs `loadFromDocumentsDirectory(String filename)` — reads file from app documents, parses, sets active model
- Both apps need a SettingsScreen with system picker (ListTile with RadioListTile for each system + "Import Custom" option)
- InitiativeTracker needs to read `initiativeConfig.isRolled` flag and either roll dice or sort by DEX value
- WikiProvider re-derives page types when GameModelService.notifyListeners() fires
</code_context>

<specifics>
## Specific Ideas

- CoC initiative is DEX-rank sort — no dice, no formula evaluation, just sort by DEX value
- Import flow: file_picker → read file → validate → parse → store in documents → GameModelService.loadFromDocumentsDirectory → notifyListeners → all UI updates live
- Error messages should say "Failed to import game model" with specific field/path info when validation fails
- "Import Custom" in settings screen opens file picker, validates, and if successful adds to available systems list
</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 10-CoC 7e, System Picker & File Import*
*Context gathered: 2026-05-08*
# Phase 10: CoC 7e, System Picker & File Import - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-05-08
**Phase:** 10-coc-7e-system-picker-file-import
**Areas discussed:** CoC 7e schema, System picker UI & persistence, File import, CoC 7e initiative

---

## CoC 7e schema

Session resumed from checkpoint — area completed in prior session.

| Option | Description | Selected |
|--------|-------------|----------|
| Keep same pattern | FieldSchema same pattern as D&D 5e | ✓ |
| Same pattern but CoC-specific | Additional CoC-specific schema elements | |

**Decisions from prior session:**
- CoC attributes (STR/CON/SIZ/DEX/APP/INT/POW/EDU) use same FieldSchema pattern
- CoC doesn't use derivedFrom for modifiers — attribute values stored directly
- Entity types: investigator + creature + location + item + rule
- Investigator entity: full CoC 7e stat block with 8 characteristics, derived fields, percentile skills
- Creature entity: name, hp, armor, attacks, abilities, sanity effects — no CR/XP/legendary actions

---

## System picker UI & persistence

Session resumed from checkpoint — area completed in prior session.

| Option | Description | Selected |
|--------|-------------|----------|
| Dedicated settings screen | Settings screen with system picker | ✓ |
| Dropdown in app bar | Dropdown in app bar | |
| Companion app only | Only in companion app | |

**Decisions from prior session:**
- System picker lives in dedicated settings screen
- Both companion and DM app get the settings screen
- Selected system persisted via SharedPreferences
- Switching system shows migration dialog (clear vs keep existing data)

---

## File import

| Option | Description | Selected |
|--------|-------------|----------|
| Apps only | file_picker in apps only; GameModelService gets parsed JSON string | ✓ |
| Core package | file_picker in core; core handles import and storage | |

**User's choice:** Apps only (Recommended)
**Notes:** Core stays platform-agnostic; apps pass parsed JSON string to GameModelService

| Option | Description | Selected |
|--------|-------------|----------|
| App documents directory | Survives app restart; user can access via Files app | ✓ |
| SharedPreferences only | Persists selected system but not the file itself | |
| App cache directory | May be cleared by system | |

**User's choice:** App documents directory
**Notes:** Imported files stored in app documents directory

| Option | Description | Selected |
|--------|-------------|----------|
| Dedicated validator class | Pre-parse validation (schemaVersion, entityTypes, required fields) | ✓ |
| GameModelParser handles it | GameModelParser.parse() catches FormatException | |
| Two-phase validation | Parse early, validate in multiple passes | |

**User's choice:** Dedicated validator class
**Notes:** GameModelValidator checks schemaVersion present, entityTypes array not empty, required fields exist

| Option | Description | Selected |
|--------|-------------|----------|
| AlertDialog | Title + specific error message + 'OK' button | ✓ |
| SnackBar | Error message + 'Dismiss' at bottom | |
| Full-screen error page | Error screen with 'Try Again' / 'Cancel' | |

**User's choice:** AlertDialog
**Notes:** User-friendly error display for malformed import attempts

---

## CoC 7e initiative

| Option | Description | Selected |
|--------|-------------|----------|
| Add isRolled flag | Add isRolled: false flag; tracker checks this instead of evaluating formula | ✓ |
| Pure formula (DEX) | Use formula 'DEX' only; evaluator returns attribute value directly | |
| Separate dexRank field | Add dexRank field; initiative = DEX rank sort | |

**User's choice:** Add isRolled flag
**Notes:** Tracker checks initiativeConfig.isRolled — if false, sort by DEX value (no roll)

| Option | Description | Selected |
|--------|-------------|----------|
| No tiebreaker | Unstable sort; DM manually handles ties | ✓ |
| APP tiebreaker | Use APP as tiebreaker after DEX | |
| POW tiebreaker | Use POW as tiebreaker | |
| Name alphabetical | Alphabetical by name | |

**User's choice:** No tiebreaker
**Notes:** Accept unstable sort for same-DEX combatants; DM manually resolves

| Option | Description | Selected |
|--------|-------------|----------|
| Show DEX value | Tracker shows raw DEX value | ✓ |
| Order by sort only | Order is implicit in sort position only | |

**User's choice:** Show DEX value
**Notes:** Players can reference DEX value during tie negotiation

---

## Agent's Discretion

- Settings screen UI implementation pattern (Flutter ListTile + RadioListTile)
- SharedPreferences key naming (e.g., `activeGameSystem`)
- AlertDialog styling (title, message, button text)
- coc7e.json field ordering and grouping within sections
- Error message format in GameModelValidator output (include field path)

## Deferred Ideas

None — discussion stayed within phase scope.
# SaveState — GameModel

## What This Is

SaveState is a TTRPG companion and DM app suite where game system rules, entity types, and field schemas are defined by a swappable `GameModel` — a JSON schema file that tells the app what entities exist (characters, adversaries, wiki pages, etc.), what fields they have, and how core rules like initiative and dice work. Users can switch between bundled systems (D&D 5e ships built-in) or import their own `.json` game model files. The app adapts: wiki page types change, character sheet fields change, encounter rules change.

## Core Value

Any TTRPG group can open SaveState, pick or import their game system, and immediately have a properly structured wiki, character sheet, and encounter tracker — no hardcoded D&D assumptions.

## Requirements

### Validated

- ✓ Wiki popup UI accessible via book icon in both apps — v1.0 Wiki milestone
- ✓ Schema-driven wiki page types with per-type field definitions — v1.0 Wiki milestone
- ✓ Full-text search with title-prioritized scoring — v1.0 Wiki milestone
- ✓ Create flow with type-driven forms — v1.0 Wiki milestone
- ✓ Responsive two-panel / single-panel modal — v1.0 Wiki milestone
- ✓ File-based JSON persistence for wiki pages — v1.0 Wiki milestone
- ✓ Dart workspace monorepo with shared core package — existing
- ✓ Encounter and initiative tracking (DM app) — existing
- ✓ Provider-based state management wired in both apps — existing

### Active

- [ ] `GameModel` data structure: defines entity types, field schemas per entity type, wiki page types, and game rules config (dice notation, initiative formula, ability score display names)
- [ ] D&D 5e GameModel bundled as a JSON asset — replaces hardcoded D&D enum values
- [ ] Call of Cthulhu 7e GameModel bundled as a second JSON asset — proof of true agnosticism
- [ ] External GameModel import: user can load a `.json` game model file from disk
- [ ] In-app game system selector: user can switch the active GameModel
- [ ] `GameEntity` replaces typed `PlayerCharacter`, `Monster`, `NPC` Dart classes — schema-driven `Map<String, dynamic>` data with a type key pointing into the active GameModel's entity schemas
- [ ] Wiki page types driven by active GameModel — `WikiPageType` enum replaced by runtime-loaded type registry
- [ ] Character sheet UI generated from active GameModel's character entity schema
- [ ] Encounter tracker uses active GameModel's initiative config (formula, turn order rules)
- [ ] All existing D&D demo data migrated to `GameEntity` format against the D&D 5e GameModel
- [ ] Both apps reflect the active GameModel without restart

### Out of Scope

- Cloud sync of GameModel files — local-only for this milestone
- User-authored schema editor (build a game model in-app) — import/bundled only for v1
- Multiplayer/networked GameModel switching — single-user switch, NSD sync deferred
- Per-page custom fields beyond what the GameModel schema defines — schema is authoritative
- Backwards compatibility shims for old typed Dart models — clean replacement, no bridge

## Context

**Existing schema pattern to extend:**
`WikiPageType.fields` already returns `List<WikiPageFieldDefinition>` per type — this exact pattern is the blueprint. GameModel externalizes that into JSON so it's runtime-configurable rather than compile-time Dart.

**Models being replaced:**
- `packages/core/lib/models/player_character.dart` — ~200 hardcoded D&D5e fields
- `packages/core/lib/models/monster.dart` — CR, XP, legendary actions, lair actions
- `packages/core/lib/models/npc.dart` — role, biography, no CR
- `packages/core/lib/models/wiki_page_type.dart` — hardcoded D&D-centric page types and field schemas
- `packages/core/lib/models/enums.dart` — ability scores, alignment, size, damage types (all D&D)

**Call of Cthulhu is the agnosticism test because:**
- Skills are percentile (10–100), not D&D ability modifiers
- Characters have Sanity, Luck, Build — no HP as D&D knows it
- No spell levels; no alignment; no class/subclass
- Adversaries are "monsters" but lack CR/XP/legendary actions
- This means if CoC works, the schema is truly flexible

**Tech stack constraints:**
- Flutter/Dart, shared `core` package, workspace monorepo
- JSON assets loaded via `rootBundle` at app startup
- File import via `file_picker` (to be added) for external GameModel files
- Provider pattern for `GameModelService` (active model + switch)

## Constraints

- **No cloud**: Game model files are local assets or imported from disk — no network fetch
- **No restart required**: Switching the active GameModel must update all Provider consumers live
- **Backward compat**: D&D 5e GameModel must reproduce the exact field experience users have today
- **Core package only**: GameModel, GameEntity, and GameModelService live in `packages/core/` — apps are UI only
- **Performance**: GameModel JSON files must load synchronously at startup (<50ms parse time target)

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Replace typed Dart models with generic GameEntity | Typed classes (PlayerCharacter, Monster) encode D&D assumptions at the type level — can't be extended for other TTRPGs without forking | — Pending |
| JSON as schema format | Human-readable, easily authored outside the app, supports import workflow, matches existing wiki persistence format | — Pending |
| `WikiPageType` enum replaced by GameModel registry | Enum is compile-time D&D-only; runtime registry supports any set of page types a GameModel defines | — Pending |
| CoC 7e as second bundled model | Structurally very different from D&D (percentile skills, Sanity, no CR/XP) — validates that the schema is genuinely agnostic | — Pending |
| Provider for active GameModel | Already the pattern in use; `GameModelService` as a ChangeNotifier drives live UI updates on system switch | — Pending |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd-complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-05-07 after GameModel project initialization*

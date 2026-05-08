# Research Summary — SaveState GameModel

## What's the Stack?

No new dependencies in `packages/core`. Everything uses already-declared capabilities:

- **`dart:convert`** — JSON parsing for GameModel assets
- **`rootBundle.loadString()`** — loads bundled `dnd5e.json` / `coc7e.json` from `packages/core/assets/game_models/` (requires `packages/core/` path prefix + pubspec asset declaration)
- **`provider ^6.1.2` + `ChangeNotifierProxyProvider`** — `GameModelService` broadcasts model switches to `WikiProvider` and future downstream providers
- **`file_picker: ^11.0.0`** — native file browser for external `.json` import — **apps only**, not core
- **`DynamicEntityForm`** (custom widget, ~60 lines) — renders form inputs from `List<FieldSchema>` via `switch` on `inputType`; all pub.dev alternatives are dead (9–54 downloads)

**Do not add:** `json_schema`, any form-generation package, `flutter_gen`.

## Table Stakes Features

1. `GameModel` + `GameEntity` data classes in `packages/core` — foundation for everything
2. `WikiPageType` enum replaced by runtime string keys from `GameModel.entityTypes` — existing wiki page files must be migrated, not broken
3. Character sheet UI generated from active GameModel `FieldSchema` list — no hardcoded D&D field names in UI
4. Game system selector accessible from both apps, persisted across restarts
5. CoC 7e as second bundled GameModel — the agnosticism proof (Sanity, percentile skills, no class/CR/XP)
6. `GameModelService` as `ChangeNotifier` — no app restart on system switch
7. Encounter tracker reads `initiativeFormula` from active GameModel
8. Schema validation on external file import — readable errors, never silent crash

**Defer:** In-app schema editor, third bundled system, cross-system entity migration.

## Top 5 Pitfalls

1. **Null crash from unchecked map access** — `entity.data['hp'] as int` throws when key is absent. Fix: typed accessor helpers (`getInt`, `getString`) with `??` fallback, established in Phase A before any entity reads.

2. **WikiPageType enum deletion corrupts persisted data** — `loadAllPages()` line 159 silently swallows all deserialization errors; users lose their entire wiki. Fix: write a migration runner that rewrites legacy type strings to D&D 5e GameModel keys before the enum is deleted. Phase E.

3. **Provider cascade rebuilds 5+ widget subtrees on system switch** — `Consumer<GameModelService>` wrapping large subtrees. Fix: use `Selector` not `Consumer` at all downstream consumers. Establish in Phase C before adding consumer widgets.

4. **CoC and D&D name the same concepts with incompatible semantics** — both have "HP" (different derivation), "DEX" (different range), "abilities" (3–18 vs 15–90). Fix: encounter tracker reads ALL mechanical params from `GameModel.rulesConfig`, never hardcoded field names. Test CoC initiative (DEX-rank sort, no roll) before declaring success.

5. **Schema versioning absent from day one** — renaming any type key silently breaks all persisted files referencing the old key. Fix: `schemaVersion` field is required in every GameModel JSON and persisted entity from the first commit. Cannot be retrofitted.

## Recommended Phase Sequence

| Phase | Focus | Key Deliverable |
|-------|-------|-----------------|
| A | Core data layer | `GameModel`, `EntityTypeSchema`, `FieldSchema`, `GameEntity` + accessor helpers, `GameModelParser` with migration chain — pure Dart, zero Flutter deps |
| B | Service layer + D&D 5e asset | `GameModelService` ChangeNotifier, `dnd5e.json` bundled asset, startup loading |
| C | Provider rewiring | `WikiPage.pageType` → String, `WikiProvider.updateGameModel()`, `ChangeNotifierProxyProvider` in both app main.dart — highest regression risk |
| D | UI generalization | `GameModelFormBuilder`, updated `WikiCreateForm` + `WikiTypePicker`, delete `wiki_page_type.dart` |
| E | Typed model replacement + migration | `GameEntity` storage, demo data migrated, migration runner for legacy wiki files, delete `PlayerCharacter`/`Monster`/`NPC`/`enums.dart` |
| F | CoC + system picker | `coc7e.json`, system picker UI, file import, end-to-end agnosticism test |

## Critical Open Question for Planning

**Initiative formula parser grammar.** The `initiativeFormula` field needs a defined grammar before Phase F planning. Is CoC's DEX-rank sort (no roll) a special formula token (`@dex_sort`) or an `initiativeConfig.isRolled: false` flag? This decision is small but blocks both the encounter tracker migration and CoC GameModel authoring. Write a 1-page design doc in Phase A or B.

## Confidence

| Area | Level |
|------|-------|
| Stack | HIGH — verified on pub.dev |
| D&D 5e feature requirements | HIGH — verified against existing codebase |
| CoC 7e field requirements | MEDIUM — from Roll20 official sheets + Chaosium PDFs |
| Architecture / phase sequence | HIGH — derived from actual codebase import graph |
| Pitfalls | HIGH — each grounded in specific line of existing code |

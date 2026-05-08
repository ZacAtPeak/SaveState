# Technology Stack — GameModel Milestone

**Project:** SaveState — GameModel Runtime Schema System
**Researched:** 2026-05-07
**Milestone context:** Adds a JSON schema runtime layer on top of the existing Flutter/Dart workspace monorepo. Replaces hardcoded D&D 5e Dart classes with a `GameModel` JSON file that defines entity types, field schemas, wiki page types, and game rules config. D&D 5e and CoC 7e are the first two bundled models.

---

## 1. JSON Schema Validation

### Recommendation: Manual schema parsing — do NOT add `json_schema`

**Confidence: HIGH**

The `json_schema` package (Workiva, v5.2.2, 171k weekly downloads, published 7 months ago) implements JSON Schema Draft 7 and is actively maintained. It works on Flutter/mobile. However, it is the wrong tool for this milestone.

The GameModel JSON is *our own schema*, not an arbitrary third-party JSON Schema. We control the structure entirely. The appropriate validation approach is:

1. Define a `GameModelSchema` Dart class with `fromJson` that parses and validates the JSON as it constructs domain objects.
2. Throw descriptive `FormatException` errors on missing required fields or invalid types.
3. Provide a `GameModel.validate()` method that walks the loaded model and returns a list of validation errors.

This is the same pattern already used by `WikiPage.fromJson` in this codebase. It is synchronous, has zero overhead, produces readable error messages, and adds no dependencies.

**Why not `json_schema`:**
- JSON Schema Draft 7 validation is designed for externally-authored arbitrary schemas. A `GameModel` file authored by us has a fixed structure — enforcing it with Draft 7 meta-schema rules adds indirection without benefit.
- The package adds ~171k lines of parser/validator code to the binary for a use case that 40 lines of `fromJson` handles.
- Validation errors from Draft 7 ("instance failed to match exactly one schema", "additionalProperties") are less actionable than custom messages ("entityTypes[2].fields[0] is missing required key 'inputType'").
- `json_schema` is most valuable when you want to accept *user-authored* arbitrary schemas validated against a meta-schema — that is out of scope for v1 (no in-app schema editor).

**When to revisit:** If a future milestone adds user-authored schema editing with live validation feedback, `json_schema` 5.x becomes appropriate.

---

## 2. TTRPG Data Formats to Reference

### For GameModel JSON structure design

**Confidence: MEDIUM** (based on public API/format inspection; no single TTRPG community standard exists)

#### The existing `WikiPageFieldDefinition` pattern is your best reference

The `WikiPageType.fields` extension in `packages/core/lib/models/wiki_page_type.dart` already defines the exact pattern the GameModel should externalize:

```
entityType → list of WikiPageFieldDefinition(key, label, inputType, required, hint, options)
```

The GameModel JSON is that mapping, but runtime-loaded. Design the JSON schema to mirror this Dart structure 1:1.

#### Open5e API v2 — reference for D&D 5e field naming conventions

Source: `https://api.open5e.com/v2/creatures/srd_aboleth/`

The Open5e v2 creature object uses flat field names for primitive stats and nested objects for groupings:

```
armor_class, hit_points, hit_dice, challenge_rating, proficiency_bonus,
ability_scores (nested), saving_throws (nested), skill_bonuses (nested),
actions (array of objects), traits (array)
```

Use these field *keys* in the D&D 5e GameModel JSON for interoperability with community tooling. Naming conventions: `snake_case`, plural for arrays, nested objects only for logical groupings (ability scores, saving throws), not for individual fields.

#### 5e-bits/5e-database — reference for SRD monster/spell data structure

Source: `https://github.com/5e-bits/5e-database`

Provides the JSON source files backing the D&D 5e SRD API. Useful for: (a) validating your D&D 5e GameModel covers all SRD fields, (b) seeding the demo data migration for `GameEntity` objects. No direct dependency — copy field names only.

#### Foundry VTT `template.json` — reference for multi-entity schema design

Source: `https://foundryvtt.wiki/en/development/guides/SD-tutorial/SD04-templatejson`

Foundry defines entity types (`Actor`, `Item`) and their sub-types (character, npc, monster) in `template.json`, with per-subtype field definitions. The `documentTypes` key in `system.json` registers valid sub-types so the engine doesn't discard unknown types.

**Borrow this pattern:** The GameModel JSON should have a top-level `entityTypes` array where each entry has a `typeKey` (the machine-readable identifier), `displayName`, and `fields` array. This mirrors Foundry's approach but is simpler and Dart-native.

Do NOT import Foundry's JavaScript DataModel classes or depend on Foundry's format — reference the *conceptual structure* only.

#### Roll20 CoC 7e `sheet.json` — reference for CoC field inventory

Source: `https://github.com/Roll20/roll20-character-sheets/blob/master/Call_of_Cthulhu_7th_Ed/sheet.json`

The Roll20 CoC 7e sheet confirms the CoC 7e GameModel needs:
- Percentile skills (10–100 range, not modifiers)
- Sanity (current/max), Luck, Build stats
- No spell levels, no alignment, no class
- Movement rate, magic points, damage bonus (auto-calculated from core stats)
- Weapon tracking with malfunction values (different from D&D weapon properties)
- Bouts of madness (no D&D equivalent)

This field inventory drives what `inputType` values and validation rules the CoC 7e GameModel must define. Use `number` input type with `min`/`max` annotations for percentile skills.

#### What NOT to reference

| Format | Why not |
|--------|---------|
| JSON Schema Draft 7 / Draft 2020 meta-schema | Designed for arbitrary schema validation, not TTRPG entity definition. Over-engineered for this use case. |
| D&D Beyond API | Proprietary, no public schema, terms prohibit derivative use |
| Pathfinder 2e Remaster JSON | Different publisher (Paizo), different field semantics. CoC 7e is a better agnosticism test than PF2e. |
| FVTT `system.json` manifest format | Too tied to Foundry's web-based actor/item lifecycle. Borrow concepts, not syntax. |

---

## 3. File Import: `file_picker` for External GameModel Files

### Recommendation: `file_picker ^9.x` (current: 11.0.2)

**Confidence: HIGH** (pub.dev verified, 4.9k likes, 2.36M downloads, published 31 days ago)

```yaml
# Add to apps/companion_app/pubspec.yaml and apps/dm_app/pubspec.yaml
dependencies:
  file_picker: ^11.0.0
```

`file_picker` is the correct and only practical choice for letting users browse the native file system to select a `.json` file. It provides:
- Native file picker UI on Android, iOS, macOS, Windows, Linux
- Extension filtering: `allowedExtensions: ['json']` + `type: FileType.custom`
- Returns `PlatformFile` with path and bytes — read content with `dart:io` `File(result.files.single.path!).readAsString()`

`path_provider + dart:io` is the right stack for reading from known locations (app documents directory, bundled assets). It is NOT a file picker — it provides directory paths, not user-facing file browsing UI. Use `path_provider` only for storing the user's selected GameModel preference and saving imported model files to the app documents directory.

**The correct combined pattern:**
1. `file_picker` — user browses and picks a `.json` file → get the file path
2. `dart:io File.readAsString()` — read the raw JSON content
3. `dart:convert jsonDecode()` — parse to `Map<String, dynamic>`
4. `GameModel.fromJson()` — validate and construct the GameModel object
5. `path_provider` (documents directory) — copy the file to app storage for persistence
6. `provider` (`GameModelService.notifyListeners()`) — broadcast the switch to all consumers

**Platform note for iOS:** The file picker returns a temporary path that may become inaccessible after app restart. Always copy the file to the app documents directory (via `path_provider`) immediately after import. This is the iOS sandboxing constraint, not a `file_picker` bug.

---

## 4. Asset Loading for Bundled GameModel JSON Files

### Recommendation: `rootBundle.loadString` with `packages/core/assets/` path convention

**Confidence: HIGH** (Flutter official docs confirmed)

Bundled GameModel files (D&D 5e, CoC 7e) belong in `packages/core/` because `GameModel`, `GameModelService`, and `GameEntity` all live there. The apps should not duplicate asset files.

**File placement:**
```
packages/core/
  assets/
    game_models/
      dnd5e.json
      coc7e.json
  pubspec.yaml
```

**`packages/core/pubspec.yaml` declaration:**
```yaml
flutter:
  assets:
    - packages/core/assets/game_models/dnd5e.json
    - packages/core/assets/game_models/coc7e.json
```

**Loading from within `packages/core` code:**
```dart
import 'package:flutter/services.dart';
final String json = await rootBundle.loadString(
  'packages/core/assets/game_models/dnd5e.json',
);
```

The `packages/<package_name>/` path prefix is required when loading an asset that is declared in a dependency package (not the app's own `pubspec.yaml`). Flutter's asset bundling includes these automatically when the package is a dependency.

**Startup loading strategy:**
Load both bundled GameModel files at app startup in `GameModelService.init()` before the first frame. Both D&D 5e and CoC 7e JSON files should parse in well under 50ms — the parse time target in PROJECT.md — because these are schema files (~5–20 KB), not data dumps. Call this from each app's `main()` before `runApp()`:

```dart
final gameModelService = GameModelService();
await gameModelService.init(); // loads bundled models
runApp(
  ChangeNotifierProvider.value(
    value: gameModelService,
    child: const MyApp(),
  ),
);
```

**Do NOT use `flutter_gen` for this milestone.** `flutter_gen` (v5.14.1, supports Dart workspaces) generates type-safe asset accessors and is a reasonable future optimization. It is not needed now — the asset paths are static strings (`'packages/core/assets/game_models/dnd5e.json'`), there is no risk of typos at this scale, and adding a build_runner code-generation step adds CI/build complexity for minimal benefit in a 2-file asset scenario.

---

## 5. Dynamic Form Generation from GameModel Field Schemas

### Recommendation: Custom `GameModelFormBuilder` widget — do NOT use a package

**Confidence: HIGH**

The existing `WikiPageFieldDefinition` struct already defines the data model for dynamic forms:

```dart
class WikiPageFieldDefinition {
  final String key;
  final String label;
  final WikiFieldInputType inputType; // text, number, multiline, select
  final bool required;
  final String? hint;
  final List<String>? options; // for select type
}
```

The `create` flow in the wiki UI already renders forms from this definition list. The GameModel milestone extends this pattern to more entity types — it does not introduce a new form-generation problem.

**Build a `DynamicEntityForm` widget** in `packages/core` (or in each app's `widgets/`) that takes a `List<WikiPageFieldDefinition>` (or its GameModel successor) and renders the appropriate Flutter `TextField`/`DropdownButtonFormField`/`TextFormField` based on `inputType`. This is ~60 lines of code with a `switch` on `inputType`.

**Why every JSON form package is wrong for this use case:**

| Package | Version | Problem |
|---------|---------|---------|
| `flutter_json_schema_form` | 0.0.10 | 54 total downloads, last published 3 years ago, proof-of-concept quality. Dead. |
| `schema_form_builder` | 0.0.3 | 9 downloads, last published 15 months ago, dropdowns "coming soon". Dead. |
| `flutter_smart_forms` | 1.0.2 | 36 weekly downloads, 1 like. Published 52 days ago but no adoption signal. Imposes a specific JSON schema format that would require translating `WikiPageFieldDefinition` → their schema format just to get back what you already have. |
| `flutter_form_builder` | 10.3.0+2 | Well-maintained (2.7k likes, 160 pub points). BUT: it is a widget library for building imperative forms — does not accept a `List<FieldDefinition>` and render a form. You would write the `switch` statement yourself anyway. Adds dependency for zero-gain over `TextFormField`. |
| `json_form_builder` | unknown | Multi-language support emphasis — not the problem being solved here. |

**The summary:** The TTRPG dynamic form problem is 4 input types (`text`, `number`, `multiline`, `select`) with labels, hints, and validation. Every form-generation package in the Dart ecosystem is either dead, has near-zero adoption, or solves a harder problem than the one this milestone has.

Write the custom widget. It will be ~60 lines, you will own it, and it will be exactly as complex as your data model requires.

**Minimum field type coverage for GameModel v1:**

| `inputType` | Flutter widget | Notes |
|-------------|---------------|-------|
| `text` | `TextFormField` | Single-line string |
| `number` | `TextFormField(keyboardType: TextInputType.number)` | Parse to `num` on submit |
| `multiline` | `TextFormField(maxLines: null, minLines: 3)` | Free text |
| `select` | `DropdownButtonFormField<String>` | Uses `options` list |

The GameModel milestone may introduce additional types (e.g., `boolean` for toggle fields like "Requires Attunement"). Add them to the `WikiFieldInputType` enum and the `DynamicEntityForm` switch as needed. Keep them in sync.

---

## Additions to `packages/core/pubspec.yaml`

```yaml
# No new dependencies required for the GameModel milestone core logic.
# All needed capabilities are:
#   - dart:convert (built-in) — JSON parsing
#   - dart:io (built-in) — file reading for imported models
#   - flutter/services.dart (built-in) — rootBundle for bundled assets
#   - provider ^6.1.2 (already present) — GameModelService state
#   - path ^1.9.0 (already present) — file path manipulation

# NEW: needed for the bundled JSON assets to be resolvable from the package
flutter:
  assets:
    - packages/core/assets/game_models/dnd5e.json
    - packages/core/assets/game_models/coc7e.json
```

## Additions to app `pubspec.yaml` files

```yaml
# Add to apps/companion_app/pubspec.yaml AND apps/dm_app/pubspec.yaml
dependencies:
  file_picker: ^11.0.0   # for external GameModel import UI
```

---

## What NOT to Use

| Package / Approach | Why Not |
|-------------------|---------|
| `json_schema` (Workiva) | Full JSON Schema Draft 7 validator — correct library, wrong problem. Use `fromJson` with explicit Dart validation instead. |
| `flutter_json_schema_form` | Dead (3 years, 54 downloads). |
| `schema_form_builder` | Dead (dropdowns not implemented, 9 downloads). |
| `flutter_smart_forms` | No adoption signal (1 like). Imposes foreign schema format. |
| `flutter_form_builder` | Does not accept a field list and auto-render. You write the switch anyway. Skip the dependency. |
| `flutter_gen` | Useful code-gen for assets, but overkill for 2 static JSON file paths. Adds build_runner to the workflow. Revisit if the asset count grows. |
| D&D Beyond / Foundry VTT as dependencies | No — reference their schemas for naming conventions only. Never take a runtime dependency on them. |
| `path_provider` alone for file import | `path_provider` gives directory paths; it cannot open a native file picker dialog. Use `file_picker` for that. |

---

## Sources

- [json_schema 5.2.2 on pub.dev](https://pub.dev/packages/json_schema) — HIGH confidence (pub.dev, Workiva publisher, 171k weekly downloads)
- [file_picker 11.0.2 on pub.dev](https://pub.dev/packages/file_picker) — HIGH confidence (pub.dev, 4.9k likes, 2.36M downloads, published 31 days ago)
- [flutter_json_schema_form 0.0.10 on pub.dev](https://pub.dev/packages/flutter_json_schema_form) — HIGH confidence (pub.dev — confirmed dead, 54 downloads, 3 years old)
- [schema_form_builder 0.0.3 on pub.dev](https://pub.dev/packages/schema_form_builder) — HIGH confidence (pub.dev — confirmed dead, 9 downloads)
- [flutter_smart_forms 1.0.2 on pub.dev](https://pub.dev/packages/flutter_smart_forms) — HIGH confidence (pub.dev — confirmed low-adoption)
- [flutter_form_builder 10.3.0+2 on pub.dev](https://pub.dev/packages/flutter_form_builder) — HIGH confidence (pub.dev, 2.7k likes, well-maintained)
- [flutter_gen 5.14.1 on pub.dev](https://pub.dev/packages/flutter_gen) — HIGH confidence (pub.dev, workspace support confirmed)
- [Open5e v2 creature API (Aboleth)](https://api.open5e.com/v2/creatures/srd_aboleth/) — HIGH confidence (live API response, verified 2026-05-07)
- [Roll20 CoC 7th Ed sheet.json](https://github.com/Roll20/roll20-character-sheets/blob/master/Call_of_Cthulhu_7th_Ed/sheet.json) — HIGH confidence (official Roll20 GitHub)
- [D&D 5e Monster JSON Schema reference](https://brianwendt.github.io/dnd5e_json_schema/Monster.schema.json.html) — MEDIUM confidence (community-maintained, not official WotC)
- [Flutter asset loading from packages — official docs](https://docs.flutter.dev/ui/assets/assets-and-images) — HIGH confidence (flutter.dev)
- [Flutter multi-package asset rootBundle path convention](https://blog.kinto-technologies.com/posts/2024-12-23-MobileAdventCalendar-en/) — MEDIUM confidence (community blog, Dec 2024, verified against official docs)
- [Open5e schema design discussion](https://github.com/open5e/open5e/wiki/In-Progress:-Schemas) — MEDIUM confidence (open5e GitHub wiki, community standard in progress)
- [Foundry VTT template.json guide](https://foundryvtt.wiki/en/development/guides/SD-tutorial/SD04-templatejson) — MEDIUM confidence (community wiki, referenced for conceptual pattern only)

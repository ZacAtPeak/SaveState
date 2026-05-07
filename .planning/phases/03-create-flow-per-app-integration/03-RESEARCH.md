# Phase 3: Create Flow & Per-App Integration - Research

**Researched:** 2026-05-07
**Domain:** Flutter create-flow UX, provider state wiring, and shared core wiki integration
**Confidence:** HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
### Create Form Navigation
- **D-01:** The create form replaces the detail panel — in two-panel mode it occupies the right panel; in single-panel mode it pushes via Navigator (same routing already used for detail view).
- **D-02:** After successful save, the new page is auto-selected and shown in the detail view (not the create form, not an empty state).

### Type Picker Design
- **D-03:** The type picker is a 2×4 grid of icon cards, one per `WikiPageType` (7 types). Each card shows an icon and the type's `displayName`.
- **D-04:** The picker is cancellable — a back arrow (or Cancel button) returns to the previous state without creating a page.

### Form Field Depth
- **D-05:** Full per-type structured fields — each type shows its own set of labeled fields beyond the common title/body/tags/aliases.
- **D-06:** Field schemas are defined via a `fields` getter on `WikiPageTypeExtension` in `core` — returns a list of field definitions (label + key + input type) per type. This keeps schema knowledge centralized in the model layer, not scattered in the UI.
- **D-07:** Structured field values are stored in the existing `statBlock: Map<String, dynamic>` on `WikiPage`. No model changes needed — form writes field values as map entries keyed by the field definition's key string.

### Book Icon & App Integration
- **D-08:** The book icon (`Icons.menu_book`) lives as an `AppBar` action in both `companion_app` and `dm_app`.
- **D-09:** Each app wraps its `MaterialApp` in a top-level `WikiProvider` (a `ChangeNotifier`) that loads all pages from `WikiStorageService` at startup. The provider holds the live pages list so new pages created in the modal appear in the sidebar immediately.

### Claude's Discretion
- Specific per-type field definitions (which fields belong to creature, spell, item, etc.) — Claude should derive sensible D&D-relevant fields from the type's domain.
- Icon choices for each type in the type picker grid — use Material icons appropriate to each type's domain.
- Exact widget layout of the create form (spacing, padding, field ordering within each type).

### Deferred Ideas (OUT OF SCOPE)
None — discussion stayed within phase scope.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| CREATE-01 | Plus button in modal opens page type picker | AppBar action pattern in `WikiModalShell`, modal route behavior with `showModalBottomSheet`, and provider-driven create mode state |
| CREATE-02 | Type picker presents available wiki page types | Enum-driven grid from `WikiPageType.values` + extension metadata (`displayName`, new `fields`) |
| CREATE-03 | Form displays fields appropriate to selected page type | `Form` + `TextFormField` validation lifecycle; schema-driven dynamic field rendering |
| CREATE-04 | New page saves with title, tags, aliases, markdown body, and structured fields | Existing `WikiPage` constructor + `statBlock` map + `WikiStorageService.savePage/loadAllPages` + provider list refresh |
</phase_requirements>

## Summary

Phase 3 should be planned as a **shared-core UI implementation** plus **thin per-app wiring**, not as two separate feature builds. The current code already has the modal shell, page list, detail view, `WikiPage` model, and file persistence service in `packages/core`; the missing piece is a provider-driven create state machine and create widgets living in `packages/core/lib/wiki/`, then app-level trigger/wrapper integration in each app. [VERIFIED: codebase read of `wiki_modal_shell.dart`, `wiki_modal_provider.dart`, `wiki_page_list.dart`, `wiki_page.dart`, `wiki_storage_service.dart`]

The safest architecture for planning is: `WikiProvider` (app scope) owns loaded pages and persistence calls; `WikiModalProvider` (modal scope) owns transient UI state (selected page, creating mode, pending type, draft fields) and receives page mutations via explicit methods. This aligns with Provider guidance on creating vs reusing objects and read/watch semantics, and preserves immediate sidebar refresh after save. [CITED: https://pub.dev/packages/provider] [VERIFIED: codebase patterns]

**Primary recommendation:** Implement one schema-driven create flow in `packages/core/lib/wiki/` (type picker + dynamic form + submit path) and only wire app entry points (`companion_app`, `dm_app`) to open modal with a top-level `WikiProvider`. [VERIFIED: ROADMAP + CONTEXT + codebase]

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Book icon trigger in both apps | Browser / Client | — | AppBars exist in app UI trees; trigger is pure UI event handling. [VERIFIED: `apps/*/lib/main.dart`] |
| Modal presentation and responsive layout branch | Browser / Client | Frontend Server (—) | Flutter client handles width checks and widget branching (`>=600dp` split). [VERIFIED: `wiki_modal_shell.dart`] |
| Type picker UI and selection | Browser / Client | — | Pure widget interaction backed by modal provider state. [ASSUMED] |
| Per-type field schema source of truth | API / Backend-equivalent domain layer (`core/models`) | Browser / Client | Must be centralized in shared model extension so both apps render identical schemas. [VERIFIED: D-06 decision + existing extension pattern] |
| Form validation and draft capture | Browser / Client | — | `Form`/`TextFormField` are client-side validation primitives. [CITED: https://api.flutter.dev/flutter/widgets/Form-class.html] [CITED: https://api.flutter.dev/flutter/material/TextFormField-class.html] |
| Page persistence | Database / Storage | API / Backend-equivalent service layer (`core/services`) | `WikiStorageService` writes/reads JSON files from disk. [VERIFIED: `wiki_storage_service.dart`] |
| Auto-select newly created page and sidebar refresh | Browser / Client | Storage | UI provider updates selected page and in-memory list after successful save. [VERIFIED: CONTEXT D-02/D-09 + current provider/list usage] |

## Project Constraints (from AGENTS.md)

- Domain models must live in `packages/core/lib/models/`; do not duplicate models in app packages. [VERIFIED: AGENTS.md]
- Shared services belong in `packages/core/lib/services/`. [VERIFIED: AGENTS.md]
- App-specific UI belongs in `apps/<app>/lib/...`; shared wiki UI belongs in `packages/core/lib/wiki/`. [VERIFIED: AGENTS.md + CONTEXT canonical refs]
- Apps depend on `core`; apps must not depend on each other. [VERIFIED: AGENTS.md]
- Workspace uses `resolution: workspace`. [VERIFIED: AGENTS.md + pubspecs]
- SDK constraints currently include Dart `^3.11.5` (workspace, companion app) and `^3.5.0` (core, dm app). [VERIFIED: `pubspec.yaml` files]

## Standard Stack

### Core
| Library | Version (repo) | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Flutter Material SDK | Flutter 3.41.9 installed | UI primitives (AppBar, icons, modal, form widgets, Navigator) | Native framework primitives minimize extra deps and integrate with existing app architecture. [VERIFIED: `flutter --version`] [CITED: https://api.flutter.dev/flutter/material/showModalBottomSheet.html] |
| provider | ^6.1.2 pinned (`core` + apps) | Shared app/modal state via `ChangeNotifierProvider` and consumers | Already used in core modal shell; canonical lightweight state package for ChangeNotifier patterns. [VERIFIED: pubspecs + codebase] [CITED: https://pub.dev/packages/provider] |
| core models/services (`WikiPage`, `WikiPageTypeExtension`, `WikiStorageService`) | in-repo | Type schemas + persistence contract | Existing source of truth; phase decisions explicitly require extension-driven schema and statBlock persistence. [VERIFIED: CONTEXT D-06/D-07 + codebase] |

### Supporting
| Library | Version (repo) | Purpose | When to Use |
|---------|---------|---------|-------------|
| uuid | ^4.5.1 pinned | Page ID generation via `WikiPage` default constructor | Use on create submit when no explicit ID provided. [VERIFIED: `wiki_page.dart`] |
| flutter_markdown | ^0.7.0 pinned | Rendering created markdown body in detail panel post-save | Existing detail renderer path; no phase-3 replacement needed. [VERIFIED: `wiki_page_detail.dart`] |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Provider + ChangeNotifier | Riverpod/Bloc | More ceremony and migration cost for a phase focused on incremental integration, not state-stack replacement. [ASSUMED] |
| Dynamic schema in `WikiPageTypeExtension` | Hardcoded per-widget fields | Faster initially but duplicates logic and violates locked decision D-06. [VERIFIED: CONTEXT D-06] |

**Version verification (current registry snapshots):**
- `provider` latest on pub.dev: `6.1.5+1` (published 2025-08-19). [CITED: https://pub.dev/packages/provider/changelog]
- `uuid` latest on pub.dev: `4.5.3` (published 2 months ago). [CITED: https://pub.dev/packages/uuid]
- `path` latest on pub.dev: `1.9.1` (published 18 months ago). [CITED: https://pub.dev/packages/path]
- `flutter_markdown` latest listed: `0.7.7+1`, marked discontinued/replaced by `flutter_markdown_plus`. [CITED: https://pub.dev/packages/flutter_markdown]

**Planning guidance:** keep pinned repo versions for this phase unless explicitly upgrading dependency ranges is added to scope. [ASSUMED]

## Architecture Patterns

### System Architecture Diagram

```text
[Companion App AppBar book icon] ─┐
                                  ├─> WikiModalShell.show(...) -> [Modal route via showModalBottomSheet]
[DM App AppBar book icon] ────────┘                                  |
                                                                       v
                                                            [WikiModalProvider state]
                                                           /         |            \
                                              [list mode] /   [create mode]      [detail mode]
                                                        v          v                 v
                                                 WikiPageList -> Type Picker -> Dynamic Create Form
                                                                              | validate + submit
                                                                              v
                                                                WikiStorageService.savePage(page)
                                                                              |
                                                                              v
                                                                WikiProvider pages list mutation
                                                                              |
                                                                              v
                                                              auto-select new page -> WikiPageDetail
```

### Recommended Project Structure
```text
packages/core/lib/
├── models/
│   └── wiki_page_type.dart         # add field definition model + fields getter
├── wiki/
│   ├── wiki_modal_provider.dart    # add create-flow state + page mutation methods
│   ├── wiki_modal_shell.dart       # add '+' action and create/detail routing
│   ├── wiki_type_picker.dart       # new 2x4 grid picker widget
│   ├── wiki_create_form.dart       # new dynamic form widget
│   └── wiki_provider.dart          # new app-scope provider for load/save/list
└── services/
    └── wiki_storage_service.dart   # reuse existing load/save methods

apps/companion_app/lib/main.dart    # wrap app with WikiProvider + AppBar action wiring
apps/dm_app/lib/main.dart           # same wiring
```

### Pattern 1: Modal-local finite state (list / picker / form / detail)
**What:** Encode modal mode in provider fields (`selectedPage`, `isCreating`, `pendingType`) and derive body widget from those flags. [VERIFIED: CONTEXT + current provider pattern]
**When to use:** Any modal flow that must preserve history-like transitions without introducing full route complexity inside two-panel mode. [ASSUMED]
**Example:**
```dart
// Source: https://pub.dev/packages/provider and existing wiki_modal_provider.dart pattern
class WikiModalProvider extends ChangeNotifier {
  WikiPage? selectedPage;
  bool isCreating = false;
  WikiPageType? pendingType;

  void startCreate() { isCreating = true; pendingType = null; notifyListeners(); }
  void pickType(WikiPageType type) { pendingType = type; notifyListeners(); }
  void cancelCreate() { isCreating = false; pendingType = null; notifyListeners(); }
}
```

### Pattern 2: Schema-driven field rendering
**What:** Render form sections from `WikiPageTypeExtension.fields` instead of per-type hardcoded widgets. [VERIFIED: D-06]
**When to use:** Multiple types sharing the same shell but varying field sets. [ASSUMED]
**Example:**
```dart
// Source: project locked decision D-06 + Form/TextFormField docs
for (final field in selectedType.fields) {
  children.add(TextFormField(
    decoration: InputDecoration(labelText: field.label, hintText: field.hint),
    validator: field.required ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null : null,
    onSaved: (v) => statBlock[field.key] = v,
  ));
}
```

### Anti-Patterns to Avoid
- **Hardcoding type-specific forms in app packages:** breaks shared UI contract and duplicates logic. [VERIFIED: AGENTS + CONTEXT]
- **Mutating provider during build synchronously:** provider docs warn this can cause inconsistent rebuild timing; mutate in callbacks or provider methods. [CITED: https://pub.dev/packages/provider]
- **Using `ChangeNotifierProvider.value` to create new objects:** provider docs recommend default constructor for creation and `.value` only for existing instances. [CITED: https://pub.dev/packages/provider]

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Modal route semantics | Custom overlay stack manager | `showModalBottomSheet` | Handles barrier, dismissal, and route Future lifecycle correctly. [CITED: https://api.flutter.dev/flutter/material/showModalBottomSheet.html] |
| Form orchestration | Ad-hoc validation maps | `Form` + `TextFormField` + validators | Built-in save/reset/validate lifecycle and error display. [CITED: https://api.flutter.dev/flutter/widgets/Form-class.html] [CITED: https://api.flutter.dev/flutter/material/TextFormField-class.html] |
| App-wide mutable state bus | Homemade singleton | `provider` `ChangeNotifierProvider` | Existing package in repo and standard O(1) lookup/read patterns. [CITED: https://pub.dev/packages/provider] |

**Key insight:** This phase is integration-heavy; custom infra increases bug surface without adding product value. [ASSUMED]

## Common Pitfalls

### Pitfall 1: Sidebar doesn’t refresh after save
**What goes wrong:** New page persists to disk but list UI still shows old pages until reopen. [VERIFIED: expected from current `WikiPageList` receiving passed list]
**Why it happens:** Source list remains outside provider mutation path, and modal/provider ownership is split incorrectly. [VERIFIED: current shell takes `pages` parameter + provider lacks pages]
**How to avoid:** Make one provider own canonical in-memory list and append/select after successful save before returning to detail mode. [VERIFIED: D-09]
**Warning signs:** Save succeeds with no error, but list count unchanged in same modal session. [ASSUMED]

### Pitfall 2: Wrong navigator context in single-panel create flow
**What goes wrong:** `push`/`pop` affects parent route or fails to show expected screen transition. [CITED: https://api.flutter.dev/flutter/widgets/Navigator-class.html]
**Why it happens:** `Navigator.of(context)` binds to nearest ancestor navigator; large build trees can use unintended context. [CITED: https://api.flutter.dev/flutter/widgets/Navigator-class.html]
**How to avoid:** Trigger route operations from a context intentionally below the intended navigator (or keep modal-local state-based switching in two-panel). [CITED: https://api.flutter.dev/flutter/widgets/Navigator-class.html]
**Warning signs:** Back button exits modal unexpectedly instead of returning from create/picker. [ASSUMED]

### Pitfall 3: Schema drift between enum and form widgets
**What goes wrong:** Added/changed page types do not appear or fields mismatch save keys. [VERIFIED: risk implied by D-06/D-07 contract]
**Why it happens:** UI uses separate hardcoded map rather than extension field definitions. [VERIFIED: D-06]
**How to avoid:** Generate picker and dynamic form directly from `WikiPageType.values` and each type’s `fields`. [VERIFIED: D-03 + D-06]
**Warning signs:** One type missing from picker grid or empty structured map for filled fields. [ASSUMED]

## Code Examples

### Modal launcher in both apps
```dart
// Source: existing WikiModalShell.show + Flutter IconButton patterns
IconButton(
  icon: const Icon(Icons.menu_book),
  tooltip: 'Wiki',
  onPressed: () {
    WikiModalShell.show(
      context,
      provider: context.read<WikiModalProvider>(),
      pages: context.read<WikiProvider>().pages,
    );
  },
)
```

### Form submit with validation + save
```dart
// Source: Form/TextFormField docs + existing WikiPage/WikiStorageService APIs
final formKey = GlobalKey<FormState>();
if (formKey.currentState!.validate()) {
  formKey.currentState!.save();
  final page = WikiPage(
    title: title,
    pageType: selectedType,
    body: body,
    tags: tags,
    aliases: aliases,
    statBlock: statBlock,
  );
  await storage.savePage(page);
  modal.addPageAndSelect(page);
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `provider` 6.1.2 in repo | `provider` 6.1.5+1 latest | 2025-08-19 | Repo is behind latest patch; acceptable for phase scope unless upgrade planned. [CITED: https://pub.dev/packages/provider/changelog] |
| `flutter_markdown` active package | `flutter_markdown` discontinued; suggested `flutter_markdown_plus` | Discontinuation notice currently on package page | Do not expand markdown feature surface in this phase; migration can be future phase. [CITED: https://pub.dev/packages/flutter_markdown] |

**Deprecated/outdated:**
- `flutter_markdown` is discontinued upstream (still functional but not actively maintained). [CITED: https://pub.dev/packages/flutter_markdown]

## Open Questions (RESOLVED)

1. **Where should `WikiStorageService` base directory come from in each app?**
   - **Resolution for planning:** each app-level `WikiProvider` resolves base directory once at startup using the existing app path policy; if no shared path helper exists, use `path_provider` app-documents directory as the fallback implementation path.
   - What we know: service requires `Directory baseDirectory` at construction. [VERIFIED: `wiki_storage_service.dart`]
   - Planning assumption captured: directory resolution is owned by app wiring (not modal widgets), and the resolved directory is passed into `WikiStorageService` used by `WikiProvider`.

2. **Should single-panel create flow use explicit Navigator push or provider-state view swap?**
   - **Resolution for planning:** use explicit `Navigator.push` for create flow in single-panel mode, mirroring existing detail-route behavior and back semantics.
   - What we know: locked decision D-01 mandates Navigator push in single-panel mode.
   - Planning assumption captured: cancel/save paths must pop back to list/detail flow and never dismiss the modal unexpectedly. [VERIFIED: D-01]

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Dart SDK | Build/tests and provider logic | ✓ | 3.11.5 | — |
| Flutter SDK | UI widgets/modal/form integration | ✓ | 3.41.9 | — |
| provider package | state management wiring | ✓ (in repo deps) | ^6.1.2 pinned | upgrade optional |

**Missing dependencies with no fallback:**
- None identified for this phase. [VERIFIED: environment probe + scope]

**Missing dependencies with fallback:**
- None identified for this phase. [VERIFIED]

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | `flutter_test` (app widgets) + `dart test` (core package) [VERIFIED: test files + pubspecs] |
| Config file | none explicit (default tooling) |
| Quick run command | `cd packages/core && dart test` |
| Full suite command | `dart test && cd apps/companion_app && flutter test && cd ../dm_app && flutter test` |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| CREATE-01 | '+' opens type picker | widget | `cd packages/core && dart test test/wiki_create_flow_test.dart -r compact` | ❌ Wave 0 |
| CREATE-02 | picker shows all `WikiPageType` values | widget | `cd packages/core && dart test test/wiki_create_flow_test.dart -r compact` | ❌ Wave 0 |
| CREATE-03 | selected type renders schema-specific fields | widget | `cd packages/core && dart test test/wiki_create_form_test.dart -r compact` | ❌ Wave 0 |
| CREATE-04 | submit persists and refreshes list/selection | unit+widget | `cd packages/core && dart test test/wiki_create_submit_test.dart -r compact` | ❌ Wave 0 |

### Sampling Rate
- **Per task commit:** `cd packages/core && dart test`
- **Per wave merge:** `dart test && cd apps/companion_app && flutter test && cd ../dm_app && flutter test`
- **Phase gate:** Full suite green before `/gsd-verify-work`

### Wave 0 Gaps
- [ ] `packages/core/test/wiki_create_flow_test.dart` — covers CREATE-01/02
- [ ] `packages/core/test/wiki_create_form_test.dart` — covers CREATE-03
- [ ] `packages/core/test/wiki_create_submit_test.dart` — covers CREATE-04
- [ ] app-level wiring tests for both AppBar book icon handlers (`apps/*/test/`) to ensure modal launch path

## Security Domain

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | no | Not in scope for local create-flow UI |
| V3 Session Management | no | Not in scope |
| V4 Access Control | no | Single-user local flow in current phase scope |
| V5 Input Validation | yes | `Form` + `TextFormField.validator` + trimming/parsing for structured fields [CITED: https://api.flutter.dev/flutter/widgets/Form-class.html] [CITED: https://api.flutter.dev/flutter/material/TextFormField-class.html] |
| V6 Cryptography | no | No new crypto operations in scope |

### Known Threat Patterns for Flutter local-form + file persistence

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Oversized input causing UI/perf degradation | Denial of Service | Add max lengths for free-text fields and avoid unbounded synchronous processing in build callbacks. [ASSUMED] |
| Malformed structured values in `statBlock` | Tampering | Normalize/validate field types at submit before save. [VERIFIED: statBlock map is dynamic in model] |
| Accidental data loss on dismiss/back | Repudiation | Require explicit cancel path and keep save action intentional. [VERIFIED: D-04 cancelability requirement] |

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | Provider + modal state machine is the best-fit architecture versus route-heavy alternatives | Summary / Architecture Patterns | Could add rework if team prefers route-first design |
| A2 | Keeping dependency pins unchanged is preferred for this phase | Standard Stack | Might miss needed fixes if current pins are insufficient |
| A3 | Size/perf input limits should be added as validation hardening | Security Domain | Might be unnecessary scope if dataset remains tiny |
| A4 | Explicit `path_provider` may be needed for base directory wiring | Open Questions | Could add unnecessary task if app already has path policy |

## Sources

### Primary (HIGH confidence)
- `/websites/api_flutter_dev` (Context7) — Navigator push/pop patterns and popup-route behavior [VERIFIED via ctx7 CLI docs output]
- https://api.flutter.dev/flutter/material/showModalBottomSheet.html — modal API contract
- https://api.flutter.dev/flutter/widgets/Form-class.html — form lifecycle/validation contract
- https://api.flutter.dev/flutter/material/TextFormField-class.html — field validation/saving behavior
- https://pub.dev/packages/provider — Provider creation/consumption guidance
- Local codebase files: `wiki_modal_shell.dart`, `wiki_modal_provider.dart`, `wiki_page_list.dart`, `wiki_page.dart`, `wiki_storage_service.dart`, app `main.dart` files

### Secondary (MEDIUM confidence)
- https://pub.dev/packages/provider/changelog — latest provider release metadata
- https://pub.dev/packages/uuid
- https://pub.dev/packages/path
- https://pub.dev/packages/flutter_markdown

### Tertiary (LOW confidence)
- None

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — grounded in existing repo dependencies and official package/API docs
- Architecture: HIGH — constrained by locked decisions and existing code integration points
- Pitfalls: MEDIUM — some warning signs are inferred from typical Flutter/provider failure modes

**Research date:** 2026-05-07
**Valid until:** 2026-06-06

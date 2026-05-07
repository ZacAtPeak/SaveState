# Project Research Summary

**Project:** SaveState Wiki Popup UI
**Domain:** Flutter D&D wiki popup with responsive layouts
**Researched:** 2026-05-07
**Confidence:** HIGH

## Executive Summary

This project adds a full-screen wiki popup UI to two existing Flutter apps (companion_app and dm_app) in a Dart workspace monorepo. The wiki provides D&D players and DMs with quick access to rules, creatures, spells, items, and custom content during gameplay — accessible via a book icon in each app's AppBar. The core challenge is building a responsive, two-panel layout (sidebar + detail) that works across phones, tablets, and desktops, with full-text search, markdown rendering, and structured stat block display.

The recommended approach leverages existing infrastructure: `provider` for state management (already in companion_app), `flutter_markdown_plus` for markdown rendering (the maintained successor to discontinued `flutter_markdown`), file-based JSON storage, and built-in Flutter widgets (`MediaQuery.sizeOf`, `LayoutBuilder`, `showModalBottomSheet`) for responsive layout and modal presentation. Shared UI components belong in `packages/core/lib/wiki/` to avoid duplication between apps — following the existing pattern of shared `CreatureDetailView`.

Key risks include: (1) repeating the monolithic view anti-pattern already present in `creature_detail_view.dart` (757 lines) — mitigated by strict component decomposition into focused widgets under 150 lines each; (2) using device-type checks instead of window-size branching — mitigated by enforcing `MediaQuery.sizeOf` with Material 3 breakpoints from the first commit; (3) state loss on modal dismiss — mitigated by lifting wiki state to a `ChangeNotifier` scoped above the modal; and (4) search performance degradation — mitigated by debouncing and title-first filtering. All risks have clear, documented prevention strategies.

## Key Findings

### Recommended Stack

**Core technologies:**
- `flutter_markdown_plus` ^1.0.7: Render markdown wiki content — official successor to discontinued `flutter_markdown`, drop-in API compatible
- `provider` ^6.1.2: Wiki state management — already used in companion_app, consistent with existing architecture
- `path_provider` ^2.1.4: App documents directory — standard Flutter package for file path resolution
- Flutter `MediaQuery.sizeOf` + `LayoutBuilder`: Responsive two-panel vs single-panel switching — zero dependency, built into SDK
- `showModalBottomSheet` / `showGeneralDialog`: Full-screen slide-up modal — built-in, no external dependency needed
- Custom Dart search: In-memory full-text search with title prioritization — no external package for v1; defer `fuzzywuzzy` to v2 if needed
- `dart:io` + `dart:convert`: File-based JSON persistence — sufficient for v1 single-device storage

**Critical: Do NOT use `flutter_markdown`** — it is officially discontinued and will not receive updates.

### Expected Features

**Must have (table stakes):**
- Full-screen modal popup triggered by book icon — core interaction pattern
- Responsive layout (two-panel on wide, single-panel on narrow) — must work on phones, tablets, desktops
- Page list with type indicator (creature, item, spell, rule, etc.) — users need to see what exists
- Full-text search with title prioritization — primary way users find content mid-game
- Page detail view with markdown rendering — core content display
- Stat block rendering for creature-type pages — D&D-specific differentiator
- Tag display on pages — primary organization mechanism
- Create new page from modal — DM needs to add custom content
- Close/dismiss modal — basic modal hygiene

**Should have (competitive differentiators):**
- Title-prioritized full-text search with scoring — dramatically faster lookup during gameplay
- Alias-based search (alternative names) — critical for D&D terminology
- Typed page schemas with per-type field sets — spells show casting time, items show weight, etc.
- Keyboard navigation support (desktop) — arrow keys, Enter, Escape for desktop DMs

**Defer (v2+):**
- Edit/delete existing pages — scope expansion; create-only validates content model first
- NSD sync from DM to companion — next milestone; requires networking complexity
- Hierarchical folder/tree organization — tags sufficient for v1
- External import/export — format diversity and licensing complexity
- Rich text editor — markdown is sufficient for v1
- Cross-linking from app text into wiki — requires text parsing infrastructure

### Architecture Approach

The architecture follows a three-layer pattern: core models/services in `packages/core/`, shared UI components also in `packages/core/lib/wiki/`, and per-app modal wrappers + triggers in each app's `lib/wiki/`. This avoids duplicating wiki UI between apps while keeping app-specific entry points isolated. State management uses a standalone `WikiState` ChangeNotifier instantiated at the modal level, keeping wiki state self-contained and independent of app-level providers.

**Major components:**
1. **WikiPage model** (core) — Immutable domain model with toJson/fromJson, UUID, title, tags, aliases, markdown body, stat block fields, page type
2. **WikiPageType enum** (core) — Typed page system (rule, item, spell, creature, location, npc, other) with per-type stat block field schemas
3. **WikiStorageService** (core) — File-based JSON persistence using path_provider + dart:io
4. **WikiSearchService** (core) — In-memory full-text search with title prioritization and scoring
5. **WikiResponsiveLayout** (shared UI) — Branches between 1-panel and 2-panel using MediaQuery.sizeOf with 600px breakpoint
6. **WikiPageList** (shared UI) — Searchable sidebar with TextField + ListView.builder
7. **WikiPageDetail** (shared UI) — Markdown rendering via flutter_markdown_plus + custom stat block widgets
8. **WikiCreateForm** (shared UI) — Dynamic form with fields driven by WikiPageType enum
9. **WikiModal** (per-app) — Full-screen modal wrapper with slide-up animation
10. **WikiTrigger** (per-app) — Book icon button wired into each app's AppBar

### Critical Pitfalls

1. **Device-type checking instead of window-size branching** — Use `MediaQuery.sizeOf(context).width` with Material 3 breakpoints (600px), never `Platform.isIOS` or `Platform.isAndroid` for layout decisions
2. **Using MaterialPageRoute instead of slide-up modal** — Use `showModalBottomSheet` with `isScrollControlled: true` or `showGeneralDialog` with custom PageRouteBuilder for slide-up animation
3. **State loss on modal dismiss** — Lift wiki state (search query, selected page, scroll position) to a ChangeNotifier scoped above the modal; use PageStorageKey for ListView scroll preservation
4. **Using discontinued flutter_markdown** — Use `flutter_markdown_plus: ^1.0.7`; API is identical, just a dependency swap
5. **Duplicating wiki UI code across apps** — Place shared wiki UI widgets in `packages/core/lib/wiki/`; each app only owns modal wrapper and trigger button
6. **Monolithic view files** — Enforce component decomposition: each widget under 150 lines; the codebase already suffers from the 757-line CreatureDetail anti-pattern
7. **Search without debounce** — Add 200-300ms debounce on search input; filter titles first, then body

## Implications for Roadmap

Based on research, suggested phase structure:

### Phase 1: Core Models + Services
**Rationale:** Everything depends on the data shape. Cannot build UI without WikiPage model, and services are needed before UI can display real data.
**Delivers:** WikiPageType enum, WikiPage model, StatBlock value type, WikiStorageService (file-based JSON), WikiSearchService (in-memory search with title prioritization)
**Addresses:** Typed page schemas, full-text search foundation, persistence layer
**Avoids:** Monolithic model design — keep models focused with clear toJson/fromJson boundaries

### Phase 2: Shared UI Components (in core)
**Rationale:** Core UI components are the bulk of the work. Building them in core means both apps get them simultaneously and avoids duplication.
**Delivers:** WikiPageList (search bar + filtered list), WikiPageDetail (markdown + stat blocks), WikiCreateForm (dynamic type-driven form), WikiResponsiveLayout (adaptive 1/2-panel branching), WikiState (ChangeNotifier provider)
**Uses:** flutter_markdown_plus, provider, MediaQuery.sizeOf, LayoutBuilder
**Implements:** Responsive layout pattern, Provider-based state management, typed page schema with dynamic forms
**Avoids:** Monolithic view files (enforce <150 lines per widget), device-type checking (enforce size-based branching), state loss on dismiss (ChangeNotifier scoped above modal)

### Phase 3: Per-App Integration
**Rationale:** Wiring the modal and trigger is trivial once shared UI exists. DM app's wiki icon already exists at line 142 of main.dart — just needs connection.
**Delivers:** WikiModal + WikiTrigger in companion_app, WikiModal + wired icon in dm_app, provider dependency added to dm_app
**Uses:** showModalBottomSheet / showGeneralDialog for slide-up modal presentation
**Implements:** Full-screen modal overlay accessible from both apps
**Avoids:** Wrong modal transition (enforce slide-up animation), duplicated UI code (import from core only)

### Phase 4: Polish + Testing
**Rationale:** Animation tuning, responsive breakpoint testing, and tests require the full stack to be functional.
**Delivers:** Slide-up animation tuning, responsive breakpoint testing (phone/tablet/desktop), core package unit tests (WikiPage model + search service), widget tests (WikiPageList filtering), keyboard navigation support
**Addresses:** Keyboard navigation (desktop), empty states, search debounce verification
**Avoids:** Missing core tests, untested responsive breakpoints, no keyboard navigation on desktop

### Phase Ordering Rationale

- **Models → Services → Shared UI → Per-App → Polish** follows the dependency graph: WikiPage is the root, services depend on models, UI depends on services, per-app integration depends on shared UI, polish depends on everything being functional.
- **Shared UI before per-app** prevents the duplication pitfall — both apps consume the same components from core.
- **Stat block rendering in Phase 2** (not deferred) because it's a P1 table-stakes feature for D&D content — expected by DMs and a key differentiator from competitors like Roll20's plain-text compendium.
- **Keyboard navigation in Phase 4** because it enhances but is not required for core functionality — the modal works without it, but desktop UX is significantly degraded.

### Research Flags

Phases likely needing deeper research during planning:
- **Phase 2 (Stat Block Rendering):** Custom stat block widget design needs careful planning — the existing CreatureDetail is a 757-line monolith that needs modularization. Research the optimal component breakdown for stat block sections (abilities, actions, legendary actions, spell slots).

Phases with standard patterns (skip research-phase):
- **Phase 1 (Core Models + Services):** Well-documented Dart patterns — JSON serialization, file I/O, in-memory search are all standard.
- **Phase 3 (Per-App Integration):** Trivial wiring — modal wrapper + trigger button are straightforward Flutter patterns.
- **Phase 4 (Polish + Testing):** Standard Flutter testing patterns — unit tests for models/services, widget tests for UI components.

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | All packages verified on pub.dev with download counts, maintenance status, and official lineage. flutter_markdown_plus confirmed as official successor. |
| Features | HIGH | Features classified against competitor analysis (D&D Beyond, Roll20, Foundry VTT) and validated against existing codebase patterns. |
| Architecture | HIGH | Architecture follows existing workspace conventions (core package for shared code, per-app UI layers). Dependency graph validated against codebase inspection. |
| Pitfalls | HIGH | Pitfalls sourced from official Flutter docs, Material 3 specs, and direct codebase observation (757-line monolith, missing tests, model duplication). |

**Overall confidence:** HIGH

### Gaps to Address

- **Stat block field schema:** The exact structured fields for each page type (creature, spell, item, etc.) need definition during implementation. Research identified the pattern (enum with statBlockFields getter) but not the complete field list for all types.
- **Markdown edge cases:** How to handle empty body, malformed markdown, and very long single-line content needs validation with test data during Phase 2.
- **Desktop dismiss behavior:** Whether to disable tap-outside-dismiss on desktop (to prevent accidental closure) while keeping it on mobile needs UX validation during Phase 4.
- **Scaling threshold:** Research notes file-based JSON is sufficient for "a few hundred pages" but the exact threshold for switching to SQLite (500? 1000?) should be monitored during Phase 4 testing.

## Sources

### Primary (HIGH confidence)
- [flutter_markdown_plus 1.0.7 on pub.dev](https://pub.dev/packages/flutter_markdown_plus) — Official successor to discontinued flutter_markdown
- [flutter_markdown discontinuation notice](https://pub.dev/packages/flutter_markdown) — Confirms discontinuation, links to flutter_markdown_plus
- [Flutter Adaptive/Responsive Design docs](https://docs.flutter.dev/ui/adaptive-responsive) — Official Flutter docs, updated 2026-05-05
- [Material 3 Layout Breakpoints](https://m3.material.io/foundations/layout/applying-layout/window-size-classes) — Official Material Design spec
- [Flutter showGeneralDialog API](https://api.flutter.dev/flutter/material/showGeneralDialog.html) — Official Flutter API
- [Flutter MediaQuery.sizeOf API](https://api.flutter.dev/flutter/widgets/MediaQuery/sizeOf.html) — Official Flutter API
- Existing codebase analysis (monster.dart, creature_detail_view.dart, main.dart, pubspec.yaml files) — Direct filesystem observation

### Secondary (MEDIUM confidence)
- [markdown 7.3.1 on pub.dev](https://pub.dev/packages/markdown) — Underlying parser, dart.dev publisher
- [fuzzywuzzy 1.2.0 on pub.dev](https://pub.dev/packages/fuzzywuzzy) — Deferred v2 search option
- [modal_bottom_sheet 3.0.0 on pub.dev](https://pub.dev/packages/modal_bottom_sheet) — Considered but rejected (2 years since update)

### Tertiary (LOW confidence)
- Competitor feature analysis (D&D Beyond, Roll20, Foundry VTT) — Based on public product observation, not direct testing

---
*Research completed: 2026-05-07*
*Ready for roadmap: yes*

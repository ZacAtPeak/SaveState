# Phase 4: Polish & Testing - Context

**Gathered:** 2026-05-07
**Status:** Ready for planning

<domain>
## Phase Boundary

Harden and verify the existing wiki modal behavior without adding new product capability: finalize dismissal rules, lock responsive behavior checks at defined breakpoints, standardize search debounce ownership/behavior, and deliver targeted Phase 4 test coverage plus validation runs across core and both apps.

</domain>

<spec_lock>
## Requirements (locked via SPEC.md)

**UI contract is locked.** See `04-UI-SPEC.md` for approved design-system and interaction constraints relevant to this phase.

Downstream agents MUST read `04-UI-SPEC.md` before planning or implementing. Requirements are not duplicated here.

**In scope (locked for this phase):**
- Modal dismissal via close button and tap-outside behavior
- Search debounce behavior in the 200-300ms range (locked to a concrete decision below)
- Responsive correctness verification at phone/tablet/desktop breakpoints
- Test-driven robustness for current wiki UI behavior

**Out of scope (for this phase):**
- New wiki capabilities (editing, filtering, bookmarking, comments, sync redesign)
- New desktop-specific layout mode beyond current two-panel behavior
- Broad non-wiki refactors unrelated to phase success criteria

</spec_lock>

<decisions>
## Implementation Decisions

### Dismissal Policy
- **D-01:** If the modal is dismissed while in type picker/create flow, in-progress create state resets on next open.
- **D-02:** Tap-outside dismissal is disabled while create flow is active.
- **D-03:** Top-left close button (`X`) closes the modal directly (no in-flow back behavior).
- **D-04:** On reopen after a normal close, restore the last selected wiki page.

### Breakpoint Contract
- **D-05:** Keep the existing layout mode switch threshold at exactly 600dp.
- **D-06:** Treat 600-840dp (tablet) and >840dp (desktop) with the same two-panel behavior for Phase 4.
- **D-07:** Responsive verification must assert structure plus key panel width expectations (not structure-only).
- **D-08:** Boundary verification widths are 599, 600, 840, and 841.

### Debounce Ownership
- **D-09:** Move debounce ownership to a shared service (not local-only in `WikiPageList` and not provider-owned).
- **D-10:** Canonical debounce duration is 250ms.
- **D-11:** Debounce behavior is trailing-edge only.
- **D-12:** External query callbacks fire only when debounce settles (no per-keystroke immediate callback).

### Test Boundary
- **D-13:** Widget-level Phase 4 wiki UI tests live in app-level test targets.
- **D-14:** Mandatory scenario set is focused Phase 4 coverage only: dismissal, breakpoint behavior, debounce behavior.
- **D-15:** Debounce tests use deterministic timer pumping with explicit pre/post 250ms assertions.
- **D-16:** Minimum verification gates before closeout: core tests + companion app tests + DM app tests.

### the agent's Discretion
- Exact naming and file placement for the shared debounce service, as long as it remains reusable and consistent with existing package conventions.
- Concrete assertion style details in tests (matchers/helpers), as long as decisions D-13 through D-16 are enforced.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Phase Scope and Locked Inputs
- `.planning/ROADMAP.md` — Phase 4 goal, success criteria, and plan placeholders (04-01 to 04-03)
- `.planning/REQUIREMENTS.md` — `MODAL-04` and related wiki requirement status context
- `.planning/PROJECT.md` — milestone constraints, out-of-scope boundaries, and architectural context
- `.planning/STATE.md` — current phase/session state and carry-forward decisions
- `.planning/phases/04-polish-testing/04-UI-SPEC.md` — locked UI contract to preserve during implementation

### Prior Phase Decisions to Carry Forward
- `.planning/phases/01-core-infrastructure/01-CONTEXT.md` — model/search/storage assumptions and constraints
- `.planning/phases/02-modal-ui-components/02-CONTEXT.md` — modal architecture and 600dp responsive split baseline
- `.planning/phases/03-create-flow-per-app-integration/03-CONTEXT.md` — create-flow behavior and provider integration choices

### Current Wiki Implementation (Primary Integration Points)
- `packages/core/lib/wiki/wiki_modal_shell.dart` — modal presentation, close action, panel branching, create-flow routing
- `packages/core/lib/wiki/wiki_modal_provider.dart` — selected page/create state handling and modal state transitions
- `packages/core/lib/wiki/wiki_page_list.dart` — existing debounced search input/list filtering behavior
- `packages/core/lib/wiki/wiki_page_detail.dart` — right-panel/detail rendering target for responsive and regression checks
- `packages/core/lib/wiki/wiki_provider.dart` — app-level wiki data source used when opening modal

### Existing Test Baseline
- `packages/core/test/wiki_page_test.dart` — current WikiPage model coverage
- `packages/core/test/wiki_search_service_test.dart` — current search ranking/behavior coverage
- `apps/companion_app/test/widget_test.dart` — companion app test harness baseline
- `apps/dm_app/test/widget_test.dart` — DM app test harness baseline

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `WikiModalShell.show(...)`: existing modal entrypoint used by both apps; ideal hook for dismissal behavior hardening.
- `WikiModalProvider`: existing `ChangeNotifier` state holder for selection/create flow; can host reset/restore semantics.
- `WikiSearchService`: existing search service usable by a shared debounce wrapper without replacing scoring logic.
- App-level Flutter test harnesses already exist in both apps; can be extended for Phase 4 widget behavior tests.

### Established Patterns
- 600dp breakpoint already drives single vs two-panel behavior in `WikiModalShell`; Phase 4 keeps this as canonical.
- Provider-based wiki state wiring is established in both app `main.dart` entrypoints.
- Core package currently runs pure Dart `test` suite; app widget behavior is best validated in app Flutter test targets.
- Prior phases favor focused, incremental behavior changes over broad refactors.

### Integration Points
- Dismissal behavior changes: `packages/core/lib/wiki/wiki_modal_shell.dart` + `packages/core/lib/wiki/wiki_modal_provider.dart`.
- Debounce extraction: `packages/core/lib/wiki/wiki_page_list.dart` plus a new shared debounce utility/service location in core.
- Responsive verification: app-level widget tests that pump `WikiModalShell` at boundary widths (599/600/840/841).
- End-of-phase validation: run `dart test` in `packages/core`, then `flutter test` in both apps.

</code_context>

<specifics>
## Specific Ideas

- Boundary-first responsive checks at 599/600/840/841 are preferred over broad-only samples.
- Debounce callback semantics should be settled-output only to avoid churn in downstream listeners.
- Keep desktop behavior aligned with tablet in this phase; prioritize robustness and regression protection over new layout modes.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 04-polish-testing*
*Context gathered: 2026-05-07*

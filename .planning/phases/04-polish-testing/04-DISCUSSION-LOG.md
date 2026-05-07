# Phase 4: Polish & Testing - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-05-07
**Phase:** 04-polish-testing
**Areas discussed:** Dismissal policy, Breakpoint contract, Debounce ownership, Test boundary

---

## Dismissal policy

| Option | Description | Selected |
|--------|-------------|----------|
| Reset on close | Always clear create/type state on dismissal | ✓ |
| Preserve draft | Reopen with unfinished create flow restored | |
| Context-based | Preserve/reset based on dismissal method | |

**User's choice:** Reset on close.
**Notes:** User additionally chose to disable tap-outside dismissal during create, keep `X` as direct modal close, and restore last selected page on reopen.

---

## Breakpoint contract

| Option | Description | Selected |
|--------|-------------|----------|
| Same behavior | 600-840 and >840 both remain two-panel | ✓ |
| Desktop constrained | Desktop gets capped/constrained two-panel widths | |
| Desktop variant | Desktop gets distinct layout behavior | |

**User's choice:** Same behavior.
**Notes:** User locked 600dp as the switch threshold and requested boundary-focused verification at 599/600/840/841 with structural + key width assertions.

---

## Debounce ownership

| Option | Description | Selected |
|--------|-------------|----------|
| Keep in WikiPageList | Keep current local debounce placement | |
| Move to modal provider | Centralize debounce in provider state | |
| Move to shared service | Extract reusable debounce behavior | ✓ |

**User's choice:** Move to shared service.
**Notes:** Duration locked to 250ms, trailing-edge behavior, and debounced-only callback emission.

---

## Test boundary

| Option | Description | Selected |
|--------|-------------|----------|
| App-level tests | Implement widget behavior tests in app test targets | ✓ |
| Core package Flutter tests | Convert/extend core to use flutter_test | |
| Split by concern | Logic in core, interactions in apps | |

**User's choice:** App-level tests.
**Notes:** Scope locked to focused Phase 4 scenarios; debounce checks should use deterministic timer pumping; minimum validation run includes core + both app test suites.

---

## the agent's Discretion

- Exact naming/location of the shared debounce service.
- Exact test helper/matcher style as long as deterministic timing and boundary coverage are enforced.

## Deferred Ideas

None.

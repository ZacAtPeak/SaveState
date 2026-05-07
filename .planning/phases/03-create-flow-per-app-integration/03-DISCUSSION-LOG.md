# Phase 3: Create Flow & Per-App Integration - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-05-07
**Phase:** 03-create-flow-per-app-integration
**Areas discussed:** Create form navigation, Type picker design, Form field depth, Book icon placement

---

## Create Form Navigation

| Option | Description | Selected |
|--------|-------------|----------|
| Replace detail panel | Two-panel: form replaces right panel. Single-panel: push via Navigator. No layered sheets. | ✓ |
| New bottom sheet on top | Show a new bottom sheet over the existing modal. | |
| Full-screen route | Push a route outside the modal (close modal, open create screen). | |

**User's choice:** Replace detail panel (Recommended)
**Notes:** None.

---

| Option | Description | Selected |
|--------|-------------|----------|
| Auto-select the new page | Switch back to detail view showing the newly created page. | ✓ |
| Return to empty detail | Form clears and detail panel shows "select a page" empty state. | |
| Close the modal | Dismiss the whole wiki modal after saving. | |

**User's choice:** Auto-select the new page (Recommended)
**Notes:** None.

---

## Type Picker Design

| Option | Description | Selected |
|--------|-------------|----------|
| Grid of icon cards | 2×4 grid with icon + label for each type. | ✓ |
| Scrollable list | Simple ListView with type name + short description. | |
| Inline dropdown in form | Type is a dropdown field at the top of a single combined form. | |

**User's choice:** Grid of icon cards (Recommended)
**Notes:** None.

---

| Option | Description | Selected |
|--------|-------------|----------|
| Yes — back arrow or "Cancel" | Back arrow in a mini-AppBar returns to the previous view. | ✓ |
| Yes — close button only | An X button dismisses the picker. | |

**User's choice:** Yes — back arrow or "Cancel" (Recommended)
**Notes:** None.

---

## Form Field Depth

| Option | Description | Selected |
|--------|-------------|----------|
| Title + body + tags + aliases | Core fields for all types. Stat block via markdown or deferred. | |
| Full per-type structured fields | Each type gets custom fields (CR, AC, HP for creature; level, school for spell, etc.). | ✓ |
| Title + body only (minimal) | Fastest to build but misses ROADMAP criteria for structured fields. | |

**User's choice:** Full per-type structured fields
**Notes:** User chose the most complete option despite the extra build effort (7x form logic).

---

| Option | Description | Selected |
|--------|-------------|----------|
| Define in WikiPageType extension | Add `fields` getter to `WikiPageTypeExtension` in core. Central, reusable, testable. | ✓ |
| Hardcode in the form widget | Switch/case in the create form widget per type. | |

**User's choice:** Define in WikiPageType extension (Recommended)
**Notes:** None.

---

| Option | Description | Selected |
|--------|-------------|----------|
| In the existing statBlock map | Already on WikiPage as Map<String, dynamic>. No model changes needed. | ✓ |
| New typed fields per type | Extend WikiPage with per-type nullable fields. More type safety but large model change. | |

**User's choice:** In the existing statBlock map (Recommended)
**Notes:** None.

---

## Book Icon Placement

| Option | Description | Selected |
|--------|-------------|----------|
| AppBar action in both apps | `actions: [IconButton(Icons.menu_book)]` in each app's top AppBar. Persistent and discoverable. | ✓ |
| FAB in both apps | FloatingActionButton with book icon. May conflict with dm_app layout. | |
| Tab in companion_app, AppBar in dm_app | More prominent in companion but inconsistent UX between apps. | |

**User's choice:** AppBar action in both apps (Recommended)
**Notes:** None.

---

| Option | Description | Selected |
|--------|-------------|----------|
| Loaded at modal open time | Load pages from WikiStorageService when icon is tapped. | |
| Held in a top-level Provider | Each app wraps MaterialApp in a WikiProvider that loads at startup. | ✓ |

**User's choice:** Held in a top-level Provider
**Notes:** Adds startup cost but enables immediate list update after page creation without reload.

---

## Claude's Discretion

- Specific per-type field definitions (which fields belong to creature, spell, item, etc.)
- Icon choices for each type in the type picker grid
- Exact widget layout of the create form (spacing, padding, field ordering within each type)

## Deferred Ideas

None — discussion stayed within phase scope.

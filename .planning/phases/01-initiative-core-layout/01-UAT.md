---
status: partial
phase: 01-initiative-core-layout
source: 01-SUMMARY.md
started: 2026-05-09T04:15:00Z
updated: 2026-05-09T04:15:00Z
---

## Current Test

[testing complete]

## Tests

### 1. Cold Start Smoke Test
expected: |
  Kill any running app instance. Clear any cached state. Launch the app fresh.
  App starts without errors, database initializes, and the three-panel layout
  appears (sidebar on left, initiative strip at top-right, detail view below).
  No crash, no blank screen, no error dialogs.
result: pass

### 2. Three-Panel Layout Structure
expected: |
  The app displays three visible panels:
  - Left: Sidebar (~250px wide) with "Bookmarked" section at top and "Recent" section below
  - Top-right: Initiative strip (horizontal, ~120px tall) showing initiative cards
  - Bottom-right: Detail view area (expanded, shows "Select an entity" when none selected)
  Window is at least 768px wide.
result: pass

### 3. Add Entity to Initiative
expected: |
  In the initiative strip, tap the + button. A list of available entities appears.
  Select an entity. The entity appears as a card in the initiative strip with:
  - Entity name
  - HP (current/max)
  - AC value
  - Initiative value
  The card is visually distinct (highlighted border, different background).
result: issue
reported: "The initiative strip is a little small, it needs to be about 50% taller"
severity: cosmetic

### 4. HP Adjustment from Card
expected: |
  On an initiative card in the strip, there are HP adjustment buttons (+/-).
  Tap + to increase HP. The HP value updates immediately.
  Tap - to decrease HP. The HP value updates immediately.
  HP cannot go below 0 or above maxHp (if maxHp is set).
result: pass

### 5. Remove Entity from Initiative
expected: |
  On an initiative card, there is an X or remove button.
  Tap it. The entity is removed from the initiative strip.
  The strip no longer shows that entity's card.
result: pass

### 6. Sidebar Bookmarked Section
expected: |
  The sidebar shows a "Bookmarked" section at the top.
  Entities marked as bookmarked appear here with their name and game system icon.
  Tapping a bookmarked entity opens its details in the detail view.
result: issue
reported: "There is a bookmarked section but I'm not seeing any entities in there"
severity: major

### 7. Sidebar Recent Section
expected: |
  The sidebar shows a "Recent" section below bookmarks.
  Entities you have viewed recently appear here (last 10 viewed), sorted by
  lastViewedAt descending (most recent first).
  Tapping a recent entity opens its details.
result: issue
reported: "I see the 'recent' category but no actual entities"
severity: major

### 8. Bookmark Toggle
expected: |
  On any entity in the sidebar (bookmarked or recent section), there is a star icon.
  Tap the star to toggle bookmark status.
  If it was bookmarked → it becomes unbookmarked, disappears from Bookmarked section.
  If it was not bookmarked → it becomes bookmarked, appears in Bookmarked section.
  The change persists after app restart (saved to database).
result: skipped
reason: "No entities appear in sidebar - cannot test bookmark toggle"

### 9. Entity Selection Opens Detail View
expected: |
  Tap an entity in the sidebar (bookmarked or recent).
  The detail view (bottom-right panel) updates to show that entity's information:
  - Entity name
  - HP (current/max)
  - AC
  - Initiative value
  The detail view is not blank.
result: skipped
reason: "No entities appear in sidebar - cannot test entity selection"

### 10. Initiative Card Selection Opens Detail View
expected: |
  Tap an initiative card in the initiative strip.
  The detail view (bottom-right panel) updates to show that entity's information.
  The selected initiative card is visually highlighted (different border/color).
result: skipped
reason: "No entities appear in sidebar to compare with initiative strip selection"

## Summary

total: 10
passed: 4
issues: 3
pending: 0
skipped: 3
blocked: 0

## Gaps

- truth: "Initiative strip displays with sufficient height (~50% taller) for card readability"
  status: failed
  reason: "User reported: The initiative strip is a little small, it needs to be about 50% taller"
  severity: cosmetic
  test: 3
  artifacts: []
  missing: []

- truth: "Sidebar bookmarked section displays bookmarked entities with name and game system icon"
  status: failed
  reason: "User reported: There is a bookmarked section but I'm not seeing any entities in there"
  severity: major
  test: 6
  artifacts: []
  missing: []

- truth: "Sidebar recent section displays last 10 viewed entities sorted by lastViewedAt descending"
  status: failed
  reason: "User reported: I see the 'recent' category but no actual entities"
  severity: major
  test: 7
  artifacts: []
  missing: []
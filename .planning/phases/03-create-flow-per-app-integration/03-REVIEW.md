---
phase: 03-create-flow-per-app-integration
reviewed: 2026-05-07T00:00:00Z
depth: standard
files_reviewed: 16
files_reviewed_list:
  - packages/core/lib/models/wiki_page_type.dart
  - packages/core/lib/wiki/wiki.dart
  - packages/core/lib/wiki/wiki_modal_shell.dart
  - packages/core/lib/wiki/wiki_provider.dart
  - packages/core/lib/wiki/wiki_create_form.dart
  - packages/core/lib/wiki/wiki_modal_provider.dart
  - packages/core/lib/wiki/wiki_type_picker.dart
  - packages/core/lib/wiki/wiki_page_list.dart
  - packages/core/lib/wiki/wiki_page_detail.dart
  - packages/core/lib/wiki/wiki_stat_block.dart
  - packages/core/lib/services/wiki_storage_service.dart
  - packages/core/test/wiki_create_submit_test.dart
  - apps/companion_app/lib/main.dart
  - apps/dm_app/lib/main.dart
  - apps/companion_app/test/wiki_entry_integration_test.dart
  - apps/dm_app/test/wiki_entry_integration_test.dart
findings:
  critical: 2
  warning: 2
  info: 0
  total: 4
status: issues_found
---

# Phase 3: Code Review Report

**Reviewed:** 2026-05-07T00:00:00Z  
**Depth:** standard  
**Files Reviewed:** 16  
**Status:** issues_found

## Summary

Reviewed all scoped Phase 3 source files for correctness, security, and maintainability defects. I found two **BLOCKER** issues (security + incorrect behavior) and two **WARNING** issues affecting reliability/UX consistency.

## Critical Issues

### CR-01 (BLOCKER): Path traversal in pageId-based file access

**File:** `packages/core/lib/services/wiki_storage_service.dart:140-141,168-169`  
**Issue:** `loadPage` and `deletePage` build filesystem paths directly from `pageId` (`'$pageId.json'`) with no sanitization. A crafted `pageId` like `../../sensitive/file` can escape the intended wiki directory and read/delete unintended files.  
**Fix:** Validate `pageId` against a strict allowlist (e.g., UUID format) before path join, and reject anything containing separators or traversal tokens.

```dart
bool _isValidPageId(String id) {
  final uuid = RegExp(r'^[0-9a-fA-F-]{36}$');
  return uuid.hasMatch(id);
}

Future<WikiPage?> loadPage(String pageId) async {
  if (!_isValidPageId(pageId)) {
    throw ArgumentError('Invalid page id');
  }
  final file = File(path.join(_pagesDir.path, '$pageId.json'));
  ...
}
```

### CR-02 (BLOCKER): Structured stat blocks hidden for non-reference page types

**File:** `packages/core/lib/wiki/wiki_page_detail.dart:31-32`  
**Issue:** The detail view only renders `WikiStatBlock` when `page.pageType.isReferenceType` (creature/npc). However, the create flow collects structured fields for **all** page types (spell/item/rule/location/other too). Result: valid saved data is not shown to users for most types.  
**Fix:** Render stat block whenever non-empty, independent of type.

```dart
if (page.statBlock.isNotEmpty)
  WikiStatBlock(statBlock: page.statBlock),
```

## Warnings

### WR-01 (WARNING): Search index is never refreshed after pages list changes

**File:** `packages/core/lib/wiki/wiki_page_list.dart:29-33,49-52`  
**Issue:** `WikiSearchService.index(widget.pages)` runs only in `initState`. After a new page is created, `widget.pages` updates but index stays stale, so newly added pages are not searchable until widget remount/reopen.  
**Fix:** Re-index in `didUpdateWidget` when `pages` changes.

```dart
@override
void didUpdateWidget(covariant WikiPageList oldWidget) {
  super.didUpdateWidget(oldWidget);
  if (!identical(oldWidget.pages, widget.pages)) {
    _searchService.index(widget.pages);
  }
}
```

### WR-02 (WARNING): Hard-coded type picker item count can desync from enum

**File:** `packages/core/lib/wiki/wiki_type_picker.dart:43`  
**Issue:** `itemCount: 8` is hard-coded while `WikiPageType.values.length` is currently 7. This creates dead/blank grid slots and will break silently if enum size changes.  
**Fix:** Use `types.length` directly.

```dart
itemCount: types.length,
```

---

_Reviewed: 2026-05-07T00:00:00Z_  
_Reviewer: the agent (gsd-code-reviewer)_  
_Depth: standard_

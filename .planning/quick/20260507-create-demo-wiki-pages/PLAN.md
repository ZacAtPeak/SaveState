---
title: Create 20 demo wiki entries
slug: create-demo-wiki-pages
date: 2026-05-07
---

# Task: Create 20 demo wiki entries

Create `packages/core/lib/data/demo_wiki_pages.dart` with 20 diverse `WikiPage` instances covering all 7 page types. Export from `data.dart`. Seed `WikiProvider` with demo pages on first load when wiki is empty.

## Steps

1. Create `demo_wiki_pages.dart` — 20 entries: 3 creatures, 3 spells, 3 items, 3 rules, 3 locations, 3 NPCs, 2 other
2. Export from `packages/core/lib/data/data.dart`
3. Modify `WikiProvider.loadAll()` to seed demo pages when storage is empty

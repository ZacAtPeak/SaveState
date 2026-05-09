---
phase: 01-initiative-core-layout
plan: 02
type: execute
wave: 1
depends_on: []
gap_closure: true
files_modified:
  - lib/ui/layout.dart
  - lib/data/uts_db_loader.dart
autonomous: true
requirements:
  - INIT-03
  - SIDE-01
  - SIDE-02

must_haves:
  truths:
    - "Initiative strip displays with sufficient height (~180px, 50% taller than 120px) for card readability"
    - "Sidebar bookmarked section displays entities marked with isBookmarked=1"
    - "Sidebar recent section displays last viewed entities with lastViewedAt timestamps"
  artifacts:
    - path: lib/ui/layout.dart
      contains: "height: 180" or "height: 120 * 1.5"
    - path: lib/data/uts_db_loader.dart
      contains: "isBookmarked: 1" for demo entities
    - path: lib/data/uts_db_loader.dart
      contains: "lastViewedAt:" for demo entities
  key_links:
    - from: lib/ui/layout.dart
      to: lib/ui/initiative_strip.dart
      via: SizedBox(height: ...)
    - from: lib/data/uts_db_loader.dart
      to: lib/data/database.dart
      via: Entity insertion with isBookmarked and lastViewedAt fields
---

<objective>
Fix 3 UAT-identified gaps from Phase 1 implementation:
1. Initiative strip height too small (needs ~50% taller)
2. Sidebar bookmarked section empty (no entities have isBookmarked=1)
3. Sidebar recent section empty (no entities have lastViewedAt set)
</objective>

<execution_context>
@/Users/zacharyreyes/Documents/GitHub/SaveState/.planning/phases/01-initiative-core-layout/01-PLAN.md
@/Users/zacharyreyes/Documents/GitHub/SaveState/lib/ui/layout.dart
@/Users/zacharyreyes/Documents/GitHub/SaveState/lib/ui/sidebar.dart
@/Users/zacharyreyes/Documents/GitHub/SaveState/lib/data/uts_db_loader.dart
@/Users/zacharyreyes/Documents/GitHub/SaveState/lib/data/database.dart
</execution_context>

<context>
## UAT Gap Summary

From 01-UAT.md, 3 tests failed:

### Gap 1: Initiative strip height (cosmetic)
- **Test:** 3 - Add Entity to Initiative
- **User reported:** "The initiative strip is a little small, it needs to be about 50% taller"
- **Root cause:** `lib/ui/layout.dart` line 50 sets `height: 120` for the initiative strip
- **Fix:** Change height from 120 to 180 (50% increase)

### Gap 2: Sidebar bookmarked section empty (major)
- **Test:** 6 - Sidebar Bookmarked Section
- **User reported:** "There is a bookmarked section but I'm not seeing any entities in there"
- **Root cause:** Demo data in `uts_db_loader.dart` never sets `isBookmarked: 1` on any entity
- **Fix:** Mark 2 demo entities as bookmarked in the built-in demo data

### Gap 3: Sidebar recent section empty (major)
- **Test:** 7 - Sidebar Recent Section
- **User reported:** "I see the 'recent' category but no actual entities"
- **Root cause:** Demo data in `uts_db_loader.dart` never sets `lastViewedAt` on any entity
- **Fix:** Set `lastViewedAt` timestamps on 3 demo entities in built-in demo data
</context>

<tasks>

<task type="auto">
  <name>Task 1: Increase initiative strip height to 180px</name>
  <files>lib/ui/layout.dart</files>
  <read_first>
    - lib/ui/layout.dart (the file being modified)
  </read_first>
  <action>
    In lib/ui/layout.dart line 50, change:
      `height: 120,`
    to:
      `height: 180,`
    
    This increases the initiative strip height from 120px to 180px (50% increase) per user UAT feedback.
  </action>
  <verify>
    <automated>grep -n "height: 180" lib/ui/layout.dart</automated>
  </verify>
  <done>Initiative strip is 180px tall (~50% taller than original 120px)</done>
  <acceptance_criteria>
    - grep -n "height: 180" lib/ui/layout.dart returns line number
    - No other height values in layout.dart were accidentally changed
    - Initiative strip visually appears taller in running app
  </acceptance_criteria>
</task>

<task type="auto">
  <name>Task 2: Add bookmarked entities to demo data</name>
  <files>lib/data/uts_db_loader.dart</files>
  <read_first>
    - lib/data/uts_db_loader.dart (the file being modified)
    - lib/data/database.dart (to understand Entity model and isBookmarked field)
  </read_first>
  <action>
    In lib/data/uts_db_loader.dart, in the _loadBuiltInDemoData() function around line 166 where demoEntities are defined:
    
    Mark 2 entities as bookmarked by adding isBookmarked: 1 to their Entity constructors:
    
    Change the Goblin entity (around line 167) from:
      Entity(name: 'Goblin', gameSystemId: 1, hp: 7, maxHp: 7, ac: 15, initiative: 14),
    to:
      Entity(name: 'Goblin', gameSystemId: 1, hp: 7, maxHp: 7, ac: 15, initiative: 14, isBookmarked: 1),
    
    Change the Dragon entity (around line 191) from:
      Entity(name: 'Dragon (Young Red)', gameSystemId: 1, hp: 178, maxHp: 178, ac: 18, initiative: 12),
    to:
      Entity(name: 'Dragon (Young Red)', gameSystemId: 1, hp: 178, maxHp: 178, ac: 18, initiative: 12, isBookmarked: 1),
  </action>
  <verify>
    <automated>grep -c "isBookmarked: 1" lib/data/uts_db_loader.dart</automated>
  </verify>
  <done>At least 2 demo entities are marked as bookmarked in the built-in demo data</done>
  <acceptance_criteria>
    - grep -c "isBookmarked: 1" lib/data/uts_db_loader.dart returns 2 or more
    - UAT Test 6 (Sidebar Bookmarked Section) would show Goblin and Dragon in bookmarked section
  </acceptance_criteria>
</task>

<task type="auto">
  <name>Task 3: Add lastViewedAt timestamps to demo entities</name>
  <files>lib/data/uts_db_loader.dart</files>
  <read_first>
    - lib/data/uts_db_loader.dart (the file being modified)
    - lib/data/models.dart (to understand Entity model and lastViewedAt field)
  </read_first>
  <action>
    In lib/data/uts_db_loader.dart, in the _loadBuiltInDemoData() function where demoEntities are defined:
    
    Add lastViewedAt timestamps to 3 entities to populate the Recent section. Use DateTime.now() with decreasing durations to simulate viewing history:
    
    For the Lich entity (around line 207), add lastViewedAt to show it was viewed most recently:
      Entity(name: 'Lich', gameSystemId: 1, hp: 135, maxHp: 135, ac: 17, initiative: 16, lastViewedAt: DateTime.now().subtract(Duration(minutes: 5))),
    
    For the Troll entity (around line 199), add lastViewedAt to show it was viewed slightly older:
      Entity(name: 'Troll', gameSystemId: 1, hp: 84, maxHp: 84, ac: 15, initiative: 11, lastViewedAt: DateTime.now().subtract(Duration(hours: 1))),
    
    For the Orc Warrior entity (around line 175), add lastViewedAt to show it was viewed older:
      Entity(name: 'Orc Warrior', gameSystemId: 1, hp: 15, maxHp: 15, ac: 13, initiative: 12, lastViewedAt: DateTime.now().subtract(Duration(hours: 3))),
    
    Note: Since these are static demo data definitions, use recent relative timestamps. The actual displayed time will be "recently" but the relative ordering (Lich most recent, then Troll, then Orc) will be correct.
  </action>
  <verify>
    <automated>grep -c "lastViewedAt:" lib/data/uts_db_loader.dart</automated>
  </verify>
  <done>At least 3 demo entities have lastViewedAt timestamps set in built-in demo data</done>
  <acceptance_criteria>
    - grep -c "lastViewedAt:" lib/data/uts_db_loader.dart returns 3 or more
    - UAT Test 7 (Sidebar Recent Section) would show Lich, Troll, and Orc Warrior in recent section (ordered by lastViewedAt descending)
  </acceptance_criteria>
</task>

</tasks>

<threat_model>
## Trust Boundaries

| Boundary | Description |
|----------|-------------|
| client → database | Untrusted: demo data seeding |

## STRIDE Threat Register

| Threat ID | Category | Component | Disposition | Mitigation Plan |
|-----------|----------|-----------|-------------|-----------------|
| T-01-GAP-01 | Information | uts_db_loader.dart demo data | accept | Demo data only, no sensitive info |
</threat_model>

<verification>
After all tasks complete:

1. **Initiative strip height:** grep -n "height: 180" lib/ui/layout.dart returns line number
2. **Bookmarked entities:** grep -c "isBookmarked: 1" lib/data/uts_db_loader.dart returns >= 2
3. **Recent entities:** grep -c "lastViewedAt:" lib/data/uts_db_loader.dart returns >= 3
4. Run flutter test to ensure no regressions
</verification>

<success_criteria>
- Gap 1 fixed: Initiative strip is 180px tall (50% taller)
- Gap 2 fixed: Sidebar bookmarked section shows entities (Goblin, Dragon)
- Gap 3 fixed: Sidebar recent section shows entities (Lich, Troll, Orc Warrior ordered by lastViewedAt)
</success_criteria>

<output>
After completion, create .planning/phases/01-initiative-core-layout/01-GAPS-SUMMARY.md
</output>
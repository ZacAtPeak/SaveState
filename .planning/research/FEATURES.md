# Feature Landscape: TTRPG-Agnostic Schema-Driven GameModel

**Domain:** TTRPG companion/DM app with swappable game system schemas
**Researched:** 2026-05-07
**Confidence:** HIGH (core schema architecture), MEDIUM (system popularity), MEDIUM (UX expectations)
**Supersedes:** Prior wiki-milestone FEATURES.md (that research still applies to the wiki subsystem)

---

## Research Context

This file answers six questions about the GameModel milestone:
1. How do Foundry/Roll20/Fantasy Grounds handle multi-system support, and what is the lesson?
2. D&D 5e vs Call of Cthulhu 7e schema divergence — where do they differ?
3. What TTRPG systems are commonly requested beyond D&D/Pathfinder?
4. Table stakes vs differentiators for a game system switcher companion app
5. What users expect when switching systems — does ALL data change, or just templates?
6. Anti-features — what schema-driven VTT apps got wrong

---

## Ecosystem Lessons: How Production VTTs Do It

### Foundry VTT (the clearest architectural model)

Foundry VTT is the strongest reference. Its architecture is:

- **Each game system is a standalone package** with a `system.json` manifest declaring: entity types (Actor subtypes like "character", "npc", "vehicle"), item types, initiative formula, and compatible version range.
- **Data models are schema classes** — each Actor/Item subtype has a `TypeDataModel` that uses typed fields (`NumberField`, `StringField`, `ArrayField`, `SchemaField`) with defaults and validation. Systems call `defineSchema()` to declare their own field structure.
- **Derived values** are computed in `prepareDerivedData()` — things like proficiency bonus from level, or saving throw mod from ability score. The engine calls this automatically on change.
- **Initiative** is a single formula string in `system.json` (e.g. `"1d20 + @abilities.dex.mod"`). The combat tracker reads and evaluates this at roll time.
- **World-level isolation**: a Foundry "world" is pinned to exactly one system. Data created in that world uses only that system's schemas. There is no concept of switching a campaign mid-life — you pick a system when creating a world and it stays.
- **~300 community-maintained game systems** ship on Foundry. System dev is documented and accessible.

**Key architectural lesson for SaveState:** Foundry proves that a generic document store (Actor, Item, JournalEntry) + a system-provided schema works at scale. The GameModel JSON approach SaveState is building is the correct pattern. The critical insight is that **the schema describes types and fields; the engine stores/renders generic maps**. Foundry made one mistake worth learning from: HTML+JS templates for sheet rendering require redoing the whole UI per system. SaveState's Flutter approach (schema-driven form widgets) avoids this entirely.

### Roll20's approach

Roll20 character sheets are HTML/CSS/JavaScript per system — essentially a bespoke web form per game system. Switching game systems means switching to a completely different sheet template. Old character data from a different system is not migrated — it's orphaned. Multiple community forks exist for the same system because there's no canonical schema spec. The lesson: **per-system bespoke templates do not scale and fragment the community**.

### Fantasy Grounds

Fantasy Grounds builds on CoreRPG, a base ruleset that other systems extend. Characters can export/import across rulesets derived from CoreRPG, but cross-ruleset import is manual and lossy. The lesson: **a shared base type with system-specific extensions is better than isolated types**, but extension without a formal schema spec still causes fragmentation.

### The correct synthesis for SaveState

- GameModel defines: entity types (character, adversary, etc.), field schemas per type, wiki page types, initiative formula, dice notation
- GameEntity stores: a `typeKey` pointing into the active GameModel's entity schema, plus a `Map<String, dynamic>` data payload
- Switching GameModel changes: what schemas are active, how UI renders, what initiative formula is used
- Switching GameModel does NOT affect: campaign notes, wiki pages scoped to a campaign, entity records that belong to a different system (they remain but show as "schema mismatch")

---

## D&D 5e vs Call of Cthulhu 7e: Schema Divergence Map

This is the core test for whether the GameModel design is genuinely agnostic.

### D&D 5e required schema concepts

The existing `PlayerCharacter` and `Monster` models are the reference:

**Character fields unique to D&D 5e:**
- Six ability scores (STR/DEX/CON/INT/WIS/CHA) with associated modifiers
- Proficiency bonus (derived from level, flat formula: `2 + floor((level-1)/4)`)
- Saving throw proficiencies (one boolean per ability score)
- Skills: ~18 named skills each mapped to an ability score, proficiency multiplier
- Spell slots by level (nine tiers, each with max/used count)
- Known spells list
- Class + subclass + background
- Creature size enum (Tiny/Small/Medium/Large/Huge/Gargantuan)
- Alignment (lawful/neutral/chaotic × good/neutral/evil)
- Armor class with source string
- Damage vulnerabilities, resistances, immunities (typed damage categories)
- Condition immunities
- Hit dice notation (e.g. "10d8")
- Movement speed (walk, swim, fly, burrow, climb)
- Senses (darkvision range, passive perception)
- Legendary actions list + legendary action budget

**Adversary fields unique to D&D 5e:**
- Challenge Rating (decimal, 0.125 to 30)
- XP award (table-lookup from CR)
- Legendary action count + legendary action list
- Lair actions (optional)

**Initiative formula:** `1d20 + DEX modifier`

### Call of Cthulhu 7e required schema concepts

**Structural differences from D&D that break D&D assumptions:**

| Concept | D&D 5e | CoC 7e | Schema impact |
|---------|--------|--------|---------------|
| Core stats | 6 ability scores (3–18 range) | 8 characteristics (STR, CON, SIZ, DEX, APP, INT, POW, EDU) (all 1–100 range) | Cannot share a field name — values, ranges, and semantics differ. Both are `Map<String, int>` but with different key sets |
| Skill system | ~18 named skills, proficiency-based bonuses (not percentage) | ~40+ named skills, each a percentage 1–100. Rolling = roll d100 under skill value | Completely different model: CoC skills are just `Map<String, int>` percentages, no proficiency concept |
| HP derivation | Hit Dice (d6–d12) + CON modifier per level | `(CON + SIZ) / 10`, flat number, not level-scaled | HP is a derived field from a custom formula — formula must be in the schema |
| Sanity | Does not exist | SAN: starts at `POW × 5`, max = `99 − Cthulhu Mythos skill`, depletes permanently | Entirely new resource type: `sanity_current`, `sanity_max`, `insanity_flags` |
| Luck | Does not exist | Luck: separate value 1–100, spent to improve rolls, does not recover easily | New resource, not HP analog |
| Magic Points | Spell slots by level | `POW / 5`, a flat pool not divided into tiers | No spell levels, no slot tiers |
| Build / Damage Bonus | Not applicable | Derived from STR + SIZ combination; affects melee damage | New derived field |
| Dodge | Passive (AC calculation) | Active skill at half DEX, can increase with advancement | Dodge is a trackable skill percentage |
| Alignment | Lawful/Neutral/Chaotic × Good/Neutral/Evil | No alignment — replaced by psychological/ideological concepts | Alignment field doesn't exist, no enum equivalent |
| Class/Subclass | Core identity, drives most mechanics | No class — Occupation is flavor only, gives some skill bonuses | No class system |
| Level | 1–20, everything scales with it | No levels — Occupation grants initial skill bonuses; advancement is through session points | No level field; advancement model is entirely different |
| CR/XP | Adversary rating (CR) + numeric reward (XP) | No CR or XP — monsters are described narratively | Adversary schema omits CR and XP entirely |
| Damage types | Bludgeoning/piercing/slashing/fire/cold/etc. | No damage type categories — just numeric damage | No damage type enum |
| Condition immunities | Typed list | Not applicable | Omit |
| Legendary actions | D&D-specific boss mechanic | Not applicable | Omit |
| Initiative | d20 + DEX mod | DEX rank order, or DEX characteristic / 2 for numerical comparison | Different formula |

**Conclusion:** D&D 5e and CoC 7e share: name, description, HP (both have it, derived differently), a skills-like concept (totally different implementation), and adversaries (without CR/XP in CoC). Everything else is system-specific. This validates that a `Map<String, dynamic>` `GameEntity` with no hardcoded fields is the right model — there is no universal "character" structure that applies to both.

---

## Commonly Requested TTRPG Systems

Based on the ICv2 and Roll20 Orr Group data, plus community research (MEDIUM confidence):

| Rank | System | Market Share Notes | Structural Archetype |
|------|--------|-------------------|---------------------|
| 1 | D&D 5e | ~40–50% of all TTRPG play | Six ability scores, class/level, spell slots |
| 2 | Pathfinder 2e | Strong second, growing | Very similar to D&D 5e structurally; adds degrees of success |
| 3 | Call of Cthulhu 7e | Third globally, #1 non-fantasy | Percentile skills, Sanity, no class/level |
| 4 | Star Wars RPG (Edge of Empire / Genesys) | Largest licensed IP system | Narrative dice pool (symbols not numbers); Characteristics + Skills drive pool size; Wound/Strain thresholds instead of HP; no initiative roll (side-order initiative) |
| 5 | Vampire: The Masquerade 5e | Dominant horror system | Attributes + Skills (dot ratings 1–5); Hunger track instead of blood pool; Disciplines; Health + Willpower tracks; no alignment, no class |
| 6 | Starfinder | Sci-fi Pathfinder derivative | Resolves/Stamina Points layered on top of HP; Drone/AI mechanics; similar core structure to PF2e |
| 7 | Blades in the Dark | Most influential indie | No character stats as numbers; Action ratings 0–4; Stress track; Harm boxes; no initiative (free-form position/effect); completely different advancement |
| 8 | Warhammer 40K: Wrath & Glory | Warhammer universe | d6 dice pool, Wrath die, Ruin track |
| 9 | Shadowrun 5e/6e | Cyberpunk cult classic | Eight body attributes + Edge + Essence; dice pool of d6s counting hits; Karma advancement; Matrix/Magic/Resonance subsystems |
| 10 | OSR Systems (Old School Essentials, etc.) | Collectively significant | Closer to original D&D; ascending/descending AC; fewer skills; more rulings-at-table |

**Priority for SaveState's GameModel system support:**

D&D 5e (bundled, milestone requirement) and CoC 7e (bundled, agnosticism proof) cover ranks 1 and 3. These two together validate the schema is genuinely flexible. Pathfinder 2e would be the highest-value third addition because structural similarity to D&D 5e means the D&D 5e GameModel file is a strong starting template.

---

## Table Stakes vs Differentiators for a Game System Switcher

### Table Stakes

Features users expect when the app says it supports "any TTRPG system."

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| Game system selector UI | Users must be able to choose the active GameModel; hidden system switching is a UX failure | LOW | Picker widget, shows system name + short description. Persists selection across app restarts. Must be accessible from both apps' main navigation. |
| System stays pinned per campaign | Users expect D&D campaign data to remain D&D, even after switching globally. The standard pattern from Foundry/Roll20 is that a campaign is pinned to a system. | MEDIUM | Each campaign record stores a `gameModelId`. The active GameModel for that campaign is separate from a global "last used" default. |
| Character sheet adapts to active system | When viewing a character, the fields shown must match the active system — not a D&D sheet pretending to be CoC | HIGH | Form widgets generated from `GameModel.entitySchemas[typeKey].fields`. No hardcoded field names in UI. |
| Entity type names match the system | D&D calls them "monsters"; CoC calls them "creatures" or "NPCs." The UI must use the GameModel's own terminology | LOW | `GameModel.entityTypes[key].displayName` drives all labels. No hardcoded "Monster," "PC," "NPC" strings in app code. |
| Encounter/initiative adapts to active system | D&D uses d20 + DEX mod; CoC uses DEX rank. The tracker must use whatever formula the GameModel declares | MEDIUM | `GameModel.encounterConfig.initiativeFormula` is evaluated at roll time. Parser handles dice notation + attribute references. |
| Wiki page types match the system | A CoC game should have wiki types for Cults, Tomes, Locations — not D&D Spell and Monster pages | MEDIUM | Wiki page type registry driven by `GameModel.wikiPageTypes`. Already the planned direction per PROJECT.md. |
| Demo/seed data for bundled systems | Users expect to see sample content when they first select a built-in system | MEDIUM | Each bundled GameModel ships with a companion seed data asset. D&D 5e seed = existing demo data migrated to `GameEntity` format. CoC 7e seed = new set of investigators + creatures. |
| No restart required on system switch | Users expect instant feedback when switching systems, not a loading spinner or app relaunch | HIGH | Provider-based `GameModelService` as `ChangeNotifier` drives all downstream widgets. All system-sensitive UI must listen to `GameModelService`. This is the hardest table stake to implement correctly. |
| Schema validation on import | When a user imports an external `.json` game model, the app must validate it — not crash silently | MEDIUM | JSON schema validation before accepting import. Show clear error messages for missing required fields. |
| External GameModel import from file | Users of niche systems need to import their own schema | MEDIUM | `file_picker` + JSON parsing + validation flow. Import once, stored in app documents directory. |

### Differentiators

Features that set SaveState apart from generic campaign tools.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Bundled CoC 7e as genuine second system | Proves the schema is not secretly D&D-centric. CoC has Sanity, percentile skills, no class/level — if it works, everything works. Users of any percentile or skill-based system (BRP derivatives) benefit immediately. | HIGH | CoC 7e schema must correctly model: percentile skill list, eight characteristics, Sanity current/max, Luck, Build/Damage Bonus, Magic Points, Occupation, no alignment, no CR/XP |
| Campaign-scoped system pinning | A user running both D&D and CoC simultaneously sees the right sheet, wiki types, and encounter rules for each campaign. No current mobile companion app does this well. | MEDIUM | `Campaign.gameModelId` field. `GameModelService.forCampaign(id)` returns the correct model. |
| Initiative formula as a first-class config | DMs of systems with unusual initiative (side-based, stat-rank, flat rolls) can configure it without code changes. Most apps hardcode d20+DEX. | MEDIUM | Formula parser handles: `1d20`, `d20+@dex.mod`, `@dex` (rank order), `constant(5)` (flat group initiative). Documented in GameModel JSON spec. |
| Schema-version migration path | When a GameModel file is updated (e.g. D&D 5e 2024 revision changes some field names), the app needs a clear story for existing entity data | HIGH | `GameModel.version` + `GameEntity.schemaVersion` fields. Migration hooks in `GameModelService` called on load if versions differ. Even if v1 does not implement migrations, the version field must exist. |
| Community GameModel registry hint | If users can discover community-authored `.json` game model files (even via a simple URL), the platform becomes a hub. The RPG Companion App does this with `repositories.rpg-companion.app`. | LOW (registry itself) HIGH (full workflow) | For v1: just document the JSON spec publicly so community authors can write systems. A registry URL can be added later. Do not build the registry as part of this milestone. |
| Rich dice notation in schema | Systems like Genesys use non-standard dice (custom symbol dice). The dice config in GameModel can specify notation + display glyphs, even if full Genesys symbol resolution is out of scope. | MEDIUM | `GameModel.dice` block: `[{"notation": "d6", "sides": 6}, {"notation": "dA", "display": "ability", "sides": 8}]`. The tracker displays the notation; rolling custom symbol dice is deferred. |

### Anti-Features

These are commonly requested or intuitively appealing — but building them in this milestone would cause harm.

| Anti-Feature | Why Requested | Why Problematic | Correct Alternative |
|--------------|---------------|-----------------|---------------------|
| In-app GameModel schema editor (build your own system from scratch) | Power users want to create entirely new systems without JSON editing | Requires a full schema-editing UI with field type pickers, validation previews, formula testing, and save/load. This is a separate product. The PROJECT.md correctly marks this Out of Scope for v1. Building it now delays the core schema engine which is the actual value. | Document the JSON spec thoroughly. External editors (VS Code + JSON schema validation) are sufficient. Import the finished file. |
| Cross-system entity migration ("convert my D&D character to CoC") | Appealing in theory for groups switching systems | D&D and CoC share almost no fields. Any automatic migration would produce either empty fields or nonsensical mappings. Worse, it suggests the app understands the semantic equivalence between systems, which it doesn't. Users who try it will trust incorrect data. | Show a clear "this entity was created in D&D 5e, which is not your current system" banner. Let users re-enter data in the new system. Do not attempt automatic migration. |
| Global system switch that affects all campaigns simultaneously | Feels like a clean "change your game" gesture | A user running a D&D campaign and a CoC campaign would have both campaigns broken. Foundry's lesson is explicit: campaigns are pinned to systems. | Per-campaign system pinning is the right model. Global switch only affects new campaigns or a "default system" preference, not existing campaign data. |
| Infinite custom fields per entity beyond the GameModel spec | GMs always want one more field | Breaks the schema contract. If any entity can have any field, then UI can't know what to render, search can't index, and exports are unreliable. Kanka's freeform "Attributes" approach leads to user complaints that the tool "fights you." | The GameModel IS the authority on fields. If a field is needed, it belongs in the GameModel file. The companion-app version of this is: edit the `.json` file, reimport. For v1, the schema is authoritative. |
| System-aware compendium with rules text | Users want to look up rules in-app | Requires licensing agreements for official system content (D&D SRD, CoC Quick-Start). Foundry navigates this through official licensed modules that cost money. Including rules text for bundled systems is a legal and scope problem. | Wiki pages are user-authored. Demo seed data shows the format. Official rules text is out of scope. |
| Real-time GameModel sync over network | DM and players could theoretically share a GameModel live | Introduces version conflicts, merge hell, and latency. The PROJECT.md correctly marks networked GameModel switching as Out of Scope. | Local-only per device. Each app loads the same bundled JSON. No sync needed for same-system play. |
| Backwards compatibility shims for old typed Dart models | Tempting to bridge `PlayerCharacter` → `GameEntity` rather than replacing | Shims double the maintenance surface. The existing typed models encode D&D assumptions — any bridge would re-introduce those assumptions through the back door. The PROJECT.md explicitly says: "clean replacement, no bridge." | Hard cut. Migrate existing D&D demo data to `GameEntity` format. Remove the old Dart model files. |
| "Auto-detect system" from imported JSON | Seems user-friendly | Heuristic detection is fragile and creates false confidence. A D&D homebrew variant might look like CoC to a heuristic. | Require the `id` field in every GameModel JSON. Imports must declare their system ID explicitly. |

---

## Feature Dependencies

```
GameModel Milestone (core)
    │
    ├──requires──> GameModel data structure (Dart, in core package)
    │                  ├── EntityTypeDefinition (fields, display name)
    │                  ├── FieldDefinition (name, type, required, default)
    │                  ├── WikiPageTypeDefinition (replaces enum)
    │                  ├── EncounterConfig (initiative formula, turn order rules)
    │                  └── DiceConfig (notation, sides, display glyph)
    │
    ├──requires──> GameEntity (replaces PlayerCharacter, Monster, NPC)
    │                  ├── id, gameModelId, typeKey, schemaVersion
    │                  └── data: Map<String, dynamic>
    │
    ├──requires──> GameModelService (Provider, ChangeNotifier)
    │                  ├── activeModel: GameModel
    │                  ├── switchModel(id) → notifyListeners()
    │                  └── forCampaign(campaignId) → GameModel
    │
    ├──requires──> D&D 5e GameModel JSON asset
    │                  ├──depends on──> GameModel data structure finalized
    │                  └── Must reproduce all existing PlayerCharacter/Monster fields
    │
    ├──requires──> CoC 7e GameModel JSON asset
    │                  ├──depends on──> GameModel data structure finalized
    │                  └── Must include: percentile skills, Sanity, Luck, no CR/XP
    │
    ├──requires──> Character sheet UI from schema
    │                  ├──depends on──> GameEntity + GameModelService
    │                  └── Generated form widgets from FieldDefinition list
    │
    ├──requires──> Encounter tracker using initiative config
    │                  ├──depends on──> GameModelService (active model)
    │                  └── Formula parser for initiative expression
    │
    ├──enhances──> Wiki page types from GameModel registry
    │                  ├──depends on──> WikiPageTypeDefinition in GameModel
    │                  └──replaces──> WikiPageType enum
    │
    └──optional──> External GameModel import
                       ├──depends on──> file_picker package
                       ├──depends on──> JSON schema validation
                       └──depends on──> GameModel data structure finalized
```

**Critical path:** GameModel data structure → D&D 5e + CoC 7e JSON → GameModelService → everything else. The schema must be finalized before any JSON file authoring begins.

**Blocking dependency:** The formula parser for initiative is a discrete sub-problem. It needs its own design (what grammar is supported?) before encounter tracker integration.

---

## MVP Definition for GameModel Milestone

### Must ship (milestone complete when these are done)

1. `GameModel` Dart class in `core` package — schema for entity types, field definitions, wiki page types, encounter config
2. `GameEntity` Dart class in `core` — replaces `PlayerCharacter`, `Monster`, `NPC`
3. D&D 5e `GameModel` JSON asset — field-compatible with existing typed models; existing demo data migrated
4. CoC 7e `GameModel` JSON asset — proves agnosticism
5. `GameModelService` Provider — loads active model, notifies listeners on switch
6. Character sheet UI generated from active GameModel schema — no hardcoded D&D field names in UI
7. Game system selector widget — accessible from both apps
8. Encounter tracker reads initiative formula from active GameModel
9. Wiki page type registry driven by active GameModel (enum replaced)
10. Both apps reflect active GameModel without restart

### Defer to subsequent milestone

- External GameModel file import (file_picker workflow) — useful but not needed to prove the concept
- Community GameModel registry/discovery
- Schema-version migration logic (add version fields now; implement migration later)
- Custom symbol dice rendering (Genesys-style narrative dice)
- Third bundled system (Pathfinder 2e is the next logical candidate)

---

## Confidence Assessment

| Area | Level | Source |
|------|-------|--------|
| Foundry VTT architecture | HIGH | Official Foundry docs (foundryvtt.com/article/system-development/) |
| D&D 5e field requirements | HIGH | Existing codebase (player_character.dart, monster.dart) |
| CoC 7e field requirements | MEDIUM | Official character sheet PDFs + Roll20 CoC sheet documentation |
| System popularity rankings | MEDIUM | ScriptoriumGM 2025 article citing Roll20 Orr Group data |
| Genesys/Star Wars dice model | MEDIUM | FFG official character sheet PDFs + community writeups |
| VtM 5e field model | MEDIUM | Roll20 VtM wiki + StartPlaying character creation guides |
| Schema anti-patterns | MEDIUM | Foundry dev docs, Cannibal Halfling campaign manager analysis |
| User expectation on system switch | MEDIUM | Cannibal Halfling review + RPGPub forum thread on system migration |

---

## Sources

- Foundry VTT system development: https://foundryvtt.com/article/system-development/ (HIGH)
- Foundry VTT system data models: https://foundryvtt.com/article/system-data-models/ (HIGH)
- Top 10 TTRPG systems 2025: https://www.scriptoriumgm.com/blog/top-10-most-popular-ttrpg-systems-2025 (MEDIUM)
- CoC 7e Roll20 sheet documentation: https://help.roll20.net/hc/en-us/articles/360052637253-Call-of-Cthulhu-7E-by-Roll20 (MEDIUM)
- CoC 7e character creation overview: https://startplaying.games/blog/posts/how-do-you-create-character-call-of-cthulhu-coc-7e (MEDIUM)
- RPG Companion App system schema: https://docs.rpg-companion.app/System/RPGSystem (MEDIUM)
- System Split: Campaign Managers: https://cannibalhalflinggaming.com/2023/03/29/system-split-campaign-managers/ (MEDIUM)
- VtM 5e mechanics overview: https://www.strangeassembly.com/2019/character-optimization-in-vampire-the-masquerade-v5 (MEDIUM)
- Genesys/Star Wars dice writeup: https://philgamer.wordpress.com/2018/07/25/lets-study-genesys-part-1-narrative-dice-basic-rules/ (MEDIUM)
- SaveState PROJECT.md (HIGH — project source of truth)
- packages/core/lib/models/player_character.dart (HIGH — codebase)
- packages/core/lib/models/monster.dart (HIGH — codebase)

---
*Feature research for: TTRPG-agnostic schema-driven GameModel milestone*
*Researched: 2026-05-07*

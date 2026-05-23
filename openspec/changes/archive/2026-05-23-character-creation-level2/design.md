## Context

SaveState's character creation currently consists of a single modal form with 14 raw text/number inputs that map to a minimal `CreateCharacterRequest`. The backend writes to three flat tables (`entities`, `entity_stats`, `character_profiles`) using SQL INSERTs that ignore most of the existing schema — `character_classes`, `entity_skills`, `entity_stats.save_prof_*`, `entities.alignment`, and `character_profiles.subclass`/`background` are all unused by the creation flow.

Meanwhile, the schema already has populated `classes`, `subclasses`, and `skills` tables with real D&D 5e data, and `character_profiles`/`character_classes` are designed for multi-classing and rich character data. The gap between what the schema supports and what the creation flow captures is the primary motivation.

Constraints:
- SPA mode — no routing, everything is a component shown/hidden by state
- All DB access goes through Tauri IPC (Rust commands)
- No new dependencies outside of existing Cargo.toml
- The `character_classes` join table approach for multi-class support should be respected, not bypassed

## Goals / Non-Goals

**Goals:**
- Replace free-text class/race inputs with data-driven dropdowns from DB tables
- Add subclass, background, subrace, and alignment to the creation form
- Support D&D 5e ability score generation methods (Standard Array, Point Buy, 4d6-drop-lowest) with validation
- Auto-calculate derived stats: proficiency bonus from class/level, hit points from hit die + CON mod, speed/size from race
- Add saving throw proficiency selection and skill proficiency picker
- Expand `CreateCharacterRequest` to carry the full payload
- Populate `character_classes`, `entity_skills`, and save proficiencies on creation
- Add pre-creation validation on the backend (score limits, point buy totals, class-subclass matching)
- Fix the `GET_PLAYER_CHARACTERS` query to handle characters without `character_classes` entries gracefully

**Non-Goals:**
- Not a multi-step creation wizard — the form grows within a single scrollable panel/modal
- Not adding classes beyond the SRD subset (existing 5 classes + PHB-style reference data)
- Not building a level-up or editing flow (that's future work)
- Not implementing full multiclass validation (prerequisite scores, etc. — simple level-per-class is enough)
- Not building a full spell selection flow (spell library exists but selection is deferred)
- Not adding equipment or inventory
- Not changing the initiative strip, encounter builder, or any non-character-creation surface

## Decisions

### Decision 1: Richer modal instead of full-page panel

The current `CreateCharacterModal.svelte` is 460px wide — too narrow for all the new fields. Two options:

**Option A (resizable panel):** Make the modal wider (600-700px) and taller, with improved scroll behavior. Replace the detail panel in the bottom-pane layout temporarily, or overlay as a larger modal.
- Pro: Minimal layout disruption. Modal pattern is already established.
- Pro: Can be expanded further for future Level 3/4 features.
- Con: A modal this big can feel heavy.
- Verdict: **Chosen** — enlarge the existing modal to ~640px, improve internal layout with columns and sections, keep the overlay pattern.

**Option B (replace detail panel):** When creating a character, swap out the detail panel with the creation form.
- Con: Disrupts the existing layout rhythm and requires state management for the selected character vs. creation mode.
- Verdict: Rejected.

### Decision 2: Backend validation command instead of frontend-only

Validation logic lives in Rust, called as a Tauri command (`validate_character_stats`), invoked by the frontend on input change (debounced) and on submit.

- Pro: Single source of truth for D&D rules. Frontend is pure rendering.
- Pro: The same validation can be reused for future edit/level-up flows.
- Con: Round-trip latency on validation feedback.
- Mitigation: Debounce validation calls (300ms). Simple client-side co-validation (non-negative values, expected ranges) for instant feedback; authoritative validation on the backend.

### Decision 3: `races` and `backgrounds` as new SQLite tables, not JSON blobs

Both get their own tables with foreign keys where appropriate, seeded from the `5e_data.sqlite` seed database.

- Pro: Consistent with existing `classes`/`subclasses`/`skills` pattern.
- Pro: Queryable — future features can filter races by source, backgrounds by skill picks.
- Con: Schema changes require rebuild of the seed database.
- Verdict: **Chosen**. JSON blobs would be faster to seed but harder to query and validate against.

### Decision 4: Stat rolling method stored as a type + results array

`CreateCharacterRequest` carries a `stat_roll_method: String` field ("standard_array", "point_buy", "rolled") and the resulting 6 ability scores as the existing 6 integer fields. The generator picks which validation rules to apply based on the method.

- Point Buy: validates total spent ≤ 27, each score 8–15, using the PHB cost table (embedded in Rust logic).
- Standard Array: validates the values are exactly [15, 14, 13, 12, 10, 8] (order doesn't matter).
- 4d6-drop-lowest: validates each score 3–18, no total validation (luck of the roll).
- Pro: Clean separation. Frontend can implement the interactive rollers (point buy UI, dice roller) using the same data structure, backend validates final result.
- Con: The rolling mechanics themselves (point buy cost UI, 4d6 animation) are frontend-only logic with no backend mirror.

### Decision 5: `entity_skills` populated at creation

When a character is created, skill proficiencies from class, background, and any manual picks are written to `entity_skills` in a batch INSERT. The frontend picks which skills are proficient; the backend validates that the total number of proficient skills doesn't exceed class+background allotment.

- The `GET_CHARACTER_SKILLS` query already handles this table correctly.
- The existing `skills` table has all 18 skills with associated ability scores.

### Decision 6: Keep `character_profiles.class` as a computed/derived field

Instead of storing a flat `class` string in `character_profiles.class`, the field becomes a denormalized convenience view of the top-level class from `character_classes`. The `GET_PLAYER_CHARACTERS` query already does this via `GROUP_CONCAT`. The INSERT will now write to `character_classes` instead of the flat field, with a trigger or code-level fallback for the denormalized column.

- Simpler approach: Write to both `character_classes` (for proper structure) and `character_profiles.class`/`level` (for backward compatibility with the existing query) during creation. Future query cleanup can remove the duplication.

## Risks / Trade-offs

- **[Complexity] The form grows significantly** — from a compact modal to a feature-rich panel with 30+ interactive fields. Risk of overwhelming new users. Mitigation: Group fields into clearly labeled sections (Details, Abilities, Proficiencies) with visual hierarchy. The stat rolling method becomes a tab-like selector to keep the UI focused.
- **[Data maintenance] Seeding races and backgrounds** requires authoring real D&D 5e content. Mitigation: Start with a focused SRD subset (PHB races: dwarf, elf, halfling, human, dragonborn, gnome, half-elf, half-orc, tiefling; PHB backgrounds: acolyte, criminal, folk hero, noble, sage, soldier, etc.). Content can be expanded later.
- **[Coupling] D&D 5e rules baked into Rust** — the point buy cost table, stat array, HP formula, and proficiency bonus formula are all hardcoded in Rust. If the GameModel v2.0 materializes, these need extraction. Mitigation: Keep rules in dedicated pure functions in a `rules.rs` module — easy to find and replace later.
- **[Performance] Validation round-trips** — each field change triggers a debounced IPC call. Mitigation: Keep debounce at 300ms. The validation function is a pure computation (no DB access needed for score validation), so it's fast.

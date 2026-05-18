# AGENTS.md — SaveState

## Project overview

SaveState is a Tauri 2 desktop application for TTRPG initiative and combat tracking. The current feature set targets D&D 5e (character sheets, stat blocks, skill modifiers, initiative order). The v2.0 roadmap replaces the hardcoded D&D schema with a runtime JSON GameModel system so any TTRPG can be supported.

---

## Tech stack

| Layer | Technologies |
|-------|-------------|
| Frontend | Svelte 5, SvelteKit 2, TypeScript 5.6, Vite 6, GSAP 3 |
| Desktop bridge | Tauri 2, `@tauri-apps/api` v2 |
| Backend | Rust (stable), Tauri 2 command handlers |
| Database | SQLite via `rusqlite` (bundled), `serde`, `uuid` |

---

## Architecture

```
src/
├── routes/+page.svelte          ← Thin shell, composes components
├── lib/
│   ├── components/             ← Svelte 5 component library
│   │   ├── AppBar.svelte
│   │   ├── InitiativeStrip.svelte
│   │   ├── CharacterCard.svelte
│   │   ├── CharacterList.svelte
│   │   ├── CharacterDetail.svelte
│   │   ├── CreateCharacterModal.svelte
│   │   └── DiceRoller.svelte
│   ├── stores/app.svelte.ts    ← Shared state (Svelte 5 runes)
│   ├── types/index.ts          ← TypeScript interfaces
│   └── styles/theme.css        ← CSS custom properties + resets
        │
        │  invoke("command_name", { args })   [Tauri IPC]
        ▼
src-tauri/src/
├── lib.rs                      ← Entry point + command registration
├── models.rs                   ← IPC structs (Serialize/Deserialize)
├── db.rs                       ← Connection pool + queries + row constants
└── commands/
    ├── characters.rs           ← get_player_characters, create_player_character
    ├── creatures.rs             ← get_monsters, get_npcs
    └── skills.rs                ← get_character_skills
        │
        │  rusqlite
        ▼
Assets/5e_data.sqlite           ← SQLite database (bundled at build time)
```

Key constraints:
- SvelteKit runs in **static/SPA mode** — no server-side rendering, no API routes.
- All business logic and database access lives in **Rust**. The frontend only calls `invoke()` and renders results.
- The IPC boundary is the only place where Rust structs cross into TypeScript — match field names exactly (snake_case on both sides; Tauri serializes as-is).

---

## Build and run

```bash
npm run tauri dev      # start full dev environment (Vite + Rust watch)
npm run dev            # Vite frontend only (no Rust; invoke() calls will fail)
npm run build          # production frontend build
npm run check          # TypeScript + Svelte type-check (run before committing)
npm run tauri          # raw Tauri CLI passthrough
```

**No test suite exists yet.** Don't add tests unless explicitly requested.

---

## Key files

| Path | Role |
|------|------|
| `src/routes/+page.svelte` | Main UI shell |
| `src/lib/components/*.svelte` | Reusable UI components |
| `src/lib/stores/app.svelte.ts` | Shared application state |
| `src/lib/types/index.ts` | TypeScript interfaces |
| `src/lib/styles/theme.css` | CSS custom properties |
| `src-tauri/src/lib.rs` | Tauri entry point + command registration |
| `src-tauri/src/models.rs` | IPC data structs |
| `src-tauri/src/db.rs` | DB connection pool + queries |
| `src-tauri/src/commands/*.rs` | Tauri command handlers |
| `Assets/savestate_schema.sql` | Canonical DB schema definition |
| `Assets/5e_data.sqlite` | Bundled SQLite DB (seed + demo data) |
| `Assets/savestate_demo_data.sql` | Demo data SQL (5 PCs, 25 monsters, 10 NPCs) |
| `src-tauri/tauri.conf.json` | Window config, bundle settings, capability grants |
| `vite.config.js` | Dev server on port 1420, HMR on 1421 |

---

## Coding conventions

**Rust / Tauri**
- New Tauri commands go in `src-tauri/src/commands/` — one file per domain.
- Register commands in `src-tauri/src/lib.rs` via `tauri::generate_handler!`.
- Use `#[derive(Debug, Serialize, Deserialize)]` on every struct that crosses the IPC boundary.
- Use named constants from `db::row_indexes` for row access — no magic numbers.

**Svelte / TypeScript**
- Use **Svelte 5 runes** (`$state`, `$derived`, `$effect`, `$props`) — not legacy Svelte 4 store patterns.
- Application state lives in `src/lib/stores/app.svelte.ts` (Svelte 5 runes-based store).
- Use typed interfaces from `src/lib/types/index.ts` — don't duplicate structs.
- Components are in `src/lib/components/` — one file per component.
- Animations use GSAP — don't add a second animation library.
- Icons come from [Iconoir](https://iconoir.com) — use Iconoir SVGs for any new icons.

**Database**
- Schema changes go in `Assets/savestate_schema.sql` first, then applied to `Assets/5e_data.sqlite`.
- Use `INSERT OR IGNORE` / `INSERT OR REPLACE` patterns consistent with the existing seed scripts.

---

## What NOT to do

- **No SSR.** The static adapter is intentional; don't switch to a Node adapter.
- **Don't write to `Assets/5e_data.sqlite` directly** in code — it's the bundled seed DB. Runtime writes go through the Tauri app data directory.
- **Don't use `@tauri-apps/api` v1 patterns** (e.g., `tauri.invoke` from `@tauri-apps/api/tauri`). Import from `@tauri-apps/api/core` (v2).
- **Don't add npm dependencies** without verifying they survive `npm run check` and are compatible with the static/SPA build.

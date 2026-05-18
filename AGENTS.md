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
src/routes/+page.svelte       ← All UI (SPA, no SSR)
        │
        │  invoke("command_name", { args })   [Tauri IPC]
        ▼
src-tauri/src/lib.rs          ← All Tauri commands + DB queries
        │
        │  rusqlite
        ▼
Assets/5e_data.sqlite         ← SQLite database (bundled at build time)
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
| `src/routes/+page.svelte` | Entire frontend UI |
| `src-tauri/src/lib.rs` | All Tauri commands and DB queries |
| `src-tauri/src/main.rs` | App entry point (minimal) |
| `Assets/savestate_schema.sql` | Canonical DB schema definition |
| `Assets/5e_data.sqlite` | Bundled SQLite DB (seed + demo data) |
| `Assets/savestate_demo_data.sql` | Demo data SQL (5 PCs, 25 monsters, 10 NPCs) |
| `src-tauri/tauri.conf.json` | Window config, bundle settings, capability grants |
| `vite.config.js` | Dev server on port 1420, HMR on 1421 |

---

## Coding conventions

**Rust / Tauri**
- All new Tauri commands go in `src-tauri/src/lib.rs` and must be registered in the `tauri::Builder::invoke_handler` macro.
- Resolve the DB path at runtime with `tauri::path::BaseDirectory::Resource` — never hardcode a path.
- Use `#[derive(Debug, Serialize, Deserialize)]` on every struct that crosses the IPC boundary.

**Svelte / TypeScript**
- Use **Svelte 5 runes** (`$state`, `$derived`, `$effect`, `$props`) — not legacy Svelte 4 store patterns.
- Keep all application state in `+page.svelte` for now; don't introduce a separate store layer without a specific reason.
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
- **Don't hardcode D&D-specific logic** in new features — the v2.0 direction is TTRPG-agnostic.

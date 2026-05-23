## Context

The application uses a single SQLite database (`5e_data.sqlite`) bundled in `Assets/` at build time. Currently `DbPool::new()` resolves the path at compile time using `env!("CARGO_MANIFEST_DIR")`, which hardcodes the source tree location. All runtime writes (creating player characters, updating HP, etc.) go into this same file.

The encounters and sessions modules in `commands/encounters.rs` already use the correct pattern — they call `app.path().app_data_dir()` through Tauri's `AppHandle` to get a platform-appropriate data directory (e.g., `~/.local/share/com.zacharyreyes.savestate/` on Linux, `~/Library/Application Support/com.zacharyreyes.savestate/` on macOS).

The core challenge: `DbPool` is currently created eagerly in `lib.rs::run()` before `.manage()` is called — before Tauri's `AppHandle` is available. We need to restructure initialization so the DB path comes from the app data directory, not a compile-time constant.

Constraints:
- `rusqlite::Connection` is not `Send`, so it's wrapped in `Mutex<Connection>`.
- Tauri's `State<DbPool>` expects the pool to be managed with a fixed type.
- The bundled `Assets/5e_data.sqlite` must stay as the seed source for app data dir copies.
- No new dependencies outside of what's already in `Cargo.toml`.

## Goals / Non-Goals

**Goals:**
- Runtime database lives in the Tauri app data directory (same location as encounters/sessions JSON files).
- Bundled `Assets/5e_data.sqlite` is copied to the app data dir on first launch (or when missing).
- All user writes modify the app-data-dir copy, never the bundled asset.
- The bundled asset is read-only at runtime — the source tree stays clean from user data.
- Existing user data in the source-tree DB is migrated to the new location (one-time).
- All existing commands (get/create characters, HP updates, monsters, NPCs, skills, spells) continue to work without frontend changes.

**Non-Goals:**
- Not introducing a migration framework or schema versioning (that's a future concern).
- Not separating user data from seed data within the same DB file (still one file, just in the right location).
- Not changing the frontend — this is purely a backend/infrastructure change.
- Not adding a test suite (no test suite exists yet per project conventions).

## Decisions

### Decision 1: Lazy `DbPool` via Tauri `setup()` hook instead of managed `Option<DbPool>`

**Option A (Lazy via `setup()`):** Move DB initialization into Tauri's `.setup(|app| { ... })` closure, where `AppHandle` is available. Create `DbPool` there and register it with `app.manage()`.
- Pro: Clean pattern, no optional wrapping, `State<DbPool>` remains infallible after init.
- Pro: Follows idiomatic Tauri — setup is the intended place for one-time initialization.
- Con: Requires moving `DbPool::new()` call from the function body into the closure.
- Verdict: **Chosen**.

**Option B (Lazy via `Mutex<Option<DbPool>>`):** Manage a `Mutex<Option<DbPool>>` and have each command check `pool.lock()?.as_ref().ok_or(...)`.
- Con: Every command handler needs to handle a "not initialized" error.
- Con: Adds noise to every existing command.
- Con: `State<Mutex<Option<DbPool>>>` is awkward.
- Verdict: Rejected.

### Decision 2: `DbPool::new()` accepts a path parameter

Change `DbPool::new()` from taking no arguments to taking `db_path: PathBuf`. The caller (the `setup()` hook) resolves the runtime path and passes it in.

- The compile-time `env!("CARGO_MANIFEST_DIR")` path is removed from `DbPool`.
- `DbPool::from_conn()` (for testing) remains unchanged.
- This keeps `DbPool` simple — it just wraps a connection, no path resolution logic.

### Decision 3: Seed DB copy on first launch

Add a `DbPool::ensure_seeded(dest_path: PathBuf, seed_path: PathBuf) -> Result<(), String>` function (or similar standalone function) that:
1. Checks if `dest_path` exists.
2. If not, copies `seed_path` to `dest_path`.
3. If it does exist, does nothing (the user may have data in it; don't overwrite).

The `setup()` hook resolves both paths and calls this before creating `DbPool`.

**Why not `COPY_ONCE` env var or feature flag?** Simpler is better. A file-exists check is the same mechanism SQLite-based apps commonly use.

### Decision 4: One-time migration of existing source-tree data

If the user has data in the old source-tree DB (e.g., characters they created before this change), we need to copy that file to the app data dir on first launch — but only if the app data dir doesn't already have a DB file.

The copy-on-first-launch in Decision 3 handles this: if the app data dir doesn't have `5e_data.sqlite` yet, we copy the seed file from the bundle. If they already have a DB in the source tree with user data, that data was in the same file as seed data, and we'd be overwriting with a fresh seed copy.

**Mitigation:** For the first launch after this change, check if the old source-tree DB exists AND the app data dir DB doesn't exist. If so, copy the source-tree DB (which includes user data) to the app data dir, rather than copying the fresh bundled seed. Future launches copy only from the bundled seed (which will be overwritten by any existing app-data-dir copy).

This is a one-time migration path. After the first successful launch, the source-tree DB is never touched again.

### Decision 5: Store the bundled seed path using `include_bytes!` or resolve relative to the binary

The bundled `Assets/5e_data.sqlite` is distributed alongside the binary. In development, it's at `Assets/5e_data.sqlite` relative to the source tree. In production, we need it bundled as a resource via Tauri's resource system.

Tauri 2 can bundle files via `tauri.conf.json` `bundle.resources`. We'll add an entry to bundle `Assets/5e_data.sqlite` and resolve it at runtime via `app.path().resource_dir()`.

For development, we fall back to the source-tree path relative to `CARGO_MANIFEST_DIR` (but only for reading the seed, not for the runtime DB).

**Updated decision (simpler):** Keep using `env!("CARGO_MANIFEST_DIR")` only to find the seed file for the copy operation. The runtime DB path is resolved via Tauri's `app.path().app_data_dir()`. This means:
- Dev: seed = `CARGO_MANIFEST_DIR/../Assets/5e_data.sqlite`, runtime = `app_data_dir/5e_data.sqlite`
- Release: We'll need `tauri.conf.json` to bundle the asset; seed = resolved at runtime from resource dir

## Risks / Trade-offs

- **[Risk] Existing user data in source-tree DB could be lost** → Mitigation: Decision 4's migration logic copies the source-tree DB to app data dir if it exists and the app data dir doesn't have one yet.
- **[Risk] The `setup()` hook panics if DB copy/init fails** → Mitigation: The hook returns `Err(...)`, which Tauri shows as an error dialog. Any failure during init is fatal and should be surfaced immediately.
- **[Risk] Tauri resource bundling adds complexity to build** → Mitigation: This is a one-time tauri.conf.json change. The resource path is well-documented in Tauri 2 docs.
- **[Trade-off] Single SQLite file instead of separate seed/user DBs** → Acceptable for now. The v2.0 GameModel refactor will change the schema entirely; this change just fixes the path problem.
- **[Risk] Concurrent access to the same SQLite file from multiple instances** → Low risk (single-user desktop app), and `rusqlite` with WAL mode handles this if needed in the future.

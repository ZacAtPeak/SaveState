## Why

The database connection in `DbPool::new()` uses `env!("CARGO_MANIFEST_DIR")` — a compile-time path into the source tree — to open `Assets/5e_data.sqlite`. All writes (e.g., `create_player_character`) go directly into this bundled asset file. This means user-created characters are written into the source tree, won't survive a release update or AppImage rebuild, and on bundled/release builds the path doesn't exist at all. The encounters and sessions modules already solve this correctly by writing JSON to the Tauri app data directory via `app.path().app_data_dir()`. The database needs to follow the same pattern.

## What Changes

- **Seed/copy** the bundled `Assets/5e_data.sqlite` into the Tauri app data directory on first launch (or when the file doesn't exist yet)
- **Re-initialize** `DbPool` to use the app-data-dir path instead of the compile-time source-tree path
- **Separate** read-only seed data from user-writable runtime data — the bundled asset remains pristine; the runtime DB in the app data dir is the one that gets modified
- **Handle migration** of any existing user data from the old location (source tree) to the new location (app data dir) if needed
- **Add a new Tauri command** (e.g., `initialize_database`) called during app startup to set up the DB in the app data dir before `DbPool` is used

## Capabilities

### New Capabilities
- `db-app-data-init`: Copy the bundled seed database to the Tauri app data directory and return the correct path. Called once at startup before any read/write operations.
- `db-pool-runtime-path`: Modify `DbPool::new()` to accept or resolve the runtime database path from the app data directory instead of using the compile-time `CARGO_MANIFEST_DIR` constant.

### Modified Capabilities
<!-- No existing specs in openspec/specs/ to modify; this is a new change area. -->

## Impact

- **`src-tauri/src/db.rs`**: `DbPool::new()` needs to change — either accept a `PathBuf` parameter, or the pool needs lazy initialization after Tauri provides the app data dir path.
- **`src-tauri/src/lib.rs`**: The boot sequence changes. Currently `DbPool::new()` is called eagerly before `.manage()`. It now needs the app data dir, which requires Tauri's `AppHandle`. The pool should be managed as a `Mutex<Option<DbPool>>` (lazy init), or we add an init command that sets up the DB, or we restructure the Tauri setup to run DB init inside a `setup()` hook.
- **`src-tauri/src/commands/`**: A new `db_init.rs` command file for the initialization command.
- **`Assets/5e_data.sqlite`**: No longer written to at runtime. The bundled file is the read-only seed source.
- **Build / packaging**: The bundled DB (`Assets/5e_data.sqlite`) stays in the bundle as a seed source; no structural changes to build config.

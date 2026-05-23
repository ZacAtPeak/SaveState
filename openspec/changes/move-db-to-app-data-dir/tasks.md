## 1. Database initialization in app data directory

- [x] 1.1 Add bundle resource entry for `Assets/5e_data.sqlite` in `tauri.conf.json` under `bundle.resources`
- [x] 1.2 Modify `DbPool::new()` to accept a `db_path: PathBuf` parameter instead of resolving the path at compile time
- [x] 1.3 Add a standalone `seed_database(dest: &Path, seed: &Path) -> Result<(), String>` function to `db.rs` that copies the seed file if the destination doesn't exist, with one-time migration logic for the source-tree DB
- [x] 1.4 Restructure `lib.rs::run()` to move `DbPool` creation into Tauri's `.setup()` closure where `AppHandle` is available, resolving the runtime path via `app.path().app_data_dir()`
- [x] 1.5 Register the new `DbPool` instance with `app.manage()` inside the setup closure, and remove the eager `DbPool::new()` call from the function body
- [x] 1.6 Remove the unused `use std::env;` import and any compile-time path constants from `db.rs`

## 2. Verify and test the migration

- [x] 2.1 Build the application with `npm run tauri build -- --debug` and verify it starts without errors
- [x] 2.2 Run `npm run tauri dev` and confirm all existing commands still work (create character, load monsters, etc.)
- [x] 2.3 Verify the runtime database is created at the correct app data directory path (not in the source tree)
- [x] 2.4 Verify that no writes occur to `Assets/5e_data.sqlite` after the change (the bundled file remains pristine)
- [x] 2.5 Simulate a fresh install by deleting the app data dir DB and confirm the seed is copied correctly
- [x] 2.6 Run `npm run check` to confirm no TypeScript/Svelte type errors were introduced (frontend should be unchanged)

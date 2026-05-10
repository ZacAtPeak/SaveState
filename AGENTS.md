# save-state

Tauri v2 + Vite + vanilla TypeScript + Rust app.

## Dev commands

- `npm run tauri dev` — full app (frontend on :1420, Rust backend). Runs `npm run dev` automatically.
- `npm run tauri build` — production bundle. Runs `npm run build` (tsc → vite) first.
- `npm run dev` — Vite dev server only (no Rust).
- `npm run build` — typecheck (tsc) + Vite production build.

## Architecture

- `src/` — TypeScript frontend entrypoint (`main.ts`), assets, styles.
- `src-tauri/src/lib.rs` — Rust command handler (`greet`). Tauri entry via `save_state_lib::run()`.
- `index.html` — Web entry loaded by Tauri window.

## Notable quirks

- Rust lib name is `save_state_lib` (with `_lib` suffix). Required for Windows Cargo uniqueness — do not change.
- Vite config (`vite.config.ts`) ignores `src-tauri/` from file watching — Rust changes require restart.
- `TAURI_DEV_HOST` env var (set in shell) controls HMR remote device settings in vite.config.ts.
- No test framework or ESLint configured. TypeScript strict mode is the only code quality gate.
- `beforeBuildCommand` runs `tsc` — type errors will block `npm run tauri build`.
# save-state

A Tauri desktop application for managing tabletop RPG game systems, actors, and encounters. Built with Rust (backend) and TypeScript/Vite (frontend).

## Tech Stack

- **Frontend**: TypeScript, Vite, vanilla HTML/CSS
- **Backend**: Rust with Tauri 2
- **Database**: SQLite (rusqlite)
- **UI Icons**: ikonate

## Project Structure

```
save-state/
├── src/                  # Frontend TypeScript source
│   ├── main.ts          # Main application logic
│   ├── styles.css       # Application styles
│   └── assets/          # Static assets (db, SQL, icons)
├── src-tauri/           # Rust backend
│   ├── src/lib.rs       # Tauri commands and business logic
│   ├── Cargo.toml       # Rust dependencies
│   └── tauri.conf.json  # Tauri configuration
├── dist/                # Built frontend output
└── package.json         # Node dependencies and scripts
```

## Commands

| Command | Description |
|---------|-------------|
| `npm run dev` | Start Vite dev server with Tauri |
| `npm run build` | Build TypeScript and bundle frontend |
| `npm run preview` | Preview production build |
| `npm run tauri` | Run Tauri CLI commands |

## Database

- SQLite database at `src/assets/demo-UTS.db`
- Tables: `actors`, `game_systems`
- Actor fields: `id`, `system_id`, `name`, `actor_type`, `base_hp`, `base_ac`, `stats_blob`

## Tauri Commands

- `get_actors(system_id?)` - Fetch actors, optionally filtered by game system
- `get_game_systems()` - Fetch all game systems

## Development Notes

- Frontend builds to `dist/`, served by Tauri in production
- Tauri dev server runs on port 1420
- HMR enabled for frontend development
- `src-tauri/` is excluded from Vite file watching
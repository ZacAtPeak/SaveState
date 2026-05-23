## ADDED Requirements

### Requirement: DbPool accepts a runtime path instead of using compile-time path
`DbPool::new()` SHALL accept a `std::path::PathBuf` parameter specifying the database file path, instead of resolving the path at compile time via `env!("CARGO_MANIFEST_DIR")`.

#### Scenario: DbPool::new() accepts a path parameter
- **WHEN** `DbPool::new(db_path)` is called with a `PathBuf` pointing to a valid SQLite file
- **THEN** the connection SHALL be opened at that path
- **AND** no `env!("CARGO_MANIFEST_DIR")` constant SHALL appear in the connection resolution logic

#### Scenario: DbPool::new() fails with invalid path
- **WHEN** `DbPool::new(db_path)` is called with a `PathBuf` pointing to a non-existent or unwritable location
- **THEN** the function SHALL return `Err(String)` with a descriptive error message

### Requirement: from_conn remains unchanged
`DbPool::from_conn(conn: Connection)` SHALL continue to exist and accept an already-opened `Connection` for testing purposes, with no behavior change.

#### Scenario: Testing constructor works as before
- **WHEN** a test creates a `DbPool` via `DbPool::from_conn(conn)`
- **THEN** the pool wraps the provided connection
- **AND** `lock()` returns a `MutexGuard` to that connection

### Requirement: Commands continue to work with no frontend changes
All existing Tauri commands (get_player_characters, create_player_character, update_entity_hp, get_monsters, get_npcs, get_character_skills, get_character_spells, get_spell_library) SHALL continue to accept and use `State<DbPool>` with no signature changes.

#### Scenario: Character creation writes to app data directory
- **WHEN** a user creates a player character via `create_player_character`
- **THEN** the character data SHALL be written to the database file in the app data directory
- **AND** the bundled `Assets/5e_data.sqlite` SHALL NOT be modified

#### Scenario: HP updates persist across app restarts
- **WHEN** a user updates an entity's HP via `update_entity_hp`
- **THEN** the change SHALL be persisted to the runtime database in the app data directory
- **AND** SHALL be visible on the next application launch

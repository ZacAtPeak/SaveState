## ADDED Requirements

### Requirement: System copies seed database to app data directory on first launch
On application startup, the system SHALL ensure that a writable copy of the bundled seed database exists in the Tauri app data directory before any database commands are executed.

#### Scenario: First launch with no existing runtime database
- **WHEN** the application starts for the first time
- **AND** no `5e_data.sqlite` exists in the Tauri app data directory
- **THEN** the system SHALL copy the bundled seed database from `Assets/5e_data.sqlite` to the app data directory
- **AND** the system SHALL open the copied database as the runtime connection

#### Scenario: Subsequent launch with existing runtime database
- **WHEN** the application starts
- **AND** a `5e_data.sqlite` already exists in the Tauri app data directory
- **THEN** the system SHALL NOT overwrite the existing file
- **AND** the system SHALL open the existing file as the runtime connection

#### Scenario: Source-tree database with user data exists (migration)
- **WHEN** the application starts after this change is deployed
- **AND** no runtime database exists in the app data directory
- **AND** a database with user data exists at the old source-tree path (`Assets/5e_data.sqlite`)
- **THEN** the system SHALL copy the source-tree database (preserving user data) to the app data directory
- **AND** the system SHALL NOT use a fresh seed copy (to avoid data loss)

#### Scenario: Seed database is missing from bundle
- **WHEN** the application starts
- **AND** the bundled seed database cannot be found
- **AND** no runtime database exists in the app data directory
- **THEN** the system SHALL return a fatal error and refuse to start

### Requirement: Database initialization happens before any commands
The system SHALL ensure the runtime database path is resolved and the database is initialized before any Tauri commands that depend on `DbPool` are invoked.

#### Scenario: Init happens in Tauri setup hook
- **WHEN** the Tauri application starts
- **THEN** the database initialization SHALL occur inside the `.setup(|app| { ... })` closure
- **AND** `DbPool` SHALL be registered with `app.manage()` after successful initialization
- **AND** `State<DbPool>` SHALL be available to all command handlers after setup completes

#### Scenario: Init failure prevents application start
- **WHEN** database initialization fails (e.g., cannot copy seed, cannot open file)
- **THEN** the setup hook SHALL return an `Err`
- **AND** the application SHALL show an error dialog and exit

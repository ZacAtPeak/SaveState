## ADDED Requirements

### Requirement: Class data queryable via Tauri command
The `classes` table SHALL be queryable at runtime to populate the creation form's class dropdown.

#### Scenario: Get all classes
- **WHEN** the `get_classes` command is called
- **THEN** it SHALL return a list of all classes with `id`, `name`, `hit_die`, `saving_throw_1`, `saving_throw_2`, `primary_ability`, and `description`

#### Scenario: Get subclasses for a class
- **WHEN** the `get_subclasses(class_id)` command is called with a valid class ID
- **THEN** it SHALL return all subclasses belonging to that class, with `id`, `name`, and `description`

#### Scenario: Unknown class ID returns empty
- **WHEN** `get_subclasses(class_id)` is called with a non-existent class ID
- **THEN** it SHALL return an empty list (not an error)

### Requirement: Classes reference data seeded in SQLite
The seed database SHALL include classes covering the core PHB set with accurate hit dice and saving throw proficiencies.

#### Scenario: Minimum class set
- **WHEN** the seed database is created
- **THEN** the `classes` table SHALL contain at minimum: Barbarian, Bard, Cleric, Druid, Fighter, Monk, Paladin, Ranger, Rogue, Sorcerer, Warlock, Wizard
- **AND** each class SHALL have the correct hit die (`d6`/`d8`/`d10`/`d12`), `saving_throw_1`, and `saving_throw_2`

#### Scenario: Each class has subclasses
- **WHEN** the seed database is created
- **THEN** each class SHALL have at least 2 subclasses defined in the `subclasses` table

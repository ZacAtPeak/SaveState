## ADDED Requirements

### Requirement: Character creation form with data-driven dropdowns
The character creation form SHALL replace free-text Class, Race, and Subrace inputs with dropdowns populated from backend Tauri commands (`get_classes`, `get_subclasses`, `get_races`).

#### Scenario: Class dropdown populated from backend
- **WHEN** the creation form opens
- **THEN** the Class dropdown SHALL be populated with class names and IDs from the `classes` DB table via the `get_classes` command
- **AND** the default selection SHALL be empty (no class preselected)

#### Scenario: Subclass dropdown filters by class
- **WHEN** a class is selected in the Class dropdown
- **THEN** the Subclass dropdown SHALL be populated with subclass options that belong to that class, fetched via `get_subclasses(class_id)`
- **AND** the Subclass dropdown SHALL reset to empty when the class selection changes

#### Scenario: Race dropdown with subrace
- **WHEN** the creation form opens
- **THEN** the Race dropdown SHALL be populated with races from the `races` DB table via the `get_races` command
- **AND** if a race has subraces, a Subrace dropdown SHALL appear after race selection

#### Scenario: Background dropdown
- **WHEN** the creation form opens
- **THEN** the Background dropdown SHALL be populated with backgrounds from the `backgrounds` DB table via the `get_backgrounds` command

#### Scenario: Alignment picker
- **WHEN** the creation form opens
- **THEN** an Alignment picker SHALL display the standard D&D 5e alignment grid (Lawful/Neutral/Chaotic × Good/Neutral/Evil plus Unaligned)
- **AND** the default selection SHALL be empty

### Requirement: Derived stat auto-calculation
The creation form SHALL display auto-calculated values that update when relevant inputs change.

#### Scenario: Proficiency bonus from class and level
- **WHEN** a class and level are selected
- **THEN** the proficiency bonus SHALL be calculated as `((level - 1) / 4) + 2` and displayed as a read-only field

#### Scenario: Hit points from class hit die and CON
- **WHEN** a class is selected
- **THEN** the suggested HP range SHALL be displayed based on the class hit die
- **AND** a minimum HP field SHALL show `hit_die_max + CON_mod` at level 1

#### Scenario: Speed and size from race
- **WHEN** a race is selected
- **THEN** the walking speed and size SHALL be displayed as read-only fields populated from the race data

### Requirement: Stat rolling method selector
The creation form SHALL let the user choose a D&D 5e ability score generation method and interactively build their scores.

#### Scenario: Standard Array method
- **WHEN** the user selects "Standard Array"
- **THEN** the 6 ability score fields SHALL be pre-filled with the values 15, 14, 13, 12, 10, 8
- **AND** the user SHALL be able to assign each value to any ability score by clicking
- **AND** no score SHALL be assignable twice
- **AND** the backend SHALL reject the character if the final scores are not exactly these 6 values

#### Scenario: Point Buy method
- **WHEN** the user selects "Point Buy"
- **THEN** the form SHALL display 6 ability score inputs starting at 8 each, with a total budget of 27
- **AND** increasing a score SHALL decrement the remaining budget according to the PHB cost table (8=0, 9=1, 10=2, 11=3, 12=4, 13=5, 14=7, 15=9)
- **AND** scores SHALL be clamped to 8–15 before racial bonuses
- **AND** the remaining budget SHALL be displayed and updated in real time
- **AND** the backend SHALL reject the character if total cost exceeds 27 or any raw score is outside 8–15

#### Scenario: 4d6 drop lowest method
- **WHEN** the user selects "Rolled (4d6 drop lowest)"
- **THEN** the form SHALL display a "Roll" button
- **WHEN** the user clicks "Roll"
- **THEN** 6 sets of [[4d6 drop lowest]] SHALL be rolled and displayed
- **AND** the user SHALL be able to re-roll individual sets or all 6
- **AND** each resulting score SHALL be between 3 and 18
- **AND** the user SHALL be able to assign the 6 values to abilities freely

#### Scenario: Manual entry method
- **WHEN** the user selects "Manual"
- **THEN** all 6 ability score inputs SHALL be editable number fields with bounds 1–30

### Requirement: Inline validation feedback
The form SHALL display validation errors and warnings in real time as the user makes selections.

#### Scenario: Validation call on input change
- **WHEN** any ability score, class, level, or selection changes
- **THEN** a debounced (300ms) `validate_character_stats` command SHALL be invoked
- **AND** any errors SHALL be displayed inline next to the relevant field

#### Scenario: Submit blocked on validation errors
- **WHEN** the user clicks "Create Character"
- **AND** there are unresolved validation errors
- **THEN** the "Create Character" button SHALL be disabled
- **AND** the first error SHALL be scrolled into view

### Requirement: Saving throw and skill proficiency pickers
The form SHALL allow the user to set saving throw proficiencies and choose skill proficiencies.

#### Scenario: Saving throw toggles
- **WHEN** a class is selected
- **THEN** the saving throws matching the class's proficiency list SHALL be pre-toggled on
- **AND** the user SHALL be able to toggle any of the 6 saving throws on or off

#### Scenario: Skill proficiency selection
- **WHEN** a class and background are selected
- **THEN** the form SHALL show all 18 skills with a toggle for proficiency
- **AND** the number of class-granted proficiencies and background-granted proficiencies SHALL be displayed
- **AND** the user SHALL be able to toggle additional skills up to the class/background allotment
- **AND** the total number of proficient skills SHALL NOT exceed class + background allotment (enforced by backend validation)

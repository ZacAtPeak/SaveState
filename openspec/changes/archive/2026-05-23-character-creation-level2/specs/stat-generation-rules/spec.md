## ADDED Requirements

### Requirement: Standard Array validation
The system SHALL validate that the Standard Array method produces exactly the 6 expected values.

#### Scenario: Valid standard array
- **WHEN** a character is submitted with `stat_roll_method = "standard_array"`
- **AND** the 6 ability scores are exactly 15, 14, 13, 12, 10, 8 (in any order, before racial bonuses)
- **THEN** the backend SHALL accept the submission

#### Scenario: Invalid standard array
- **WHEN** a character is submitted with `stat_roll_method = "standard_array"`
- **AND** the 6 ability scores do not match 15, 14, 13, 12, 10, 8 (before racial bonuses)
- **THEN** the backend SHALL reject the submission with a clear error message

### Requirement: Point Buy validation
The system SHALL validate Point Buy submissions against the PHB cost table and score limits.

#### Scenario: Valid point buy
- **WHEN** a character is submitted with `stat_roll_method = "point_buy"`
- **AND** each raw score is between 8 and 15 inclusive
- **AND** the total cost using the PHB table does not exceed 27
- **THEN** the backend SHALL accept the submission

#### Scenario: Invalid point buy — score below 8
- **WHEN** a character is submitted with `stat_roll_method = "point_buy"`
- **AND** any raw score is below 8
- **THEN** the backend SHALL reject with an error indicating the minimum score is 8

#### Scenario: Invalid point buy — score above 15
- **WHEN** a character is submitted with `stat_roll_method = "point_buy"`
- **AND** any raw score is above 15
- **THEN** the backend SHALL reject with an error indicating the maximum score is 15

#### Scenario: Invalid point buy — budget exceeded
- **WHEN** a character is submitted with `stat_roll_method = "point_buy"`
- **AND** the total cost using the PHB table exceeds 27
- **THEN** the backend SHALL reject with an error showing the remaining budget

### Requirement: 4d6-drop-lowest validation
The system SHALL validate that rolled scores are within the expected bounds.

#### Scenario: Valid rolled scores
- **WHEN** a character is submitted with `stat_roll_method = "rolled"`
- **AND** each score is between 3 and 18 inclusive
- **THEN** the backend SHALL accept the submission

#### Scenario: Rolled score out of bounds
- **WHEN** a character is submitted with `stat_roll_method = "rolled"`
- **AND** any score is below 3 or above 18
- **THEN** the backend SHALL reject with an error

### Requirement: Racial ASI application
Racial ability score bonuses SHALL be applied to raw scores on the backend.

#### Scenario: Racial ASI correctly applied
- **WHEN** a character is created with race "Dwarf" (which has +2 CON)
- **AND** the raw Constitution score is 14
- **THEN** the stored Constitution SHALL be 16
- **AND** the `CreateCharacterRequest` SHALL carry both `raw_scores` and the race ID, so the backend computes final scores

#### Scenario: Half-Elf flexible ASIs
- **WHEN** a character is created with race "Half-Elf" (which grants +2 CHA and +1 to two other scores of choice)
- **THEN** the request SHALL include the two chosen ability score increases
- **AND** the backend SHALL validate that no score receives more than one +1 bonus from this feature

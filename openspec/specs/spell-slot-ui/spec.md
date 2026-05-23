## Requirements

### Requirement: Slot display in Character Detail view

The Character Detail view SHALL display a character's spell slots grouped by slot type, with visual indicators per level.

#### Scenario: Slot group sections
- **WHEN** a character with spell slots opens the Character Detail view
- **THEN** each `SpellSlotGroup` SHALL render as a separate section with a header showing the group type (e.g., "Spellcasting (INT)" or "Pact Magic (CHA)")
- **AND** the group header SHALL also display `Save DC` and `Attack Bonus`

#### Scenario: Per-level slot indicators
- **WHEN** a slot group has multiple levels of slots
- **THEN** each level SHALL display:
  - The level number (e.g., "1st", "2nd")
  - A visual indicator showing remaining vs max (e.g., filled/empty dots or a fraction like "3/4")
  - The numeric count (e.g., "3/4")

#### Scenario: Depleted slot styling
- **WHEN** a slot level has `current = 0`
- **THEN** its visual indicator SHALL be visually distinct (e.g., dimmed, grayed out) to communicate depletion at a glance

#### Scenario: Zero-slot levels hidden
- **WHEN** a slot group has a level with `max = 0`
- **THEN** that level SHALL NOT be displayed

#### Scenario: Non-spellcaster shows nothing
- **WHEN** a character has no spell slot groups (e.g., Barbarian)
- **THEN** no slot section SHALL appear in the view
- **AND** no errors or empty placeholders SHALL be shown

### Requirement: Slot display in Character Modal

The Character Modal (opened from the initiative strip) SHALL show the same slot display as the Character Detail view.

#### Scenario: Modal shows slots
- **WHEN** the Character Modal is opened for a spellcaster
- **THEN** the slots SHALL be displayed in the same grouped format as the Character Detail view
- **AND** the slot state SHALL be loaded fresh when the modal opens

### Requirement: Slot state reactive updates

Slot state in the frontend SHALL be reactive and update immediately on consumption.

#### Scenario: Slot decreases after cast
- **WHEN** the user casts a spell from the Character Modal
- **THEN** the displayed slot count SHALL decrement immediately in the UI
- **AND** the updated state SHALL be persisted to the database (debounced, matching the HP sync pattern)

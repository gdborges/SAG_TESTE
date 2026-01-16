# form-layout Spec Delta

## MODIFIED Requirements

### Requirement: Field Width Distribution

The system SHALL distribute field widths proportionally within multi-field rows to utilize 100% of available horizontal space.

**Current behavior**: Fields use fixed widths from `TamaCamp`, leaving unused space on wider screens.

**New behavior**: Fields grow proportionally based on their `TamaCamp` values, maintaining relative proportions while filling available space.

#### Scenario: Multi-field row width distribution
- **GIVEN** a row with multiple fields
- **AND** fields have TamaCamp values [150, 310, 150]
- **AND** container width is 1000px
- **WHEN** the row is rendered
- **THEN** fields SHALL grow proportionally to fill 100% width
- **AND** relative proportions (1:2:1) SHALL be maintained
- **AND** final widths SHALL be approximately [238, 492, 238] pixels

#### Scenario: Single field in row
- **GIVEN** a row with exactly one field
- **AND** field is not a checkbox or button
- **WHEN** the row is rendered
- **THEN** field SHALL expand to use available width
- **AND** field SHALL NOT be constrained by max-width

#### Scenario: Checkbox fields
- **GIVEN** a field with ComponentType Checkbox or CalcCheckbox
- **WHEN** the field is rendered in a multi-field row
- **THEN** field SHALL NOT grow beyond its natural width
- **AND** field SHALL use `flex: 0 0 auto`

#### Scenario: Button fields
- **GIVEN** a field with ComponentType Button
- **WHEN** the field is rendered
- **THEN** field SHALL NOT grow beyond its natural width
- **AND** field SHALL use `flex: 0 0 auto`

#### Scenario: Mixed row with inputs and checkboxes
- **GIVEN** a row with text inputs and checkboxes
- **WHEN** the row is rendered
- **THEN** text inputs SHALL grow to fill available space
- **AND** checkboxes SHALL remain compact
- **AND** proportion between text inputs SHALL be maintained

#### Scenario: Minimum width protection
- **GIVEN** a field in a multi-field row
- **AND** viewport is narrow
- **WHEN** the row is rendered
- **THEN** field SHALL NOT shrink below min-width
- **AND** min-width SHALL be min(TamaCamp, 120)px

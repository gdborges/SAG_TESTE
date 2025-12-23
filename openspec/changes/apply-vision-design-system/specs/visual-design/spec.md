## ADDED Requirements

### Requirement: Vision Theme Variables
The system SHALL provide global CSS variables that define the color palette, typography, and spacing of the Vision design system.

#### Scenario: Color variables available
- **WHEN** the application is loaded
- **THEN** neutral color CSS variables (`--neutral-100` to `--neutral-800`) are available
- **AND** the primary color variable (`--primary-300: #447BDA`) is available
- **AND** feedback variables (`--feedback-error-100`, etc.) are available

#### Scenario: Spacing variables available
- **WHEN** the application is loaded
- **THEN** spacing variables (`--spacing-xs` to `--spacing-xl`) are available
- **AND** border-radius variables (`--radius-sm`, `--radius-md`, `--radius-lg`) are available

### Requirement: Inter Typography
The system SHALL use the Inter font as the default font for the entire interface.

#### Scenario: Inter font applied
- **WHEN** any SAG-WEB page is loaded
- **THEN** the Inter font is applied to body and all text elements
- **AND** the font is loaded via Google Fonts CDN

### Requirement: Input Styling
The system SHALL apply Vision visual styles to form fields (inputs, selects, textareas).

#### Scenario: Input with Vision style
- **WHEN** an input field is rendered
- **THEN** the input has border-radius of 6px
- **AND** the border uses color `--neutral-300`
- **AND** the background is `--neutral-white`
- **AND** the text uses color `--neutral-800`

#### Scenario: Input in focus state
- **WHEN** an input receives focus
- **THEN** the border changes to color `--primary-300`
- **AND** a smooth transition is applied

#### Scenario: Input in error state
- **WHEN** an input is in error state
- **THEN** the border changes to color `--feedback-error-100`
- **AND** the help text displays the error message in the same color

#### Scenario: Input in disabled state
- **WHEN** an input is disabled
- **THEN** the background changes to `--neutral-100`
- **AND** the cursor indicates it is not interactive

### Requirement: Button Styling
The system SHALL apply Vision visual styles to buttons.

#### Scenario: Primary button
- **WHEN** a primary button is rendered
- **THEN** the background is `--primary-300`
- **AND** the text is `--neutral-white`
- **AND** the border-radius is 6px

#### Scenario: Primary button on hover
- **WHEN** user hovers over a primary button
- **THEN** the background darkens to `--primary-400`
- **AND** a smooth 150ms transition is applied

#### Scenario: Secondary button
- **WHEN** a secondary button is rendered
- **THEN** the background is `--neutral-white`
- **AND** the border is `--neutral-300`
- **AND** the text is `--neutral-800`

### Requirement: Container Styling
The system SHALL apply Vision visual styles to form containers.

#### Scenario: Form container with Vision style
- **WHEN** a form container is rendered
- **THEN** the border-radius is 16px
- **AND** the background is `--neutral-white`
- **AND** the shadow/border follows the Vision pattern

#### Scenario: Bevel group with Vision style
- **WHEN** a field grouping (bevel-group) is rendered
- **THEN** the border uses color `--neutral-200`
- **AND** the border-radius is appropriate for the context
- **AND** the group title uses color `--neutral-600`

### Requirement: Grid Styling
The system SHALL apply Vision visual styles to the query grid.

#### Scenario: Grid header
- **WHEN** the query grid is rendered
- **THEN** the header uses background `--neutral-100`
- **AND** the header text uses color `--neutral-700`
- **AND** the font is Inter with weight 600

#### Scenario: Grid rows
- **WHEN** grid rows are rendered
- **THEN** alternating rows have slightly different background
- **AND** the bottom border uses `--neutral-200`

#### Scenario: Grid row on hover
- **WHEN** user hovers over a grid row
- **THEN** the background changes to `--primary-100`
- **AND** a smooth transition is applied

#### Scenario: Grid row selected
- **WHEN** a grid row is selected
- **THEN** the background is `--primary-100`
- **AND** the left border uses `--primary-300`

### Requirement: Tab Styling
The system SHALL apply Vision visual styles to navigation tabs.

#### Scenario: Active tab
- **WHEN** a tab is active
- **THEN** the text uses color `--primary-300`
- **AND** there is a visual indicator (bottom border) in `--primary-300`
- **AND** the tab border-radius is 6px

#### Scenario: Inactive tab
- **WHEN** a tab is inactive
- **THEN** the text uses color `--neutral-600`
- **AND** there is no selection indicator

#### Scenario: Tab on hover
- **WHEN** user hovers over an inactive tab
- **THEN** the text changes to a darker color
- **AND** a smooth transition is applied

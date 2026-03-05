## ADDED Requirements

### Requirement: Theme Selector
The app SHALL display a row of circular theme previews. Each circle SHALL be split
vertically: left half shows text color, right half shows background color. Selecting
a theme SHALL update all cards instantly.

#### Scenario: User selects a theme
- **WHEN** the user taps a theme circle
- **THEN** all cards re-render with the new theme's text and background colors

#### Scenario: Theme selection animation
- **WHEN** the user taps a theme circle
- **THEN** the circle plays a spring scale animation: 1.0 → 1.1 → 1.0 over ~0.25s

### Requirement: Theme Persistence
The last selected theme SHALL be persisted to UserDefaults so it is restored when
the user shares another note in a subsequent session.

#### Scenario: Theme restored on next session
- **WHEN** the app launches with new shared text after a previous session
- **THEN** the previously selected theme is pre-applied to the new cards

### Requirement: Font Family Selector
The app SHALL provide a font family selector offering 7 fonts: Instrument (default),
Mona, Georgia, Helvetica Neue, Cambria, Courier New, Liberation Mono. Selecting a
font SHALL re-render all cards.

#### Scenario: User changes font family
- **WHEN** the user selects a different font from the selector
- **THEN** all cards re-render using the new font family

### Requirement: Font Size Control
The app SHALL provide increase and decrease font size buttons. These adjust a multiplier
applied to the base font size. Users SHALL NOT see numeric values. Icons SHALL use
Lucide `a-arrow-up` (increase) and `a-arrow-down` (decrease).

#### Scenario: User increases font size
- **WHEN** the user taps the increase button
- **THEN** the font size multiplier increases and all cards re-render with larger text

#### Scenario: User decreases font size
- **WHEN** the user taps the decrease button
- **THEN** the font size multiplier decreases and all cards re-render with smaller text

### Requirement: Font Persistence
The last selected font family SHALL be persisted to UserDefaults and restored on the
next session.

#### Scenario: Font restored on next session
- **WHEN** the app launches with new shared text
- **THEN** the previously selected font family is pre-applied

## MODIFIED Requirements

### Requirement: Navigation Bar Branding
The app navigation bar SHALL display the logo image ("logo_transparent") centered as the principal toolbar item at a maximum height of 40pt, rather than a text title.

#### Scenario: Logo appears in nav bar
- **WHEN** the main screen is visible
- **THEN** the navigation bar shows the logo image centered, not the text "Silver Horn"

### Requirement: Card Aspect Ratio
Cards SHALL render with a landscape 5:4 aspect ratio (wider than tall). The preview in the carousel and the SkeletonCardView SHALL both use this ratio.

#### Scenario: Card is wider than tall
- **WHEN** a card is displayed in the carousel
- **THEN** its width is greater than its height (ratio 5:4)

### Requirement: Controls Layout
The main screen controls SHALL be arranged in a vertically scrollable VStack with Divider separators, in this order: carousel, action buttons row, theme selector, font controls. Each row SHALL have a minimum height of 56pt via padding (not fixed frame).

#### Scenario: Controls scroll below carousel
- **WHEN** the user scrolls the main content
- **THEN** the theme selector and font controls scroll up while the Share bar remains fixed

### Requirement: Persistent Share Bar
A Share button SHALL be pinned to the bottom safe area using `.safeAreaInset(edge: .bottom)` with an `.ultraThinMaterial` background. It SHALL remain visible while the user scrolls the controls. It SHALL use `.buttonStyle(.borderedProminent)` and `.controlSize(.large)`.

#### Scenario: Share bar stays visible during scroll
- **WHEN** the user scrolls the controls area
- **THEN** the Share bar remains visible at the bottom of the screen

### Requirement: Action Buttons Row
Below the carousel and above the theme selector, there SHALL be a row containing: Edit (targets current carousel card, `.bordered`), Save (saves current card only, `.bordered`), and Save All (saves all cards, `.bordered`, visible only when count > 1).

#### Scenario: Edit targets visible card
- **WHEN** the user taps Edit
- **THEN** the TextEditModal opens for the card currently visible in the carousel

#### Scenario: Save targets visible card
- **WHEN** the user taps Save
- **THEN** only the currently visible card image is saved to the photo library

#### Scenario: Save All hidden for single card
- **WHEN** only one card exists
- **THEN** the Save All button is not visible

### Requirement: Theme Circle Size
Theme selector circles SHALL have a diameter of 33pt (down from 44pt).

#### Scenario: Theme circles are compact
- **WHEN** the theme selector row is displayed
- **THEN** each circle measures 33pt in diameter

### Requirement: Font Controls Row Height
The FontControls row SHALL have a minimum height of 56pt via `.frame(minHeight: 56)` combined with horizontal padding of 24pt and vertical padding of 8pt. Size-button labels and the Menu label SHALL expand to fill the row height.

#### Scenario: Font controls fill touch area
- **WHEN** the font controls row is displayed
- **THEN** the tappable area spans the full row height

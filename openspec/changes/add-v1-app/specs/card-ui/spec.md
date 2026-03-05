## ADDED Requirements

### Requirement: Card Carousel
Cards SHALL be displayed in a horizontal paging carousel with snapping scroll behaviour.
A row of page indicator dots SHALL appear below the carousel.

#### Scenario: Swiping between cards
- **WHEN** the user swipes left or right
- **THEN** the carousel snaps to the next or previous card with paging behaviour

#### Scenario: Page dots reflect position
- **WHEN** the user navigates to a card
- **THEN** the corresponding page dot is highlighted

### Requirement: Skeleton Loading
When cards first load, placeholder skeleton cards SHALL appear immediately while
rendering completes. Skeleton cards SHALL match card dimensions and display a subtle
shimmer. Rendered images SHALL replace skeletons as they become available.

#### Scenario: Initial load skeleton display
- **WHEN** the app receives shared text and begins rendering
- **THEN** skeleton placeholder cards appear instantly in the carousel before any UIImage is ready

#### Scenario: Skeleton replaced by rendered card
- **WHEN** a card's UIImage snapshot is ready
- **THEN** the skeleton for that card is replaced with the rendered image

### Requirement: Card Shadow
Preview cards in the carousel SHALL display a drop shadow (radius 12, vertical offset 6,
opacity ~0.12) to visually separate them from the UI background. Exported images SHALL
NOT contain the shadow.

#### Scenario: Shadow visible in preview
- **WHEN** a card is displayed in the carousel
- **THEN** a drop shadow is rendered around the card view

#### Scenario: Exported image has no shadow
- **WHEN** a card is exported as an image
- **THEN** the resulting UIImage contains no shadow

### Requirement: Card Deletion
Each card SHALL display an X button in the top-right corner. Tapping it SHALL remove
the card immediately with no confirmation. A minimum of 1 card SHALL always remain.

#### Scenario: Delete one of many cards
- **WHEN** the user taps the X button on a card when more than 1 card exists
- **THEN** the card is removed immediately and the carousel updates

#### Scenario: Attempt to delete the last card
- **WHEN** only 1 card remains and the user taps its X button
- **THEN** nothing happens; the card is not removed

### Requirement: Empty State
When the app launches without shared text, an empty state message SHALL be displayed
instead of the carousel.

#### Scenario: Direct app launch with no pending text
- **WHEN** the app is opened directly without shared text
- **THEN** the message "Share text from Notes to create social cards." is displayed and no carousel is shown

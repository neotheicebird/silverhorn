## ADDED Requirements

### Requirement: Paragraph Splitting
The app SHALL split input text into paragraphs using `"\n\n"` as the delimiter. Each
paragraph SHALL be trimmed of surrounding whitespace. Empty paragraphs SHALL be
discarded.

#### Scenario: Standard paragraph split
- **WHEN** input text contains multiple paragraphs separated by double newlines
- **THEN** the app produces one card per non-empty trimmed paragraph

#### Scenario: Empty paragraphs discarded
- **WHEN** the input text contains consecutive blank lines producing empty segments
- **THEN** those empty segments are silently dropped and do not produce cards

### Requirement: Paragraph Count Limit
The app SHALL support a maximum of 8 paragraphs per session. If the input yields more
than 8 paragraphs, a selection modal SHALL be presented.

#### Scenario: 8 or fewer paragraphs
- **WHEN** parsing produces 8 or fewer paragraphs
- **THEN** all paragraphs are immediately converted to cards with no modal shown

#### Scenario: More than 8 paragraphs
- **WHEN** parsing produces more than 8 paragraphs
- **THEN** the paragraph selector modal is presented with all paragraphs listed and the first 8 pre-selected

### Requirement: Paragraph Selector Modal
When more than 8 paragraphs exist, the app SHALL present a scrollable modal with
radio-style selection circles. The user MAY select up to 8 paragraphs. Confirming
the selection converts the chosen paragraphs into cards.

#### Scenario: User selects exactly 8 paragraphs and confirms
- **WHEN** the user has 8 paragraphs selected and taps Confirm
- **THEN** the modal dismisses and the 8 selected paragraphs become cards

#### Scenario: User attempts to select more than 8
- **WHEN** 8 paragraphs are already selected and the user taps an unselected paragraph
- **THEN** the tap is ignored and the selection remains unchanged

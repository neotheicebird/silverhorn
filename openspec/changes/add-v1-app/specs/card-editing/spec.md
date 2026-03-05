## ADDED Requirements

### Requirement: Per-Card Text Editing
Each card SHALL display an edit icon below the card. Tapping it SHALL open a modal
text editor for that card's paragraph. The editor SHALL enforce a single paragraph:
line breaks are NOT permitted. Saving SHALL update the card text and trigger a
re-render. Cancelling SHALL discard all changes.

#### Scenario: User edits and saves a card
- **WHEN** the user taps the edit icon, modifies text, and taps Save
- **THEN** the modal closes, the card text is updated, and a re-render is triggered for that card only

#### Scenario: User cancels editing
- **WHEN** the user taps the edit icon, modifies text, and taps Cancel
- **THEN** the modal closes and the card text remains unchanged

#### Scenario: Line break attempt blocked
- **WHEN** the user attempts to insert a line break in the text editor
- **THEN** the line break is not inserted; the text remains single-paragraph

## ADDED Requirements

### Requirement: Repeated Share Rendering Trigger
When new shared text is ingested, the app SHALL trigger card rendering even if the resulting number of cards is unchanged from the previous session.

#### Scenario: Same note shared repeatedly
- **WHEN** a user shares the same note content to Silverhorn multiple times in sequence
- **THEN** newly created cards transition from skeleton placeholders to rendered images for each share event

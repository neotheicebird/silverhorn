## MODIFIED Requirements

### Requirement: Card Output Dimensions
Cards SHALL be rendered at landscape 5:4 dimensions. The logical render size SHALL be 675×540pt, producing a 1350×1080px exported image at @2x. The HTMLTemplateBuilder constants SHALL be `cardWidthPt = 675`, `cardHeightPt = 540`.

#### Scenario: Exported image is landscape
- **WHEN** a card image is exported
- **THEN** the image dimensions are 1350px wide × 1080px tall

### Requirement: Card Text Width
The `.text` CSS class SHALL use `width: 80%` (not `max-width: 80%`) so the text element always occupies its full allocated horizontal space rather than shrinking to content width.

#### Scenario: Text fills allocated width
- **WHEN** a short text paragraph is rendered
- **THEN** the text block spans 80% of the card width, not less

## ADDED Requirements

### Requirement: WKWebView Card Rendering
The app SHALL render each card by loading an HTML/CSS template into an off-screen
`WKWebView` and capturing a snapshot as a `UIImage`. The output image SHALL be
1080×1350 pixels (4:5 portrait). Card layout SHALL use CSS flexbox with center-aligned
text, 120px padding on all sides, and a maximum text width of 80% of card width.

#### Scenario: Card renders successfully
- **WHEN** a card's text, theme, and font are set
- **THEN** the WKWebView loads the HTML template, completes navigation, and produces a 1080×1350px UIImage snapshot

#### Scenario: Custom font in WKWebView
- **WHEN** a custom font (e.g. Instrument, Mona) is selected
- **THEN** the font is injected into the HTML via a base64-encoded `@font-face` declaration so it renders correctly in the isolated WebView context

### Requirement: Font Scaling
The app SHALL render card text starting at 72px. If the text overflows the card bounds,
the font size SHALL be reduced in 2px steps until it fits or reaches 36px. At 36px, if
overflow remains, text SHALL be truncated with an ellipsis "…".

#### Scenario: Short text fits at base size
- **WHEN** the paragraph text fits within the card at 72px
- **THEN** the card renders at 72px with no truncation

#### Scenario: Long text requires scaling
- **WHEN** the paragraph text overflows at 72px
- **THEN** the font is reduced by 2px steps until text fits, stopping at a minimum of 36px

#### Scenario: Text still overflows at minimum size
- **WHEN** the paragraph text still overflows at 36px
- **THEN** the text is truncated with "…" at the overflow point

### Requirement: Render Cache and Debounce
Rendered `UIImage` outputs SHALL be cached in memory keyed by card ID. Any change to
text, theme, or font SHALL invalidate the affected cache entries and trigger a re-render
after a 300ms debounce.

#### Scenario: Rapid theme switching
- **WHEN** the user switches themes multiple times within 300ms
- **THEN** only one re-render is triggered after the last change, using the final theme

#### Scenario: Single card text edit
- **WHEN** the user saves an edit to one card's text
- **THEN** only that card's cache entry is invalidated and re-rendered; other cards are unaffected

### Requirement: Emoji Rendering
Card text SHALL render emoji correctly regardless of the selected font. A CSS font-family
fallback stack ending with `"Apple Color Emoji", sans-serif` SHALL be applied.

#### Scenario: Emoji in text with custom font
- **WHEN** the selected font is Instrument and the paragraph contains emoji
- **THEN** the emoji renders using Apple Color Emoji and the remaining text uses Instrument

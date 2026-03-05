## ADDED Requirements

### Requirement: Share Extension Text Capture
The Share Extension SHALL appear as a share target in the iOS share sheet and capture
plain text shared from any app (primarily Apple Notes). Formatting SHALL be stripped
except for emoji characters.

#### Scenario: Text shared from Notes
- **WHEN** a user selects "Silver Horn" from the iOS share sheet with plain or rich text
- **THEN** the extension extracts the plain text, strips all formatting except emoji, stores it in the App Groups shared container under key "pendingSharedText", launches the main app via the `silverhorn://open` URL scheme, and dismisses the extension

#### Scenario: Non-text content shared
- **WHEN** a user shares content that contains no plain text (e.g. image only)
- **THEN** the extension completes without writing to shared storage and dismisses without launching the main app

### Requirement: App Groups IPC
The Share Extension and main app SHALL communicate via a shared `UserDefaults` suite
bound to the App Groups container identifier. The main app SHALL read and clear
`"pendingSharedText"` on launch via the custom URL scheme.

#### Scenario: Main app receives shared text
- **WHEN** the main app is launched via `silverhorn://open`
- **THEN** it reads `"pendingSharedText"` from the shared UserDefaults suite, clears the key, and passes the text to the paragraph parser

#### Scenario: Main app launched directly (no shared text)
- **WHEN** the main app is opened directly without a pending share
- **THEN** it finds no `"pendingSharedText"` and displays the empty state

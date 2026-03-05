## ADDED Requirements

### Requirement: Save to Photo Library
The app SHALL save all rendered card images to the user's camera roll using
`PHPhotoLibrary`. Photo library add permission SHALL be requested before the first
save. If permission is denied, an alert SHALL be shown with a link to Settings.

#### Scenario: User saves cards with permission granted
- **WHEN** the user taps "Save to Library" and photo library permission is granted
- **THEN** all rendered card images are saved to the camera roll and a success confirmation is shown

#### Scenario: Permission not yet granted
- **WHEN** the user taps "Save to Library" and permission has not been requested
- **THEN** the system permission dialog is shown; if granted, saving proceeds

#### Scenario: Permission denied
- **WHEN** the user taps "Save to Library" and permission is denied
- **THEN** an alert explains the limitation and offers a deep link to the app's Settings page

### Requirement: Share via iOS Share Sheet
The app SHALL present an `UIActivityViewController` containing all rendered card images
when the user taps "Share".

#### Scenario: User shares cards
- **WHEN** the user taps Share
- **THEN** the iOS share sheet is presented with all card images available for sharing to any compatible app

### Requirement: Export Progress Indicator
While images are being collected for export (save or share), the app SHALL display a
`ProgressView` spinner with the text "Preparing images…" to prevent perceived freezing.

#### Scenario: Export in progress
- **WHEN** the user initiates a save or share action
- **THEN** a progress indicator with "Preparing images…" is shown until the operation completes or the share sheet appears

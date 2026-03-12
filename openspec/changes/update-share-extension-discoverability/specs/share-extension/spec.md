## ADDED Requirements

### Requirement: Notes-Compatible Share Activation
The share extension SHALL be discoverable and eligible in the iOS share sheet when the shared payload from Apple Notes contains text-compatible item providers. Activation rules SHALL support `public.text` and `public.plain-text` for v1.

#### Scenario: Sharing a text note from Apple Notes
- **WHEN** a user opens a note in Apple Notes, taps Share, and opens the app list (including "More" if needed)
- **THEN** Silverhorn is available as a share target for text note content

#### Scenario: Notes provides text type identifiers
- **WHEN** the extension receives Notes share items with `public.text` or `public.plain-text`
- **THEN** the extension activation rule matches and allows user selection of Silverhorn

### Requirement: Share Extension Build Configuration Validity
The share extension SHALL be configured for App Store builds with `NSExtensionPointIdentifier` set to `com.apple.share-services`, embedded in the host app, included in the active build scheme, deployment-target compatible with the host app, and correctly signed with valid bundle identifiers.

#### Scenario: App Store build configuration check
- **WHEN** release configuration is reviewed before submission
- **THEN** extension point, embedding, scheme membership, deployment targets, bundle identifiers, and signing are all valid for distribution

### Requirement: Fresh Install Discoverability Verification
Before App Store resubmission, the product team SHALL verify on a fresh install that Silverhorn appears in the Notes share sheet and accepts shared text input.

#### Scenario: Fresh install from scratch
- **WHEN** the app is deleted, reinstalled, and a note is shared from Apple Notes
- **THEN** Silverhorn appears in the share options (directly or under "More") and launches its text-processing flow

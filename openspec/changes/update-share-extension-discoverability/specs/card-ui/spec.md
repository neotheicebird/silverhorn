## ADDED Requirements

### Requirement: Educational First-Launch Onboarding
On first direct launch, the app SHALL present a dismissible educational onboarding screen with: a welcome title, short product description, three feature rows with icons, and a Continue button. The screen SHALL be shown only once per install using `@AppStorage("hasSeenOnboarding")`.

#### Scenario: First direct launch after install
- **WHEN** a user opens the app directly for the first time
- **THEN** onboarding appears with title "Welcome to Silverhorn", three icon + text feature rows, and a Continue button

#### Scenario: Dismiss onboarding
- **WHEN** the user taps Continue
- **THEN** `hasSeenOnboarding` is set to true and onboarding is dismissed

#### Scenario: Subsequent direct launch
- **WHEN** a user reopens the app after dismissing onboarding
- **THEN** onboarding is not shown again automatically

### Requirement: Share-Extension Launch Bypasses Onboarding
The app SHALL skip onboarding when launch is triggered from the share extension and shared text is already pending.

#### Scenario: First launch from share extension
- **WHEN** shared text is pending from Notes share flow and the app opens from the extension
- **THEN** onboarding is not presented and the user is taken directly to card generation flow

### Requirement: Minimal Main Screen Help Surface
The main screen SHALL keep Help accessible from the top-right `?` icon and SHALL NOT show a separate "How to use" button in the empty state.

#### Scenario: Empty state stays minimal
- **WHEN** the app shows the empty state
- **THEN** it displays the workflow message without an extra "How to use" button

#### Scenario: Help remains accessible
- **WHEN** the user taps the top-right `?` icon
- **THEN** a help modal opens with onboarding-aligned workflow guidance

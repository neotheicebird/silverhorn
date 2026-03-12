# Change: Improve Discoverability With Educational Onboarding

## Why
App Store review feedback highlighted share-extension discoverability issues. We already introduced onboarding/help, but the current UX is more tutorial-like than needed. Silverhorn should orient users quickly with a calm, Apple-style educational onboarding surface and keep the main screen uncluttered.

## What Changes
- Keep first-launch onboarding, but redesign it as an educational onboarding surface with concise icon + text capability rows.
- Show onboarding only once via `@AppStorage("hasSeenOnboarding")` and skip onboarding entirely when app launch is driven by shared text from the share extension.
- Keep Help accessible from the top-right `?` icon and align help copy with onboarding messaging.
- Remove redundant “How to use” action from the main empty state to keep the interface minimal.
- Preserve existing share-extension activation/configuration and repeated-share rendering reliability work.

## Impact
- Affected specs: share-extension, card-ui, card-rendering
- Affected code: `SilverHorn/SilverHornApp.swift`, `SilverHorn/UI/MainScreen.swift`, `SilverHorn/AppState.swift`
- QA impact: requires fresh-install checks for first-launch onboarding and share-extension launch bypass behavior

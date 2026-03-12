# Tasks: update-share-extension-discoverability

## 1. Share Extension Activation and Configuration Audit
- [x] 1.1 Review `NSExtensionActivationRule` and confirm Notes-shared text types are covered (`public.text`, `public.plain-text`).
- [x] 1.2 Keep activation logic unchanged unless audit finds a concrete mismatch with Notes-provided item providers.
- [x] 1.3 Verify extension point identifier is `com.apple.share-services`.
- [x] 1.4 Verify share extension target embedding in main app target and inclusion in the active build scheme.
- [x] 1.5 Verify deployment target compatibility between app and extension targets.
- [x] 1.6 Verify bundle identifiers and signing settings are valid for App Store distribution.

## 2. Educational Onboarding and Help
- [x] 2.1 Replace tutorial-like onboarding with educational layout: title, description, three icon + text feature rows, Continue button.
- [x] 2.2 Keep first-launch gating with `@AppStorage("hasSeenOnboarding")`.
- [x] 2.3 Skip onboarding when app launch is driven by shared text from extension.
- [x] 2.4 Match Continue button visual style to main Share button styling.
- [x] 2.5 Keep Help modal reachable from top-right `?` and align help content with onboarding messaging.
- [x] 2.6 Remove empty-state “How to use” button from main screen.

## 3. Repeated Share Rendering Reliability
- [x] 3.1 Reproduce repeated-share skeleton-stall bug by sharing the same note multiple times.
- [x] 3.2 Ensure shared text ingestion explicitly triggers rendering after parsing, even when card count is unchanged.
- [ ] 3.3 Verify repeated shares of identical note content render to completed cards instead of indefinite skeleton state.

## 4. Validation Before Resubmission
- [ ] 4.1 Perform fresh-install test on device: uninstall app, install fresh build, open Notes, share note text.
- [ ] 4.2 Verify Silverhorn appears in the Notes share sheet directly or via "More".
- [ ] 4.3 Verify extension activates and passes text payload into app ingestion path.
- [ ] 4.4 Verify onboarding appears only on direct first launch and is skipped when opening via share extension.
- [x] 4.5 Capture reviewer-facing verification notes for App Store Connect submission metadata.

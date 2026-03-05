# Tasks: add-v1-app

## 0. Project Setup
- [ ] 0.1 Create Xcode project `SilverHorn` (iOS 17+, SwiftUI, iPhone only, no tests target)
- [ ] 0.2 Add `SilverHornShareExtension` target (Share Extension template)
- [ ] 0.3 Configure App Groups entitlement on both targets (`group.club.skape.silverhorn`)
- [ ] 0.4 Add custom URL scheme `silverhorn` to main app `Info.plist`
- [ ] 0.5 Add `NSPhotoLibraryAddUsageDescription` to main app `Info.plist`
- [ ] 0.6 Set deployment target iOS 17.0, device family iPhone only on both targets
- [ ] 0.7 Add `Assets/fonts/`, `Assets/html/`, `Assets/css/`, `Config/` folders to project
- [ ] 0.8 Add app icon to Xcode asset catalog using `assets/logo.png` as source
- [ ] 0.9 Verify clean build on iPhone 12 (no code yet — just empty targets)

## 1. Config & Models
- [x] 1.1 Create `Config/themes.json` with 4 themes (Mauve, Mist, Olive, Carbon)
- [x] 1.2 Create `Models/ThemeModel.swift` — `Codable` struct + JSON loader
- [x] 1.3 Create `Models/FontModel.swift` — enum of 7 fonts with display name + CSS name
- [x] 1.4 Create `Models/ParagraphModel.swift` — `Identifiable` struct (id, text, isSelected)
- [x] 1.5 Create `Models/CardModel.swift` — `Identifiable` struct (id, paragraph, cached UIImage?)

## 2. App State
- [x] 2.1 Create `AppState.swift` — `@Observable` + `@MainActor` class holding: cards, selectedTheme, selectedFont, fontSizeMultiplier
- [x] 2.2 Add UserDefaults read/write for last theme + font (optional persistence, spec §24)

## 3. Share Extension
- [x] 3.1 Implement `ShareViewController.swift` — extract plain text from `NSExtensionItem`
- [x] 3.2 Strip formatting, keep emoji only (spec §4)
- [x] 3.3 Write text to shared `UserDefaults` suite under key `"pendingSharedText"`
- [x] 3.4 Call `openURL("silverhorn://open")` to launch main app
- [x] 3.5 Call `extensionContext?.completeRequest` to dismiss extension

## 4. Main App Launch & Text Ingestion
- [x] 4.1 In `SilverHornApp.swift`, handle `silverhorn://open` via `.onOpenURL`
- [x] 4.2 Read and clear `pendingSharedText` from shared UserDefaults
- [x] 4.3 Pass raw text to paragraph parser

## 5. Paragraph Parsing
- [x] 5.1 Create `Services/ParagraphParser.swift` — split on `"\n\n"`, trim, drop empty
- [x] 5.2 If ≤8 paragraphs: map directly to `CardModel` array
- [x] 5.3 If >8 paragraphs: trigger `ParagraphSelectorModal`

## 6. Paragraph Selector Modal
- [x] 6.1 Create `Modals/ParagraphSelectorModal.swift` — scrollable list, radio-style circles
- [x] 6.2 Pre-select first 8 paragraphs (spec §5)
- [x] 6.3 Enforce max 8 selected; disable further selection when limit reached
- [x] 6.4 Confirm button maps selected paragraphs → `CardModel` array

## 7. HTML Template & Rendering
- [x] 7.1 CSS inlined in HTMLTemplateBuilder (no external card.css needed — WKWebView is sandboxed)
- [x] 7.2 Create `Assets/html/card.html` — template with `{{STYLE_BLOCK}}` and `{{TEXT}}` tokens
- [x] 7.3 Create `Rendering/HTMLTemplateBuilder.swift` — substitutes tokens, injects `@font-face` as base64
- [x] 7.4 Create `Rendering/CardRenderer.swift` — off-screen `WKWebView`, sequential render queue
- [x] 7.5 Implement font scaling in JS: check overflow → reduce by 2px → stop at 36px → truncate with "…"
- [x] 7.6 Implement `WKNavigationDelegate.didFinish` → `takeSnapshot` → return `UIImage`
- [x] 7.7 Wire 300ms debounce using `DispatchWorkItem` cancellation

## 8. Card UI — CarouselView
- [x] 8.1 Create `UI/CardView.swift` — displays `UIImage` in 4:5 ratio with drop shadow (spec §18)
- [x] 8.2 Create `UI/SkeletonCardView.swift` — shimmer placeholder matching card dimensions
- [x] 8.3 Create `UI/CardCarousel.swift` — `TabView` paging, page dots
- [x] 8.4 Show skeleton cards immediately on load; replace with rendered images as they complete (spec §17)
- [x] 8.5 Add X delete button (top-right); enforce minimum 1 card (spec §13)

## 9. Theme & Font Controls
- [x] 9.1 Create `UI/ThemeSelector.swift` — row of circular split-color previews (left=text, right=bg)
- [x] 9.2 Implement tap → scale spring animation 1.0→1.1→1.0 (spec §19)
- [x] 9.3 Theme selection updates all cards instantly (triggers re-render debounce)
- [x] 9.4 Create `UI/FontControls.swift` — font family picker + size decrease/increase buttons (spec §9)
- [x] 9.5 Font/size change triggers re-render debounce on all cards

## 10. Card Editing
- [x] 10.1 Create `Modals/TextEditModal.swift` — single-line text editor (no line breaks, spec §11)
- [x] 10.2 Edit icon below each card opens modal
- [x] 10.3 Cancel discards changes; Save updates card text and triggers re-render

## 11. Main Screen Layout
- [x] 11.1 Create `UI/MainScreen.swift` — assembles carousel, theme selector, font controls, export buttons
- [x] 11.2 Implement empty state view: "Share text from Notes to create social cards." (spec §23)
- [x] 11.3 Export toolbar: "Share" and "Save to Library" buttons

## 12. Image Export
- [x] 12.1 Create `Services/ImageExportService.swift` — collects all rendered `UIImage` from cache
- [x] 12.2 Show `ProgressView` + "Preparing images…" while gathering (spec §20)
- [x] 12.3 **Save to Library:** `PHPhotoLibrary` batch save with permission request
- [x] 12.4 **Share:** present `UIActivityViewController` with image array
- [x] 12.5 Handle photo library permission denial gracefully (completion callback; settings link TODO in polish)

## 13. Polish & Acceptance Criteria Verification
- [ ] 13.1 Verify Silver Horn appears in iOS share menu (Notes → Share → Silver Horn)
- [ ] 13.2 Verify text from Notes imports and parses correctly
- [ ] 13.3 Verify all 8 acceptance criteria in project-spec.txt §31 pass on iPhone 12
- [ ] 13.4 Verify exported images have no shadow and are exactly 1080×1350px
- [ ] 13.5 Verify memory stays under 200MB with 8 cards loaded (spec §27)
- [ ] 13.6 Verify initial render of 8 cards completes in <1.5s on iPhone 12 (spec §27)

## 14. TestFlight Build
- [ ] 14.1 Set correct bundle identifier and version (1.0, build 1)
- [ ] 14.2 Archive build in Xcode (Product → Archive)
- [ ] 14.3 Upload to App Store Connect using `APPLE_ID` + `APPLE_APP_SPECIFIC_PASSWORD`
- [ ] 14.4 Add iPhone 12 as TestFlight tester and install build

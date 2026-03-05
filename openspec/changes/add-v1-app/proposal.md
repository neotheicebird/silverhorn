# Change: Build Silver Horn v1 — Text-to-Social-Card iOS App

## Why

Silver Horn v1 is a greenfield iPhone app. No Xcode project exists yet. This change
implements the complete v1 feature set as defined in project-spec.txt: a Share Extension
that captures text, parses it into paragraphs, renders them as styled social media card
images (via WKWebView), and lets users export those images to their photo library or
iOS share sheet.

## What Changes

- **NEW** Xcode project with two targets: `SilverHorn` (main app) and `SilverHornShareExtension`
- **NEW** App Groups entitlement shared between both targets for IPC
- **NEW** Share Extension — captures text from iOS share sheet, stores in App Groups container, launches main app
- **NEW** Paragraph parsing — splits on `\n\n`, trims, max 8; selection modal when >8
- **NEW** Card rendering pipeline — `HTMLTemplateBuilder` → `WKWebView` → `UIImage` snapshot (1080×1350px, 4:5)
- **NEW** Font scaling — base 72px → minimum 36px with overflow truncation via "…"
- **NEW** Card carousel UI — horizontal paging scroll, page dots, skeleton loading, empty state
- **NEW** Theme selector — 4 themes from `Config/themes.json` (Mauve, Mist, Olive, Carbon) with animated selection
- **NEW** Font selector — 7 locally-bundled fonts; size controls (increase/decrease multiplier)
- **NEW** Card editing — per-card text edit modal (no line breaks); card deletion (min 1)
- **NEW** Image export — save to photo library (`PHPhotoLibrary`) and iOS share sheet with progress indicator
- **NEW** Optional UserDefaults persistence for last-used theme and font

## Impact

- Affected specs: share-extension, paragraph-parsing, card-rendering, card-ui, theme-font-controls, card-editing, image-export
- Affected code: entire codebase (greenfield)
- Requires: Xcode project creation, App Groups entitlement (`group.club.skape.silverhorn`), developer cert trusted on iPhone 12
- App icon: available at `assets/logo.png` — add to Xcode asset catalog
- Bundle ID: `club.skape.silverhorn` | URL scheme: `silverhorn://open`

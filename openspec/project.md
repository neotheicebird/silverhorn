# Project Context

## Purpose

Silver Horn is an iPhone-only iOS 17+ utility app that converts shared text (primarily from Apple Notes) into visually formatted social media card images. Users share text via the iOS share sheet, preview and edit cards, adjust theme/font, and export images to their photo library or share sheet.

## Tech Stack

- Swift / SwiftUI (iOS 17+)
- WKWebView (card rendering via HTML/CSS templates)
- App Groups (IPC between Share Extension and main app)
- PHPhotoLibrary (photo export)
- No third-party dependencies (minimize external packages)

## Project Conventions

### Code Style

- Swift naming conventions (camelCase for vars/functions, PascalCase for types)
- No third-party dependency unless strictly necessary and approved
- Prefer simple, direct implementations — avoid premature abstraction
- Comments only where logic is non-obvious

### Architecture Patterns

- MVVM-lite: SwiftUI views with lightweight view models
- Share Extension → App Groups shared container → Main App reads on launch
- Card rendering pipeline: Text → HTMLTemplateBuilder → WKWebView → UIImage snapshot
- Rendered images cached in memory; re-render debounced at 300ms
- Themes defined in `Config/themes.json` and loaded at runtime

File structure (§25 of project-spec.txt):
```
App/
  Extensions/ShareExtension/
  UI/           # SwiftUI views
  Modals/       # ParagraphSelectorModal, TextEditModal
  Rendering/    # CardRenderer, HTMLTemplateBuilder
  Models/       # ParagraphModel, ThemeModel, FontModel
  Services/     # ShareDataService, ImageExportService, PhotoLibraryService
  Assets/fonts/
  Assets/html/
  Assets/css/
  Config/themes.json
```

### Testing Strategy

- Manual testing on physical iPhone 12
- No automated test suite in v1
- Acceptance criteria defined in project-spec.txt §31

### Git Workflow

- Branch per feature/change
- Main branch: `main`
- Descriptive commit messages with context
- No force-push to main

## Domain Context

- Cards are 4:5 portrait (1080×1350px), center-aligned text, 120px padding all sides, max text width 80%
- Font scaling: base 72px → minimum 36px; overflow truncated with "…"
- Paragraph splitting on "\n\n", max 8 paragraphs; selection modal if >8
- 4 built-in themes (Mauve, Mist, Olive, Carbon) with text+bg hex colors
- Available fonts: Instrument (default), Mona, Georgia, Helvetica Neue, Cambria, Courier New, Liberation Mono — all stored locally in assets
- Shadow on preview cards only (radius 12, y-offset 6, opacity ~0.12); exported images must NOT include shadow
- Skeleton loading placeholders appear while cards render

## Important Constraints

- iPhone only — no iPad layout
- iOS 17 minimum
- No analytics, no login, no persistence (UserDefaults only for last theme/font selection)
- No cloud services — fully offline
- No watermark
- App must not generate or design the app icon (developer provides)
- No code implementation begins without an approved OpenSpec change proposal

## External Dependencies

- Apple TestFlight (distribution)
- App Groups entitlement shared between main app and Share Extension
- Environment variables for signing/upload: `APPLE_ID`, `APPLE_TEAM_ID`, `APPLE_APP_SPECIFIC_PASSWORD` (set in `~/.zshrc`)
- Test device: iPhone 12 (physical)
- Build/run script for physical device: planned, not yet created

# Design: Silver Horn v1

## Context

Greenfield iOS 17+ app. iPhone-only. No backend, no accounts, no analytics. The primary
constraint is that AI-assisted development must remain deterministic and auditable —
every architectural decision must trace back to project-spec.txt. Dependencies are
minimised to Swift standard library + Apple frameworks only.

## Goals / Non-Goals

- **Goals**
  - Two-target Xcode project (main app + share extension) sharing an App Group
  - WKWebView-based card rendering producing pixel-accurate 1080×1350px images
  - SwiftUI-first UI with minimal UIKit bridging (only where WKWebView requires it)
  - Fully offline; no network calls anywhere in the app
  - TestFlight-distributable build on first pass

- **Non-Goals**
  - iPad layout
  - Automated tests (v1 manual testing only on iPhone 12)
  - Watermarks, analytics, login, cloud sync
  - v2 features: gradients, textures, animations, author attribution, batch posting

---

## Decisions

### 1. Project Structure — Two Xcode Targets

**Decision:** Single `.xcodeproj` with two targets:
- `SilverHorn` — main SwiftUI app
- `SilverHornShareExtension` — `NSExtension` share extension

Both targets share the same App Group identifier: `group.club.skape.silverhorn`.

**Why:** iOS requires a separate extension bundle for share targets. App Groups is the
only supported IPC mechanism between an extension and its host app on iOS.

**Alternatives considered:**
- Universal Links deep-link launch: rejected — requires web server, not offline-safe.
- Clipboard as IPC: rejected — fragile, user clipboard gets polluted.

---

### 2. IPC — App Groups Shared Container

**Decision:** Share Extension writes received text to
`UserDefaults(suiteName: "group.club.skape.silverhorn")` under key `"pendingSharedText"`,
then calls `openURL` with a custom scheme (`silverhorn://open`) to launch the main app.
Main app reads and clears `pendingSharedText` on `onAppear`.

**Why:** Simplest reliable mechanism. No file I/O, no Keychain. UserDefaults shared suite
is atomic for single-value reads/writes.

---

### 3. Card Rendering — WKWebView Snapshot

**Decision:** Each card is rendered by loading an HTML string into an off-screen
`WKWebView` sized exactly 1080×1350 (logical: 540×675 @2x), then calling
`WKWebView.takeSnapshot(with:)` to produce a `UIImage`.

**Why:** spec §14 mandates WKWebView. HTML/CSS flexbox gives precise center-alignment,
word-wrap, and emoji rendering without manual CoreText layout. Font scaling logic
(72px → 36px, overflow "…") is implemented in JavaScript before snapshot.

**Font scaling approach:** Inject JS that checks `scrollHeight > clientHeight` after
render; if overflow, reduce `font-size` by 2px steps until 36px or fits; if still
overflows at 36px, set `text-overflow: ellipsis` + `overflow: hidden`.

**Alternatives considered:**
- Pure SwiftUI / CoreText rendering: rejected — complex emoji+font fallback logic,
  harder to match CSS flexbox centering precisely.
- PDFKit: rejected — overkill, no spec requirement for PDF.

---

### 4. Rendering Cache + Debounce

**Decision:** `CardRenderer` maintains an `[UUID: UIImage]` in-memory cache keyed by
card ID. Any state change (text edit, theme change, font change) invalidates affected
entries and schedules a re-render after a 300ms debounce (spec §16) using
`DispatchWorkItem` cancellation pattern.

**Why:** Prevents redundant WKWebView loads during rapid UI interaction (e.g. theme
swiping). Keeps memory bounded — cache is purged when app enters background.

---

### 5. Themes — Runtime JSON

**Decision:** `Config/themes.json` is bundled in the main app target. `ThemeModel`
loads it once at app start. The file defines an array of `{name, textColor, bgColor}`
objects. Adding a theme in v2 requires only editing JSON, not recompiling.

**Why:** spec §10 specifies themes.json explicitly. Decouples theme data from code.

**themes.json structure:**
```json
[
  { "id": "mauve",  "name": "Mauve",  "textColor": "#a79ea8", "bgColor": "#594c5b" },
  { "id": "mist",   "name": "Mist",   "textColor": "#9da8ab", "bgColor": "#4b585b" },
  { "id": "olive",  "name": "Olive",  "textColor": "#abab9c", "bgColor": "#5b5b4b" },
  { "id": "carbon", "name": "Carbon", "textColor": "#ffffff", "bgColor": "#0c0c09" }
]
```

---

### 6. Fonts — Locally Bundled

**Decision:** All fonts (Instrument, Mona) are added to `Assets/fonts/` and declared
in `Info.plist` under `UIAppFonts`. System fonts (Georgia, Helvetica Neue, Courier New)
are referenced by PostScript name. The HTML template references the font by CSS
`font-family` name passed as a parameter.

**Why:** spec §7 states fonts are stored locally. Avoids network dependency.

**Emoji fallback:** CSS `font-family` stack ends with `"Apple Color Emoji", sans-serif`
to ensure emoji renders correctly regardless of chosen font (spec §7).

---

### 7. State Management — SwiftUI @Observable / @State

**Decision:** Use Swift 5.9 `@Observable` macro for `AppState` (holds cards array,
selected theme, selected font, font size multiplier). No external state management
library (no Combine pipelines beyond `DispatchWorkItem` debounce).

**Why:** iOS 17 minimum allows `@Observable`. Keeps dependency count at zero.
App state is simple enough that a single observable root object suffices.

---

### 8. Shadow — Preview Only

**Decision:** Drop shadow (radius 12, y-offset 6, opacity 0.12) applied via SwiftUI
`.shadow()` modifier on the card container view only. `CardRenderer` renders into a
`WKWebView` with a plain white/transparent background — no shadow CSS — so snapshots
are clean (spec §18).

---

### 9. Export

**Decision:**
- **Save to Library:** `PHPhotoLibrary.shared().performChanges` with
  `PHAssetChangeRequest.creationRequestForAsset(from: image)`. Request photo library
  permission on first use with `NSPhotoLibraryAddUsageDescription`.
- **Share:** `UIActivityViewController` presented over the SwiftUI view via
  `UIViewControllerRepresentable`. If multiple images, pass array — iOS will handle
  what it can. No custom fallback needed for v1 (spec §21 notes this is acceptable).

---

## Risks / Trade-offs

| Risk | Mitigation |
|------|-----------|
| WKWebView snapshot timing (render not complete when snapshot taken) | Use `WKNavigationDelegate.didFinish` before calling `takeSnapshot` |
| Font not found in WKWebView (custom font unavailable in web context) | Load font via `@font-face` CSS with base64-encoded font data injected into HTML |
| App Groups entitlement misconfiguration (silent IPC failure) | Validate in Share Extension by reading back the written value before launching |
| >8 paragraphs selection modal UX confusion | First 8 pre-selected per spec §5; modal is scrollable with clear count indicator |

## Resolved

- **Bundle identifier:** `club.skape.silverhorn` — App Group: `group.club.skape.silverhorn`
- **App icon:** available at `assets/logo.png` — use as the basis for the Xcode asset catalog icon set (no manual step required before TestFlight build)
- **Custom URL scheme:** `silverhorn://open` confirmed

<!-- OPENSPEC:START -->
# OpenSpec Instructions

These instructions are for AI assistants working in this project.

Always open `@/openspec/AGENTS.md` when the request:
- Mentions planning or proposals (words like proposal, spec, change, plan)
- Introduces new capabilities, breaking changes, architecture shifts, or big performance/security work
- Sounds ambiguous and you need the authoritative spec before coding

Use `@/openspec/AGENTS.md` to learn:
- How to create and apply change proposals
- Spec format and conventions
- Project structure and guidelines

Keep this managed block so 'openspec update' can refresh the instructions.

<!-- OPENSPEC:END -->

# CLAUDE.md — Silver Horn

This file provides orientation for Claude instances working on this project.

---

## Project Summary

Silver Horn is an **iPhone-only iOS 17+ utility app** that converts shared text (primarily from Apple Notes) into formatted social media card images.

- No accounts, analytics, persistence, cloud services, or watermarks
- Functions entirely offline
- Distribution: TestFlight
- Devices: iPhone only (no iPad layout required)

---

## Architecture

### Rendering Pipeline

```
Share Extension
  → App Groups shared container
    → Main App (SwiftUI)
      → WKWebView
        → HTML/CSS template
          → UIImage snapshot (1080×1350px)
```

### Planned File Structure (§25)

```
App/
  Extensions/ShareExtension/

  UI/
    MainScreen.swift
    CardCarousel.swift
    CardView.swift
    ThemeSelector.swift
    FontControls.swift

  Modals/
    ParagraphSelectorModal.swift
    TextEditModal.swift

  Rendering/
    CardRenderer.swift
    HTMLTemplateBuilder.swift

  Models/
    ParagraphModel.swift
    ThemeModel.swift
    FontModel.swift

  Services/
    ShareDataService.swift
    ImageExportService.swift
    PhotoLibraryService.swift

  Assets/fonts/
  Assets/html/
  Assets/css/

  Config/themes.json
```

---

## Key Spec Constraints

| Constraint | Value |
|---|---|
| Max paragraphs per session | 8 (§5) |
| Card aspect ratio | 4:5 portrait (§6) |
| Card image dimensions | 1080×1350 px (§6) |
| Safe text padding | 120px all sides (§6) |
| Max text width | 80% of card width (§6) |
| Base font size | 72px (§8) |
| Minimum font size | 36px (§8) |
| Overflow handling | shrink to 36px, then truncate with "…" (§8) |
| Render debounce | 300ms (§16) |
| Initial render target | <1.5s for 8 cards (§27) |
| Memory target | <200MB (§27) |

### Themes (defined in `Config/themes.json`, §10)

| Name | Text | Background |
|---|---|---|
| Mauve | #a79ea8 | #594c5b |
| Mist | #9da8ab | #4b585b |
| Olive | #abab9c | #5b5b4b |
| Carbon | #ffffff | #0c0c09 |

### IPC Mechanism

Share Extension writes text to an **App Groups shared container**. The main app reads it on launch (§22).

### Rendering Notes

- Cards rendered via `WKWebView` → HTML template → snapshot → `UIImage`
- Rendered images cached in memory; re-render on edit with 300ms debounce (§16)
- Preview cards show drop shadow (radius 12, y-offset 6, opacity ~0.12); exported images must NOT include shadow (§18)

---

## Agent Rules

From `agent.md`:

- Follow `project-spec.txt` strictly
- Never change architecture without asking the user
- Prefer simple solutions
- Minimize dependencies

From `project-spec.txt` §30 (OpenSpec Workflow):

1. Generate specs via OpenSpec
2. Generate feature tasks
3. Review tasks with the human developer
4. Implement tasks sequentially

**No code implementation should begin without a reviewed task plan.**

Do not generate or design the app icon (§26). Add a manual reminder step in the task list for the developer to provide one before TestFlight build.

---

## Build & Run

**Status: Pre-implementation. No Xcode project exists yet.**

- iOS 17+, iPhone only
- When the project is created: use a two-target setup (main app + share extension) sharing an App Group entitlement
- Distribution target: TestFlight

**Test device: iPhone 12** (physical device, used for manual testing)

A physical device build/run workflow or script is planned but not yet created.

Environment variables already configured in `~/.zshrc`:
- `APPLE_ID`
- `APPLE_TEAM_ID`
- `APPLE_APP_SPECIFIC_PASSWORD`

These are available for use in build/sign/upload scripts without additional setup.

Before building, a developer must:
1. Create the Xcode project
2. Configure App Groups entitlement for both targets
3. Provide an app icon asset

# Change: UI Polish v1 — Visual Refinements

## Why
Post-testing feedback identified several visual issues in the v1 implementation: the navigation bar shows raw text instead of the app logo, cards render in portrait (4:5) instead of landscape (5:4), card text doesn't fill its allocated width, carousel dots overlap where the edit button was, and the controls area lacks a persistent Share bar with proper layout hierarchy.

## What Changes
- Navigation bar: replace text title with logo image (40pt height)
- Card dimensions: swap to landscape 5:4 (1350×1080px exported), update all aspect ratio constants
- Card text CSS: `max-width: 80%` → `width: 80%` so text fills its allocated column
- Edit button: move out of CardView/carousel; placed in dedicated action row below carousel
- Layout: ScrollView with Divider-separated rows for action buttons, theme, and font controls
- Share button: persistent `.safeAreaInset(bottom)` bar with `.ultraThinMaterial` background
- Action row: Edit | Save | [Save All] with `.bordered` style; Save targets current carousel card
- Theme circles: diameter 44 → 33pt (25% smaller)
- Font controls: padding-based row height (`minHeight: 56`) so controls fill touch area

## Impact
- Affected specs: card-ui, card-rendering
- Affected code: MainScreen.swift, CardCarousel.swift, CardView.swift, SkeletonCardView.swift, ThemeSelector.swift, FontControls.swift, HTMLTemplateBuilder.swift, Assets.xcassets

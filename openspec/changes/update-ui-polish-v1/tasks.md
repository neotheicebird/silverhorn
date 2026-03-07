# Tasks: update-ui-polish-v1

## 0. Assets
- [x] 0.1 Create `logo_transparent.imageset` in Assets.xcassets with Contents.json (2x slot)
- [x] 0.2 Copy `assets/logo_transparent.png` into the imageset folder

## 1. Navigation Bar Logo
- [x] 1.1 Replace `.navigationTitle("Silver Horn")` with `.toolbar { ToolbarItem(.principal) { Image("logo_transparent") } }` in MainScreen.swift

## 2. HTML Card Landscape + Text Width Fix
- [x] 2.1 Swap `cardWidthPt` 540→675, `cardHeightPt` 675→540 in HTMLTemplateBuilder.swift
- [x] 2.2 Change CSS `max-width: 80%` → `width: 80%` in the text class
- [x] 2.3 Update file header comments to reflect 675×540pt / 1350×1080px landscape

## 3. CardView Landscape + Remove Edit Button
- [x] 3.1 Change `aspectRatio` constant: 4.0/5.0 → 5.0/4.0
- [x] 3.2 Remove `var onEdit: () -> Void` parameter
- [x] 3.3 Remove `// MARK: Edit Button` block (VStack second child)
- [x] 3.4 Remove wrapping VStack; GeometryReader is sole body content
- [x] 3.5 Update header comments

## 4. SkeletonCardView Landscape
- [x] 4.1 Change `aspectRatio`: 4.0/5.0 → 5.0/4.0

## 5. CardCarousel: Height Formula + Remove onEdit + Expose currentPage
- [x] 5.1 Remove `var onEdit: (CardModel) -> Void` and its usage in CardView init
- [x] 5.2 Fix `carouselHeight`: `cardWidth * (5.0 / 4.0)` → `cardWidth * (4.0 / 5.0)`
- [x] 5.3 Change `@State private var currentPage` → `@Binding var currentPage`

## 6. ThemeSelector Smaller Circles
- [x] 6.1 Change `private let diameter: CGFloat`: 44 → 33

## 7. FontControls Row Height
- [x] 7.1 Add `.frame(maxHeight: .infinity)` to both size-button labels
- [x] 7.2 Add `.frame(maxWidth: .infinity, maxHeight: .infinity)` to Menu label
- [x] 7.3 Replace `.padding(.horizontal)` with `.frame(minHeight: 56).padding(.horizontal, 24).padding(.vertical, 8)`

## 8. MainScreen Full Layout Restructure
- [x] 8.1 Add `@State private var currentCarouselPage: Int = 0`
- [x] 8.2 Replace `mainContent` with scrollable layout + `.safeAreaInset(bottom)` share bar
- [x] 8.3 Build `shareBar` computed var (`.borderedProminent`, `.ultraThinMaterial`)
- [x] 8.4 Build `actionButtonsRow` computed var (Edit | Save | Save All)
- [x] 8.5 Add `currentCard` computed var targeting `currentCarouselPage`
- [x] 8.6 Update `exportImages` to accept `singleIndex: Int? = nil`
- [x] 8.7 Remove `exportButtons` computed var

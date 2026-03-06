// MainScreen.swift
// Root screen of the Silver Horn app — assembles all UI components.
//
// LAYOUT (top to bottom in ScrollView):
// 1. CardCarousel        — horizontal paging cards + page dots
// 2. actionButtonsRow    — Edit | Save | [Save All]  (~56pt min height)
// 3. ThemeSelector row   — circular theme switcher   (~56pt min height)
// 4. FontControls row    — font family picker + size buttons
//
// safeAreaInset(bottom):
//   shareBar             — always visible; .ultraThinMaterial background
//
// EMPTY STATE (spec §23):
// When cards array is empty, a centred empty-state message is shown
// instead of the carousel and controls.
//
// MODAL PRESENTATION:
// - ParagraphSelectorModal: shown when >8 paragraphs are parsed
// - TextEditModal: shown when the user taps Edit in actionButtonsRow
//
// NOTE ON @Bindable:
// With @Observable + @Environment, we declare @Bindable as a view property
// to get $ bindings into AppState. It cannot be passed through function
// parameters — sub-views receive AppState via @Environment instead.

import SwiftUI

struct MainScreen: View {

    @Environment(AppState.self) private var appState

    // The card currently being edited (nil = no edit modal shown).
    @State private var editingCard: CardModel? = nil

    // Controls visibility of the export progress overlay (spec §20).
    @State private var isExporting: Bool = false

    // Tracks which carousel page is currently visible.
    // Exposed to CardCarousel as a @Binding so Edit/Save target the right card.
    @State private var currentCarouselPage: Int = 0

    var body: some View {
        NavigationStack {
            Group {
                if appState.cards.isEmpty {
                    emptyStateView
                } else {
                    mainContent
                }
            }
            // Logo replaces text title for brand identity (no .navigationTitle).
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    // Image asset added in Task 0 (logo_transparent.imageset).
                    // scaledToFit + maxHeight keeps it proportional in the nav bar.
                    Image("logo_transparent")
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 40)
                }
            }
            .overlay {
                if isExporting { exportProgressOverlay }
            }
        }
        // Paragraph selector modal (spec §5).
        .sheet(isPresented: Binding(
            get: { appState.showParagraphSelector },
            set: { appState.showParagraphSelector = $0 }
        )) {
            ParagraphSelectorModal(
                paragraphs: Binding(
                    get: { appState.allParsedParagraphs },
                    set: { appState.allParsedParagraphs = $0 }
                ),
                onConfirm: {
                    ParagraphParser.confirmSelection(
                        from: appState.allParsedParagraphs,
                        into: appState
                    )
                    appState.renderCards()
                }
            )
            .presentationDetents([.large])
        }
        // Text edit modal (spec §11).
        .sheet(item: $editingCard) { card in
            TextEditModal(
                card: card,
                onSave: { newText in
                    if let index = appState.cards.firstIndex(where: { $0.id == card.id }) {
                        appState.cards[index].text = newText
                        appState.invalidateAndRender(id: card.id)
                    }
                    editingCard = nil
                },
                onCancel: { editingCard = nil }
            )
            .presentationDetents([.medium, .large])
        }
        // Kick off rendering whenever cards first populate.
        .onChange(of: appState.cards.count) { _, newCount in
            if newCount > 0 { appState.renderCards() }
        }
    }

    // MARK: - Main Content

    private var mainContent: some View {
        ScrollView {
            VStack(spacing: 0) {

                CardCarousel(
                    cards: appState.cards,
                    onDelete: { id in appState.cards.removeAll { $0.id == id } },
                    currentPage: $currentCarouselPage
                )
                .padding(.top, 16)

                Divider().padding(.horizontal).padding(.top, 16)

                // Edit | Save | [Save All] — targets the currently visible card.
                // Isolated from the carousel so dots no longer overlap the button.
                actionButtonsRow
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .frame(minHeight: 56)

                Divider().padding(.horizontal)

                ThemeSelector(
                    themes: appState.availableThemes,
                    selectedTheme: Binding(
                        get: { appState.selectedTheme },
                        set: { appState.selectedTheme = $0 }
                    ),
                    onSelect: { _ in appState.invalidateAndRender() }
                )
                .frame(minHeight: 56)

                Divider().padding(.horizontal)

                // FontControls row is already padded to minHeight 56 internally (Task 7).
                FontControls(
                    selectedFont: Binding(
                        get: { appState.selectedFont },
                        set: { appState.selectedFont = $0 }
                    ),
                    fontSizeMultiplier: Binding(
                        get: { appState.fontSizeMultiplier },
                        set: { appState.fontSizeMultiplier = $0 }
                    ),
                    onChange: { appState.invalidateAndRender() }
                )

                Divider().padding(.horizontal)
            }
        }
        // Share bar floats above the bottom safe area, always visible while scrolling.
        // safeAreaInset reserves the space so the scroll content doesn't go under it.
        .safeAreaInset(edge: .bottom) {
            shareBar
        }
    }

    // MARK: - Share Bar

    // Persistent bottom bar — always visible, glass/translucent background.
    // .borderedProminent makes Share the visually primary action (Apple HIG).
    private var shareBar: some View {
        Button {
            exportImages(mode: .share)
        } label: {
            Label("Share", systemImage: "square.and.arrow.up")
                .font(.headline)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        // .ultraThinMaterial gives the iOS-native translucent glass look,
        // letting scroll content bleed through at the bottom edge.
        .background(.ultraThinMaterial)
    }

    // MARK: - Action Buttons Row

    // Secondary actions targeting the currently visible carousel card.
    // .bordered (not .borderedProminent) signals these are secondary to Share.
    private var actionButtonsRow: some View {
        HStack(spacing: 8) {

            // Edit — opens TextEditModal for the card currently visible in the carousel.
            if let card = currentCard {
                Button {
                    editingCard = card
                } label: {
                    Label("Edit", systemImage: "pencil")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }

            // Save — exports only the currently visible card to the photo library.
            // singleIndex limits the export to one image rather than all cards.
            Button {
                exportImages(mode: .save, singleIndex: currentCarouselPage)
            } label: {
                Label("Save", systemImage: "photo.badge.arrow.down")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)

            // Save All — exports every card; only visible when multiple cards exist.
            if appState.cards.count > 1 {
                Button {
                    exportImages(mode: .save)
                } label: {
                    Label("Save All", systemImage: "square.and.arrow.down.on.square")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
        }
    }

    // The card at the currently visible carousel page, or nil if out of range.
    private var currentCard: CardModel? {
        guard currentCarouselPage < appState.cards.count else { return nil }
        return appState.cards[currentCarouselPage]
    }

    // MARK: - Empty State (spec §23)

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "rectangle.stack")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            Text("Share text from Notes to create social cards.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Export Progress Overlay (spec §20)

    private var exportProgressOverlay: some View {
        ZStack {
            Color.black.opacity(0.35).ignoresSafeArea()
            VStack(spacing: 12) {
                ProgressView().controlSize(.large).tint(.white)
                Text("Preparing images…")
                    .foregroundStyle(.white)
                    .font(.subheadline)
            }
            .padding(24)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
    }

    // MARK: - Export Logic

    private enum ExportMode { case share, save }

    // Exports card images in the given mode.
    // - singleIndex: when provided, exports only that one card (Save button).
    //   When nil, exports all cards (Save All and Share).
    private func exportImages(mode: ExportMode, singleIndex: Int? = nil) {
        isExporting = true
        let images: [UIImage]
        if let i = singleIndex, i < appState.cards.count,
           let img = appState.cards[i].renderedImage {
            // Single-card path: wrap the one image in an array.
            images = [img]
        } else {
            // All-cards path: compact-map drops cards not yet rendered.
            images = appState.cards.compactMap(\.renderedImage)
        }
        guard !images.isEmpty else { isExporting = false; return }

        switch mode {
        case .share:
            isExporting = false
            ImageExportService.share(images: images)
        case .save:
            ImageExportService.saveToLibrary(images: images) { _ in
                self.isExporting = false
            }
        }
    }
}

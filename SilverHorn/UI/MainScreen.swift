// MainScreen.swift
// Root screen of the Silver Horn app — assembles all UI components.
//
// LAYOUT (top to bottom):
// 1. CardCarousel     — horizontal paging cards
// 2. ThemeSelector    — circular theme switcher
// 3. FontControls     — font family picker + size buttons
// 4. Export toolbar   — Share and Save to Library buttons
//
// EMPTY STATE (spec §23):
// When cards array is empty, a centred empty-state message is shown
// instead of the carousel and controls.
//
// MODAL PRESENTATION:
// - ParagraphSelectorModal: shown when >8 paragraphs are parsed
// - TextEditModal: shown when the user taps Edit on a card
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

    var body: some View {
        NavigationStack {
            Group {
                if appState.cards.isEmpty {
                    emptyStateView
                } else {
                    mainContent
                }
            }
            .navigationTitle("Silver Horn")
            .navigationBarTitleDisplayMode(.inline)
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
            VStack(spacing: 24) {

                CardCarousel(
                    cards: appState.cards,
                    onDelete: { id in
                        appState.cards.removeAll { $0.id == id }
                    },
                    onEdit: { card in editingCard = card }
                )

                Divider().padding(.horizontal)

                ThemeSelector(
                    themes: appState.availableThemes,
                    selectedTheme: Binding(
                        get: { appState.selectedTheme },
                        set: { appState.selectedTheme = $0 }
                    ),
                    onSelect: { _ in appState.invalidateAndRender() }
                )

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

                exportButtons
                    .padding(.bottom, 32)
            }
            .padding(.top, 16)
        }
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

    // MARK: - Export Buttons (spec §21)

    private var exportButtons: some View {
        HStack(spacing: 16) {
            Button { exportImages(mode: .share) } label: {
                Label("Share", systemImage: "square.and.arrow.up")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)

            Button { exportImages(mode: .save) } label: {
                Label("Save to Library", systemImage: "photo.badge.plus")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(.horizontal)
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

    private func exportImages(mode: ExportMode) {
        isExporting = true
        let images = appState.cards.compactMap(\.renderedImage)
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

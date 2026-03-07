// AppState.swift
// Central observable state for the Silver Horn app.
//
// ARCHITECTURE NOTE:
// @Observable (Swift 5.9 / iOS 17) replaces ObservableObject + @Published.
// Any view that reads a property automatically subscribes to changes
// for that specific property only — no need for explicit @Published.
//
// This class is passed through the SwiftUI environment so every view
// in the hierarchy can access and mutate shared state without prop drilling.
//
// PERSISTENCE (spec §24):
// The last selected theme and font are stored in standard UserDefaults
// so they survive between share sessions. Only theme id and font rawValue
// are stored — not card content (no persistence of user data).

import SwiftUI

// @MainActor ensures all mutations happen on the main thread, which is required
// because CardRenderer is @MainActor (WKWebView must run on the main thread)
// and SwiftUI @Observable state must be mutated on the main thread anyway.
@MainActor
@Observable
final class AppState {

    // MARK: - Card State
    // The ordered list of cards derived from the shared paragraph text.
    // Each CardModel wraps a paragraph and its cached rendered UIImage.
    var cards: [CardModel] = []

    // Controls whether the paragraph selector modal is shown.
    // Set to true by the parser when input yields >8 paragraphs.
    var showParagraphSelector: Bool = false

    // Holds all parsed paragraphs when >8 are found, for the selection modal.
    var allParsedParagraphs: [ParagraphModel] = []

    // MARK: - Appearance State
    // The currently selected colour theme applied to all cards.
    // Initialised from UserDefaults if a previous selection exists.
    var selectedTheme: ThemeModel {
        didSet { persistTheme() }
    }

    // The currently selected font family applied to all cards.
    var selectedFont: FontModel {
        didSet { persistFont() }
    }

    // Multiplier applied on top of the base font size.
    // Default is slightly reduced to match preferred first-render sizing.
    var fontSizeMultiplier: Double = 0.8

    // All available themes loaded from Config/themes.json.
    let availableThemes: [ThemeModel]

    // MARK: - Init
    // Loads themes from JSON and restores last-used theme/font from UserDefaults.
    init() {
        let themes = ThemeModel.loadAll()
        availableThemes = themes

        // Restore last theme — fall back to first theme (Mauve) if none saved.
        let savedThemeId = UserDefaults.standard.string(forKey: "lastThemeId")
        selectedTheme = themes.first(where: { $0.id == savedThemeId }) ?? (themes.first ?? .default)

        // Restore last font — fall back to Instrument if none saved.
        let savedFontRaw = UserDefaults.standard.string(forKey: "lastFontId")
        selectedFont = FontModel(rawValue: savedFontRaw ?? "") ?? .instrument
    }

    // MARK: - IPC (spec §22, design.md §2)
    // Called by SilverHornApp when the `silverhorn://open` URL fires.
    // Reads the pending text written by the Share Extension, clears it,
    // and passes it to the paragraph parser.
    func loadSharedText() {
        let defaults = UserDefaults(suiteName: "group.club.skape.silverhorn")

        // Read and immediately clear the key so stale text is never re-loaded
        // if the user opens the app directly a second time without sharing.
        guard let text = defaults?.string(forKey: "pendingSharedText"),
              !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else { return }

        defaults?.removeObject(forKey: "pendingSharedText")
        defaults?.synchronize()

        // Hand off to the paragraph parser (Phase 5).
        ParagraphParser.parse(text, into: self)
    }

    // MARK: - Rendering

    /// Triggers a render pass for all cards that lack a cached image.
    /// Should be called after cards are set or appearance changes.
    func renderCards() {
        CardRenderer.shared.scheduleRender(
            cards: cards,
            theme: selectedTheme,
            font: selectedFont,
            multiplier: fontSizeMultiplier
        ) { [weak self] id, image in
            guard let self else { return }
            // Find the card and update its rendered image.
            // SwiftUI observes this mutation and redraws the affected card.
            if let index = self.cards.firstIndex(where: { $0.id == id }) {
                self.cards[index].renderedImage = image
            }
        }
    }

    /// Invalidates all card images and re-renders (theme or font change).
    func invalidateAndRender() {
        CardRenderer.shared.invalidateAll()
        for index in cards.indices { cards[index].renderedImage = nil }
        renderCards()
    }

    /// Invalidates a single card's image and re-renders (text edit).
    func invalidateAndRender(id: UUID) {
        CardRenderer.shared.invalidate(id: id)
        if let index = cards.firstIndex(where: { $0.id == id }) {
            cards[index].renderedImage = nil
        }
        renderCards()
    }

    // MARK: - Persistence (spec §24)

    private func persistTheme() {
        UserDefaults.standard.set(selectedTheme.id, forKey: "lastThemeId")
    }

    private func persistFont() {
        UserDefaults.standard.set(selectedFont.rawValue, forKey: "lastFontId")
    }
}

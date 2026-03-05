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
// PHASE STATUS: Stub — properties and methods will be filled in
// during Phases 1–12 as each capability is implemented.

import SwiftUI

@Observable
final class AppState {

    // MARK: - Card State
    // The ordered list of cards derived from the shared paragraph text.
    // Each CardModel wraps a paragraph and its cached rendered UIImage.
    var cards: [CardModel] = []

    // MARK: - Appearance State
    // The currently selected colour theme applied to all cards.
    var selectedTheme: ThemeModel = ThemeModel.default

    // The currently selected font family applied to all cards.
    var selectedFont: FontModel = .instrument

    // Multiplier applied on top of the 72px base font size.
    // Values above 1.0 increase size; below 1.0 decrease it.
    // The rendered font is clamped to [36px, 72px] by the HTML template.
    var fontSizeMultiplier: Double = 1.0

    // MARK: - IPC
    // Called by SilverHornApp when the silverhorn://open URL is received.
    // Reads pending text from the App Group shared container.
    // Full implementation in Phase 4.
    func loadSharedText() {
        // Phase 4: read UserDefaults(suiteName:) and parse paragraphs
    }
}

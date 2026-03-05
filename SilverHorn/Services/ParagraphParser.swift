// ParagraphParser.swift
// Splits raw shared text into paragraphs and populates AppState.
//
// PARSING RULES (spec §5):
// - Split on "\n\n" (double newline)
// - Trim whitespace from each segment
// - Discard empty segments
// - Maximum 8 paragraphs per session
// - If >8 paragraphs: show selection modal with first 8 pre-selected
//
// DESIGN CHOICE:
// This is a static-method namespace rather than a class/struct instance
// because parsing is a pure transformation with no stored state.
// It writes directly into AppState to keep the call site in AppState
// simple (one function call).

import Foundation

@MainActor
enum ParagraphParser {

    // Maximum cards allowed per session (spec §5).
    static let maxParagraphs = 8

    /// Parses `text` into paragraphs and writes the result into `state`.
    /// - If ≤8 paragraphs: directly sets `state.cards`.
    /// - If >8 paragraphs: sets `state.allParsedParagraphs` and raises the selection modal.
    static func parse(_ text: String, into state: AppState) {
        // Split on double newline — the canonical paragraph separator (spec §5).
        let segments = text.components(separatedBy: "\n\n")

        // Trim surrounding whitespace and drop empty segments (spec §5).
        let paragraphs = segments
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        if paragraphs.count <= maxParagraphs {
            // Happy path: convert directly to cards, no modal needed.
            state.cards = paragraphs.map { CardModel(text: $0) }
        } else {
            // More than 8 paragraphs: build ParagraphModel array for the
            // selection modal. Pre-select the first 8 (spec §5).
            state.allParsedParagraphs = paragraphs.enumerated().map { index, text in
                ParagraphModel(text: text, isSelected: index < maxParagraphs)
            }
            state.showParagraphSelector = true
        }
    }

    /// Converts the user's confirmed selection from the paragraph modal into cards.
    /// Called by ParagraphSelectorModal when the user taps Confirm.
    static func confirmSelection(from paragraphs: [ParagraphModel], into state: AppState) {
        // Only take selected paragraphs, preserving their original order.
        let selected = paragraphs.filter { $0.isSelected }
        state.cards = selected.map { CardModel(text: $0.text) }
        state.showParagraphSelector = false
        state.allParsedParagraphs = []
    }
}

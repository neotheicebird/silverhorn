// ParagraphModel.swift
// Represents a single parsed paragraph from the shared input text.
//
// ARCHITECTURE NOTE:
// ParagraphModel is an intermediate representation used only during
// the paragraph selection phase (when >8 paragraphs exist).
// Once the user confirms their selection, ParagraphModels are converted
// into CardModels and ParagraphModel is no longer referenced.
//
// `Identifiable` allows SwiftUI List to efficiently diff rows.

import Foundation

struct ParagraphModel: Identifiable {

    // Stable identity for SwiftUI diffing.
    let id: UUID

    // The trimmed paragraph text.
    let text: String

    // Whether this paragraph is selected in the paragraph selector modal.
    // Mutated by the selection UI; max 8 can be true simultaneously.
    var isSelected: Bool

    init(text: String, isSelected: Bool = false) {
        self.id = UUID()
        self.text = text
        self.isSelected = isSelected
    }
}

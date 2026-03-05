// CardModel.swift
// Represents a single renderable card in the carousel.
//
// ARCHITECTURE NOTE:
// CardModel is the core data unit. Each instance holds the paragraph text
// for one card and the cached rendered UIImage (nil until rendering completes).
//
// The rendered image is stored here rather than in a separate cache dictionary
// so that SwiftUI can observe per-card image updates directly via AppState.
//
// `id` is a stable UUID used to:
//   - Key the render cache in CardRenderer
//   - Drive SwiftUI ForEach diffing in the carousel

import UIKit

struct CardModel: Identifiable {

    // Stable identity used for render cache lookup and SwiftUI diffing.
    let id: UUID

    // The paragraph text displayed on this card.
    // Mutated when the user edits the card via TextEditModal.
    var text: String

    // The rendered UIImage snapshot from WKWebView.
    // nil while the card is pending render (skeleton shown in its place).
    var renderedImage: UIImage?

    init(text: String) {
        self.id = UUID()
        self.text = text
        self.renderedImage = nil
    }
}

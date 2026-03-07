// CardView.swift
// Displays a single rendered card in the carousel.
//
// STATES:
// 1. renderedImage == nil  → SkeletonCardView (shimmer placeholder, spec §17)
// 2. renderedImage != nil  → Rendered UIImage at 5:4 landscape aspect ratio
//
// SHADOW (spec §18):
// Drop shadow is applied here in SwiftUI — NOT in the HTML/CSS template.
// Exported images are taken from CardRenderer's UIImage cache (no shadow).
//
// DELETE BUTTON (spec §13):
// X button in the top-right corner. Hidden when only 1 card remains.
//
// NOTE: The Edit button has been moved to MainScreen's actionButtonsRow
// so it no longer overlaps the carousel page indicator dots.

import SwiftUI

struct CardView: View {

    let card: CardModel
    let isLastCard: Bool      // Determines whether the delete button is visible.
    var onDelete: () -> Void

    // 5:4 landscape aspect ratio as a CGFloat for GeometryReader calculations.
    // Width is always greater than height (wider than tall).
    private let aspectRatio: CGFloat = 5.0 / 4.0

    var body: some View {
        // MARK: Card Image Area
        // GeometryReader fills available width; height is derived from the 5:4 ratio.
        GeometryReader { geo in
            let width  = geo.size.width
            let height = width / aspectRatio  // Derived from width for 5:4 ratio.

            ZStack(alignment: .topTrailing) {

                // Rendered image or skeleton placeholder.
                if let image = card.renderedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        // Drop shadow: preview only (spec §18).
                        .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 6)
                } else {
                    SkeletonCardView()
                        .frame(width: width, height: height)
                }

                // Delete button — hidden when this is the only remaining card.
                if !isLastCard {
                    Button(action: onDelete) {
                        Image(systemName: "xmark.circle.fill")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, Color.black.opacity(0.5))
                            .font(.title2)
                    }
                    .padding(8)
                }
            }
            .frame(width: width, height: height)
        }
        // Constrain the GeometryReader to the correct height for 5:4.
        // GeometryReader is greedy by nature; explicit frame prevents layout collapse.
        .aspectRatio(aspectRatio, contentMode: .fit)
    }
}

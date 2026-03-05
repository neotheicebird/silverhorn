// CardCarousel.swift
// Horizontal paging carousel displaying all card views with page dots.
//
// SPEC §12 — Carousel Behaviour:
// "swipe left/right, paging enabled, snapping scroll, Instagram-like interaction"
//
// IMPLEMENTATION:
// TabView with .tabViewStyle(.page) gives us free paging + snapping.
// Page indicator dots are the native iOS dots (indexDisplayMode: .always).
//
// The carousel receives cards and callbacks from MainScreen.
// It does not mutate state directly — deletions and edits are routed
// up via closures so AppState remains the single source of truth.

import SwiftUI

struct CardCarousel: View {

    // The cards to display. Observed indirectly via MainScreen's AppState binding.
    let cards: [CardModel]

    // Callbacks routed back to MainScreen / AppState.
    var onDelete: (UUID) -> Void
    var onEdit:   (CardModel) -> Void

    // Tracks the currently visible page for programmatic control if needed.
    @State private var currentPage: Int = 0

    var body: some View {
        // TabView with page style gives horizontal paging + snapping (spec §12).
        // Each page shows one CardView centred horizontally.
        TabView(selection: $currentPage) {
            ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                CardView(
                    card: card,
                    isLastCard: cards.count == 1,
                    onDelete: { onDelete(card.id) },
                    onEdit:   { onEdit(card) }
                )
                // Horizontal padding gives the Instagram-like look where the
                // current card fills most of the screen width.
                .padding(.horizontal, 24)
                // Tag ties this page to the TabView selection index.
                .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        // Tint the page dots using the accent colour.
        .indexViewStyle(.page(backgroundDisplayMode: .never))
        // Height is derived from card width via 4:5 ratio plus some bottom space for dots.
        .frame(height: carouselHeight)
        // Reset to first page when the card list is replaced (new share session).
        .onChange(of: cards.count) { _, newCount in
            if newCount > 0, currentPage >= newCount {
                currentPage = max(0, newCount - 1)
            }
        }
    }

    // Computes the carousel height from the available screen width.
    // Card width = screen width - 2 * 24pt padding.
    // Card height = card width * (5/4) to maintain 4:5 ratio (spec §6).
    // Add ~40pt for page dots below the card.
    private var carouselHeight: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let cardWidth   = screenWidth - 48  // 24pt padding each side.
        let cardHeight  = cardWidth * (5.0 / 4.0)
        return cardHeight + 40
    }
}

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
// currentPage is a @Binding (not @State) so MainScreen can read which card
// is visible and target Edit / Save actions to it.
//
// The carousel receives cards and deletion callback from MainScreen.
// It does not mutate state directly — deletions are routed up via the
// closure so AppState remains the single source of truth.
// The Edit action has moved to MainScreen's actionButtonsRow.

import SwiftUI

struct CardCarousel: View {

    // The cards to display. Observed indirectly via MainScreen's AppState binding.
    let cards: [CardModel]

    // Deletion callback routed back to MainScreen / AppState.
    var onDelete: (UUID) -> Void

    // Tracks the currently visible page — binding exposes it to MainScreen
    // so the parent can target Edit/Save actions to the correct card.
    @Binding var currentPage: Int

    var body: some View {
        // TabView with page style gives horizontal paging + snapping (spec §12).
        // Each page shows one CardView centred horizontally.
        TabView(selection: $currentPage) {
            ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                CardView(
                    card: card,
                    isLastCard: cards.count == 1,
                    onDelete: { onDelete(card.id) }
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
        // Height is derived from card width via 5:4 landscape ratio plus space for dots.
        .frame(height: carouselHeight)
        // Reset to last valid page when cards are deleted.
        .onChange(of: cards.count) { _, newCount in
            if newCount > 0, currentPage >= newCount {
                currentPage = max(0, newCount - 1)
            }
        }
    }

    // Computes the carousel height from the available screen width.
    // Card width = screen width - 2 * 24pt padding.
    // Card height = card width * (4/5) to maintain 5:4 landscape ratio.
    // iPhone 12 example: 390 - 48 = 342pt wide → 274pt tall → 314pt with dots.
    // Add ~40pt for page dots below the card.
    private var carouselHeight: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let cardWidth   = screenWidth - 48  // 24pt padding each side.
        let cardHeight  = cardWidth * (4.0 / 5.0)
        return cardHeight + 40
    }
}

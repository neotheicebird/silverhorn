// SkeletonCardView.swift
// Shimmer placeholder shown while a card's UIImage is being rendered.
//
// SPEC §17 — Skeleton Loading:
// "When the app first loads cards, placeholder cards must appear instantly.
//  Skeleton cards mimic the card layout and display a subtle placeholder shimmer."
//
// IMPLEMENTATION:
// A shimmer is produced by animating a LinearGradient's start/end points
// across the card frame. The gradient moves left-to-right, cycling on repeat.
// This is a pure SwiftUI approach — no external library needed.

import SwiftUI

struct SkeletonCardView: View {

    // Controls the phase of the shimmer animation.
    // Toggled by .onAppear to start the loop.
    @State private var animating = false

    // 4:5 aspect ratio (spec §6).
    private let aspectRatio: CGFloat = 4.0 / 5.0

    // Shimmer gradient colours — subtle light pulse on a muted base.
    private let baseColor    = Color(white: 0.85)
    private let shimmerColor = Color(white: 0.95)

    var body: some View {
        GeometryReader { geo in
            let width  = geo.size.width
            let height = geo.size.height

            ZStack {
                baseColor

                // The shimmer highlight travels across the card width.
                LinearGradient(
                    gradient: Gradient(colors: [
                        baseColor,
                        shimmerColor,
                        baseColor
                    ]),
                    startPoint: animating
                        ? UnitPoint(x: 1.5, y: 0.5)   // End position (off-screen right)
                        : UnitPoint(x: -0.5, y: 0.5),  // Start position (off-screen left)
                    endPoint: animating
                        ? UnitPoint(x: 2.5, y: 0.5)
                        : UnitPoint(x: 0.5, y: 0.5)
                )
                .frame(width: width * 2)  // Extra width for the sweep effect.
                .offset(x: animating ? width : -width)
            }
            .frame(width: width, height: height)
            .clipShape(RoundedRectangle(cornerRadius: 4))
            // Apply the same shadow as the real card for visual consistency.
            .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
        }
        .aspectRatio(aspectRatio, contentMode: .fit)
        .onAppear {
            withAnimation(
                .linear(duration: 1.2).repeatForever(autoreverses: false)
            ) {
                animating = true
            }
        }
    }
}

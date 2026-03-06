// ThemeSelector.swift
// Horizontal row of circular theme previews.
//
// SPEC §10 — Theme Selector UI:
// "Circular color previews split vertically.
//  Left side = text color, Right side = background color."
//
// SPEC §19 — Selection Animation:
// "Apply a quick scale animation: scale 1.0 → 1.1 → 1.0
//  Animation curve: SwiftUI spring animation (~0.25s)"

import SwiftUI

struct ThemeSelector: View {

    let themes: [ThemeModel]

    // Two-way binding to the selected theme in AppState.
    @Binding var selectedTheme: ThemeModel

    // Callback fired after selection so MainScreen can trigger re-render.
    var onSelect: (ThemeModel) -> Void

    var body: some View {
        HStack(spacing: 16) {
            ForEach(themes) { theme in
                ThemeCircle(
                    theme: theme,
                    isSelected: theme.id == selectedTheme.id,
                    onTap: {
                        selectedTheme = theme
                        onSelect(theme)
                    }
                )
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Theme Circle

// A single split-colour circle representing one theme.
private struct ThemeCircle: View {

    let theme:      ThemeModel
    let isSelected: Bool
    let onTap:      () -> Void

    // Drives the spring scale animation (spec §19).
    @State private var scale: CGFloat = 1.0

    // Diameter of the circle in points (25% smaller than original 44pt).
    private let diameter: CGFloat = 33

    var body: some View {
        Button(action: handleTap) {
            ZStack {
                // Full circle — right half (background colour).
                Circle()
                    .fill(theme.bgSwiftUIColor)
                    .frame(width: diameter, height: diameter)

                // Left half overlay — text colour.
                // Achieved with a Rectangle mask clipped to the left 50%.
                theme.textSwiftUIColor
                    .clipShape(
                        // Custom half-circle shape clipping the left side.
                        HalfCircle(side: .left)
                    )
                    .frame(width: diameter, height: diameter)

                // Selection ring — visible only on the active theme.
                if isSelected {
                    Circle()
                        .strokeBorder(Color.primary.opacity(0.6), lineWidth: 2.5)
                        .frame(width: diameter + 5, height: diameter + 5)
                }
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(scale)
        .accessibilityLabel(theme.name)
    }

    // Triggers the scale pulse animation (spec §19) then calls onTap.
    private func handleTap() {
        withAnimation(.spring(duration: 0.25)) {
            scale = 1.1
        }
        // Return to normal scale after the up-pulse.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.spring(duration: 0.15)) {
                scale = 1.0
            }
        }
        onTap()
    }
}

// MARK: - Half Circle Shape

// A Shape that clips only the left or right half of a circle's bounding rect.
private struct HalfCircle: Shape {
    enum Side { case left, right }
    let side: Side

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let midX = rect.midX
        switch side {
        case .left:
            path.addArc(
                center: CGPoint(x: rect.midX, y: rect.midY),
                radius: rect.width / 2,
                startAngle: .degrees(90),
                endAngle: .degrees(270),
                clockwise: false
            )
            path.addLine(to: CGPoint(x: midX, y: rect.minY))
        case .right:
            path.addArc(
                center: CGPoint(x: rect.midX, y: rect.midY),
                radius: rect.width / 2,
                startAngle: .degrees(270),
                endAngle: .degrees(90),
                clockwise: false
            )
            path.addLine(to: CGPoint(x: midX, y: rect.maxY))
        }
        path.closeSubpath()
        return path
    }
}

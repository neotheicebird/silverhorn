// FontControls.swift
// Font family picker and size increase/decrease controls.
//
// SPEC §9 — Font Size Control UI:
// "Two buttons: Decrease font size / Increase font size
//  Icons: Lucide a-arrow-down / a-arrow-up
//  Font size is adjusted as a multiplier on the base size.
//  Users never see numeric font values."
//
// SPEC §7 — Available fonts:
// Instrument (default), Mona, Georgia, Helvetica Neue,
// Cambria, Courier New, Liberation Mono
//
// IMPLEMENTATION NOTE — Lucide Icons:
// Lucide a-arrow-up/down are not in SF Symbols. We use SF Symbols
// "textformat.size.larger" and "textformat.size.smaller" as the
// closest semantic equivalents available natively on iOS 17.

import SwiftUI

struct FontControls: View {

    // Two-way bindings to AppState values.
    @Binding var selectedFont:       FontModel
    @Binding var fontSizeMultiplier: Double

    // Callback fired when any change occurs, so MainScreen can trigger re-render.
    var onChange: () -> Void

    // Step size for the multiplier per button tap.
    // 0.1 gives gentle increments without jarring jumps.
    private let step: Double = 0.1

    // Clamp range for the multiplier — prevents font from becoming unreadable.
    private let minMultiplier: Double = 0.5   // 36pt logical → 18pt (36px / 2)
    private let maxMultiplier: Double = 1.5   // 54pt logical → 108px rendered

    var body: some View {
        HStack(spacing: 16) {

            // MARK: Font Size Decrease (Lucide a-arrow-down equivalent)
            Button {
                let newValue = (fontSizeMultiplier - step).rounded(to: 1)
                fontSizeMultiplier = max(minMultiplier, newValue)
                onChange()
            } label: {
                Image(systemName: "textformat.size.smaller")
                    .font(.title3)
                    .foregroundStyle(fontSizeMultiplier <= minMultiplier ? .tertiary : .primary)
                    // Fill row height so the full area is tappable.
                    .frame(maxHeight: .infinity)
            }
            .disabled(fontSizeMultiplier <= minMultiplier)
            .buttonStyle(.plain)

            // MARK: Font Family Picker
            // Presented as a Menu to keep the toolbar compact.
            // Users see font display names; the enum rawValue is stored in AppState.
            Menu {
                ForEach(FontModel.allCases) { font in
                    Button {
                        selectedFont = font
                        onChange()
                    } label: {
                        // Show a checkmark next to the active font.
                        Label(
                            font.displayName,
                            systemImage: font == selectedFont ? "checkmark" : ""
                        )
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(selectedFont.displayName)
                        .font(.subheadline)
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption2)
                }
                .foregroundStyle(.primary)
                // Expand to fill row so the entire label area is tappable.
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .buttonStyle(.plain)

            // MARK: Font Size Increase (Lucide a-arrow-up equivalent)
            Button {
                let newValue = (fontSizeMultiplier + step).rounded(to: 1)
                fontSizeMultiplier = min(maxMultiplier, newValue)
                onChange()
            } label: {
                Image(systemName: "textformat.size.larger")
                    .font(.title3)
                    .foregroundStyle(fontSizeMultiplier >= maxMultiplier ? .tertiary : .primary)
                    // Fill row height so the full area is tappable.
                    .frame(maxHeight: .infinity)
            }
            .disabled(fontSizeMultiplier >= maxMultiplier)
            .buttonStyle(.plain)
        }
        // Padding-based row sizing: minHeight ensures easy tap targets,
        // horizontal/vertical padding adds breathing room without fixing height.
        .frame(minHeight: 56)
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
    }
}

// MARK: - Double Rounding Helper

private extension Double {
    /// Rounds to `places` decimal places to avoid floating-point drift in the multiplier.
    func rounded(to places: Int) -> Double {
        let factor = pow(10.0, Double(places))
        return (self * factor).rounded() / factor
    }
}

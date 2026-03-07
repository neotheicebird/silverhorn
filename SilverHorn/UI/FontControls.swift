// FontControls.swift
// Font family picker and size increase/decrease controls.

import SwiftUI

struct FontControls: View {

    @Binding var selectedFont: FontModel
    @Binding var fontSizeMultiplier: Double
    var onChange: () -> Void

    private let step: Double = 0.1
    private let minMultiplier: Double = 0.5
    private let maxMultiplier: Double = 1.5

    var body: some View {
        HStack {
            HStack(spacing: 0) {
                Button {
                    let newValue = (fontSizeMultiplier - step).rounded(to: 1)
                    fontSizeMultiplier = max(minMultiplier, newValue)
                    onChange()
                } label: {
                    Image(systemName: "textformat.size.smaller")
                        .font(.subheadline.weight(.semibold))
                        .frame(width: 40, height: 34)
                }
                .buttonStyle(.plain)
                .disabled(fontSizeMultiplier <= minMultiplier)

                divider

                Menu {
                    ForEach(FontModel.allCases) { font in
                        Button {
                            selectedFont = font
                            onChange()
                        } label: {
                            Label(
                                font.displayName,
                                systemImage: font == selectedFont ? "checkmark" : ""
                            )
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Text(selectedFont.displayName)
                            .font(.subheadline)
                            .lineLimit(1)
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.caption2)
                    }
                    .frame(minWidth: 140, minHeight: 34)
                }
                .buttonStyle(.plain)

                divider

                Button {
                    let newValue = (fontSizeMultiplier + step).rounded(to: 1)
                    fontSizeMultiplier = min(maxMultiplier, newValue)
                    onChange()
                } label: {
                    Image(systemName: "textformat.size.larger")
                        .font(.subheadline.weight(.semibold))
                        .frame(width: 40, height: 34)
                }
                .buttonStyle(.plain)
                .disabled(fontSizeMultiplier >= maxMultiplier)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.18))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.45), lineWidth: 1)
            )
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 56)
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.45))
            .frame(width: 1, height: 20)
    }
}

private extension Double {
    func rounded(to places: Int) -> Double {
        let factor = pow(10.0, Double(places))
        return (self * factor).rounded() / factor
    }
}

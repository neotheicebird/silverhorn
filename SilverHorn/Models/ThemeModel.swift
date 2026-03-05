// ThemeModel.swift
// Represents a single colour theme used for card rendering.
//
// ARCHITECTURE NOTE:
// Themes are loaded at runtime from Config/themes.json (bundled in the app).
// This decouples theme data from code — adding a theme in a future version
// only requires editing the JSON file, not recompiling.
//
// The `Codable` conformance maps directly to the JSON keys.
// `Identifiable` lets SwiftUI ForEach iterate over themes by id.

import SwiftUI

struct ThemeModel: Codable, Identifiable, Equatable {

    // Unique string identifier matching the JSON `id` field (e.g. "mauve").
    let id: String

    // Human-readable display name shown in the theme selector UI.
    let name: String

    // Hex colour strings (e.g. "#a79ea8") parsed into SwiftUI Color below.
    let textColor: String
    let bgColor: String

    // MARK: - Computed SwiftUI Colors
    // Converts the hex string stored in JSON into a usable SwiftUI Color.
    // Used by ThemeSelector for the split circle preview.
    var textSwiftUIColor: Color { Color(hex: textColor) }
    var bgSwiftUIColor: Color   { Color(hex: bgColor) }

    // MARK: - Default
    // The fallback theme used before JSON finishes loading.
    static let `default` = ThemeModel(
        id: "mauve",
        name: "Mauve",
        textColor: "#a79ea8",
        bgColor: "#594c5b"
    )
}

// MARK: - JSON Loading
extension ThemeModel {

    /// Loads all themes from Config/themes.json bundled in the app.
    /// Returns the 4 hardcoded defaults if the file cannot be read.
    static func loadAll() -> [ThemeModel] {
        guard
            let url = Bundle.main.url(forResource: "themes", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let themes = try? JSONDecoder().decode([ThemeModel].self, from: data)
        else {
            return [.default]
        }
        return themes
    }
}

// MARK: - Color Hex Extension
// Parses a CSS hex string (#RRGGBB or #RGB) into a SwiftUI Color.
// Used by ThemeModel and the HTML template builder.
extension Color {
    init(hex: String) {
        // Strip the leading `#` if present.
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r, g, b: Double
        switch hex.count {
        case 6:
            // Full 6-digit hex: #RRGGBB
            r = Double((int >> 16) & 0xFF) / 255
            g = Double((int >> 8)  & 0xFF) / 255
            b = Double(int         & 0xFF) / 255
        case 3:
            // Shorthand 3-digit hex: #RGB → #RRGGBB
            r = Double((int >> 8)  & 0xF) / 15
            g = Double((int >> 4)  & 0xF) / 15
            b = Double(int         & 0xF) / 15
        default:
            r = 1; g = 1; b = 1
        }
        self.init(red: r, green: g, blue: b)
    }
}

// FontModel.swift
// Enumerates the font families available for card rendering.
//
// ARCHITECTURE NOTE:
// Fonts are stored locally in Assets/fonts/ (custom ones) or referenced
// by PostScript name (system fonts). The `cssName` property is what gets
// injected into the HTML template's font-family CSS declaration.
//
// The `requiresEmbedding` flag distinguishes fonts that need a
// base64-encoded @font-face injection in the WKWebView HTML from
// system fonts that are available natively in WebKit.

import Foundation

enum FontModel: String, CaseIterable, Identifiable {

    // System fonts available in iOS WebKit without custom embedding.
    case helveticaNeue = "Helvetica Neue"
    case georgia       = "Georgia"
    case avenirNext    = "Avenir Next"
    case palatino      = "Palatino"
    case futura        = "Futura"
    case courierNew    = "Courier New"
    case menlo         = "Menlo"

    // Identifiable conformance for SwiftUI ForEach
    var id: String { rawValue }

    // The display name shown in the font picker UI.
    var displayName: String { rawValue }

    // The CSS font-family value injected into the HTML template.
    // For system fonts this matches the PostScript/web name exactly.
    var cssName: String {
        switch self {
        case .georgia:      return "Georgia"
        case .helveticaNeue: return "Helvetica Neue"
        case .avenirNext:   return "Avenir Next"
        case .palatino:     return "Palatino"
        case .futura:       return "Futura"
        case .courierNew:   return "Courier New"
        case .menlo:        return "Menlo"
        }
    }

    // Whether this font must be embedded via base64 @font-face in the
    // WKWebView HTML. Custom fonts are not available in the WebKit sandbox
    // unless explicitly injected. System fonts do not need this.
    var requiresEmbedding: Bool {
        false
    }

    // The filename (without extension) used to locate the font file
    // in Assets/fonts/ for embedding. Nil for system fonts.
    var fontFileName: String? {
        nil
    }

    // Default font used when no prior user selection exists.
    static let defaultFont: FontModel = .helveticaNeue
}

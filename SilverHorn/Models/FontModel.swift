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

    // Custom fonts bundled in Assets/fonts/
    case instrument = "Instrument"
    case mona       = "Mona"

    // System fonts available in WebKit without embedding
    case georgia       = "Georgia"
    case helveticaNeue = "Helvetica Neue"
    case cambria       = "Cambria"
    case courierNew    = "Courier New"
    case liberationMono = "Liberation Mono"

    // Identifiable conformance for SwiftUI ForEach
    var id: String { rawValue }

    // The display name shown in the font picker UI.
    var displayName: String { rawValue }

    // The CSS font-family value injected into the HTML template.
    // For system fonts this matches the PostScript/web name exactly.
    var cssName: String {
        switch self {
        case .instrument:   return "Instrument Serif"
        case .mona:         return "Mona Sans"
        case .georgia:      return "Georgia"
        case .helveticaNeue: return "Helvetica Neue"
        case .cambria:      return "Cambria"
        case .courierNew:   return "Courier New"
        case .liberationMono: return "Liberation Mono"
        }
    }

    // Whether this font must be embedded via base64 @font-face in the
    // WKWebView HTML. Custom fonts are not available in the WebKit sandbox
    // unless explicitly injected. System fonts do not need this.
    var requiresEmbedding: Bool {
        switch self {
        case .instrument, .mona: return true
        default:                 return false
        }
    }

    // The filename (without extension) used to locate the font file
    // in Assets/fonts/ for embedding. Nil for system fonts.
    var fontFileName: String? {
        switch self {
        case .instrument: return "InstrumentSerif-Regular"
        case .mona:       return "MonaSans-Regular"
        default:          return nil
        }
    }

    // Default font as specified in project-spec.txt §7.
    static let defaultFont: FontModel = .instrument
}

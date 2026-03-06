// HTMLTemplateBuilder.swift
// Builds a complete HTML string for a single card ready to load into WKWebView.
//
// RENDERING PIPELINE (spec §14, design.md §3):
//   CardModel + ThemeModel + FontModel
//     → HTMLTemplateBuilder.build(...)
//       → HTML string with inlined CSS + optional base64 @font-face
//         → WKWebView.loadHTMLString(_:baseURL:)
//           → WKWebView.takeSnapshot(with:)
//             → UIImage (1350×1080px landscape)
//
// FONT EMBEDDING (design.md §6):
// Custom fonts (Instrument, Mona) are not available in WKWebView's isolated
// WebKit process. They must be injected as base64-encoded @font-face rules.
// System fonts (Georgia, Helvetica Neue, etc.) are available natively.
//
// CARD DIMENSIONS (spec §6):
// Logical render size: 675 × 540 pt landscape (@2x → 1350 × 1080 px)
// Padding: 60pt all sides (→ 120px at @2x)
// Text width: 80% of card width (fixed, not max-width)

import UIKit

enum HTMLTemplateBuilder {

    // MARK: - Constants (spec §6, §8)

    /// Logical card width in points. Snapshot at @2x yields 1350px (landscape).
    static let cardWidthPt:  CGFloat = 675
    /// Logical card height in points. Snapshot at @2x yields 1080px (landscape).
    static let cardHeightPt: CGFloat = 540
    /// Inner padding in points (120px / 2 for @2x).
    static let paddingPt:    CGFloat = 60
    /// Base font size in points before scaling (72px / 2 for @2x, spec §8).
    static let baseFontSizePt: CGFloat = 36   // 72px ÷ 2 = 36pt logical
    /// Minimum font size in points (36px / 2 for @2x, spec §8).
    static let minFontSizePt:  CGFloat = 18   // 36px ÷ 2 = 18pt logical

    // MARK: - Public API

    /// Builds a self-contained HTML string for the given card parameters.
    /// - Parameters:
    ///   - text: The paragraph text to render.
    ///   - theme: The colour theme (text + background hex colours).
    ///   - font: The selected font family.
    ///   - fontSizeMultiplier: Multiplier on baseFontSizePt (1.0 = default).
    /// - Returns: A complete HTML string ready for `WKWebView.loadHTMLString`.
    static func build(
        text: String,
        theme: ThemeModel,
        font: FontModel,
        fontSizeMultiplier: Double
    ) -> String {

        // Apply the size multiplier, then clamp to [minFontSizePt, baseFontSizePt * max].
        // We allow the multiplier to scale up beyond base (user increased size via controls).
        let scaledSize = baseFontSizePt * fontSizeMultiplier
        let clampedSize = max(minFontSizePt, scaledSize)

        // Build the @font-face block for custom fonts; empty string for system fonts.
        let fontFaceCSS = fontFaceBlock(for: font)

        // Inline CSS — all values substituted, no external file load needed.
        // WKWebView cannot load local files from the app bundle without a baseURL,
        // so everything is inlined to keep rendering self-contained.
        let styleBlock = """
        \(fontFaceCSS)

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        html, body {
            width:  \(Int(cardWidthPt))px;
            height: \(Int(cardHeightPt))px;
            overflow: hidden;
            background: \(theme.bgColor);
        }

        .card {
            width:   \(Int(cardWidthPt))px;
            height:  \(Int(cardHeightPt))px;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: \(Int(paddingPt))px;
            overflow: hidden;
            background: \(theme.bgColor);
        }

        .text {
            /*
              Font stack: custom/system font first, then Apple Color Emoji
              to ensure emoji renders correctly regardless of chosen font (spec §7).
            */
            font-family: "\(font.cssName)", "Apple Color Emoji", sans-serif;
            font-size: \(Int(clampedSize))px;
            color: \(theme.textColor);
            text-align: center;
            width: 80%;             /* spec §6: text width = 80% of card (fixed, not max-width) */
            word-wrap: break-word;
            overflow-wrap: break-word;
            line-height: 1.35;
            /*
              white-space: normal lets the JS overflow check work correctly.
              The JS scaling routine in card.html will adjust font-size if needed.
            */
            white-space: normal;
        }
        """

        // Escape the text for safe HTML embedding.
        // This prevents paragraph text from breaking the HTML structure
        // (e.g. if the user's text contains <, >, or &).
        let escapedText = text
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")

        // Load the HTML template from the app bundle and substitute tokens.
        guard
            let templateURL = Bundle.main.url(forResource: "card", withExtension: "html"),
            let template    = try? String(contentsOf: templateURL, encoding: .utf8)
        else {
            // Fallback inline template if file loading fails.
            return fallbackHTML(escapedText: escapedText, styleBlock: styleBlock)
        }

        return template
            .replacingOccurrences(of: "{{STYLE_BLOCK}}", with: styleBlock)
            .replacingOccurrences(of: "{{TEXT}}",        with: escapedText)
    }

    // MARK: - Font Face Block

    /// Generates a CSS @font-face block for fonts that require embedding.
    /// Returns an empty string for system fonts that are natively available in WebKit.
    private static func fontFaceBlock(for font: FontModel) -> String {
        guard font.requiresEmbedding, let fileName = font.fontFileName else {
            return ""
        }

        // Locate the font file in Assets/fonts/ within the app bundle.
        // Supported extensions in order of preference.
        let extensions = ["otf", "ttf"]
        var fontURL: URL?
        for ext in extensions {
            if let url = Bundle.main.url(forResource: fileName, withExtension: ext) {
                fontURL = url
                break
            }
        }

        guard
            let url  = fontURL,
            let data = try? Data(contentsOf: url)
        else {
            // Font file missing from bundle — fall through to system font silently.
            return ""
        }

        // Determine the MIME type for the @font-face src descriptor.
        let mimeType = url.pathExtension.lowercased() == "otf"
            ? "font/otf"
            : "font/truetype"

        let base64 = data.base64EncodedString()

        return """
        @font-face {
            font-family: "\(font.cssName)";
            src: url('data:\(mimeType);base64,\(base64)') format('\(url.pathExtension.lowercased())');
            font-weight: normal;
            font-style: normal;
        }
        """
    }

    // MARK: - Fallback

    /// Minimal inline HTML used if the bundle template file cannot be loaded.
    private static func fallbackHTML(escapedText: String, styleBlock: String) -> String {
        """
        <!DOCTYPE html>
        <html>
        <head><meta charset="UTF-8"><style>\(styleBlock)</style></head>
        <body><div class="card"><p class="text" id="cardText">\(escapedText)</p></div></body>
        </html>
        """
    }
}

// ShareViewController.swift
// Share Extension principal class — captures text from the iOS share sheet.
//
// ARCHITECTURE NOTE:
// iOS Share Extensions use a UIViewController subclass as the entry point.
// This class is set as NSExtensionPrincipalClass in Info.plist, bypassing
// the default storyboard. No UI is shown — we extract text immediately,
// write it to the App Group, launch the main app, then dismiss.
//
// IPC FLOW (spec §22, design.md §2):
// 1. User picks Silver Horn from share sheet
// 2. Extension extracts plain text from NSExtensionItem attachments
// 3. Text is written to UserDefaults(suiteName: appGroupSuite)
// 4. Main app is launched via silverhorn://open custom URL scheme
// 5. Extension completes, dismissing itself
//
// FORMATTING RULE (spec §4):
// All formatting is stripped by requesting the `public.plain-text` UTI.
// Emoji are preserved because they are valid Unicode scalar values within
// plain text — no special handling needed.

import UIKit
import UniformTypeIdentifiers

class ShareViewController: UIViewController {

    // The App Group suite shared with the main app target.
    // Both targets declare this in their .entitlements file.
    private let appGroupSuite = "group.club.skape.silverhorn"

    // The UserDefaults key the main app reads on launch via loadSharedText().
    private let sharedTextKey  = "pendingSharedText"

    // The custom URL scheme that triggers the main app to open.
    private let launchURL      = "silverhorn://open"

    // MARK: - Lifecycle

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // No UI to show — begin processing immediately on appearance.
        extractText()
    }

    // MARK: - Text Extraction

    private func extractText() {
        guard
            let item   = extensionContext?.inputItems.first as? NSExtensionItem,
            let providers = item.attachments, !providers.isEmpty
        else {
            // Nothing usable — just dismiss without launching.
            completeRequest()
            return
        }

        // Prefer public.plain-text; fall back to public.text for rich-text sources.
        // Both UTIs yield a String when loaded.
        let preferredTypes = [
            UTType.plainText.identifier,  // "public.plain-text"
            UTType.text.identifier         // "public.text"
        ]

        for typeIdentifier in preferredTypes {
            if let provider = providers.first(where: { $0.hasItemConformingToTypeIdentifier(typeIdentifier) }) {
                provider.loadItem(forTypeIdentifier: typeIdentifier, options: nil) { [weak self] item, error in
                    guard let self else { return }

                    if let text = item as? String, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        // Write to App Group so the main app can read it.
                        self.writeToAppGroup(text)
                        // Open the main app via the registered URL scheme.
                        self.openMainApp()
                    }
                    // Always complete regardless of success/failure.
                    self.completeRequest()
                }
                return  // Handled — stop iterating type identifiers.
            }
        }

        // No supported type found.
        completeRequest()
    }

    // MARK: - App Group Write

    private func writeToAppGroup(_ text: String) {
        // SharedDefaults is the IPC channel between extension and main app.
        // Using synchronize() ensures the write is flushed before we open
        // the main app URL, avoiding a race condition on fast devices.
        let defaults = UserDefaults(suiteName: appGroupSuite)
        defaults?.set(text, forKey: sharedTextKey)
        defaults?.synchronize()
    }

    // MARK: - Launch Main App

    private func openMainApp() {
        // UIApplication.open is not available directly in extensions.
        // Walking the responder chain finds the UIApplication instance
        // that manages the extension process. This is the standard pattern.
        guard let url = URL(string: launchURL) else { return }
        var responder: UIResponder? = self
        while let current = responder {
            if let app = current as? UIApplication {
                app.open(url, options: [:], completionHandler: nil)
                return
            }
            responder = current.next
        }
    }

    // MARK: - Complete

    private func completeRequest() {
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
}

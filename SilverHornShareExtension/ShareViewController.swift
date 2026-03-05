// ShareViewController.swift
// Share Extension principal class — captures text from the iOS share sheet.
//
// ARCHITECTURE NOTE:
// iOS Share Extensions use a UIViewController subclass (not SwiftUI) as
// the entry point. This class is set as NSExtensionPrincipalClass in
// Info.plist, bypassing the default storyboard approach.
//
// LIFECYCLE:
// 1. iOS instantiates this class when the user picks Silver Horn from the share sheet.
// 2. `didSelectPost()` is called when the user confirms (we auto-confirm immediately).
// 3. We extract text, write it to the App Group, open the main app, then complete.
//
// IPC MECHANISM:
// App Groups shared UserDefaults suite (group.club.skape.silverhorn) is the
// only reliable IPC between an extension and its host app on iOS.
// See design.md §2 for the rationale.
//
// PHASE STATUS: Stub implementation — full text extraction in Phase 3.

import UIKit
import Social

class ShareViewController: UIViewController {

    // The App Group suite identifier shared with the main app target.
    // Both targets must have the same App Group entitlement configured.
    private let appGroupSuite = "group.club.skape.silverhorn"

    // The UserDefaults key the main app reads on launch.
    private let sharedTextKey = "pendingSharedText"

    // The custom URL scheme that triggers the main app to open and read
    // the pending text from the App Group.
    private let appURLScheme = "silverhorn://open"

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Immediately begin processing — no UI shown in the extension.
        // Full implementation in Phase 3.
        extractAndLaunch()
    }

    // MARK: - Text Extraction (Phase 3 fills this out fully)

    private func extractAndLaunch() {
        // Walk the extension items looking for plain text.
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let attachments = extensionItem.attachments else {
            completeRequest()
            return
        }

        // `public.plain-text` is the UTI for plain text content.
        // We also accept `public.text` as a broader fallback.
        let textUTI = "public.plain-text"
        guard let provider = attachments.first(where: { $0.hasItemConformingToTypeIdentifier(textUTI) }) else {
            completeRequest()
            return
        }

        provider.loadItem(forTypeIdentifier: textUTI, options: nil) { [weak self] item, _ in
            guard let self else { return }
            if let text = item as? String, !text.isEmpty {
                self.writeToAppGroup(text)
                self.openMainApp()
            }
            self.completeRequest()
        }
    }

    // MARK: - App Group Write

    private func writeToAppGroup(_ text: String) {
        // Write the shared text into the App Group UserDefaults suite.
        // The main app reads this key in AppState.loadSharedText().
        let defaults = UserDefaults(suiteName: appGroupSuite)
        defaults?.set(text, forKey: sharedTextKey)
        defaults?.synchronize()
    }

    // MARK: - Launch Main App

    private func openMainApp() {
        // `openURL` is not directly available on UIViewController in an extension.
        // We walk the responder chain to find a UIApplication instance.
        // This is the standard pattern for opening URLs from Share Extensions.
        guard let url = URL(string: appURLScheme) else { return }
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                application.open(url, options: [:], completionHandler: nil)
                return
            }
            responder = responder?.next
        }
    }

    // MARK: - Complete Extension

    private func completeRequest() {
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
}

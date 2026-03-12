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
// Rich text is normalized to plain text before storage.
// Emoji are preserved because they are valid Unicode scalar values in plain text.

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
    
    // Prevent duplicate extraction work if viewDidAppear is fired again.
    private var hasStartedProcessing = false
    
    // The extension accepts text payloads only.
    // This aligns with v1 scope: Notes text sharing only.
    private let supportedTypeIdentifiers: [String] = [
        UTType.plainText.identifier, // "public.plain-text"
        UTType.text.identifier       // "public.text"
    ]

    // MARK: - Lifecycle

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !hasStartedProcessing else { return }
        hasStartedProcessing = true
        // No UI to show — begin processing immediately on appearance.
        extractText()
    }

    // MARK: - Text Extraction

    private func extractText() {
        let candidates = shareCandidates()
        guard !candidates.isEmpty else {
            completeRequest()
            return
        }
        loadCandidate(candidates, at: 0)
    }

    private func shareCandidates() -> [(provider: NSItemProvider, typeIdentifier: String)] {
        guard let items = extensionContext?.inputItems as? [NSExtensionItem] else {
            return []
        }

        let providers = items
            .compactMap(\.attachments)
            .flatMap { $0 }

        var candidates: [(provider: NSItemProvider, typeIdentifier: String)] = []
        for typeIdentifier in supportedTypeIdentifiers {
            for provider in providers where provider.hasItemConformingToTypeIdentifier(typeIdentifier) {
                candidates.append((provider: provider, typeIdentifier: typeIdentifier))
            }
        }
        return candidates
    }

    private func loadCandidate(_ candidates: [(provider: NSItemProvider, typeIdentifier: String)], at index: Int) {
        guard index < candidates.count else {
            completeRequest()
            return
        }

        let candidate = candidates[index]
        candidate.provider.loadItem(forTypeIdentifier: candidate.typeIdentifier, options: nil) { [weak self] item, _ in
            guard let self else { return }

            if let text = self.coerceSharedText(from: item),
               !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                DispatchQueue.main.async {
                    self.writeToAppGroup(text)
                    self.openMainApp()
                    self.completeRequest()
                }
                return
            }

            self.loadCandidate(candidates, at: index + 1)
        }
    }

    private func coerceSharedText(from item: NSSecureCoding?) -> String? {
        if let text = item as? String { return text }
        if let attributed = item as? NSAttributedString { return attributed.string }
        if let data = item as? Data {
            return String(data: data, encoding: .utf8)
        }
        return nil
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
        DispatchQueue.main.async {
            self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
        }
    }
}

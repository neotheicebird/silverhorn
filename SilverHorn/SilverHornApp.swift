// SilverHornApp.swift
// Entry point for the Silver Horn application.
//
// ARCHITECTURE NOTE:
// SwiftUI's @main attribute marks this struct as the app entry point.
// The App protocol requires a `body` property returning a Scene.
// WindowGroup is the standard scene for document/content apps on iOS.
//
// URL HANDLING:
// The `.onOpenURL` modifier intercepts the `silverhorn://open` scheme
// that the Share Extension calls after writing text to the App Group.
// This is the IPC bridge between the extension and this app.

import SwiftUI

@main
struct SilverHornApp: App {

    // AppState is the single source of truth for all UI state.
    // Declared here at the app level so it is available to all views
    // in the hierarchy via the environment.
    @State private var appState = AppState()
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var skipOnboardingForCurrentLaunch = SilverHornApp.hasPendingSharedTextAtLaunch()

    var body: some Scene {
        WindowGroup {
            MainScreen()
                .environment(appState)
                .tint(.gray)
                // Listen for the silverhorn://open URL fired by the Share Extension.
                // Phase 4 will implement the full text ingestion logic here.
                .onOpenURL { url in
                    guard url.scheme == "silverhorn" else { return }
                    skipOnboardingForCurrentLaunch = true
                    appState.loadSharedText()
                }
                .fullScreenCover(
                    isPresented: Binding(
                        get: { !hasSeenOnboarding && !skipOnboardingForCurrentLaunch },
                        set: { isPresented in
                            if !isPresented { hasSeenOnboarding = true }
                        }
                    )
                ) {
                    FirstLaunchOnboardingView {
                        hasSeenOnboarding = true
                    }
                }
                .preferredColorScheme(ColorScheme.dark)
        }
    }

    private static func hasPendingSharedTextAtLaunch() -> Bool {
        let defaults = UserDefaults(suiteName: "group.club.skape.silverhorn")
        guard let text = defaults?.string(forKey: "pendingSharedText") else {
            return false
        }
        return !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

private struct FirstLaunchOnboardingView: View {
    let onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 30) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Welcome to Silverhorn")
                        .font(.largeTitle.weight(.semibold))
                    Text("Turn text from Apple Notes into clean, shareable image cards.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                VStack(spacing: 20) {
                    featureRow(
                        symbol: "note.text",
                        title: "Share from Apple Notes",
                        text: "Open a note and send the text to Silverhorn from the Share sheet."
                    )
                    featureRow(
                        symbol: "square.stack",
                        title: "Instant image cards",
                        text: "Your paragraphs are automatically turned into simple visual cards."
                    )
                    featureRow(
                        symbol: "square.and.arrow.up",
                        title: "Share anywhere",
                        text: "Send your cards to Instagram, Messages, Journal, or any app that accepts images."
                    )
                }

                Text("If Silverhorn isn't visible in the Share sheet, tap \"More\" and enable it.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Spacer(minLength: 20)
            }
            .padding(24)
            .safeAreaInset(edge: .bottom) {
                continueButton
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var continueButton: some View {
        Button {
            onDismiss()
        } label: {
            Text("Continue")
                .font(.headline)
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.roundedRectangle(radius: 12))
        .tint(Color(white: 0.88))
        .controlSize(.large)
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }

    private func featureRow(symbol: String, title: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: symbol)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.secondary)
                .frame(width: 26, alignment: .leading)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
    }
}

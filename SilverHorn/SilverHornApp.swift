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

    var body: some Scene {
        WindowGroup {
            MainScreen()
                .environment(appState)
                .tint(.gray)
                // Listen for the silverhorn://open URL fired by the Share Extension.
                // Phase 4 will implement the full text ingestion logic here.
                .onOpenURL { url in
                    guard url.scheme == "silverhorn" else { return }
                    appState.loadSharedText()
                }
        }
    }
}

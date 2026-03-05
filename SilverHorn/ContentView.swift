// ContentView.swift
// Temporary root view — replaced by MainScreen in Phase 11.
//
// This stub exists solely to give the project a valid SwiftUI scene
// during Phase 0 (project setup). It will be deleted and replaced
// with UI/MainScreen.swift once that phase is implemented.

import SwiftUI

struct ContentView: View {

    @Environment(AppState.self) private var appState

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "rectangle.stack")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            Text("Silver Horn")
                .font(.largeTitle)
            Text("Share text from Notes to create social cards.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
}

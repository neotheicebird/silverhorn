// TextEditModal.swift
// Per-card text editor modal.
//
// SPEC §11 — Card Editing:
// "editing modifies only that card"
// "line breaks are NOT allowed"
// "editing represents a single paragraph only"
// "Cancel → changes discarded, Save → updates card text"

import SwiftUI

struct TextEditModal: View {

    // The card being edited — read-only here; mutations go through onSave.
    let card: CardModel

    // Called with the new text when the user taps Save.
    var onSave: (String) -> Void

    // Called when the user taps Cancel.
    var onCancel: () -> Void

    // Local mutable copy of the text. Starts as the card's current text.
    // Discarded on cancel; passed to onSave on confirm.
    @State private var editedText: String

    init(card: CardModel, onSave: @escaping (String) -> Void, onCancel: @escaping () -> Void) {
        self.card     = card
        self.onSave   = onSave
        self.onCancel = onCancel
        // Seed the editor with the card's existing text.
        _editedText = State(initialValue: card.text)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {

                Text("Edit paragraph text. Line breaks are not allowed.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)

                // TextEditor for multi-line display with a single-paragraph constraint.
                // The .onChange below strips any newline characters the user types
                // or pastes, enforcing the "no line breaks" rule (spec §11).
                TextEditor(text: $editedText)
                    .font(.body)
                    .padding(8)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.horizontal)
                    .frame(minHeight: 160)
                    // Strip newlines as the user types (spec §11).
                    .onChange(of: editedText) { _, newValue in
                        let stripped = newValue.replacingOccurrences(of: "\n", with: " ")
                        if stripped != newValue { editedText = stripped }
                    }

                Spacer()
            }
            .padding(.top, 16)
            .navigationTitle("Edit Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onCancel() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // Trim whitespace before saving so accidental spaces
                        // at the start/end don't carry through to the card.
                        onSave(editedText.trimmingCharacters(in: .whitespacesAndNewlines))
                    }
                    .fontWeight(.semibold)
                    // Disable Save if the field is empty after trimming.
                    .disabled(editedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

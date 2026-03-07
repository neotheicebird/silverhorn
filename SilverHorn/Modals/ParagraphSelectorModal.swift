// ParagraphSelectorModal.swift
// Modal shown when the user shares text with more than 8 paragraphs.
//
// SPEC BEHAVIOUR (§5):
// - Scrollable list of all parsed paragraphs
// - Radio-style selection circles (filled = selected)
// - First 8 paragraphs pre-selected on open
// - Max 8 can be selected simultaneously
// - Tapping a 9th paragraph when 8 are selected: no-op
// - Confirm → converts selection to cards
//
// EDUCATIONAL NOTE — @Binding vs @State:
// `paragraphs` is passed as @Binding so this modal can mutate the
// selection state that lives in AppState. The parent view owns the
// data; this modal only reads and toggles `isSelected`.
//
// Sheet presentation is handled by the parent via `isPresented` binding
// (driven by AppState.showParagraphSelector).

import SwiftUI

struct ParagraphSelectorModal: View {

    // The full list of parsed paragraphs, owned by AppState.
    // We mutate `isSelected` on individual elements via the binding.
    @Binding var paragraphs: [ParagraphModel]

    // Dismisses the sheet. Passed from the parent.
    var onConfirm: () -> Void

    // Computed count of currently selected paragraphs.
    // Used to enforce the 8-paragraph limit and to label the button.
    private var selectedCount: Int {
        paragraphs.filter(\.isSelected).count
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {

                // Subtitle explaining the limit to the user.
                Text("Choose up to \(ParagraphParser.maxParagraphs) paragraphs")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 12)

                // Scrollable list of paragraphs with radio-circle toggles.
                List {
                    ForEach($paragraphs) { $paragraph in
                        ParagraphRow(
                            paragraph: paragraph,
                            isAtLimit: selectedCount >= ParagraphParser.maxParagraphs
                        ) {
                            toggleSelection(for: &paragraph)
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Select Paragraphs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Confirm (\(selectedCount))") {
                        onConfirm()
                    }
                    // Disabled until at least one paragraph is selected.
                    .disabled(selectedCount == 0)
                    .fontWeight(.semibold)
                }
            }
        }
    }

    // Toggles selection state for a paragraph.
    // If the paragraph is unselected and the limit is already reached,
    // the tap is silently ignored (spec §5).
    private func toggleSelection(for paragraph: inout ParagraphModel) {
        if paragraph.isSelected {
            paragraph.isSelected = false
        } else if selectedCount < ParagraphParser.maxParagraphs {
            paragraph.isSelected = true
        }
        // If at limit and attempting to select: no-op (spec §5).
    }
}

// MARK: - Paragraph Row

// A single row in the selector list.
// Shows a radio circle on the left and a truncated text preview on the right.
private struct ParagraphRow: View {

    let paragraph: ParagraphModel
    // True when 8 are already selected AND this paragraph is not one of them.
    let isAtLimit: Bool
    let onTap: () -> Void

    // Unselectable when: limit reached AND this row is not selected.
    private var isDisabled: Bool { isAtLimit && !paragraph.isSelected }

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 14) {

                // Radio-style selection circle.
                // Filled circle = selected; ring = unselected.
                Image(systemName: paragraph.isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(paragraph.isSelected ? .primary : .secondary)
                    .font(.title3)
                    .padding(.top, 2)

                // Truncated paragraph preview — 3 lines max to keep rows compact.
                Text(paragraph.text)
                    .font(.body)
                    .foregroundStyle(isDisabled ? .tertiary : .primary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
            .padding(.vertical, 6)
            .contentShape(Rectangle())  // Makes the full row tappable.
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }
}

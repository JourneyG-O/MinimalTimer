//
//  TimerRow.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 10/22/25.
//

import SwiftUI

struct TimerRow: View {
    // MARK: - Dependencies
    let timer: TimerModel
    let isSelected: Bool
    let onSelect: () -> Void
    let onEdit: () -> Void


    var body: some View {
        HStack(spacing: 12) {
            // Color swatch
            Circle()
                .fill(timer.color.toColor)
                .frame(width: 14, height: 14)

            // Title + total time
            VStack(alignment: .leading, spacing: 2) {
                Text(timer.title.isEmpty ? "Timer" : timer.title)
                    .font(.body.weight(.semibold))
                    .lineLimit(1)
                    .truncationMode(.tail)

                Text(formatTotalTime(seconds: Int(timer.totalTime)))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Selected mark
            if isSelected {
                Image(systemName: "checkmark")
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.secondary)
            }

            // Viertical ellipsis edit button
            Button(action: onEdit) {
                Image(systemName: "ellip")
            }
        }
    }

    // MARK: - Helpers
    private func formatTotalTime(seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

//#Preview {
//    TimerRow(_)
//}

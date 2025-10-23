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

    // MARK: - Press State
    var body: some View {
        HStack {
            // Color swatch
            Circle()
                .fill(timer.color.toColor)
                .frame(width: 40, height: 40)

            Spacer()

            // Title + total time
            VStack(alignment: .center, spacing: 4) {
                Text(timer.title.isEmpty ? "Timer" : timer.title)
                    .font(.body.weight(.semibold))
                    .lineLimit(1)
                    .truncationMode(.tail)

                Text(formatTotalTime(seconds: Int(timer.totalTime)))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Vertical ellipsis edit button
            Button(action: onEdit) {
                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(90))
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: 40, height: 40)
                    .contentShape(Rectangle())
                    .symbolRenderingMode(.hierarchical)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Edit Timer")
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 15)
        .glassEffect(.regular.interactive())
        .onTapGesture { onSelect() }
        .accessibilityElement(children: .combine)
    }

    // MARK: - Helpers
    private func formatTotalTime(seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

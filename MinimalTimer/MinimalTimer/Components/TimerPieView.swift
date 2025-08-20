//
//  NewTimerContentView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 6/23/25.
//

import SwiftUI

struct TimerPieView: View {
    // MARK: - Properties
    let timer: TimerModel
    let progress: CGFloat
    let isRunning: Bool
    let isDragging: Bool
    let interactionMode: InteractionMode

    // MARK: - Computed Properties
    private var fillColor: Color {
        if interactionMode == .normal && !isRunning && !isDragging {
            return timer.color.toColor.opacity(0.6)
        } else {
            return timer.color.toColor
        }
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            PieShape(progress: progress)
                .fill(fillColor)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            if interactionMode == .normal && isDragging {
                TickMarksView(totalMinutes: Int(timer.totalTime) / 60)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

//
//  NewTimerContentView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 6/23/25.
//

import SwiftUI

struct TimerContentView: View {
    // MARK: - Properties
    let timer: TimerModel
    let progress: CGFloat
    let diameter: CGFloat
    let isRunning: Bool
    let isDragging: Bool
    let interactionMode: InteractionMode

    // MARK: - Computed Properties
    private var fillColor: Color {
        if interactionMode == .normal && !isRunning && !isDragging {
            return timer.color.opacity(0.6)
        } else {
            return timer.color
        }
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            PieShape(progress: progress)
                .fill(fillColor)
                .frame(width: diameter, height: diameter)

            if interactionMode == .normal && isDragging {
                TickMarksView(
                    diameter: diameter,
                    totalMinutes: Int(timer.totalTime) / 60
                )
            }
        }
    }
}

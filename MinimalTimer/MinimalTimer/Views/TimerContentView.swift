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

    // MARK: - Constants
        let offsetValue: CGFloat = 4

    // MARK: - Computed Properties
    var timerDiameter: CGFloat { diameter - 8 }

    // MARK: - Body
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.clear)
                .frame(width: offsetValue, height: offsetValue)

            Circle()
                .fill(Color.white.opacity(0.7))
                .frame(width: timerDiameter, height: timerDiameter)
                .offset(x: 4, y: 4)

            Circle()
                .fill(
                    Color.smoke
                        .shadow(.inner(color: .gray.opacity(0.6), radius: 6, x: 6, y: 6))
                )
                .frame(width: timerDiameter, height: timerDiameter)
                .animation(interactionMode == .normal ? .easeInOut(duration: 0.25) : nil, value: isRunning)

            PieShape(progress: progress)
                .fill(interactionMode == .normal ? (isRunning ? timer.color.opacity(0.6) : timer.color.opacity(0.3)) : timer.color.opacity(0.3))
                .animation(interactionMode == .normal ? .easeInOut(duration: 0.25) : nil, value: isRunning)
                .frame(width: timerDiameter, height: timerDiameter)

            if interactionMode == .normal && isDragging {
                TickMarksView(
                    diameter: timerDiameter,
                    totalMinutes: Int(timer.totalTime) / 60
                )
            }
        }
    }
}

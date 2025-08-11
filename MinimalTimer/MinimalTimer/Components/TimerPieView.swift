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
            return timer.color.opacity(0.6)
        } else {
            return timer.color
        }
    }

    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height

            ZStack {
                PieShape(progress: progress)
                    .fill(fillColor)
                    .frame(width: width, height: height)

                if interactionMode == .normal && isDragging {
                    TickMarksView(totalMinutes: Int(timer.totalTime) / 60)
                    .frame(width: width, height: height)
                }
            }
        }

    }
}

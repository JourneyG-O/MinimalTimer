//
//  NewTimerContentView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 6/23/25.
//

import SwiftUI

struct TimerPieView: View {
    let timer: TimerModel
    let progressAt: (Date) -> CGFloat
    let isRunning: Bool
    let isDragging: Bool
    let interactionMode: InteractionMode

    private var fillColor: Color {
        if interactionMode == .normal && !isRunning && !isDragging {
            return timer.color.toColor.opacity(0.7)
        } else {
            return timer.color.toColor
        }
    }

    var body: some View {
        ZStack {

            if timer.lastUserSetTime == 0 {
                ZeroMarker(color: fillColor)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            TimelineView(.animation(paused: !isRunning)) { context in
                PieShape(progress: progressAt(context.date))
                    .fill(fillColor)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            if isDragging || timer.isTickAlwaysVisible {
                let useSeconds = timer.totalTime < Constants.Time.snapSecondThreshold
                Group {
                    if useSeconds {
                        TickMarksView(totalSeconds: Int(timer.totalTime))
                    } else {
                        TickMarksView(totalMinutes: Int(timer.totalTime / 60))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

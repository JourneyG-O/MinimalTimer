//
//  TimerDisplayView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 6/23/25.
//

import SwiftUI

struct TimerDisplayView: View {
    // MARK: - Properties
    let timer: TimerModel
    let progress: CGFloat
    let diameter: CGFloat
    let isRunning: Bool
    let isDragging: Bool
    let interactionMode: InteractionMode
    let onSingleTap: (() -> Void)?
    let onDoubleTap: (() -> Void)?
    let onDrag: ((Double) -> Void)?
    let onDragEnd: (() -> Void)?
    let onLongPress: (() -> Void)?

    // MARK: - Body
    var body: some View {
        ZStack {
            TimerContentView(
                timer: timer,
                progress: progress,
                diameter: diameter,
                isRunning: isRunning,
                isDragging: isDragging,
                interactionMode: interactionMode
            )
            .frame(width: diameter, height: diameter)

            TimerInteractionView(
                interactionMode: interactionMode,
                diameter: diameter,
                onSingleTap: onSingleTap,
                onDoubleTap: onDoubleTap,
                onDrag: onDrag,
                onDragEnd: onDragEnd,
                onLongPress: onLongPress
            )
            .frame(width: diameter, height: diameter)
        }
    }
}

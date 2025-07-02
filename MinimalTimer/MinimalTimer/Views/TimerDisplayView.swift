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
                onDoubleTap: interactionMode == .normal ? onDoubleTap : nil,
                onDrag: interactionMode == .normal ? onDrag : nil,
                onDragEnd: interactionMode == .normal ? onDragEnd : nil
            )
            .frame(width: diameter, height: diameter)
        }
    }
}

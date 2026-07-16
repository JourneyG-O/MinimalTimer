//
//  TimerDisplayView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 6/23/25.
//

import SwiftUI

struct SingleTimerView: View {
    let timer: TimerModel
    let progressAt: (Date) -> CGFloat
    let isRunning: Bool
    let isDragging: Bool
    let interactionMode: InteractionMode
    let onSingleTap: (() -> Void)?
    let onDoubleTap: (() -> Void)?
    let onDrag: ((Double) -> Void)?
    let onDragEnd: (() -> Void)?

    var body: some View {
        ZStack {
            TimerPieView(
                timer: timer,
                progressAt: progressAt,
                isRunning: isRunning,
                isDragging: isDragging,
                interactionMode: interactionMode
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            TimerDialView(
                interactionMode: interactionMode,
                onSingleTap: onSingleTap,
                onDoubleTap: interactionMode == .normal ? onDoubleTap : nil,
                onDrag: interactionMode == .normal ? onDrag : nil,
                onDragEnd: interactionMode == .normal ? onDragEnd : nil
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

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
    let isInteractive: Bool
    let onSingleTap: (() -> Void)?
    let onDoubleTap: (() -> Void)?
    let onDrag: ((Double) -> Void)?
    let onDragEnd: (() -> Void)?

    // MARK: - Body
    var body: some View {
        ZStack {
            NewTimerContentView(
                timer: timer,
                progress: progress,
                diameter: diameter,
                isRunning: isRunning,
                isDragging: isDragging,
                isPreviewMode: !isInteractive
            )

            TimerInteractionView(
                isInteractive: isInteractive,
                diameter: diameter,
                onSingleTap: onSingleTap,
                onDoubleTap: isInteractive ? onDoubleTap : nil,
                onDrag: isInteractive ? onDrag : nil,
                onDragEnd: isInteractive ? onDragEnd : nil
            )
        }
    }
}

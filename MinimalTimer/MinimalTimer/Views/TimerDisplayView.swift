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
    let isSwitchMode: Bool
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
                isPreviewMode: !isSwitchMode
            )

            TimerInteractionView(
                isSwitchMode: isSwitchMode,
                diameter: diameter,
                onSingleTap: onSingleTap,
                onDoubleTap: isSwitchMode ? onDoubleTap : nil,
                onDrag: isSwitchMode ? onDrag : nil,
                onDragEnd: isSwitchMode ? onDragEnd : nil
            )
        }
    }
}

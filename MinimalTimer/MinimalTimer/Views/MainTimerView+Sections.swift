//
//  MainTimerView+Sections.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 6/10/25.
//

import SwiftUI

// MARK: - Title View
extension MainTimerView {
    struct TitleView: View {
        let title: String?
        var body: some View {
            Text(title ?? "Minimal Timer")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .fontWeight(.semibold)
                .foregroundColor(.black)
        }
    }
}

// MARK: - Timer Display Section

extension MainTimerView {
    struct TimerDisplaySection: View {
        @ObservedObject var viewModel: MainViewModel
        let diameter: CGFloat

        var body: some View {
            ZStack {
                if let timer = viewModel.currentTimer {
                    TimerContentView(viewModel: viewModel,timer: timer, progress: viewModel.progress, diameter: diameter)
                }

                TimerInteractionView(
                    isInteractive: true,
                    diameter: diameter,
                    onSingleTap: {
                        viewModel.isRunning ? viewModel.pause(fromUser: true) : viewModel.start()
                    }, onDoubleTap: {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            viewModel.reset()
                        }
                    }, onDrag: { angle in
                        viewModel.setUserProgress(from: angle)
                    }, onDragEnd: {
                        viewModel.endDragging()
                    }
                )
            }
        }
    }
}

// MARK: - Paused Status Text

extension MainTimerView {
    struct PausedStatusText: View {
        let isRunning: Bool
        let diameter: CGFloat

        var body: some View {
            Text("Paused")
                .font(.body)
                .opacity(isRunning ? 0 : 1)
                .animation(.easeInOut(duration: 0.3), value: isRunning)
                .offset(y: diameter / 2 + 20)
        }
    }
}

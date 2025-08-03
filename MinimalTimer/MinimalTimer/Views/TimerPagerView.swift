//
//  NewTimerPagerView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 7/21/25.
//

import SwiftUI

struct TimerPagerView: View {
    @ObservedObject var viewModel: MainViewModel

    private var timers: [TimerModel] { viewModel.timers }
    private var interactionMode: InteractionMode { viewModel.interactionMode }
    private let normalScale: CGFloat = 0.8
    private let switchingScale: CGFloat = 0.6
    private let pausedStatusOffset: CGFloat = 20

    var body: some View {
        GeometryReader { geometry in
            let scale: CGFloat = interactionMode == .normal ? normalScale : switchingScale
            let timerWidth = geometry.size.width * scale
            let timerHeight = geometry.size.height * scale

            ZStack {
                TabView(selection: $viewModel.selectedTimerIndex) {
                    ForEach(0..<(viewModel.timers.count + 1), id: \.self) { index in
                        if index < timers.count {
                            let timer = timers[index]
                            let progress = viewModel.progress
                            let currentIsRunning = viewModel.isRunning
                            let currentIsDragging = viewModel.isDragging
                            let currentInteractionMode = interactionMode

                            let singleTapAction: () -> Void = {
                                if currentInteractionMode == .switching {
                                    viewModel.selectTimer(at: index)
                                    viewModel.exitSwitchMode()
                                } else {
                                    viewModel.startOrPauseTimer()
                                }
                            }

                            let doubleTapAction: (() -> Void)? = currentInteractionMode == .switching ? nil : viewModel.reset

                            let dragAction: ((Double) -> Void)? = currentInteractionMode == .switching ? nil : { angle in
                                viewModel.setUserProgress(from: angle)
                            }

                            let dragEndAction: (() -> Void)? = currentInteractionMode == .switching ? nil : viewModel.endDragging

                            SingleTimerView(
                                timer: timer,
                                progress: progress,
                                isRunning: currentIsRunning,
                                isDragging: currentIsDragging,
                                interactionMode: currentInteractionMode,
                                onSingleTap: singleTapAction,
                                onDoubleTap: doubleTapAction,
                                onDrag: dragAction,
                                onDragEnd: dragEndAction
                            )
                            .frame(width: timerWidth, height: timerHeight)
                            .animation(.easeInOut(duration: 0.3), value: interactionMode)
                            .tag(index)
                        } else {
                            AddTimerCardView()
                                .frame(width: timerWidth, height: timerHeight)
                                .onTapGesture {
                                    viewModel.presentAddTimerView()
                                }
                                .tag(index)
                        }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                if interactionMode == .normal {
                    PausedStatusView(isRunning: viewModel.isRunning)
                        .offset(y: timerHeight / 2 + pausedStatusOffset)
                }
            }
        }

    }
}

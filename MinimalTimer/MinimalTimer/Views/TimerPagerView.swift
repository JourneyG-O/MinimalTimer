//
//  NewTimerPagerView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 7/21/25.
//

import SwiftUI

struct TimerPagerView: View {
    @ObservedObject var viewModel: MainViewModel

    let diameter: CGFloat

    private var timers: [TimerModel] { viewModel.timers }
    private var interactionMode: InteractionMode { viewModel.interactionMode }
    private var currentTimerDiameter: CGFloat { interactionMode == .normal ? diameter : diameter * 0.8 }

    var body: some View {
        TabView(selection: $viewModel.selectedTimerIndex) {
            ForEach(0..<(viewModel.timers.count + 1), id: \.self) { index in
                if index < timers.count {
                    let timer = timers[index]
                    let progress = timer.totalTime > 0 ? CGFloat(timer.currentTime / timer.totalTime) : 0
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
                        diameter: currentTimerDiameter,
                        isRunning: currentIsRunning,
                        isDragging: currentIsDragging,
                        interactionMode: currentInteractionMode,
                        onSingleTap: singleTapAction,
                        onDoubleTap: doubleTapAction,
                        onDrag: dragAction,
                        onDragEnd: dragEndAction
                    )
                    .frame(width: currentTimerDiameter, height: currentTimerDiameter)
                    .tag(index)
                } else {
                    AddTimerCardView(diameter: currentTimerDiameter)
                        .onTapGesture {
                            viewModel.presentAddTimerView()
                        }
                        .tag(index)
                }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
}

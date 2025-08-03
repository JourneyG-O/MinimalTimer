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
    private let scale: CGFloat = 0.6
    private let pausedStatusOffset: CGFloat = 20

    var body: some View {
        GeometryReader { geometry in
            let timerWidth = geometry.size.width * scale
            let timerHeight = geometry.size.height * scale

            ZStack {
                TabView(selection: $viewModel.selectedTimerIndex) {
                    ForEach(0..<(viewModel.timers.count + 1), id: \.self) { index in
                        if index < timers.count {
                            let timer = timers[index]

                            SingleTimerView(
                                timer: timer,
                                progress: viewModel.progress,
                                isRunning: viewModel.isRunning,
                                isDragging: viewModel.isRunning,
                                interactionMode: viewModel.interactionMode,
                                onSingleTap: {
                                    viewModel.selectTimer(at: index)
                                    viewModel.exitSwitchMode()
                                },
                                onDoubleTap: nil,
                                onDrag: nil,
                                onDragEnd: nil
                            )
                            .frame(width: timerWidth, height: timerHeight)
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
            }
        }

    }
}

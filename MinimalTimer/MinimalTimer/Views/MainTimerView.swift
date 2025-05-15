//
//  MainTimerView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 4/24/25.
//

import SwiftUI

struct MainTimerView: View {
    @ObservedObject var viewModel: MainViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                // 타이머 UI (모드에 따라 다르게 표시)
                timerDisplayView

                // 남은 시간 텍스트
                RemainingTimeView(viewModel: viewModel)

                Spacer()
            }
            .padding()
            .navigationTitle(viewModel.currentTimer?.title ?? "Minimal Timer")
            .navigationBarTitleDisplayMode(.inline)
            .background(
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(
                        LongPressGesture(minimumDuration: 0.5)
                            .onEnded { _ in
                                withAnimation {
                                    viewModel.switchMode()
                                }
                            }
                    )
            )
        }
    }

    @ViewBuilder
    var timerDisplayView: some View {
        switch viewModel.interactionMode {
        case .normal:
            if let timer = viewModel.currentTimer {
                TimerContentView(
                    timer: timer,
                    progress: viewModel.progress,
                    isInteractive: true,
                    onSingleTap: {
                        viewModel.isRunning ? viewModel.pause() : viewModel.start()
                    },
                    onDoubleTap: {
                        viewModel.reset()
                    },
                    onDrag: { angle in
                        viewModel.setUserProgress(from: angle)
                    }
                )
                .frame(height: 280)
            }
        case . switchMode:
            // CarouselView 예정
            Text("타이머 전환 모드입니다.")
                .font(.title2)
                .foregroundColor(.gray)
        default:
            EmptyView()
        }
    }
}

#Preview {
    MainTimerView(viewModel: .init())
}

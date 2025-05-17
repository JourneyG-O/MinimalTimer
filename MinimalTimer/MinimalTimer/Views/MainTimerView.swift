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
            VStack {
                Spacer()

                // 타이머 영역 (세로 중앙 정렬)
                if let timer = viewModel.currentTimer {
                    GeometryReader { geometry in
                        let size = min(geometry.size.width, geometry.size.height) * 0.7

                        VStack(spacing: 16) {
                            // 배경 원 + 원형 타이머
                            ZStack {
                                Circle()
                                    .fill(Color.black.opacity(0.05))
                                    .frame(width: size + 30, height: size + 30)
                                    .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)

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
                                .frame(width: size, height: size)
                                .opacity(viewModel.isRunning ? 1.0 : 0.5)
                                .animation(.easeInOut(duration: 0.25), value: viewModel.isRunning)
                            }

                            // 남은 시간 표시
                            RemainingTimeView(viewModel: viewModel)
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    }
                    .frame(height: 400)
                }

                Spacer()
            }
            .padding()
            .navigationTitle(viewModel.currentTimer?.title ?? "Minimal Timer")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    MainTimerView(viewModel: .init())
}

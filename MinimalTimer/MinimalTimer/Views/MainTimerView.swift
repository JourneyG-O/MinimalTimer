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
            ZStack {
                GeometryReader { geometry in
                    let width = geometry.size.width

                    if let timer = viewModel.currentTimer {
                        // 원형 타이머
                        TimerContentView(
                            timer: timer,
                            progress: viewModel.progress,
                            diameter: width * 0.8
                        )
                    }


                    // 남은 시간
                    // RemainingTimeView()

                    // 타이머 인터랙션을 받을 뷰
                    TimerInteractionView(
                        isInteractive: true,
                        diameter: width * 0.8,
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
                }

            }
        }


        // TODO: 리팩토링 전 구조 참고용, v1 UI 완성 후 삭제 예정
        // MARK: - Legacy 타이머 UI 구조
        /*
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
                                .shadow(color: .black.opacity(0.5), radius: 4, x: 4, y: 4)
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
        */
    }
}

#Preview {
    MainTimerView(viewModel: .init())
}

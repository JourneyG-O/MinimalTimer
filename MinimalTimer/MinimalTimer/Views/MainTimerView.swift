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
        GeometryReader { geometry in
            let width = geometry.size.width
            let diameter = width * 0.8

            ZStack {
                Color.smoke.ignoresSafeArea()
                VStack {
                    Rectangle().frame(height: geometry.size.height * 0.1)

                    // 타이틀
                    Text("Minimal Timer")
                        .font(.largeTitle)
                        .fontWeight(.semibold)

                    Spacer().frame(height: geometry.size.height * 0.05) // 타이틀 아래 여백

                    ZStack {
                        if let timer = viewModel.currentTimer {
                            TimerContentView(viewModel: viewModel,timer: timer, progress: viewModel.progress, diameter: diameter)
                        }

                        TimerInteractionView(
                            isInteractive: true,
                            diameter: diameter,
                            onSingleTap: {
                                viewModel.isRunning ? viewModel.pause() : viewModel.start()
                            }, onDoubleTap: {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    viewModel.reset()
                                }
                            }, onDrag: { angle in
                                viewModel.setUserProgress(from: angle)
                            }
                        )
                    }
                    .frame(height: geometry.size.height * 0.45)

                    // 상태 텍스트 (정지 중일 때만)
                    Text("Paused")
                        .font(.body)
                        .foregroundColor(viewModel.isRunning ? .clear : .gray)
                        .padding(.top, geometry.size.height * 0.02)
                        .transition(.opacity)


                    // 남은 시간
                    RemainingTimeView(viewModel: viewModel)
                        .font(.system(size: 40, weight: .bold, design: .monospaced))
                        .padding(.top, geometry.size.height * 0.01)
                }
            }


        }
    }
}

#Preview {
    MainTimerView(viewModel: .init())
}

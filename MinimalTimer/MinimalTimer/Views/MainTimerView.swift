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

                    Spacer()

                    // 타이틀
                    Text("Minimal Timer")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(.black)

                    Spacer()

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

                    Spacer()

                    // 남은 시간
                    RemainingTimeView(viewModel: viewModel)

                    Spacer()
                }

                Text("Paused")
                    .font(.body)
                    .opacity(viewModel.isRunning ? 0 : 1)
                    .animation(.easeInOut(duration: 0.3), value: viewModel.isRunning)
                    .offset(y: diameter / 2 + 20)
            }
        }
    }
}

#Preview {
    MainTimerView(viewModel: .init())
}

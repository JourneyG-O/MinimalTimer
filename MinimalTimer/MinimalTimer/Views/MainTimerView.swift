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
            GeometryReader { geometry in
                let width = geometry.size.width
                let diameter = width * 0.8

                ZStack {
                    Color.smoke.ignoresSafeArea()

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

                    RemainingTimeView(viewModel: viewModel)
                        .offset(y: width / 2 + 10)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .navigationTitle(viewModel.currentTimer?.title ?? "Minimal Timer")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    MainTimerView(viewModel: .init())
}

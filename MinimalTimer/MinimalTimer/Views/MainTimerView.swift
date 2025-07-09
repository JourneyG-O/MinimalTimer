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
                    .gesture(
                        LongPressGesture(minimumDuration: 0.6)
                            .onEnded { _ in
                                viewModel.enterSwitchMode()
                            }
                    )

                TotalDurationText(
                    totalTime: viewModel.currentTimer?.totalTime ?? 0,
                    diameter: diameter,
                    isVisible: viewModel.interactionMode == .switching
                )

                VStack {
                    Spacer()
                    TitleView(title: viewModel.currentTimer?.title)
                        .opacity(viewModel.interactionMode == .switching ? 1 : 0)
                    Spacer()
                    Color.clear
                        .frame(height: diameter)
                    Spacer()
                    RemainingTimeView(viewModel: viewModel)
                    Spacer()
                }

                TimerCarouselView(
                    viewModel: viewModel,
                    diameter: diameter
                )
                .frame(width: width, height: diameter)

                PausedStatusText(isRunning: viewModel.isRunning, diameter: diameter)
            }
        }
    }
}

#Preview {
    MainTimerView(viewModel: .init())
}

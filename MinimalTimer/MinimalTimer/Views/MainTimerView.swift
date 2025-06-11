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
                    TitleView(title: viewModel.currentTimer?.title)
                    Spacer()
                    TimerDisplaySection(viewModel: viewModel, diameter: diameter)
                    Spacer()
                    RemainingTimeView(viewModel: viewModel)
                    Spacer()
                }

                PausedStatusText(isRunning: viewModel.isRunning, diameter: diameter)
            }
        }
    }
}

#Preview {
    MainTimerView(viewModel: .init())
}

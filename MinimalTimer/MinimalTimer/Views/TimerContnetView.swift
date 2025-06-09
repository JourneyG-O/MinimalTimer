//
//  TimerContnetView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 5/13/25.
//

import SwiftUI

struct TimerContentView: View {
    @ObservedObject var viewModel: MainViewModel

    let timer: TimerModel
    let progress: CGFloat
    let diameter: CGFloat

    var body: some View {
        styledTimerBody()
            .frame(width: diameter)
    }

    @ViewBuilder
    private func styledTimerBody() -> some View {

        ZStack {

            Circle()
                .fill(Color.clear)
                .frame(width: diameter + 8, height: diameter + 8)

            Circle()
                .fill(Color.white.opacity(0.7))
                .frame(width: diameter, height: diameter)
                .offset(x: 4, y: 4)

            // 배경 원
            Circle()
                .fill(
                    Color.smoke
                        .shadow(.inner(color: .gray.opacity(0.6), radius: 6, x: 6, y: 6))
                )
                .frame(width: diameter, height: diameter)
                .animation(.easeInOut(duration: 0.25), value: viewModel.isRunning)

            // 진행률 표시
            PieShape(progress: progress)
                .fill(viewModel.isRunning ? timer.color.opacity(0.6) : timer.color.opacity(0.3))
                .animation(.easeInOut(duration: 0.25), value: viewModel.isRunning)
                .frame(width: diameter, height: diameter)
        }
    }
}

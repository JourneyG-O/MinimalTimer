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

            // 배경 원
            Circle()
                .fill(
                    Color.smoke
                        .shadow(.inner(color: .white.opacity(0.6), radius: 6, x: -6, y: -6))
                        .shadow(.inner(color: .gray.opacity(0.6), radius: 6, x: 6, y: 6))
                )
                .frame(width: diameter)
                .animation(.easeInOut(duration: 0.25), value: viewModel.isRunning)

            // 진행률 표시
            PieShape(progress: progress)
                .fill(viewModel.isRunning ? timer.color.opacity(0.6) : timer.color.opacity(0.3))
                .animation(.easeInOut(duration: 0.25), value: viewModel.isRunning)
                .frame(width: diameter)
        }
    }
}

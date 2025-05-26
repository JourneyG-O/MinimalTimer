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
        switch timer.style {
        case .neumorphic:
            ZStack {
                // 스타일 데코
                if viewModel.isRunning {
                    Circle()
                        .fill(
                            Color.smoke
                                .shadow(.inner(color: .white.opacity(0.6), radius: 6, x: -6, y: -6))
                                .shadow(.inner(color: .gray.opacity(0.6), radius: 6, x: 6, y: 6))
                        )
                        .frame(width: diameter)
                } else {
                    Circle()
                        .fill(Color.smoke)
                        .frame(width: diameter)
                        .shadow(color: .white.opacity(0.6), radius: 6, x: -6, y: -6)
                        .shadow(color: .gray.opacity(0.6), radius: 6, x: 6, y: 6)
                }


                // 진행률 표시
                PieShape(progress: progress)
                    .fill(timer.color)
                    .frame(width: diameter * 0.9)
            }
        case .flat:
            // 진행률 표시
            PieShape(progress: progress)
                .fill(timer.color)
                .frame(width: diameter)
        case . dial:
            // 진행률 표시
            PieShape(progress: progress)
                .fill(timer.color)
                .frame(width: diameter)
        }
    }
}

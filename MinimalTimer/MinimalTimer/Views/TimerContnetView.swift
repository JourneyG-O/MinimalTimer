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
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: diameter)
                    .shadow(radius: 8)

                // 진행률 표시
                PieShape(progress: progress)
                    .fill(timer.color)
                    .frame(width: diameter * 0.8)
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

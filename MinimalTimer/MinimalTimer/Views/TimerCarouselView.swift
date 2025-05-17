//
//  TimerCarouselView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 5/13/25.
//
#if false
import SwiftUI

struct TimerCarouselView: View {
    @ObservedObject var viewModel: MainViewModel

    var body: some View {
        let itemWidth: CGFloat = 260
        let spacing: CGFloat = 16
        let sideMargin = (UIScreen.main.bounds.width - itemWidth) / 2

        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: spacing) {
                ForEach(Array(viewModel.timers.enumerated()), id: \.offset) { index, timer in
                    TimerContentView(
                        timer: timer,
                        progress: 1.0,
                        isInteractive: false,
                        onSingleTap: {
                            withAnimation {
                                viewModel.selectedTimerIndex = index
                                viewModel.interactionMode = .normal
                            }
                        },
                        onDoubleTap: nil,
                        onDrag: nil
                    )
                    .frame(width: itemWidth)
                    .scrollTransition { content, phase in
                        content
                            .scaleEffect(phase.isIdentity ? 1.0 : 0.85)
                            .opacity(phase.isIdentity ? 1.0 : 0.6)
                    }
                }
            }
            .padding(.horizontal, sideMargin)
        }.scrollTargetLayout()
            .scrollTargetBehavior(.viewAligned)
    }
}
#endif

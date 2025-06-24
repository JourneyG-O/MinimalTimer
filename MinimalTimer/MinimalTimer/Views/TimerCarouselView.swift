//
//  TimerCarouselView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 5/13/25.
//
import SwiftUI
struct TimerCarouselView: View {
    // MARK: - Properties
    @ObservedObject var viewModel: MainViewModel
    let diameter: CGFloat

    // MARK: - Body
    var body: some View {
        TabView(selection: $viewModel.selectedTimerIndex) {
            ForEach(Array(viewModel.timers.enumerated()), id: \.offset) { index, timer in
                TimerDisplayView(
                    timer: timer,
                    progress: 1.0,
                    diameter: diameter,
                    isRunning: viewModel.isRunning,
                    isDragging: viewModel.isDragging,
                    isSwitchMode: viewModel.isSwitchMode,
                    onSingleTap: {
                        viewModel.selectTimer(at: index)
                    }, onDoubleTap: nil,
                    onDrag: nil,
                    onDragEnd: nil
                )
                .tag(index)
                .padding(.horizontal, 32)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    }
}


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

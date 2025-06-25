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

    // MARK: - Computed Properties
    private var itemWidth: CGFloat {
        diameter * 0.65
    }

    private var sideMargin: CGFloat {
        (UIScreen.main.bounds.width - itemWidth) / 2
    }

    // MARK: - Body
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 20) {
                ForEach(Array(viewModel.timers.enumerated()), id: \.offset) { index, timer in
                    TimerDisplayView(
                        timer: timer,
                        progress: 1.0,
                        diameter: itemWidth,
                        isRunning: viewModel.isRunning,
                        isDragging: viewModel.isDragging,
                        isSwitchMode: viewModel.isSwitchMode,
                        onSingleTap: {
                            viewModel.selectTimer(at: index)
                        }, onDoubleTap: nil,
                        onDrag: nil,
                        onDragEnd: nil
                    )
//                    .frame(width: itemWidth, height: itemWidth)
                    .scrollTransition { content, phase in
                        content
                            .scaleEffect(phase.isIdentity ? 1 : 0.8)
                            .opacity(phase.isIdentity ? 1.0 : 0.6)
                    }
                }
            }
            .padding(.horizontal, sideMargin)
        }.scrollTargetLayout()
            .scrollTargetBehavior(.viewAligned)
    }
}

#Preview {
    TimerCarouselView(
        viewModel: {
            let vm = MainViewModel()
            vm.timers = [
                TimerModel(title: "60분", totalTime: 3600, currentTime: 1800, color: .yellow),
                TimerModel(title: "30분", totalTime: 1800, currentTime: 900, color: .blue),
                TimerModel(title: "15분", totalTime: 900, currentTime: 450, color: .red)
            ]
            vm.selectedTimerIndex = 0
            vm.isSwitchMode = true
            return vm
        }(),
        diameter: 260
    )
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

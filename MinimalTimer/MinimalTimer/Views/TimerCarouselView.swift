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
        ScrollView(.horizontal, showsIndicators: true) {
            LazyHStack(spacing: 20) {
                ForEach(Array(viewModel.timers.enumerated()), id: \.offset) { index, timer in
                    TimerDisplayView(
                        timer: timer,
                        progress: timer.totalTime > 0 ? CGFloat(timer.currentTime / timer.totalTime) : 0,
                        diameter: itemWidth,
                        isRunning: viewModel.isRunning,
                        isDragging: viewModel.isDragging,
                        interactionMode: viewModel.interactionMode,
                        onSingleTap: {
                            viewModel.selectTimer(at: index)
                            viewModel.exitSwitchMode()
                        }, onDoubleTap: nil,
                        onDrag: nil,
                        onDragEnd: nil
                    )
                    .scrollTransition { content, phase in
                        content
                            .scaleEffect(phase.isIdentity ? 1 : 0.8)
                            .opacity(phase.isIdentity ? 1.0 : 0.6)
                    }
                }
            }
            .padding(.horizontal, sideMargin)
        }
        .scrollTargetLayout()
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
            vm.enterSwitchMode()
            return vm
        }(),
        diameter: 260
    )
}

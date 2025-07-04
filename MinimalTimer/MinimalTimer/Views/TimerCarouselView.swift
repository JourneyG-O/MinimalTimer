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

    @State private var dragOffset: CGFloat = 0

    let diameter: CGFloat

    // MARK: - Privated Properties
    private let sideTimerScale: CGFloat = 0.8
    private let sideTimerOpacity: Double = 0.7
    private let timerSpacing: CGFloat = 250

    // MARK: - Computed Properties
    private var timerDiameter: CGFloat {
        viewModel.interactionMode == .switching ? diameter * 0.8 : diameter
    }


    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(Array(viewModel.timers.enumerated()), id: \.element.id) { index, timer in
                    TimerDisplayView(
                        timer: timer,
                        progress: timer.totalTime > 0 ? CGFloat(timer.currentTime / timer.totalTime) : 0,
                        diameter: timerDiameter,
                        isRunning: viewModel.isRunning,
                        isDragging: viewModel.isDragging,
                        interactionMode: viewModel.interactionMode,
                        onSingleTap: viewModel.interactionMode == .switching
                        ? {
                            viewModel.selectTimer(at: index)
                            viewModel.exitSwitchMode()
                        }
                        : viewModel.startOrPauseTimer,
                        onDoubleTap: viewModel.interactionMode == .switching ? nil : viewModel.reset,
                        onDrag: viewModel.interactionMode == .switching
                        ? nil
                        :
                        { angle in
                            viewModel.setUserProgress(from: angle)
                        },
                        onDragEnd: viewModel.interactionMode == .switching ? nil : viewModel.endDragging
                    )
                    .frame(width: timerDiameter, height: timerDiameter)
                    .scaleEffect(scaleForTimer(at: index))
                    .opacity(opacityForCard(at: index))
                    .offset(x: offsetForTimer(at: index))
                    .zIndex(zIndexForTimer(at: index))
                    .layoutPriority(index == viewModel.selectedTimerIndex ? 1 : 0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: viewModel.interactionMode == .switching)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: viewModel.selectedTimerIndex)

                }
            }
            .frame(width: geometry.size.width, height: diameter)
            .offset(x: dragOffset)
            .drawingGroup()
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if viewModel.interactionMode == .switching {
                            dragOffset = value.translation.width
                        }
                    }
                    .onEnded { value in
                        if viewModel.interactionMode == .switching {
                            let threshold: CGFloat = 80
                            withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.7)) {
                                if value.translation.width > threshold && viewModel.selectedTimerIndex > 0 {
                                    viewModel.selectedTimerIndex -= 1
                                } else if value.translation.width < -threshold && viewModel.selectedTimerIndex < viewModel.timers.count - 1 {
                                    viewModel.selectedTimerIndex += 1
                                }
                                dragOffset = 0
                            }
                        }
                    }
            )
        }
    }

    private func scaleForTimer(at index: Int) -> CGFloat {
        if viewModel.interactionMode == .normal {
            return index == viewModel.selectedTimerIndex ? 1.0 : 0.0
        }

        let distance = abs(index - viewModel.selectedTimerIndex)
        if distance == 0 {
            return 1.0
        } else if distance == 1 {
            return sideTimerScale
        } else if distance == 2 {
            return 0.7
        } else {
            return 0.0
        }
    }

    private func opacityForCard(at index: Int) -> Double {
        if viewModel.interactionMode == .normal {
            return index == viewModel.selectedTimerIndex ? 1.0 : 0.0
        }

        let distance = abs(index - viewModel.selectedTimerIndex)
        if distance == 0 {
            return 1.0
        } else if distance == 1 {
            return sideTimerOpacity
        } else if distance == 2 {
            return 0.4
        } else {
            return 0.0
        }
    }

    private func offsetForTimer(at index: Int) -> CGFloat {
        if viewModel.interactionMode == .normal {
            return 0
        }

        let difference = CGFloat(index - viewModel.selectedTimerIndex)
        return (difference * timerSpacing)
    }

    private func zIndexForTimer(at index: Int) -> Double {
        let distance = abs(index - viewModel.selectedTimerIndex)
        return Double(viewModel.timers.count - distance)
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
        diameter: UIScreen.main.bounds.width * 0.8
    )
}

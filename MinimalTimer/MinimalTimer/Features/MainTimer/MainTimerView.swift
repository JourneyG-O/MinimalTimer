//
//  MainTimerView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 4/24/25.
//
import SwiftUI

struct MainTimerView: View {
    @ObservedObject var vm: MainViewModel

    var body: some View {
        GeometryReader { proxy in

            let minSide = min(proxy.size.width, proxy.size.height)
            let timerSize = minSide * 0.8
            let showTitle = vm.currentTimer?.isTitleAlwaysVisible == true

            VStack() {

                Spacer()

                if let timer = vm.currentTimer, showTitle {
                    TitleView(title: timer.title)
                        .frame(height: 60)
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel(L("main.title.label"))
                        .accessibilityValue(
                            timer.title.isEmpty
                            ? Text(L("main.title.untitled"))
                            : Text(LocalizedStringKey(timer.title))
                        )
                        .accessibilityHint(L("main.title.hint"))
                }

                Spacer()

                if let timer = vm.currentTimer {
                    SingleTimerView(
                        timer: timer,
                        progress: vm.progress,
                        isRunning: vm.isRunning,
                        isDragging: vm.isDragging,
                        interactionMode: vm.interactionMode,
                        onSingleTap: vm.startOrPauseTimer,
                        onDoubleTap: vm.reset,
                        onDrag: { angle in vm.setUserProgress(from: angle) },
                        onDragEnd: vm.endDragging
                    )
                    .frame(width: timerSize, height:timerSize)
                    .popInOnAppear()
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(L("main.timer.current.label"))
                    .accessibilityValue(
                        vm.isRunning ? Text(L("main.timer.state.running")) : Text(L("main.timer.state.paused"))
                    )
                    .accessibilityHint(L("main.timer.current.hint"))
                } else {
                    ContentUnavailableView(
                        L("main.empty.title"),
                        systemImage: "timer",
                        description: Text(L("main.empty.description"))
                    )
                    .frame(height: timerSize)
                }

                Spacer()

                RemainingTimeView(viewModel: vm)
                    .frame(height: 60)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(L("main.remaining.label"))
                    .accessibilityHint(L("main.remaining.hint"))

                Spacer()

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 16)
        }
    }

    private var backgroundLayer: some View {
        Color(.systemBackground)
    }
}

private func formatRemaining(_ seconds: Int) -> String {
    let minutes = seconds / 60, remainingSeconds = seconds % 60
    return String(format: "%02d:%02d", minutes, remainingSeconds)
}

#Preview {
    MainTimerView(vm: .init())
}

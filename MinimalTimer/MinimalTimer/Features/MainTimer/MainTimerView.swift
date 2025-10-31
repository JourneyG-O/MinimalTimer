//
//  MainTimerView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 4/24/25.
//
import SwiftUI

struct MainTimerView: View {
    // MARK: - Dependencies
    @ObservedObject var vm: MainViewModel

    

    // MARK: - Body
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
                        .accessibilityValue(Text(LocalizedStringKey(timer.title.isEmpty ? String(localized: "main.title.untitled", defaultValue: "Untitled") : timer.title)))
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
                    .accessibilityValue(Text(vm.isRunning ? L("main.timer.state.running") : L("main.timer.state.paused")))
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
                    .accessibilityValue(Text(LF("main.remaining.value", formatRemaining(vm.remainingSeconds))))
                    .accessibilityHint(L("main.remaining.hint"))

                Spacer()

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Background
    private var backgroundLayer: some View {
        Color(.systemBackground)
    }
}

// MARK: - Accessibility Helpers
private func formatRemaining(_ seconds: Int) -> String {
    let m = seconds / 60, s = seconds % 60
    return String(format: "%02d:%02d", m, s)
}

#Preview {
    MainTimerView(vm: .init())
}

/*
 Localization Keys to provide (MainTimerView)
 - "main.empty.title" = "No timers";
 - "main.empty.description" = "Create a timer to get started.";
 - "main.timer.current.label" = "Current timer";
 - "main.timer.current.hint" = "Double-tap to reset, drag to adjust, single tap to start or pause.";
 - "main.timer.state.running" = "Running";
 - "main.timer.state.paused" = "Paused";
 - "main.title.label" = "Timer title";
 - "main.title.hint" = "Title of the selected timer.";
 - "main.title.untitled" = "Untitled";
 - "main.remaining.label" = "Remaining time";
 - "main.remaining.hint" = "Time left until the timer completes.";
 - "main.remaining.value" = "%@ remaining"; // value will be like 05:00
*/

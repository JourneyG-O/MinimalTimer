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
                } else {
                    ContentUnavailableView(
                        "No Timers",
                        systemImage: "timer",
                        description: Text("Create a timer to get started.")
                    )
                    .frame(height: timerSize)
                }

                Spacer()

                RemainingTimeView(viewModel: vm)
                    .frame(height: 60)

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

#Preview {
    MainTimerView(vm: .init())
}

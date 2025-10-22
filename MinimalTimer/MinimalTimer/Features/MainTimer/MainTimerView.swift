//
//  MainTimerView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 4/24/25.
//
import SwiftUI

enum AppRoute: Hashable {
    case list
    case create
    case edit(Int)
}

struct MainTimerView: View {
    // MARK: - Dependencies
    @ObservedObject var vm: MainViewModel

    // MARK: - Flags
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @State private var path: [AppRoute] = []

    // MARK: - Body
    var body: some View {
        NavigationStack(path: $path) {
            GeometryReader { proxy in

                let minSide = min(proxy.size.width, proxy.size.height)
                let timerSize = minSide * 0.8
                let showTitle = vm.currentTimer?.isTitleAlwaysVisible == true

                VStack() {

                    Spacer()

                    if let timer = vm.currentTimer {
                        TitleView(title: timer.title)
                            .frame(height: 60)
                            .opacity(showTitle ? 1 : 0)
                            .accessibilityHidden(!showTitle)
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
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        path.append(.list)
                    } label: {
                        Image(systemName: "list.bullet")
                    }
                    .accessibilityLabel("Timers")
                }
            }
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .list:
                    TimerListView(vm: vm)
                case .create:
                    EmptyView()
                case .edit:
                    EmptyView()
                }
            }
        }

        // 온보딩 (처음 1회)
        .fullScreenCover(
            isPresented: Binding(
                get: { !hasSeenOnboarding },
                set: { _ in }
            )
        ) {
            OnboardingView {
                hasSeenOnboarding = true
            }
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

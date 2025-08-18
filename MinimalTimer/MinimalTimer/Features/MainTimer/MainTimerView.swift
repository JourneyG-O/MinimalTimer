//
//  MainTimerView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 4/24/25.
//
import SwiftUI

struct MainTimerView: View {
    @ObservedObject var vm: MainViewModel
    @Namespace private var animationNamespace

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundLayer
                    .gesture(backgroundLongPressGesture)

                if vm.interactionMode == .normal {
//                    NormalView()
                }

                if vm.interactionMode == .switching {
//                    SwitchingView()
                }
            }
            .animation(.easeInOut(duration: 0.35), value: vm.interactionMode)
        }
        
        // 편집/생성 시트
        .fullScreenCover(item: $vm.route) { route in
            switch route {
            case .add:
                NavigationView {
                    TimerEditView(
                        vm: .init(
                            mode: .create,
                            initial: .init(),
                            saveAction: vm.handleSave
                        )
                    )
                }
            case .edit(let index):
                // 기존 모델 -> Draft로 초기화
                let initial = TimerDraft(model: vm.timers[index])
                NavigationView {
                    TimerEditView(
                        vm: .init(
                            mode: .edit(index: index),
                            initial: initial,
                            saveAction: vm.handleSave,
                            deleteAction: { idx in
                                vm.deleteTimer(at: idx)
                            }
                        )
                    )
                }
            }
        }
    }

    // MARK: - Background

    private var backgroundLayer: some View {
        Color(.systemBackground)
    }

    private var backgroundLongPressGesture: some Gesture {
        LongPressGesture(minimumDuration: 0.6)
            .onEnded { _ in
                vm.enterSwitchMode()
            }
    }

    // MARK: - Title

    private var titleSection: some View {
        let isAddTimer = vm.selectedTimerIndex == vm.timers.count
        let title = isAddTimer ? "타이머 추가" : vm.currentTimer?.title

        return TitleView(title: title)
            .opacity(vm.interactionMode == .switching ? 1 : 0)
    }

    // MARK: - Timer Display

    private func timerDisplaySection(in geometry: GeometryProxy) -> some View {
        let minSide = min(geometry.size.width, geometry.size.height)
        let timerSide = minSide * 0.8
        let dragAction: (Double) -> Void = { angle in
            vm.setUserProgress(from: angle)
        }

        return ZStack {
            if vm.interactionMode == .normal {
                if let timer = vm.currentTimer {
                    SingleTimerView(
                        timer: timer,
                        progress: vm.progress,
                        isRunning: vm.isRunning,
                        isDragging: vm.isDragging,
                        interactionMode: vm.interactionMode,
                        onSingleTap: vm.startOrPauseTimer,
                        onDoubleTap: vm.reset,
                        onDrag: dragAction,
                        onDragEnd: vm.endDragging
                    )
                    .frame(width: timerSide, height: timerSide)
                    .transition(.scale.combined(with: .opacity))
                }
            }

            if vm.interactionMode == .switching {
                TimerPagerView(vm: vm)
                    .frame(width: minSide, height: minSide)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: vm.interactionMode)
    }

    // MARK: - Bottom Information Section

    @ViewBuilder
    private func bottomInformationSection() -> some View {
        if vm.interactionMode == .normal {
            RemainingTimeView(viewModel: vm)
        } else {
            EditButtonView {
                vm.presentEditTimerView(at: vm.selectedTimerIndex)
            }
            .opacity(vm.selectedTimerIndex != vm.timers.count ? 1 : 0)
        }
    }
}

#Preview {
    MainTimerView(vm: .init())
}

//
//  MainTimerView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 4/24/25.
//
import SwiftUI

struct MainTimerView: View {
    @ObservedObject var viewModel: MainViewModel

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundLayer
                    .gesture(backgroundLongPressGesture)

                VStack {
                    Spacer()
                    titleSection
                    Spacer()
                    timerDisplaySection(in: geometry)
                    Spacer()
                    bottomInformationSection()
                    Spacer()
                }
            }
        }
        // 편집/생성 시트
        .sheet(item: $viewModel.route) { route in
            switch route {
            case .add:
                NavigationView {
                    TimerEditView(
                        vm: .init(
                        mode: .create,
                        initial: .init(),
                        saveAction: viewModel.handleSave
                        )
                    )
                }
                case .edit(let index):
                // 기존 모델 -> Draft로 초기화
                let initial = TimerDraft(model: viewModel.timers[index])
                NavigationView {
                    TimerEditView(
                        vm: .init(
                            mode: .edit(index: index),
                            initial: initial,
                            saveAction: viewModel.handleSave
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
                viewModel.enterSwitchMode()
            }
    }

    // MARK: - Title

    private var titleSection: some View {
        let isAddTimer = viewModel.selectedTimerIndex == viewModel.timers.count
        let title = isAddTimer ? "타이머 추가" : viewModel.currentTimer?.title

        return TitleView(title: title)
            .opacity(viewModel.interactionMode == .switching ? 1 : 0)
    }

    // MARK: - Timer Display

    private func timerDisplaySection(in geometry: GeometryProxy) -> some View {
        let minSide = min(geometry.size.width, geometry.size.height)
        let timerSide = minSide * 0.8
        let dragAction: (Double) -> Void = { angle in
            viewModel.setUserProgress(from: angle)
        }

        return ZStack {
            if viewModel.interactionMode == .normal {
                if let timer = viewModel.currentTimer {
                    SingleTimerView(
                        timer: timer,
                        progress: viewModel.progress,
                        isRunning: viewModel.isRunning,
                        isDragging: viewModel.isDragging,
                        interactionMode: viewModel.interactionMode,
                        onSingleTap: viewModel.startOrPauseTimer,
                        onDoubleTap: viewModel.reset,
                        onDrag: dragAction,
                        onDragEnd: viewModel.endDragging
                    )
                    .frame(width: timerSide, height: timerSide)
                    .transition(.scale.combined(with: .opacity))
                }
            }

            if viewModel.interactionMode == .switching {
                TimerPagerView(viewModel: viewModel)
                    .frame(width: minSide, height: minSide)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.interactionMode)
    }

    // MARK: - Bottom Information Section

    @ViewBuilder
    private func bottomInformationSection() -> some View {
        if viewModel.interactionMode == .normal {
            RemainingTimeView(viewModel: viewModel)
        } else {
            EditButtonView {
                viewModel.presentEditTimerView(at: viewModel.selectedTimerIndex)
            }
            .opacity(viewModel.selectedTimerIndex != viewModel.timers.count ? 1 : 0)
        }
    }
}

#Preview {
    MainTimerView(viewModel: .init())
}

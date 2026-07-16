//
//  MainTimerView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 4/24/25.
//
import SwiftUI

private enum Layout {
    /// 타이머 원형이 차지하는 짧은 변 대비 비율
    static let timerSizeRatio: CGFloat = 0.8
    /// 화면 좌우 여백
    static let horizontalPadding: CGFloat = 16
    /// 제목·남은시간 텍스트 영역 높이
    static let elementHeight: CGFloat = 60
    /// 가로모드 우측 절반의 제목-시간 간격
    static let landscapeStackSpacing: CGFloat = 16
}

struct MainTimerView: View {
    @ObservedObject var vm: MainViewModel

    var body: some View {
        GeometryReader { proxy in
            let allowsLandscape = vm.currentTimer?.isLandscapeEnabled == true
            let isLandscape = allowsLandscape && proxy.size.width > proxy.size.height

            Group {
                if isLandscape {
                    landscapeLayout(in: proxy.size)
                } else {
                    portraitLayout(in: proxy.size)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, Layout.horizontalPadding)
        }
    }
}

private extension MainTimerView {
    var showTitle: Bool {
        vm.currentTimer?.isTitleAlwaysVisible == true
    }

    // 세로모드: 위에서 아래로 제목 → 원형 → 남은시간
    func portraitLayout(in size: CGSize) -> some View {
        let timerSize = min(size.width, size.height) * Layout.timerSizeRatio
        return VStack {
            Spacer()
            if showTitle { titleView }
            Spacer()
            timerView(size: timerSize)
            Spacer()
            remainingView
            Spacer()
        }
    }

    // 가로모드: 화면을 반으로 나눠 좌측 원형, 우측 제목+남은시간
    @ViewBuilder
    func landscapeLayout(in size: CGSize) -> some View {
        if vm.currentTimer == nil {
            emptyView
        } else {
            let timerSize = min(size.width / 2, size.height) * Layout.timerSizeRatio
            HStack(spacing: 0) {
                timerView(size: timerSize)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                VStack(spacing: Layout.landscapeStackSpacing) {
                    if showTitle { titleView }
                    remainingView
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    @ViewBuilder
    var titleView: some View {
        if let timer = vm.currentTimer {
            TitleView(title: timer.title)
                .frame(height: Layout.elementHeight)
                .accessibilityElement(children: .combine)
                .accessibilityLabel(L("main.title.label"))
                .accessibilityValue(
                    timer.title.isEmpty
                    ? Text(L("main.title.untitled"))
                    : Text(LocalizedStringKey(timer.title))
                )
                .accessibilityHint(L("main.title.hint"))
        }
    }

    @ViewBuilder
    func timerView(size: CGFloat) -> some View {
        if let timer = vm.currentTimer {
            SingleTimerView(
                timer: timer,
                progressAt: { vm.graphProgress(at: $0) },
                isRunning: vm.isRunning,
                isDragging: vm.isDragging,
                interactionMode: vm.interactionMode,
                onSingleTap: vm.startOrPauseTimer,
                onDoubleTap: vm.reset,
                onDrag: { angle in vm.setUserProgress(from: angle) },
                onDragEnd: vm.endDragging
            )
            .frame(width: size, height: size)
            .popInOnAppear()
            .accessibilityElement(children: .combine)
            .accessibilityLabel(L("main.timer.current.label"))
            .accessibilityValue(
                vm.isRunning ? Text(L("main.timer.state.running")) : Text(L("main.timer.state.paused"))
            )
            .accessibilityHint(L("main.timer.current.hint"))
        } else {
            emptyView
                .frame(height: size)
        }
    }

    var remainingView: some View {
        RemainingTimeView(viewModel: vm)
            .frame(height: Layout.elementHeight)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(L("main.remaining.label"))
            .accessibilityHint(L("main.remaining.hint"))
    }

    var emptyView: some View {
        ContentUnavailableView(
            L("main.empty.title"),
            systemImage: "timer",
            description: Text(L("main.empty.description"))
        )
    }
}

#Preview {
    MainTimerView(vm: .init())
}

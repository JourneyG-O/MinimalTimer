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

    // 온보딩 1회 표시 여부
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false

    // 전환 힌트(토스트) 1회 표시 여부
    @AppStorage("hasShownSwitchHint") private var hasShownSwitchHint: Bool = false
    @State private var showSwitchHint: Bool = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundLayer
                    .gesture(backgroundLongPressGesture)

                if vm.interactionMode == .normal {
                    NormalView(vm: vm, ns: animationNamespace)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                if vm.interactionMode == .switching {
                    SwitchingView(vm: vm, ns: animationNamespace)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .animation(.easeInOut(duration: 0.35), value: vm.interactionMode)
            // ✅ 하단 토스트 오버레이 (뷰 트리의 최상단 ZStack에 붙임)
            .overlay(alignment: .bottom) {
                if showSwitchHint {
                    Text("배경을 길게 눌러 전환하기")
                        .font(.footnote)
                        .padding(.horizontal, 12).padding(.vertical, 8)
                        .background(.ultraThinMaterial, in: Capsule())
                        .overlay(Capsule().stroke(Color.primary.opacity(0.08)))
                        .padding(.bottom, 24)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
        }
        // 편집/생성/페이월 시트
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
            case .paywall:
                PaywallView(
                    priceString: "가격",
                    onClose: { vm.route = nil },
                    onUpgradeTap: { vm.handleUpgradePurchased() }
                )
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
        // ✅ 첫 실행 시 전환 힌트 1회 노출 스케줄
        .onAppear {
            guard !hasShownSwitchHint else { return }
            // 온보딩이 먼저 떠 있으면 토스트는 뒤로 미룸
            // (온보딩이 닫힌 뒤 다시 onAppear가 돌지 않으므로, 간단히 지연만 둔다)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                guard !hasShownSwitchHint, hasSeenOnboarding else { return }
                withAnimation(.easeInOut) { showSwitchHint = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation(.easeInOut) { showSwitchHint = false }
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
                // ✅ 전환모드 한 번 진입하면 힌트 영구 비활성
                hasShownSwitchHint = true
                withAnimation(.easeInOut) { showSwitchHint = false }
            }
    }
}

#Preview {
    MainTimerView(vm: .init())
}

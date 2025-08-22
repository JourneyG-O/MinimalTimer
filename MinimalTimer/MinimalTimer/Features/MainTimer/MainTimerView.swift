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
                    NormalView(vm: vm, ns: animationNamespace)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                if vm.interactionMode == .switching {
                    SwitchingView(vm: vm, ns: animationNamespace)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
}

#Preview {
    MainTimerView(vm: .init())
}

//
//  MainTimerRootView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 10/23/25.
//

import SwiftUI

// MARK: - Routes
enum AppRoute { case list }

enum EditSheetRoute: Identifiable {
    case create
    case edit(Int)

    var id: String {
        switch self {
        case .create:           return "create"
        case .edit(let i):      return "eidt-\(i)"
        }
    }
}

struct MainTimerRootView: View {
    // MARK: - Dependencies
    @ObservedObject var vm: MainViewModel

    // MARK: - Flags
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false

    // MARK: - Navigation State
    @State private var path: [AppRoute] = []
    @State private var editRoute: EditSheetRoute?
    @State private var showPaywall: Bool = false

    // MARK: - FAB State
    private var fabSymbol: String { path.isEmpty ? "list.bullet" : "plus"}
    private var fabTint: Color { .orange }


    var body: some View {
        NavigationStack(path: $path) {
            MainTimerView(vm: vm)
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .list:
                        TimerListView(
                            vm: vm,
                            onCreate: { openCreate() },
                            onEdit: { idx in openEdit(idx) }) { _ in
                                DispatchQueue.main.async {
                                    withAnimation(.snappy) { path.removeAll() }
                                }
                            }
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

        // MARK: - Persistent FAB (stays across navigation)
        .overlay(alignment: .bottomTrailing) {
            FloatingButton(symbol: fabSymbol) {
                if path.isEmpty {
                    withAnimation(.snappy) { path.append(.list) }
                } else {
                    openCreate()
                }
            }
            .padding(.trailing, 20)
            .padding(.bottom, 0)
            .ignoresSafeArea()
        }
        .animation(.snappy, value: fabSymbol)

        // MARK: - Create/Edit: sheet
        .sheet(item: $editRoute) { route in
            switch route {
            case .create:
                NavigationStack {
                    TimerEditView(
                        vm: .init(
                            mode: .create,
                            initial: .init(),
                            saveAction: vm.handleSave
                        )
                    )
                }
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)

            case .edit(let idx):
                let initial = TimerDraft(model: vm.timers[idx])
                NavigationStack {
                    TimerEditView(
                        vm: .init(
                            mode: .edit(index: idx),
                            initial: initial,
                            saveAction: vm.handleSave,
                            deleteAction: { i in vm.deleteTimer(at: i) }

                        )
                    )
                }
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
        }

        // MARK: - Paywall: fullScreenCover
        .fullScreenCover(isPresented: $showPaywall) {
            NavigationStack {
                NavigationStack {
                    PaywallView(
                        priceString: "가격",
                        onClose: { showPaywall = false },
                        onUpgradeTap: {
                            vm.handleUpgradePurchased()
                            showPaywall = false
                        }
                    )
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
    }

    // MARK: - Routing helpers
    private func openCreate() {
        if vm.isPremium || vm.timers.count < 3 {
            withAnimation(.snappy) { editRoute = .create }
        } else {
            showPaywall = true
        }
    }

    private func openEdit(_ index: Int) {
        print("openEdit가 호출 됨")
        if vm.isPremium {
            withAnimation(.snappy) { editRoute = .edit(index) }
        } else {
            showPaywall = true
        }
    }
}

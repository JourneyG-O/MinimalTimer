//
//  MainTimerRootView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 10/23/25.
//

import SwiftUI

// MARK: - Routes
private enum AppRoute { case list }

private enum EditSheetRoute: Identifiable {
    case create
    case edit(Int)

    var id: String {
        switch self {
        case .create:           return "create"
        case .edit(let i):      return "edit-\(i)"
        }
    }
}

struct MainTimerRootView: View {
    // MARK: Dependencies
    @ObservedObject var vm: MainViewModel

    // MARK: Persistent Flags
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false

    // MARK: Navigation State
    @State private var path: [AppRoute] = []
    @State private var editRoute: EditSheetRoute?
    @State private var showPaywall: Bool = false

    // MARK: Floating Action Button State
    private var fabSymbol: String { path.isEmpty ? "list.bullet" : "plus" }

    var body: some View {
        NavigationStack(path: $path) {
            MainTimerView(vm: vm)
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .list:
                        TimerListView(
                            vm: vm,
                            onCreate: { openCreate() },
                            onEdit: { idx in openEdit(idx) }
                        ) { _ in
                            DispatchQueue.main.async {
                                withAnimation(.snappy) { path.removeAll() }
                            }
                        }
                    }
                }
        }
        // MARK: Onboarding (first launch only)
        .fullScreenCover(isPresented: Binding(get: { !hasSeenOnboarding }, set: { _ in })) {
            OnboardingView { hasSeenOnboarding = true }
        }
        // MARK: Persistent FAB (stays across navigation)
        .overlay(alignment: .bottomTrailing) {
            FloatingButton(symbol: fabSymbol) {
                if path.isEmpty {
                    vm.pause(fromUser: false)
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
        // MARK: Create/Edit Sheet
        .sheet(item: $editRoute) { route in
            switch route {
            case .create:
                NavigationStack { editView(mode: .create, index: nil) }
                    .sheetStyle()
            case .edit(let idx):
                NavigationStack { editView(mode: .edit, index: idx) }
                    .sheetStyle()
            }
        }
        // MARK: Paywall
        .fullScreenCover(isPresented: $showPaywall) {
            NavigationStack {
                PaywallView(
                    priceString: "₩5,900",
                    onClose: { showPaywall = false },
                    onUpgradeTap: {
                        vm.handleUpgradePurchased()
                        showPaywall = false
                    },
                    onRestoreTap: {
                        vm.restorePurchases()
                    },
                    onOpenTerms: {
                        // TODO: 약관 링크 연결
                    },
                    onOpenPrivacy: {
                        // TODO: 개인정보 처리방침 링크 연결
                    }
                )
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

// MARK: - Private Helpers
private extension MainTimerRootView {
    enum EditMode { case create, edit }

    @ViewBuilder
    func editView(mode: EditMode, index: Int?) -> some View {
        switch mode {
        case .create:
            TimerEditView(
                vm: .init(
                    mode: .create,
                    initial: .init(),
                    saveAction: vm.handleSave
                )
            )
        case .edit:
            if let i = index {
                let initial = TimerDraft(model: vm.timers[i])
                TimerEditView(
                    vm: .init(
                        mode: .edit(index: i),
                        initial: initial,
                        saveAction: vm.handleSave,
                        deleteAction: { idx in vm.deleteTimer(at: idx) }
                    )
                )
            }
        }
    }

    func openCreate() {
        if vm.isPremium || vm.timers.count < 3 {
            withAnimation(.snappy) { editRoute = .create }
        } else {
            showPaywall = true
        }
    }

    func openEdit(_ index: Int) {
        #if DEBUG
        print("openEdit 호출: index=\(index)")
        #endif
        if vm.isPremium {
            withAnimation(.snappy) { editRoute = .edit(index) }
        } else {
            showPaywall = true
        }
    }
}

// MARK: - View Modifiers
private extension View {
    func sheetStyle() -> some View {
        self
            .presentationDragIndicator(.visible)
    }
}

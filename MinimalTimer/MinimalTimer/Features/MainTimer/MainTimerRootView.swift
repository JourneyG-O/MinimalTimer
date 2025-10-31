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
    private var fabAXLabel: LocalizedStringKey { path.isEmpty ? L("main.fab.showlist.label") : L("main.fab.create.label") }
    private var fabAXHint: LocalizedStringKey { path.isEmpty ? L("main.fab.showlist.hint") : L("main.fab.create.hint") }

    var body: some View {
        NavigationStack(path: $path) {
            MainTimerView(vm: vm)
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .list:
                        TimerListView(
                            vm: vm,
                            onCreate: { openCreate() },
                            onEdit: { idx in openEdit(idx) },
                            onShowPaywall: { showPaywall = true }
                        ) { _ in
                            DispatchQueue.main.async {
                                withAnimation(.snappy) { path.removeAll() }
                            }
                        }
                        .accessibilityLabel(L("main.timerlist.title"))
                        .accessibilityHint(L("main.timerlist.hint"))
                    }
                }
        }
        // MARK: Onboarding (first launch only)
        .fullScreenCover(isPresented: Binding(get: { !hasSeenOnboarding }, set: { _ in })) {
            OnboardingView { hasSeenOnboarding = true }
                .accessibilityIdentifier("onboarding.root")
                .accessibilityLabel(L("main.onboarding.title"))
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
            .accessibilityLabel(fabAXLabel)
            .accessibilityHint(fabAXHint)
            .accessibilityAddTraits(.isButton)
            .accessibilityIdentifier("fab.main")
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
                    priceString: String(localized: "paywall.price"),
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
                .accessibilityIdentifier("paywall.root")
                .accessibilityHint(L("main.paywall.hint"))
                .accessibilityLabel(L("main.paywall.title"))
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
        withAnimation(.snappy) { editRoute = .edit(index) }
    }
}

// MARK: - View Modifiers
private extension View {
    func sheetStyle() -> some View {
        self
            .presentationDragIndicator(.visible)
    }
}

// MARK: - Preview-friendly Localized Keys (no-op helpers)
private extension LocalizedStringKey {
    static var empty: LocalizedStringKey { "" }
}

/*
 Accessibility Localization Keys to provide (MainTimerRootView)
 - "main.fab.showlist.label" = "Show timers list";
 - "main.fab.showlist.hint" = "Opens the list of saved timers.";
 - "main.fab.create.label" = "Create timer";
 - "main.fab.create.hint" = "Create a new timer.";

 - "main.onboarding.title" = "Welcome to MinimalTimer"; // Read by VoiceOver on onboarding cover

 - "main.paywall.title" = "Upgrade to Premium"; // Title for paywall cover
 - "paywall.price" = "$2.99"; // Example localized price string; replace with real localized value or keep using existing key
 - "main.paywall.hint" = "Review premium features and purchase or restore.";
 - "main.paywall.close.hint" = "Close the paywall.";
 - "main.paywall.upgrade.hint" = "Purchase the premium upgrade.";
 - "main.paywall.restore.hint" = "Restore previous purchases.";
 - "main.paywall.terms.hint" = "Open the Terms of Service.";
 - "main.paywall.privacy.hint" = "Open the Privacy Policy.";

 - "main.timerlist.title" = "Timers"; // For the list screen when pushed
 - "main.timerlist.hint" = "Browse, edit, or create timers.";
 - "main.timerlist.create.hint" = "Create a new timer from the list.";
 - "main.timerlist.edit.hint" = "Edit the selected timer.";

 - "main.edit.create.title" = "Create Timer";
 - "main.edit.edit.title" = "Edit Timer";
 - "main.edit.save.hint" = "Save your changes.";
 - "main.edit.delete.hint" = "Delete this timer.";
*/


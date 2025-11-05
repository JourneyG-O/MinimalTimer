//
//  MainTimerRootView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 10/23/25.
//

import SwiftUI

// MARK: - Routes
private enum AppRoute { case list }

private enum ModalRoute: Identifiable {
    case edit(EditSheetRoute)
    case settings
    case paywall
    case limitInfo
    
    var id: String {
        switch self {
        case .edit(let r): return "edit-\(r.id)"
        case .settings: return "settings"
        case .paywall: return "paywall"
        case .limitInfo: return "limitInfo"
        }
    }
}

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
    
    // MARK: Purchase
    @EnvironmentObject var purchaseManager: PurchaseManager
    
    // MARK: Persistent Flags
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    
    // MARK: Navigation State
    @State private var path: [AppRoute] = []
    @State private var modalRoute: ModalRoute?
    
    // MARK: Layout constants
    private let fabPadding: CGFloat = 20
    private let fabSize: CGFloat = 64
    
    
    // MARK: Floating Action Button State
    private var fabSymbol: String { path.isEmpty && !vm.timers.isEmpty ? "list.bullet" : "plus" }
    private var fabAXLabel: LocalizedStringKey { path.isEmpty && !vm.timers.isEmpty ? L("main.fab.showlist.label") : L("main.fab.create.label") }
    private var fabAXHint: LocalizedStringKey { path.isEmpty && !vm.timers.isEmpty ? L("main.fab.showlist.hint") : L("main.fab.create.hint") }

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
                            onShowPaywall: { modalRoute = .paywall },
                            onShowSettings: { modalRoute = .settings }
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
                if path.isEmpty && !vm.timers.isEmpty {
                    vm.pause(fromUser: false)
                    withAnimation(.snappy) { path.append(.list) }
                } else {
                    openCreate()
                }
            }
            .padding(.trailing, fabPadding)
            .padding(.bottom, 0)
            .ignoresSafeArea()
            .accessibilityLabel(fabAXLabel)
            .accessibilityHint(fabAXHint)
            .accessibilityAddTraits(.isButton)
            .accessibilityIdentifier("fab.main")
        }
        .animation(.snappy, value: fabSymbol)
        
        // MARK: Paywall Promo
        .overlay(alignment: .bottomLeading) {
            let isOnList = path.last == .list
            if isOnList, !purchaseManager.isPremium {
                PaywallPromoRow {
                    modalRoute = .paywall
                }
                .padding(.leading, fabPadding)
                .padding(.trailing, fabPadding + fabSize + 10)
                .padding(.bottom, 0)
                .accessibilityElement(children: .combine)
                .accessibilityLabel(L("timerlist.promo.label"))
                .accessibilityHint(L("timerlist.promo.hint"))
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        
        // MARK: Sheets
        .sheet(item: $modalRoute) { route in
            switch route {
            case .edit(let editRoute):
                switch editRoute {
                case .create:
                    NavigationStack { editView(index: nil) }
                case .edit(let idx):
                    NavigationStack { editView(index: idx) }
                }
            case .settings:
                NavigationStack {
                    SettingsView(
                        onClose: { modalRoute = nil },
                        onShowPaywall: { modalRoute = .paywall }
                    )
                }
            case .paywall:
                NavigationStack {
                    PaywallView(
                        priceString: purchaseManager.localizedPrice,
                        onClose: { modalRoute = nil },
                        onUpgradeTap: {
                            Task {
                                let success = await purchaseManager.purchase()
                                if success { modalRoute = nil }
                            }
                        },
                        onRestoreTap: {
                            Task { await purchaseManager.restore() }
                        }
                    )
                    .accessibilityIdentifier("paywall.root")
                    .accessibilityHint(L("main.paywall.hint"))
                    .accessibilityLabel(L("main.paywall.title"))
                    .navigationBarTitleDisplayMode(.inline)
                }
            case .limitInfo:
                LimitInfoSheet(
                    currentCount: vm.timers.count, limit: 3,
                    onUpgrade: { modalRoute = .paywall },
                    onManage: {
                        // 리스트로 이동해 정리하도록 유도
                        if path.isEmpty { withAnimation(.snappy) { path.append(.list) } }
                        modalRoute = nil
                    },
                    onClose: { modalRoute = nil }
                )
            }
        }
    }
}

// MARK: - Private Helpers
private extension MainTimerRootView {
    enum EditMode { case create, edit }
    
    @ViewBuilder
    func editView(index: Int?) -> some View {
        if let i = index {
            // Edit existing
            let initial = TimerDraft(model: vm.timers[i])
            TimerEditView(
                mode: .edit(index: i),
                initial: initial,
                onPaywall: { modalRoute = .paywall },
                saveAction: vm.handleSave,
                deleteAction: { idx in vm.deleteTimer(at: idx) }
            )
        } else {
            // Create new
            TimerEditView(
                mode: .create,
                initial: .init(),
                onPaywall: { modalRoute = .paywall },
                saveAction: vm.handleSave)
        }
    }
    
    func openCreate() {
        if purchaseManager.isPremium || vm.timers.count < 3 {
            withAnimation(.snappy) { modalRoute = .edit(.create) }
        } else {
            modalRoute = .limitInfo
        }
    }
    
    func openEdit(_ index: Int) {
        withAnimation(.snappy) { modalRoute = .edit(.edit(index)) }
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


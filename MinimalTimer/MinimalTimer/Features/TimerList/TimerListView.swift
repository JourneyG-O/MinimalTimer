//
//  TimerListView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 10/22/25.
//

import SwiftUI
import StoreKit

struct TimerListView: View {
    // MARK: - Dependencies
    @ObservedObject var vm: MainViewModel
    var onCreate: (() -> Void)?
    var onEdit: ((Int) -> Void)?
    var onShowPaywall: (() -> Void)?
    var onSelectTimer: ((Int) -> Void)?
    
    
    // MARK: - States
    @Environment(\.dismiss) private var dismiss
    @Environment(\.editMode) private var editMode
    @State private var isPresentingSettings: Bool = false
    @State private var showSafari = false
    @State private var selectedPolicyURL: URL?
    @State private var isPurchasing: Bool = false
    @StateObject private var purchaseManager = PurchaseManager.shared
    
    // MARK: - Body
    var body: some View {
        
        VStack(spacing: 0) {
            List {
                ForEach(vm.timers) { timer in
                    let index = vm.timers.firstIndex(where: { $0.id == timer.id }) ?? 0
                    
                    TimerRow(
                        timer: timer,
                        onSelect: { handleSelect(index) },
                        onEdit:   { handleEdit(index) }
                    )
                    .listRowInsets(.init(top: 0, leading: 16, bottom: 0, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .padding(.vertical, 8)
                    .swipeActions(edge: .trailing) {
                        Button {
                            if editMode?.wrappedValue == .active {
                                editMode?.wrappedValue = .inactive
                            } else {
                                editMode?.wrappedValue = .active
                            }
                        } label: {
                            Label(L("timerlist.reorder"), systemImage: "arrow.up.arrow.down")
                        }
                        .tint(.blue)
                        
                        Button(role: .destructive) {
                            vm.deleteTimer(at: index)
                        } label: {
                            Label(L("timerlist.delete"), systemImage: "trash")
                        }
                    }
                    .moveDisabled(editMode?.wrappedValue != .active)
                }
                .onMove { from, to in
                    vm.timers.move(fromOffsets: from, toOffset: to)
                    vm.saveTimers()
                }
                .onDelete { indexSet in
                    indexSet.sorted(by: >).forEach { vm.deleteTimer(at: $0) }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            
            if !vm.isPremium {
                PaywallPromoRow {
                    onShowPaywall?()
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 80)
                .accessibilityElement(children: .combine)
                .accessibilityLabel(L("timerlist.promo.label"))
                .accessibilityHint(L("timerlist.promo.hint"))
            }
        }
        .background(Color(.systemBackground))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if editMode?.wrappedValue == .active {
                    Button {
                        editMode?.wrappedValue = .inactive
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .accessibilityLabel(L("list.edit.done"))
                    .accessibilityHint(L("timerlist.edit.done.hint"))
                } else {
                    Button {
                        isPresentingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityLabel(L("settings.open.label"))
                    .accessibilityHint(L("settings.open.hint"))
                }
            }
        }
        .sheet(isPresented: $isPresentingSettings) {
            NavigationStack {
                List {
                    Section(L("settings.premium.section")) {
                        if purchaseManager.isPremium || vm.isPremium {
                            Label(L("settings.premium.active"), systemImage: "checkmark.seal.fill")
                                .foregroundStyle(.green)
                        } else {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(L("settings.premium.headline"))
                                    Text(purchaseManager.localizedPrice.isEmpty ? L("settings.premium.price.loading") : LocalizedStringKey(purchaseManager.localizedPrice))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Button(action: {
                                    isPurchasing = true
                                    Task {
                                        let _ = await purchaseManager.purchase()
                                        isPurchasing = false
                                        if purchaseManager.isPremium { vm.handleUpgradePurchased() }
                                    }
                                }) {
                                    if isPurchasing {
                                        ProgressView()
                                    } else {
                                        Text(L("settings.premium.buy"))
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                            }

                            Button(L("settings.premium.restore")) {
                                Task { await purchaseManager.restore() }
                            }
                        }

                        if let err = purchaseManager.lastError {
                            Text(err)
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }
                    
                    Section(L("settings.appinfo.section")) {
                        HStack {
                            Text(L("settings.appinfo.version"))
                            Spacer()
                            Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-")
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Section(L("settings.policy.section")) {
                        Button(L("settings.policy.terms")) {
                            if let url = URL(string: "https://stannum.app/apps/minimal-timer/legal/terms.html") {
                                selectedPolicyURL = url
                                isPresentingSettings = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                    showSafari = true
                                }
                            }
                        }
                        
                        Button(L("settings.policy.privacy")) {
                            if let url = URL(string: "https://stannum.app/apps/minimal-timer/legal/privacy.html") {
                                selectedPolicyURL = url
                                isPresentingSettings = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                    showSafari = true
                                }
                            }
                        }
                    }
                }
                .navigationTitle(L("settings.title"))
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: { isPresentingSettings = false }) {
                            Image(systemName: "xmark")
                        }
                        .accessibilityLabel(L("settings.close.label"))
                        .accessibilityHint(L("settings.close.hint"))
                    }
                }
            }
            .task { await purchaseManager.refreshProducts() }
        }
        .sheet(isPresented: $showSafari) {
            if let url = selectedPolicyURL {
                SafariView(url: url)
                    .ignoresSafeArea()
            }
        }
        .onChange(of: purchaseManager.isPremium) { newValue, _ in
            if newValue { vm.handleUpgradePurchased() }
        }
    }
    
    // MARK: - Helpers
    private func handleSelect(_ index: Int) {
        vm.selectTimer(at: index)
        UISelectionFeedbackGenerator().selectionChanged()
        onSelectTimer?(index)
    }
    
    private func handleCreate() {
        onCreate?()
    }
    
    private func handleEdit(_ index: Int) {
        onEdit?(index)
    }
}

/*
 Localization Keys to provide (TimerListView)
 - "timerlist.reorder" = "Reorder";
 - "timerlist.delete" = "Delete";
 - "timerlist.edit.done.hint" = "Finish editing and return to the list.";
 - "settings.open.label" = "Open settings";
 - "settings.open.hint" = "Show app settings and information.";
 - "timerlist.promo.label" = "Unlock premium";
 - "timerlist.promo.hint" = "Open paywall to upgrade.";
 - "settings.close.label" = "Close settings";
 - "settings.close.hint" = "Dismiss the settings view.";
*/

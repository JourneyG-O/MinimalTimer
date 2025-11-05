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
    var onShowSettings: (() -> Void)?
    var onSelectTimer: ((Int) -> Void)?

    // MARK: Purchase
    @EnvironmentObject var purchaseManager: PurchaseManager

    
    // MARK: - States
    @Environment(\.dismiss) private var dismiss
    @Environment(\.editMode) private var editMode
    
    
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
            
            if !purchaseManager.isPremium {
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
                        onShowSettings?()
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityLabel(L("settings.open.label"))
                    .accessibilityHint(L("settings.open.hint"))
                }
            }
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

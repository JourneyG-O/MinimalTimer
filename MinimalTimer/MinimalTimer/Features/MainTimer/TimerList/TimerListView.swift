//
//  TimerListView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 10/22/25.
//

import SwiftUI

struct TimerListView: View {
    // MARK: - Dependencies
    @ObservedObject var vm: MainViewModel
    var onCreate: (() -> Void)?
    var onEdit: ((Int) -> Void)?

    // MARK: - States
    @Environment(\.dismiss) private var dismiss

    // MARK: - Body
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(Array(vm.timers.enumerated()), id: \.element.id) { index, timer in
                    TimerRow(timer: timer,
                             isSelected: index == vm.selectedTimerIndex,
                             onSelect: { handleSelect(index) },
                             onEdit: { handleEdit(index) }
                    )
                    .padding(.horizontal, 16)
                }
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: handleCreate){
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add Timer")
            }
        }
    }

    // MARK: - Helpers
    private func handleSelect(_ index: Int) {
        vm.selectTimer(at: index)
        UISelectionFeedbackGenerator().selectionChanged()
        dismiss()
    }

    private func handleCreate() {
        if vm.isPremium || vm.timers.count < 3 {
            onCreate?()
        } else {
            vm.route = .paywall
        }
    }

    private func handleEdit(_ index: Int) {
        if vm.isPremium {
            onEdit?(index)
        } else {
            vm.route = .paywall
        }
    }
}

//#Preview {
//    TimerListView()
//}

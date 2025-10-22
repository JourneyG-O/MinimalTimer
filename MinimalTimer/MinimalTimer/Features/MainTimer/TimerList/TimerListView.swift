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
            LazyVStack(spacing: 15) {
                ForEach(vm.timers.indices, id: \.self) { index in
                    let timer = vm.timers[index]
                    TimerRow(timer: timer,
                             isSelected: index == vm.selectedTimerIndex,
                             onSelect: { handleSelect(index) },
                             onEdit: { handleEdit(index) }
                    )
                    .padding(.horizontal, 16)
                }
            }
            .padding(.vertical, 30)
        }
        .scrollIndicators(.automatic)
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

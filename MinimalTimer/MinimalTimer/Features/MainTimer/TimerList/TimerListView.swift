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
    @Environment(\.editMode) private var editMode

    // MARK: - Body
    var body: some View {

        List {
            ForEach(vm.timers) { timer in         // ← indices 대신 모델 자체 사용
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
                    Button(role: .destructive) {
                        vm.deleteTimer(at: index)
                    } label: {
                        Label("Delete", systemImage: "trash")
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
        .background(Color(.systemBackground))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) { EditButton() }
        }
    }


    // MARK: - Helpers
    private func handleSelect(_ index: Int) {
        print("hanleSelect가 호출 됨")
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
        print("hanleEdit가 호출 됨")
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

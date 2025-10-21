//
//  SwitchingView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 8/18/25.
//
import SwiftUI

struct SwitchingView: View {
    @ObservedObject var vm: MainViewModel
    let ns: Namespace.ID

    private enum Constants {
        static let editButtonHeight: CGFloat = 48
        static let editButtonHorizontalPadding: CGFloat = 50
        static let floatingButtonSize: CGFloat = 48
        static let bottomPadding: CGFloat = 24
        static let trailingPadding: CGFloat = 20
        static let editFont: Font = .headline
        static let addFont: Font = .headline
    }

    var body: some View {
        ZStack {
            TimerPagerView(vm: vm)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .animation(.spring(response: 0.28, dampingFraction: 0.9), value: vm.interactionMode)
        .toolbar {
            
            ToolbarItemGroup(placement: .bottomBar) {
                // 편집 버튼
                    Button {
                        vm.presentEditTimerView(at: vm.selectedTimerIndex)
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .tint(vm.currentTimer?.color.toColor ?? .primary)
                    .accessibilityLabel("Edit Timer")

                Spacer()

                // + 버튼
                    Button {
                        vm.presentAddTimerView()
                    } label: {
                        Image(systemName: "plus")
                            .font(.headline)
                    }
                    .accessibilityLabel("Add Timer")
            }
        }
    }
}

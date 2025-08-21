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

    var body: some View {
        ZStack {
            TimerPagerView(vm: vm)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            VStack {
                Spacer()
                HStack(spacing: 12) {
                    Button {
                        vm.presentEditTimerView(at: vm.selectedTimerIndex)
                    } label: {
                        Label("Edit", systemImage: "pencil")
                            .font(.headline)
                            .padding(.horizontal, 16).padding(.vertical, 10)
                    }

                    Button {
                        vm.presentAddTimerView()
                    } label: {
                        Image(systemName: "plus")
                            .font(.headline)
                            .frame(width: 44, height: 44)
                            .background(Circle().fill(.primary.opacity(0.12)))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial, in: Capsule())
                .padding(.bottom, 16)
            }
            .allowsHitTesting(true)
        }
    }
}

#Preview("SwitchingView") {
    @Previewable @Namespace var ns
    let vm = MainViewModel()
    vm.interactionMode = .switching
    return SwitchingView(vm: vm, ns: ns)
}

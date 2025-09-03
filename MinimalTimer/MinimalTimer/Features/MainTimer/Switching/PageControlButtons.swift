//
//  PageControlButtons.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 8/21/25.
//
import SwiftUI

struct PageControlButtons: View {
    @ObservedObject var vm: MainViewModel
    let timerWidth: CGFloat

    // 연산 프로퍼티로 분리하여 body를 간결하게 만듭니다.
    private var isFirstPage: Bool { vm.selectedTimerIndex == 0 }
    private var isLastPage: Bool { vm.selectedTimerIndex == vm.timers.count }

    var body: some View {
        HStack {
            Spacer()

            Button(action: {
                vm.selectedTimerIndex = max(0, vm.selectedTimerIndex - 1)
            }) {
                Image(systemName: "chevron.backward")
                    .font(.largeTitle)
                    .foregroundStyle(.primary.opacity(isFirstPage ? 0.3 : 0.6))
            }
            .buttonStyle(.plain)
            .disabled(isFirstPage)

            Spacer()

            Color.clear
                .frame(width: timerWidth)

            Spacer()

            Button(action: {
                vm.selectedTimerIndex += 1
            }) {
                Image(systemName: "chevron.forward")
                    .font(.largeTitle)
                    .foregroundStyle(.primary.opacity(isLastPage ? 0.3 : 0.6))
            }
            .buttonStyle(.plain)
            .disabled(isLastPage)

            Spacer()
        }
    }
}

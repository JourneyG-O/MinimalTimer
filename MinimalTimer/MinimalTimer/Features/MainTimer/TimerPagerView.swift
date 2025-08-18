//
//  NewTimerPagerView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 7/21/25.
//

import SwiftUI

struct TimerPagerView: View {
    @ObservedObject var vm: MainViewModel

    private var timers: [TimerModel] { vm.timers }
    private let scale: CGFloat = 0.6
    private let pausedStatusOffset: CGFloat = 20

    var body: some View {
        GeometryReader { geometry in
            let timerWidth = geometry.size.width * scale
            let timerHeight = geometry.size.height * scale
            let isFirstPage = vm.selectedTimerIndex == 0
            let isLastPage = vm.selectedTimerIndex == vm.timers.count

            ZStack {
                TabView(selection: $vm.selectedTimerIndex) {
                    ForEach(0..<(vm.timers.count + 1), id: \.self) { index in
                        if index < timers.count {
                            let timer = timers[index]

                            PreviewTimerView(color: timer.color.toColor, totalTime: timer.totalTime) {
                                vm.selectTimer(at: index)
                                vm.exitSwitchMode()
                            }
                            .frame(width: timerWidth, height: timerHeight)
                            .tag(index)
                        } else {
                            AddTimerCardView()
                                .frame(width: timerWidth, height: timerHeight)
                                .onTapGesture {
                                    vm.presentAddTimerView()
                                }
                                .tag(index)
                        }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                HStack {
                    Spacer()

                    Button(action: {
                        vm.selectedTimerIndex = max(0, vm.selectedTimerIndex - 1)
                    }) {
                        Image(systemName: "chevron.backward")
                            .font(.largeTitle)
                            .foregroundStyle(isFirstPage ? .gray.opacity(0.3) : .primary)
                    }
                    .disabled(isFirstPage)

                    Spacer()

                    Color.clear
                        .frame(width: timerWidth)

                    Spacer()

                    Button(action: {
                        if !isLastPage {
                            vm.selectedTimerIndex += 1
                        }
                    }) {
                        Image(systemName: "chevron.forward")
                            .font(.largeTitle)
                            .foregroundStyle(isLastPage ? .gray.opacity(0.3) : .primary)
                    }
                    .disabled(isLastPage)

                    Spacer()
                }
            }
        }

    }
}

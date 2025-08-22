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

    var body: some View {
        GeometryReader { geometry in
            let timerWidth = geometry.size.width * scale
            let timerHeight = geometry.size.height * scale

            ZStack {
                TabView(selection: $vm.selectedTimerIndex) {
                    ForEach(0..<(vm.timers.count + 1), id: \.self) { index in
                        if index >= timers.count {
                            AddTimerCardView()
                                .frame(width: timerWidth, height: timerHeight)
                                .onTapGesture {
                                    vm.presentAddTimerView()
                                }
                                .tag(index)
                        } else {
                            let timer = timers[index]

                            PreviewTimerView(color: timer.color.toColor, totalTime: timer.totalTime, title: timer.title) {
                                vm.selectTimer(at: index)
                                vm.exitSwitchMode()
                            }
                            .frame(width: timerWidth, height: timerHeight)
                            .tag(index)
                        }




//                        if index < timers.count {
//                            let timer = timers[index]
//
//                            PreviewTimerView(color: timer.color.toColor, totalTime: timer.totalTime, title: timer.title) {
//                                vm.selectTimer(at: index)
//                                vm.exitSwitchMode()
//                            }
//                            .frame(width: timerWidth, height: timerHeight)
//                            .tag(index)
//                        } else {
//                            AddTimerCardView()
//                                .frame(width: timerWidth, height: timerHeight)
//                                .onTapGesture {
//                                    vm.presentAddTimerView()
//                                }
//                                .tag(index)
//                        }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))


                // 좌 우 화살표 버튼
                PageControlButtons(vm: vm, timerWidth: timerWidth)
            }
        }
    }
}

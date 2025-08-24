//
//  NewTimerPagerView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 7/21/25.
//

import SwiftUI

struct TimerPagerView: View {
    @ObservedObject var vm: MainViewModel

    @State private var isFirstPresented: Bool = true

    private var timers: [TimerModel] { vm.timers }
    private let scale: CGFloat = 0.6

    var body: some View {
        GeometryReader { geometry in
            let side = min(geometry.size.width, geometry.size.height) * scale

            ZStack {
                TabView(selection: $vm.selectedTimerIndex) {
                    ForEach(0..<(timers.count + 1), id: \.self) { index in
                        if index < timers.count {
                            let timer = timers[index]

                            let card = PreviewTimerView(
                                color: timer.color.toColor,
                                totalTime: timer.totalTime,
                                title: timer.title
                            ) {
                                vm.selectTimer(at: index)
                                vm.exitSwitchMode()
                            }
                            .frame(width: side, height: side)

                            Group {
                                if isFirstPresented {
                                    card.popInOnAppear()
                                } else {
                                    card
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .tag(index)

                        } else {
                            AddTimerCardView()
                                .frame(width: side, height: side)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .onTapGesture { vm.presentAddTimerView() }
                                .tag(index)
                        }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))


                // 좌 우 화살표 버튼
                PageControlButtons(vm: vm, timerWidth: side)
            }
        }
    }
}

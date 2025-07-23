//
//  MainTimerView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 4/24/25.
//
import SwiftUI

struct MainTimerView: View {
    @ObservedObject var viewModel: MainViewModel

    var body: some View {
        GeometryReader { geometry in
            let minSide = min(geometry.size.width, geometry.size.height)

            ZStack {
                Color(.systemBackground)
                    .gesture(
                        LongPressGesture(minimumDuration: 0.6)
                            .onEnded { _ in
                                viewModel.enterSwitchMode()
                            }
                    )

                VStack {
                    Spacer()
                    TitleView(title: viewModel.currentTimer?.title)
                        .opacity(viewModel.interactionMode == .switching ? 1 : 0)
                    Spacer()

                    TimerPagerView(viewModel: viewModel)
                        .frame(width: minSide, height: minSide)

                    Spacer()
                    RemainingTimeView(viewModel: viewModel)
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    MainTimerView(viewModel: .init())
}

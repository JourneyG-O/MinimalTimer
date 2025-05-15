//
//  TimerCarouselView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 5/13/25.
//

import SwiftUI

struct TimerCarouselView: View {
    @ObservedObject var viewModel: MainViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 20) {
                ForEach(Array(viewModel.timers.enumerated()), id: \.element.id) { index, timer in
                    TimerContentView(
                        timer: timer,
                        progress: 1,
                        isInteractive: false,
                        onSingleTap: {
                            withAnimation {
                                viewModel.selectedTimerIndex = index
                                viewModel.interactionMode = .normal
                            }
                        },
                        onDoubleTap: nil,
                        onDrag: nil
                    )
                    .frame(width: index == viewModel.selectedTimerIndex ? 240 : 160)
                    .scaleEffect(index == viewModel.selectedTimerIndex ? 1.0 : 0.85)
                    .opacity(index == viewModel.selectedTimerIndex ? 1.0 : 0.6)
                }
            }
            .padding(.horizontal, 32)
        }
    }
}


//
//ScrollView(.horizontal) {
//    LazyHStack(spacing: 20) {
//        ForEach(items, id: \.self) { item in
//            RoundedRectangle(cornerRadius: 20)
//                .fill(LinearGradient(
//                    gradient: Gradient(colors: [.red, .blue]),
//                    startPoint: .topLeading,
//                    endPoint: .bottomTrailing
//                ))
//                .frame(width: 250, height: 250)
//                .overlay(
//                    Text("\(item)")
//                        .font(.largeTitle)
//                        .bold()
//                        .foregroundColor(.white)
//                )
//                .scrollTransition { content, phase in
//                    content
//                        .scaleEffect(phase.isIdentity ? 1 : 0.85)
//                        .opacity(phase.isIdentity ? 1.0 : 0.6)
//
//                }
//        }
//    }
//}.scrollTargetLayout()
//    .contentMargins(.horizontal, (UIScreen.main.bounds.width - 250) / 2)
//    .scrollTargetBehavior(.viewAligned)

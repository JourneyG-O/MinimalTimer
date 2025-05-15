//
//  TimerCarouselView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 5/13/25.
//

import SwiftUI

struct TimerCarouselView: View {
    @ObservedObject var viewModel: MainViewModel

    var timers: [TimerModel] {
            viewModel.timers
        }


    var body: some View {
        ScrollView(.horizontal) {
            ForEach(timers, id: \.id) { item in
                
            }
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

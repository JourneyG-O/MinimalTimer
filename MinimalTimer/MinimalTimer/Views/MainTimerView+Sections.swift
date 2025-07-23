//
//  MainTimerView+Sections.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 6/10/25.
//

import SwiftUI

// MARK: - Title View
extension MainTimerView {
    struct TitleView: View {
        let title: String?
        var body: some View {
            Text(title ?? "Minimal Timer")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .fontWeight(.semibold)
                .foregroundColor(.black)
        }
    }
}

// MARK: - Paused Status Text

//extension MainTimerView {
//    struct PausedStatusView: View {
//        let isRunning: Bool
//        let diameter: CGFloat
//
//        var body: some View {
//            Text("Paused")
//                .font(.body)
//                .opacity(isRunning ? 0 : 1)
//                .animation(.easeInOut(duration: 0.3), value: isRunning)
//                .offset(y: diameter / 2 + 20)
//        }
//    }
//}

//
//  PreviewTimerView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 8/4/25.
//

import SwiftUI

struct PreviewTimerView: View {
    let color: Color
    let totalTime: TimeInterval
    let onTap: () -> Void

    var body: some View {
        ZStack {
            Circle()
                .fill(color)

            Text(formatTime(totalTime))
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .opacity(0.5)
        }
        .onTapGesture(perform: onTap)
    }

    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}


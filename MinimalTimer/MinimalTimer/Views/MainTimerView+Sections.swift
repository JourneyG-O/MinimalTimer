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

// MARK: - Total Duration Text

extension MainTimerView {
    struct TotalDurationText: View {
        let totalTime: TimeInterval
        let diameter: CGFloat
        let isVisible: Bool

        var body: some View {
            Text(formatTime(totalTime))
                .font(.body)
                .opacity(isVisible ? 1 : 0)
                .animation(.easeInOut(duration: 0.3), value: isVisible)
                .offset(y: -diameter / 2)
        }

        func formatTime(_ timeInterval: TimeInterval) -> String {
            let minutes = Int(timeInterval) / 60
            let seconds = Int(timeInterval) % 60
            if seconds == 0 {
                return "\(minutes)m"
            } else {
                return "\(minutes)m \(seconds)s"
            }
        }
    }
}


// MARK: - Timer Display Section

extension MainTimerView {
    struct TimerDisplaySection: View {
        @ObservedObject var viewModel: MainViewModel
        let diameter: CGFloat

        var body: some View {
            ZStack {
                TimerCarouselView(viewModel: viewModel, diameter: diameter)
            }
        }
    }
}

// MARK: - Paused Status Text

extension MainTimerView {
    struct PausedStatusText: View {
        let isRunning: Bool
        let diameter: CGFloat

        var body: some View {
            Text("Paused")
                .font(.body)
                .opacity(isRunning ? 0 : 1)
                .animation(.easeInOut(duration: 0.3), value: isRunning)
                .offset(y: diameter / 2 + 20)
        }
    }
}

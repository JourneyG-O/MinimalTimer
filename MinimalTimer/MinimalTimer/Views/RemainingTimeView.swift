//
//  RemainingTimeView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 5/13/25.
//
import SwiftUI

struct RemainingTimeView: View {
    @ObservedObject var viewModel: MainViewModel

    var body: some View {
        Text(formatTime(displayedTime))
            .font(.system(size: 60, weight: .bold, design: .rounded))
            .opacity(viewModel.isRunning ? 1.0 : 0.5)
            .animation(.easeInOut(duration: 0.3), value: viewModel.isRunning)
    }

    private var displayedTime: TimeInterval {
        if viewModel.interactionMode == .switching {
            return viewModel.currentTimer?.totalTime ?? 0
        } else {
            return viewModel.currentTimer?.currentTime ?? 0
        }
    }

    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

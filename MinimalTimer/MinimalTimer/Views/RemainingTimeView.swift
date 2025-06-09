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
        Text(formatTime(viewModel.currentTimer?.currentTime ?? 0))
            .font(.system(size: 60, weight: .bold, design: .rounded))
            .opacity(viewModel.isRunning ? 1.0 : 0.5)
    }

    func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d", minutes, seconds)
    }
}


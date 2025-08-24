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
        Text((viewModel.currentTimer?.currentTime ?? 0).mmss)
            .font(.system(size: 60, weight: .bold, design: .rounded))
            .monospacedDigit()
            .opacity(viewModel.isRunning ? 1.0 : 0.5)
            .animation(.easeInOut(duration: 0.3), value: viewModel.isRunning)
    }
}

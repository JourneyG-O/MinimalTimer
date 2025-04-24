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
        VStack {
            Text(viewModel.currentTimer?.title ?? "타이머 없음")
                .font(.title)
                .bold()

            Spacer()

            Circle()
                .fill(viewModel.currentTimer?.color ?? .gray)
                .frame(width: 260, height: 260)
                .onTapGesture(count: 1) {
                    viewModel.isRunning ? viewModel.pause() : viewModel.start()
                }
                .onTapGesture(count: 2) {
                    viewModel.reset()
                }

            Spacer()

            Text(formatTime(viewModel.currentTimer?.currentTime ?? 0))
                .font(.system(size: 48, weight: .bold, design: .monospaced))

            Spacer()
        }
        .padding(.top, 20)
    }

    // 시간 포맷터
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    MainTimerView(viewModel: .init())
}

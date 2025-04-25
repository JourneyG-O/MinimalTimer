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

            ZStack {
                GeometryReader { geometry in
                    let size = min(geometry.size.width, geometry.size.height)

                    Circle()
                        .fill(viewModel.currentTimer?.color ?? .gray)
                        .frame(width: 260, height: 260)
                        .onTapGesture(count: 1) {
                            viewModel.isRunning ? viewModel.pause() : viewModel.start()
                        }
                        .onTapGesture(count: 2) {
                            viewModel.reset()
                        }
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let center = CGPoint(x: size / 2, y: size / 2)
                                    let dx = value.location.x - center.x
                                    let dy = value.location.y - center.y
                                    let angle = atan2(dy, dx)
                                    let degrees = angle * 180 / .pi
                                    let adjusted = degrees < 0 ? degrees + 360 : degrees

                                    viewModel.setTime(from: adjusted)
                                }
                        )
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .frame(width: 260, height: 260)


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

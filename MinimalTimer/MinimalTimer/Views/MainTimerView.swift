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

            GeometryReader { geometry in
                let size = min(geometry.size.width, geometry.size.height)
                let center = CGPoint(x: size / 2, y: size / 2)

                PieShape(progress: viewModel.isDragging ? viewModel.userSetProgress : viewModel.progress)
                    .fill(viewModel.currentTimer?.color ?? .blue)
                    .frame(width: size, height: size)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                viewModel.isDragging = true
                                let angle = angleFrom(center: center, to: value.location)
                                viewModel.setUserProgress(from: angle)
                            }
                            .onEnded { _ in
                                viewModel.isDragging = false
                                viewModel.syncUserProgressWithCurrentTime()
                            }
                    )
                    .onTapGesture(count: 1) {
                        viewModel.isRunning ? viewModel.pause() : viewModel.start()
                    }
                    .onTapGesture(count: 2) {
                        viewModel.reset()
                    }
                    .animation(.linear, value: viewModel.userSetProgress)
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

    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func angleFrom(center: CGPoint, to point: CGPoint) -> Double {
        let dx = point.x - center.x
        let dy = point.y - center.y
        var angle = atan2(dy, dx) * 180 / .pi
        angle = angle < -90 ? angle + 450 : angle + 90
        return min(max(angle, 0), 360)
    }
}

#Preview {
    MainTimerView(viewModel: .init())
}

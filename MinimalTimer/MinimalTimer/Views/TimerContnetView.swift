//
//  TimerContnetView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 5/13/25.
//

import SwiftUI

struct TimerContentView: View {
    @ObservedObject var viewModel: MainViewModel

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)

            ZStack {
                PieShape(progress: viewModel.progress)
                    .fill(viewModel.currentTimer?.color ?? .blue)

                Circle()
                    .fill(Color.clear)
                    .contentShape(Circle())
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let angle = angleFrom(center: center, to: value.location)
                                viewModel.setUserProgress(from: angle)
                            }
                    )
                    .onTapGesture(count: 1) {
                        viewModel.isRunning ? viewModel.pause() : viewModel.start()
                    }
                    .onTapGesture(count: 2) {
                        viewModel.reset()
                    }
            }
            .frame(width: size, height: size)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
        .frame(height: 280)
    }

    // 드래그 위치를 각도로 변환
    func angleFrom(center: CGPoint, to point: CGPoint) -> Double {
        let dx = point.x - center.x
        let dy = point.y - center.y
        var angle = atan2(dy, dx) * 180 / .pi
        angle = angle < -90 ? angle + 450 : angle + 90
        return min(max(angle, 0), 360)
    }
}

#Preview {
    TimerContentView(viewModel: .init())
}

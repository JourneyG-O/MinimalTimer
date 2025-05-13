//
//  TimerContnetView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 5/13/25.
//

import SwiftUI

struct TimerContnetView: View {
    @ObservedObject var viewModel: MainViewModel

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let center = CGPoint(x: size / 2, y: size / 2)

            PieShape(progress: viewModel.progress)
                .fill(viewModel.currentTimer?.color ?? .blue)
                .frame(width: 260, height: 260)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let angle = self.angleFrom(center: center, to: value.location)
                            viewModel.setUserProgress(from: angle)
                        }
                )
                .onTapGesture(count: 1) {
                    viewModel.isRunning ? viewModel.pause() : viewModel.start()
                }
                .onTapGesture (count: 2){
                    viewModel.reset()
                }
                .animation(.easeInOut, value: viewModel.progress)
                .aspectRatio(1, contentMode: .fit)
                .frame(maxWidth: .infinity)
        }
        .frame(height: 280)
    }

    func angleFrom(center: CGPoint, to point: CGPoint) -> Double {
        let dx = point.x - center.x
        let dy = point.y - center.y
        var angle = atan2(dy, dx) * 180 / .pi
        angle = angle < -90 ? angle + 450 : angle + 90
        return min(max(angle, 0), 360)
    }
}

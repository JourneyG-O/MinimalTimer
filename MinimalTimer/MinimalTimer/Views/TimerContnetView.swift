//
//  TimerContnetView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 5/13/25.
//

import SwiftUI

struct TimerContentView: View {
    let timer: TimerModel
    let progress: CGFloat
    let isInteractive: Bool

    // Interaction 콜백
    let onSingleTap: (() -> Void)?
    let onDoubleTap: (() -> Void)?
    let onDrag: ((Double) -> Void)?

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)

            ZStack {
                // 남은 시간 표시용 PieShape
                PieShape(progress: progress)
                    .fill(timer.color)

                // 상호작용 레이어 (재사용 가능한 뷰 블럭으로 분리)
                interactionLayer(center: center)
            }
            .frame(width: size, height: size)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }

    // 터치 / 드래그 입력을 처리하는 레이어
    @ViewBuilder
    private func interactionLayer(center: CGPoint) -> some View {
        let baseCircle = Circle()
            .fill(Color.clear)
            .contentShape(Circle())

        if isInteractive {
            baseCircle
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let angle = center.angle(to: value.location)
                            onDrag?(angle)
                        }
                )
                .onTapGesture(count: 1) {
                    onSingleTap?()
                }
                .onTapGesture(count: 2) {
                    onDoubleTap?()
                }
        } else {
            baseCircle
                .onTapGesture {
                    onSingleTap?()
                }
        }
    }
}

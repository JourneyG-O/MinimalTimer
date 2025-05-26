//
//  TimerInteractionView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 5/23/25.
//

import SwiftUI

struct TimerInteractionView: View {
    let isInteractive: Bool
    let diameter: CGFloat

    // Interaction 콜백
    let onSingleTap: (() -> Void)?
    let onDoubleTap: (() -> Void)?
    let onDrag: ((Double) -> Void)?

    var body: some View {

        if isInteractive {
            Circle()
                .fill(Color.clear)
                .frame(width: diameter, height: diameter)
                .contentShape(Circle())
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let location = value.location
                            let centerPoint = CGPoint(x: diameter / 2, y: diameter / 2)
                            let angle = centerPoint.angle(to: location)
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
            Circle()
                .fill(Color.black)
                .frame(width: diameter, height: diameter)
                .contentShape(Circle())
                .onTapGesture {
                    onSingleTap?()
                }
        }
    }
}


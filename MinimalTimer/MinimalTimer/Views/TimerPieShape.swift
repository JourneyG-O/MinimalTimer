//
//  TimerPieShape.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 4/30/25.
//

import SwiftUI

struct PieShape: Shape {
    var progress: Double

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        let startAngle = Angle(degrees: -90)
        let endAngle = Angle(degrees: -90 + 360 * progress)

        path.move(to: center)
        path.addArc(center: center,
                    radius: radius,
                    startAngle: startAngle,
                    endAngle: endAngle,
                    clockwise: false)
        path.closeSubpath()

        return path
    }

    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }
}

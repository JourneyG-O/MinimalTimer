//
//  PreviewTimerView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 8/4/25.
//

import SwiftUI

struct PreviewTimerView: View {
    let color: Color
    let totalTime: TimeInterval
    let title: String
    let onSelected: () -> Void

    var body: some View {
        GeometryReader { geo in
            let side   = min(geo.size.width, geo.size.height)
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let radius = side / 2
            let titleY = center.y - radius / 2

            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: side, height: side)
                    .position(center)

                Text(totalTime.mmss)
                    .font(.system(size: side * 0.22, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundColor(Color(.systemBackground))
                    .position(center)

                Text(title)
                    .font(.system(size: side * 0.12, weight: .semibold, design: .rounded))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .minimumScaleFactor(0.8)
                    .allowsTightening(true)
                    .foregroundColor(Color(.systemBackground).opacity(0.95))
                    .frame(width: side * 0.8, alignment: .center)
                    .position(x: center.x, y: titleY)
            }
            .contentShape(Circle())
            .onTapGesture(perform: onSelected)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

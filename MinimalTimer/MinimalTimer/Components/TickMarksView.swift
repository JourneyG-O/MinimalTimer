//
//  TickMarksView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 6/11/25.
//

import SwiftUI

enum TickUnit {
    case second
    case minute
}

struct TickMarksView: View {
    let totalUnits: Int
    let unit: TickUnit
    let tickInset: CGFloat = 10

    init(totalMinutes: Int) {
        self.totalUnits = max(totalMinutes, 1)
        self.unit = .minute
    }

    init(totalSeconds: Int) {
        self.totalUnits = max(totalSeconds, 1)
        self.unit = .second

    }

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let size = min(width, height)
            let count = max(totalUnits, 1)
            let majorEvery = 5

            ZStack {
                ForEach(0..<count, id: \.self) { i in
                    Rectangle()
                        .fill(Color.gray.opacity(0.8))
                        .frame(width: 2, height: (i % majorEvery == 0) ? 14 : 6)
                        .offset(y: -size / 2 + tickInset)
                        .rotationEffect(.degrees(Double(i) / Double(count) * 360))
                }
            }
            .frame(width: width, height: height)
        }
    }
}

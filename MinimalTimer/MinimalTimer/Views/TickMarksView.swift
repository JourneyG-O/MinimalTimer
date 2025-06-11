//
//  TickMarksView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 6/11/25.
//

import SwiftUI

struct TickMarksView: View {
    let diameter: CGFloat
    let totalMinutes: Int

    var body: some View {
        ZStack {
            ForEach(0..<totalMinutes, id: \.self) { i in
                Rectangle()
                    .fill(Color.gray.opacity(i % 5 == 0 ? 0.8 : 0.4))
                    .frame(width: 2, height: i % 5 == 0 ? 14 : 6)
                    .offset(y: -diameter / 2)
                    .rotationEffect(.degrees(Double(i) / Double(totalMinutes) * 360))
            }
        }
        .frame(width: diameter, height: diameter)
    }
}

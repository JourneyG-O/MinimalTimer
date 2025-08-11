//
//  TickMarksView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 6/11/25.
//

import SwiftUI

struct TickMarksView: View {
    let totalMinutes: Int
    let tickInset: CGFloat = 10

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height

            ZStack {
                ForEach(0..<totalMinutes, id: \.self) { i in
                    Rectangle()
                        .fill(Color.gray.opacity(0.8))
                        .frame(width: 2, height: i % 5 == 0 ? 14 : 6)
                        .offset(y: -width / 2 + tickInset)
                        .rotationEffect(.degrees(Double(i) / Double(totalMinutes) * 360))
                }
            }
            .frame(width: width, height: height)
        }
    }
}

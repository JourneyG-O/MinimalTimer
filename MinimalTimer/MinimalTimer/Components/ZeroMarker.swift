//
//  ZeroMarker.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 8/23/25.
//

import SwiftUI

struct ZeroMarker: View {
    let color: Color
    let lineWidth: CGFloat = 2

    var body: some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(color)
                .frame(width: lineWidth, height: geometry.size.height / 2)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 4)
                .allowsHitTesting(false)
        }
    }
}

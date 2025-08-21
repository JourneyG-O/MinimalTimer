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
        ZStack {
            Circle()
                .fill(color)

            VStack(spacing: 8) {
                Text(title)
                    .foregroundColor(Color(.systemBackground))
                    .font(.system(size: 30, weight: .semibold, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text(totalTime.mmss)
                    .foregroundColor(Color(.systemBackground))
                    .font(.system(size: 40, weight: .bold, design: .rounded))
            }


        }
        .onTapGesture(perform: onSelected)
    }
}


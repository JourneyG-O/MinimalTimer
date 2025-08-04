//
//  PreviewTimerView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 8/4/25.
//

import SwiftUI

struct PreviewTimerView: View {
    let color: Color
//    let totalTime: TimeInterval
    let onTap: () -> Void

    var body: some View {
        Circle()
            .fill(color)
            .overlay(
                Circle()
                    .stroke(Color.primary.opacity(0.2), lineWidth: 2)
            )
            .onTapGesture(perform: onTap)
    }
}


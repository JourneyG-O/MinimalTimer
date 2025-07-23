//
//  PausedStatusView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 7/23/25.
//

import SwiftUI

struct PausedStatusView: View {
    let isRunning: Bool

    var body: some View {
        Text("Paused")
            .font(.body)
            .opacity(isRunning ? 0 : 1)
            .animation(.easeInOut(duration: 0.3), value: isRunning)
    }
}

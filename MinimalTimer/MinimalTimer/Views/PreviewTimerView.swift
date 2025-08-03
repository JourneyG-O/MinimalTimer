//
//  PreviewTimerView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 8/4/25.
//

import SwiftUI

struct PreviewTimerView: View {
    let color: Color
    let onTap: () -> Void

    var body: some View {
        Circle()
            .fill(color)
            .onTapGesture(perform: onTap)
    }
}


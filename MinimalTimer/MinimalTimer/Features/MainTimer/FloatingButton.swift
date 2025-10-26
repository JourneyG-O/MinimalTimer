//
//  FloatingButton.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 10/23/25.
//

import SwiftUI

struct FloatingButton: View {
    let symbol: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 20, weight: .bold))
                .symbolRenderingMode(.hierarchical)
                .contentTransition(.symbolEffect(.replace))
                .padding(18)
                .background {
                    Capsule().fill(.clear)
                }
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive(), in: .capsule)
        .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 6)
        .contentShape(Capsule())
        .accessibilityAddTraits(.isButton)
    }
}

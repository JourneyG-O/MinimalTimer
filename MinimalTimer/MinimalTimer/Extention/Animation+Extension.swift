//
//  Animation+Extension.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 8/22/25.
//

import SwiftUI

struct PopInOnAppear: ViewModifier {
    let scale: CGFloat
    let stiffness: CGFloat
    let damping: CGFloat
    let delay: Double

    @State private var shown = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(shown ? 1 : scale, anchor: .center)
            .opacity(shown ? 1 : 0)
            .onAppear {
                shown = false
                withAnimation(.interpolatingSpring(stiffness: stiffness, damping: damping).delay(delay)) {
                    shown = true
                }
            }
            .onDisappear { shown = false } // 돌아올 때 다시 애니메이션
    }
}

extension View {
    func popInOnAppear(
        scale: CGFloat = 0.6,
        stiffness: CGFloat = 320,
        damping: CGFloat = 28,
        delay: Double = 0
    ) -> some View {
        self.modifier(PopInOnAppear(scale: scale, stiffness: stiffness, damping: damping, delay: delay))
    }
}

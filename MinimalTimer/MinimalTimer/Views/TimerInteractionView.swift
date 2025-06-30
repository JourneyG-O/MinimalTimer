//
//  TimerInteractionView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 5/23/25.
//

import SwiftUI

struct TimerInteractionView: View {
    // MARK: - Configuration
    let interactionMode: InteractionMode
    let diameter: CGFloat

    // MARK: - Actions
    let onSingleTap: (() -> Void)?
    let onDoubleTap: (() -> Void)?
    let onDrag: ((Double) -> Void)?
    let onDragEnd: (() -> Void)?

    // MARK: - Body
    var body: some View {
        Circle()
            .fill(Color.clear)
            .frame(width: diameter, height: diameter)
            .contentShape(Circle())
            .gesture(interactionMode == .normal ? dragGesture : nil)
            .onTapGesture(count: 2, perform: doubleTapHandler)
            .onTapGesture(perform: singleTapHandler)
    }

    // MARK: - Drag Gesture
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                let location = value.location
                let centerPoint = CGPoint(x: diameter / 2, y: diameter / 2)
                let angle = centerPoint.angle(to: location)
                onDrag?(angle)
            }
            .onEnded { _ in
                onDragEnd?()
            }
    }

    // MARK: - Tap Handlers
    private func singleTapHandler() {
        onSingleTap?()
    }

    private func doubleTapHandler() {
        guard interactionMode == .normal else { return }
        onDoubleTap?()
    }
}


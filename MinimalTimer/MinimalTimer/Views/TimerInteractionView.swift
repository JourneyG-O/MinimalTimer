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
    let onLongPress: (() -> Void)?

    // MARK: - Body
    var body: some View {
        Circle()
            .fill(Color.clear)
            .frame(width: diameter, height: diameter)
            .contentShape(Circle())
            .gesture(combinedGesture)
            .onTapGesture(count: 2, perform: doubleTapHandler)
            .onTapGesture(perform: singleTapHandler)
    }

    // MARK: - Gesture Combination
    private var combinedGesture: some Gesture {
        let longPress = LongPressGesture(minimumDuration: 0.6)
            .onEnded { _ in
                onLongPress?()
            }

        let drag = DragGesture()
            .onChanged { value in
                let location = value.location
                let centerPoint = CGPoint(x: diameter / 2, y: diameter / 2)
                let angle = centerPoint.angle(to: location)
                onDrag?(angle)
            }
            .onEnded { _ in
                onDragEnd?()
            }

        return longPress.exclusively(before: drag)
    }

    // MARK: - Tap Handlers
    private func singleTapHandler() {
        onSingleTap?()
    }

    private func doubleTapHandler() {
        onDoubleTap?()
    }
}


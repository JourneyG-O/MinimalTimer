//
//  TimerInteractionView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 5/23/25.
//

import SwiftUI

struct TimerDialView: View {
    // MARK: - Configuration
    let interactionMode: InteractionMode

    // MARK: - Actions
    let onSingleTap: (() -> Void)?
    let onDoubleTap: (() -> Void)?
    let onDrag: ((Double) -> Void)?
    let onDragEnd: (() -> Void)?

    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let centerPoint = CGPoint(x: width / 2, y: height / 2)

            let dragGesture = DragGesture()
                .onChanged { value in
                    let location = value.location
                    let angle = centerPoint.angle(to: location)
                    onDrag?(angle)
                }
                .onEnded { _ in
                    onDragEnd?()
                }

            Circle()
                .fill(Color.clear)
                .frame(width: width, height: height)
                .position(x: centerPoint.x, y: centerPoint.y)
                .contentShape(Circle())
                .gesture(interactionMode == .normal ? dragGesture : nil)
                .onTapGesture(count: 2, perform: doubleTapHandler)
                .onTapGesture(perform: singleTapHandler)
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


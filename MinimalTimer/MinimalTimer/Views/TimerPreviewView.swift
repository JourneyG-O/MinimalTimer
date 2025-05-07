//
//  TimerPreviewView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 5/7/25.
//

import SwiftUI

struct TimerPreviewView: View {
    let title: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    let showGear: Bool
    let grearAction: () -> Void

    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: isSelected ? 100 : 90, height: isSelected ? 100 : 90)
                    .overlay(
                        Circle().stroke(Color.white, lineWidth: isSelected ? 4 : 0)
                    )
                    .onTapGesture {
                        action()
                    }
                if showGear {
                    Image(systemName: "gearshape")
                        .foregroundColor(.white)
                        .padding(6)
                        .background(Circle().fill(Color.black.opacity(0.6)))
                        .offset(x: -5, y: 5)
                        .onTapGesture {
                            grearAction()
                        }
                }
            }

            Text(title)
                .font(.caption)
        }
    }
}

#Preview {
    TimerPreviewView(
        title: "예시 타이머",
        color: .blue,
        isSelected: true,
        action: {},
        showGear: true,
        grearAction: {}
    )
}

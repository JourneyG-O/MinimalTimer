//
//  AddTimerCardView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 7/15/25.
//

import SwiftUI

struct AddTimerCardView: View {
    let diameter: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.gray.opacity(0.15))
            Image(systemName: "plus")
                .font(.system(size: diameter * 0.3, weight: .bold))
                .foregroundColor(.gray)
        }
        .frame(width: diameter, height: diameter)
    }
}

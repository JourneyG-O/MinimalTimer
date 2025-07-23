//
//  AddTimerCardView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 7/15/25.
//

import SwiftUI

struct AddTimerCardView: View {
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let minSide = min(size.width, size.height)

            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.15))

                Image(systemName: "plus")
                    .font(.system(size: minSide * 0.3, weight: .bold))
                    .foregroundColor(.gray)
            }
            .frame(width: size.width, height: size.height)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

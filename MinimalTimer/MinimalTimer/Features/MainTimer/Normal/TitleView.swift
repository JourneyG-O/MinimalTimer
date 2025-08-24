//
//  TitleView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 8/21/25.
//

import SwiftUI

struct TitleView: View {
    let title: String?

    var body: some View {
        Text(title ?? "Minimal Timer")
            .font(.system(size: 40, weight: .bold, design: .rounded))
            .fontWeight(.semibold)
            .foregroundColor(.primary)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .accessibilityIdentifier("TitleView_Text")
    }
}

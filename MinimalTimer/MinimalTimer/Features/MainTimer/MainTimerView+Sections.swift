//
//  MainTimerView+Sections.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 6/10/25.
//

import SwiftUI

// MARK: - Title View
extension MainTimerView {
    struct TitleView: View {
        let title: String?
        var body: some View {
            Text(title ?? "Minimal Timer")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .fontWeight(.semibold)
                .foregroundColor(.black)
        }
    }
}

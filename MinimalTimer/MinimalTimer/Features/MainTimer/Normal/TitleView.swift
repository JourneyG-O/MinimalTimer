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
        Text(title ?? "")
            .font(.system(size: 40, weight: .bold, design: .rounded))
            .foregroundStyle(.primary)              
            .lineLimit(1)
            .truncationMode(.tail)
            .minimumScaleFactor(0.75)
            .allowsTightening(true)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, alignment: .center)
    }
}

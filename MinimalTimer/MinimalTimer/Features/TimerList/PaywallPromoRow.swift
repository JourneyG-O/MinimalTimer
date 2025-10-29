//
//  PaywallPromoRow.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 10/29/25.
//

import SwiftUI

struct PaywallPromoRow: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.background)
                    .padding(.horizontal, 12)



                VStack(alignment: .leading, spacing: 4) {
                    Text("Minimal Timer Pro")
                        .font(.headline)
                        .foregroundStyle(.background)

                    Text("한 번 결제로 평생 소유")
                        .font(.footnote)
                        .foregroundStyle(.background.opacity(0.7))
                        .lineLimit(2)
                }

                Spacer(minLength: 0)

                Text("UPGRADE")
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(.background)
                    )
            }
            .padding(16)
            .background {
                RoundedRectangle(cornerRadius: 18)
                    .fill(.primary)
            }
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityHint("결제 화면으로 이동")
    }
}

#Preview("PaywallPromoRow – Light") {
    PaywallPromoRow(onTap: {})
        .padding()
        .background(Color(.systemBackground))
        .preferredColorScheme(.light)
}

#Preview("PaywallPromoRow – Dark") {
    PaywallPromoRow(onTap: {})
        .padding()
        .background(Color(.systemBackground))
        .preferredColorScheme(.dark)
}

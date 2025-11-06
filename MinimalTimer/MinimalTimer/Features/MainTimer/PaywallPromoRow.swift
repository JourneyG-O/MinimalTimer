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
            HStack(spacing: 8) {
                Spacer(minLength: 0)
                
                VStack(alignment: .center, spacing: 4) {
                    Text(L("paywallpromo.title"))
                        .font(.headline)
                        .foregroundStyle(.background)

                    Text(L("paywallpromo.subtitle"))
                        .font(.footnote)
                        .foregroundStyle(.background.opacity(0.7))
                        .lineLimit(2)
                }
                .padding(.leading, 22)

                Spacer(minLength: 0)

                Text(L("paywallpromo.cta"))
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(.background)
                    )
                    .padding(.trailing, 12)
            }
            .padding(.vertical, 8)
            .background {
                Capsule()
                    .fill(.primary)
            }
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityHint(L("paywallpromo.hint"))
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

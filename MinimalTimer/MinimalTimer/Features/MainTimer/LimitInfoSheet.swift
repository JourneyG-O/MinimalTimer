//
//  LimitInfoSheet.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 11/5/25.
//

import SwiftUI

struct LimitInfoSheet: View {
    let currentCount: Int
    let limit: Int
    var onUpgrade: () -> Void
    var onManage: () -> Void
    var onClose: () -> Void

    var body: some View {
        VStack(spacing: 16) {

            // MARK: - Title & Subtitle (Localized)
            Text(LF("limit.title", limit))
                .font(.title3.bold())

            Text(LF("limit.subtitle", currentCount, limit))
                .foregroundStyle(.secondary)

            // MARK: - CTA Buttons
            HStack(spacing: 12) {
                Button(L("limit.cta.manage"), action: onManage)
                    .buttonStyle(.bordered)
                    .foregroundStyle(.secondary)

                Button(L("limit.cta.upgrade"), action: onUpgrade)
                    .buttonStyle(.borderedProminent)
                    .tint(.primary)
                    .foregroundStyle(.background)
                    .accessibilityHint(L("limit.cta.upgrade.hint"))
            }
            .padding(.top, 4)

            // MARK: - Close
            Button(L("limit.close"), action: onClose)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.top, 8)
        }
        .padding(20)
        .presentationDetents([.height(220), .medium])
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            String(
                format: "%@, %@",
                String(localized: "limit.title", defaultValue: "Timers up to \(limit) free"),
                String(localized: "limit.subtitle", defaultValue: "Using \(currentCount) of \(limit)")
            )
        )
    }
}

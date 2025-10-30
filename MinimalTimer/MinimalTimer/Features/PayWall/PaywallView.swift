//
//  NewPaywallView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 10/28/25.
//

import SwiftUI

struct PaywallView: View {
    // MARK: - Dependencies
    let priceString: String
    var onClose: (() -> Void)?
    var onUpgradeTap: (() -> Void)?
    var onRestoreTap: (() -> Void)?
    var onOpenTerms: (() -> Void)?
    var onOpenPrivacy: (() -> Void)?

    // MARK: - State
    @State private var isLoadingPrice = false

    // MARK: - Body
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 24) {
                header
                    .padding(.top, 24)

                features
                    .padding(.horizontal, 32)
                    .padding(.top, 24)

                Spacer(minLength: 0)

                restoreButton

                upgradeButton
                    .buttonStyle(.plain)
            }
        }
        .toolbar { topBar }
        .navigationBarTitleDisplayMode(.inline)
        .task { await simulatePriceLoading() }
    }
}

// MARK: - Sections
private extension PaywallView {
    var header: some View {
        VStack(spacing: 8) {
            Text(L("paywall.title"))
                .font(.system(size: 32, weight: .bold, design: .rounded))
        }
    }

    var features: some View {
        VStack(alignment: .leading, spacing: 24) {
            featureRow(
                icon: "checkmark",
                title: L("paywall.feature.once.title"),
                subtitle: L("paywall.feature.unlimited.subtitle")
            )
            featureRow(
                icon: "infinity",
                title: L("paywall.feature.unlimited.title"),
                subtitle: L("paywall.feature.unlimited.subtitle")
            )
            featureRow(
                icon: "lock.open.fill",
                title: L("paywall.feature.unlock.title"),
                subtitle: L("paywall.feature.unlock.subtitle")
            )
            featureRow(
                icon: "sparkles",
                title: L("paywall.feature.future.title"),
                subtitle: L("paywall.feature.future.subtitle")
            )
        }
    }

    var restoreButton: some View {
        Button(action: { onRestoreTap?() }) {
            HStack(spacing: 6) {
                Image(systemName: "repeat")
                    .opacity(0.5)
                Text(L("paywall.restore"))
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
            }
        }
        .font(.caption)
        .tint(.primary)
    }

    var upgradeButton: some View {
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                onUpgradeTap?()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: isLoadingPrice ? "hourglass" : "lock.open")
                        .contentTransition(.symbolEffect(.replace))
                    Group {
                        if isLoadingPrice {
                            Text(L("paywall.upgrade.loading"))
                        } else {
                            Text(LF("paywall.upgrade.cta", priceString))
                        }
                    }
                    .contentTransition(.opacity)
                }
                .font(.system(size: 17, weight: .semibold))
                .frame(maxWidth: .infinity, minHeight: 52)
                .foregroundStyle(.background)
                .glassEffect(.regular.tint(.primary).interactive())
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
            }
        }
}

// MARK: - Private Views
private extension PaywallView {
    func featureRow(icon: String, title: LocalizedStringKey, subtitle: LocalizedStringKey) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .frame(width: 28, height: 28, alignment: .center)
                .alignmentGuide(.firstTextBaseline) { d in
                    d[VerticalAlignment.center]
                }
                .foregroundStyle(.primary)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Toolbar & Tasks
private extension PaywallView {
    var topBar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button { onClose?() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.background)
                    .frame(width: 32, height: 32)
            }
            .glassEffect(.regular.tint(.primary).interactive())
            .clipShape(Circle())
            .accessibilityLabel(L("paywall.close"))
        }
    }

    func simulatePriceLoading() async {
        isLoadingPrice = true
        try? await Task.sleep(nanoseconds: 900_000_000)
        isLoadingPrice = false
    }
}

// MARK: - Preview
#Preview("NewPaywallView - 기본") {
    NavigationStack {
        PaywallView(
            priceString: "₩5,900",
            onClose: { print("닫기") },
            onUpgradeTap: { print("업그레이드") },
            onRestoreTap: { print("복원") },
            onOpenTerms: { print("이용약관") },
            onOpenPrivacy: { print("개인정보 처리방침") }
        )
        .navigationBarTitleDisplayMode(.inline)
    }
}


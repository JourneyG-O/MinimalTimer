//
//  PayWallView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 9/2/25.
//

import SwiftUI

private func L(_ key: String) -> LocalizedStringKey { LocalizedStringKey(key) }

struct PaywallView: View {
    var priceString: String                  // 예: "₩3,000"
    var onClose: (() -> Void)? = nil
    var onUpgradeTap: (() -> Void)? = nil
    var onRestoreTap: (() -> Void)? = nil

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color(.systemBackground).ignoresSafeArea()

            // 닫기 버튼
            Button { onClose?() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.orange)
                    .frame(width: 32, height: 32)
                    .background(.thinMaterial, in: Circle())
            }
            .padding(.top, 16)
            .padding(.trailing, 16)

            VStack(spacing: 0) {
                // 헤더
                VStack(spacing: 12) {
                    ZStack {
                        Circle().fill(.ultraThinMaterial).frame(width: 100, height: 100)
                        Image("Logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                    }
                    .padding(.top, 56)

                    VStack(spacing: 6) {
                        Text(L("paywall.header.title"))      // Minimal Timer
                            .font(.system(.title, design: .rounded).bold())
                        Text(L("paywall.header.subtitle"))    // 업그레이드하여 모든 기능 잠금 해제
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.bottom, 8)
                }

                // 기능 리스트
                List {
                    Section {
                        FeatureRow(
                            icon: "plus.app.fill",
                            title: L("paywall.feature.1.title"),
                            subtitle: L("paywall.feature.1.desc")
                        )
                        .listRowBackground(Color(.secondarySystemBackground))
                        .listRowSeparator(.hidden)

                        FeatureRow(
                            icon: "paintpalette.fill",
                            title: L("paywall.feature.2.title"),
                            subtitle: L("paywall.feature.2.desc")
                        )
                        .listRowBackground(Color(.secondarySystemBackground))
                        .listRowSeparator(.hidden)

                        FeatureRow(
                            icon: "repeat",
                            title: L("paywall.feature.3.title"),
                            subtitle: L("paywall.feature.3.desc")
                        )
                        .listRowBackground(Color(.secondarySystemBackground))
                        .listRowSeparator(.hidden)

                        FeatureRow(
                            icon: "sparkles",
                            title: L("paywall.feature.4.title"),
                            subtitle: L("paywall.feature.4.desc")
                        )
                        .listRowBackground(Color(.secondarySystemBackground))
                        .listRowSeparator(.hidden)
                    }

                    // 하단 링크/안내
                    Section(footer:
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 16) {
                                Button(String(localized: "paywall.link.privacy")) { /* open privacy URL */ }
                                Button(String(localized: "paywall.link.terms")) { /* open terms URL */ }
                                Spacer()
                                Button(String(localized: "paywall.link.restore")) {
                                    onRestoreTap?()
                                }
                                .fontWeight(.semibold)
                            }
                            .font(.caption)
                            .foregroundStyle(.gray)

                            Text(L("paywall.footer.note")) // 일회성 결제, 동일 Apple ID로 언제든 복원 가능
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 4)
                    ) {
                        EmptyView()
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color(.systemBackground))
                .listStyle(.insetGrouped)
                .scrollIndicators(.automatic)
                .safeAreaPadding(.bottom, 80) // 하단 CTA 공간
            }
        }
        // 하단 고정 CTA
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 6) {
                Button {
                    onUpgradeTap?()
                } label: {
                    HStack(spacing: 4) {
                        Text(L("paywall.button.upgrade.prefix")) // 예: "업그레이드 ·"
                        Text(priceString)
                    }
                    .font(.system(size: 17, weight: .semibold))
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .foregroundStyle(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color.orange)
                    )
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.plain)

                Text(L("paywall.footer.note"))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .background(.ultraThinMaterial)
        }
    }
}

private struct FeatureRow: View {
    let icon: String
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.orange)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
    }
}

#Preview("Paywall – Light") {
    PaywallView(priceString: "₩3,000")
        .preferredColorScheme(.light)
}
#Preview("Paywall – Dark") {
    PaywallView(priceString: "₩3,000")
        .preferredColorScheme(.dark)
}

//
//  PayWallView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 9/2/25.
//

import SwiftUI

struct PaywallView: View {
    var priceString: String                  // e.g., "₩3,000"
    var onClose: (() -> Void)? = nil
    var onUpgradeTap: (() -> Void)? = nil
    var onRestoreTap: (() -> Void)? = nil
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color(.systemBackground).ignoresSafeArea()


            VStack(spacing: 0) {
                // Header
                VStack(spacing: 12) {

                    VStack(spacing: 6) {
                        Text(L("paywall.appName"))
                            .font(.system(.title, design: .rounded).bold())
                        Text(L("paywall.subtitle"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.bottom, 8)
                }

                // Feature list
                List {
                    Section {
                        FeatureRow(
                            icon: "plus.app.fill",
                            title: L("paywall.feature.unlimited.title"),
                            subtitle: L("paywall.feature.unlimited.subtitle")
                        )
                        .listRowBackground(Color(.secondarySystemBackground))
                        .listRowSeparator(.hidden)

                        FeatureRow(
                            icon: "paintpalette.fill",
                            title: L("paywall.feature.custom.title"),
                            subtitle: L("paywall.feature.custom.subtitle")
                        )
                        .listRowBackground(Color(.secondarySystemBackground))
                        .listRowSeparator(.hidden)

                        FeatureRow(
                            icon: "repeat",
                            title: L("paywall.feature.utility.title"),
                            subtitle: L("paywall.feature.utility.subtitle")
                        )
                        .listRowBackground(Color(.secondarySystemBackground))
                        .listRowSeparator(.hidden)

                        FeatureRow(
                            icon: "sparkles",
                            title: L("paywall.feature.future.title"),
                            subtitle: L("paywall.feature.future.subtitle")
                        )
                        .listRowBackground(Color(.secondarySystemBackground))
                        .listRowSeparator(.hidden)
                    }

                    Section(footer:
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 16) {
                                Button(L("paywall.links.privacy")) { /* open privacy */ }
                                Button(L("paywall.links.terms")) { /* open terms */ }
                                Spacer()
                                Button(L("paywall.links.restore")) { onRestoreTap?() }
                                    .fontWeight(.semibold)
                            }
                            .font(.caption)
                            .foregroundStyle(.gray)
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
                .safeAreaPadding(.bottom, 80)
            }
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 6) {
                Button { onUpgradeTap?() } label: {
                    Text(LocalizedStringKey("paywall.cta.upgrade \(priceString)")) // 유료 기능 붙힐 때 수정해야 함
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

                Text(L("paywall.restore.note"))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .background(.ultraThinMaterial)
        }

        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    if let onClose { onClose() } else { dismiss() }
                } label: {
                    Image(systemName: "xmark")
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .accessibilityLabel(L("paywall.close"))
            }
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

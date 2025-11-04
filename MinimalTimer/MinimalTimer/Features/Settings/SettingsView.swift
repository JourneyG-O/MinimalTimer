//
//  SettingsView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 11/4/25.
//

import SwiftUI

struct SettingsView: View {
    var onClose: (() -> Void)?
    var onShowPaywall: (() -> Void)?

    @EnvironmentObject private var purchaseManager: PurchaseManager
    @Environment(\.openURL) private var openURL

    var body: some View {
        List {
            premiumSection
            appInfoSection
            policySection
        }
        .listStyle(.insetGrouped)
        .navigationTitle(L("settings.title"))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { onClose?() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                }
                .accessibilityLabel(L("settings.close.label"))
                .accessibilityHint(L("settings.close.hint"))
            }
        }
        .task { await purchaseManager.refreshProducts() }
    }
}

// MARK: - Sections
private extension SettingsView {
    var premiumSection: some View {
        Section(L("settings.premium.section")) {
            if purchaseManager.isPremium {
                Label(L("settings.premium.active"), systemImage: "checkmark.seal.fill")
                    .foregroundStyle(.green)
            } else {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(L("settings.premium.headline"))
                        Text(purchaseManager.localizedPrice.isEmpty
                             ? L("settings.premium.price.loading")
                             : LocalizedStringKey(purchaseManager.localizedPrice))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 12)
                    Button(L("settings.premium.buy")) { onShowPaywall?() }
                        .buttonStyle(.borderedProminent)
                }
                Button(L("settings.premium.restore")) {
                    Task { await purchaseManager.restore() }
                }
            }

            if let err = purchaseManager.lastError {
                Text(err)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }

    var appInfoSection: some View {
        Section(L("settings.appinfo.section")) {
            HStack {
                Text(L("settings.appinfo.version"))
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-")
                    .foregroundStyle(.secondary)
            }
        }
    }

    var policySection: some View {
        Section(L("settings.policy.section")) {
            Button(L("settings.policy.terms")) {
                if let url = URL(string: "https://stannum.app/apps/minimal-timer/legal/terms.html") {
                    openURL(url)
                }
            }
            Button(L("settings.policy.privacy")) {
                if let url = URL(string: "https://stannum.app/apps/minimal-timer/legal/privacy.html") {
                    openURL(url)
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}

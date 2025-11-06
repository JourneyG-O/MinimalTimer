//
//  SettingsView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 11/4/25.
//

import SwiftUI

struct SettingsView: View {
    // MARK: - Callbacks
    var onClose: (() -> Void)?
    var onShowPaywall: (() -> Void)?

    // MARK: - Env / Deps
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @Environment(\.openURL) private var openURL

    // MARK: - State
    @State private var isRestoring = false
    @State private var showRestoreAlert = false
    @State private var restoreMessage: LocalizedStringKey = ""

    var body: some View {
        ZStack {
            // Base content
            List {
                premiumSection
                appInfoSection
                policySection
            }
            .listStyle(.insetGrouped)
            .allowsHitTesting(!isRestoring)

            // HUD overlay while restoring
            if isRestoring {
                Color.black.opacity(0.08).ignoresSafeArea()
                VStack(spacing: 8) {
                    ProgressView().progressViewStyle(.circular)
                    Text(L("restore.inprogress"))
                        .font(.footnote)
                        .foregroundStyle(.secondary)

                }
                .padding(16)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .navigationTitle(L("settings.title"))
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if isRestoring {
                    ProgressView().scaleEffect(0.9)
                }
            }
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
        .alert(isPresented: $showRestoreAlert) {
            Alert(
                title: Text(L("restore.title")),
                message: Text(restoreMessage),
                dismissButton: .default(Text(L("common.ok")))
            )
        }
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
                        Text(
                            purchaseManager.localizedPrice.isEmpty
                            ? L("settings.premium.price.loading")
                            : LocalizedStringKey(purchaseManager.localizedPrice)
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 12)
                    Button(L("settings.premium.buy")) { onShowPaywall?() }
                        .buttonStyle(.borderedProminent)
                }

                Button {
                    guard !isRestoring else { return }
                    isRestoring = true
                    Task {
                        await purchaseManager.restore()
                        isRestoring = false
                        if purchaseManager.isPremium {
                            restoreMessage = L("restore.success")
                        } else if let err = purchaseManager.lastError {
                            restoreMessage = LocalizedStringKey(err)
                        } else {
                            restoreMessage = L("restore.nothing")
                        }
                        showRestoreAlert = true
                    }
                } label: {
                    HStack(spacing: 8) {
                        if isRestoring {
                            ProgressView().scaleEffect(0.9)
                            Text(L("restore.inprogress"))
                                .foregroundStyle(.secondary)
                        } else {
                            Text(L("settings.premium.restore"))
                        }
                    }
                }
                .disabled(isRestoring)
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

// MARK: - Preview
#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(PurchaseManager.shared)
    }
}

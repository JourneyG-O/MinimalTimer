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
            Text("Minimal Timer Pro")
                .font(.system(size: 32, weight: .bold, design: .rounded))
        }
    }

    var features: some View {
        VStack(alignment: .leading, spacing: 24) {
            featureRow(
                icon: "checkmark",
                title: "한 번의 결제로 평생 소유",
                subtitle: "Minimal Timer의 모든 기능을 영원히 사용하세요."
            )
            featureRow(
                icon: "infinity",
                title: "무제한 타이머 생성",
                subtitle: "제한 없이 원하는 만큼 타이머를 만들 수 있습니다."
            )
            featureRow(
                icon: "lock.open.fill",
                title: "모든 기능 언락",
                subtitle: "컬러, 무음, 눈금, 타이틀 세밀한 설정까지 모두 열립니다."
            )
            featureRow(
                icon: "sparkles",
                title: "앞으로의 업데이트",
                subtitle: "결제 후 추가될 모든 기능을 함께 누리세요."
            )
        }
    }

    var restoreButton: some View {
        Button(action: { onRestoreTap?() }) {
            HStack(spacing: 6) {
                Image(systemName: "repeat")
                    .opacity(0.5)
                Text("구매 복원")
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
                Text(isLoadingPrice ? "가격 확인 중…" : "\(priceString)에 업그레이드")
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
    func featureRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .semibold))
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
            .accessibilityLabel("닫기")
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

//
//  PayWallView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 9/2/25.
//

import SwiftUI

struct PaywallView: View {
    var onClose: (() -> Void)? = nil
    var onUpgradeTap: (() -> Void)? = nil

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
                // 헤더(로고 + 타이틀 + 서브텍스트)
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
                        Text("Minimal Timer")
                            .font(.system(.title, design: .rounded).bold())
                        Text("업그레이드 하여 모든 기능 잠금 해제!")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.bottom, 8)
                }

                List {
                    Section {
                        FeatureRow(icon: "plus.app.fill",
                                   title: "나만의 타이머 만들기",
                                   subtitle: "원하는 시간·타이틀·컬러로 생성/편집")
                        .listRowBackground(Color(.secondarySystemBackground))
                        .listRowSeparator(.hidden)
                        FeatureRow(icon: "paintpalette.fill",
                                   title: "맞춤 스타일 설정",
                                   subtitle: "눈금·타이틀 표시 여부를 취향대로")
                        .listRowBackground(Color(.secondarySystemBackground))
                        .listRowSeparator(.hidden)
                        FeatureRow(icon: "repeat",
                                   title: "타이머 편의 기능",
                                   subtitle: "반복 등 꼭 필요한 기능만 간결하게")
                        .listRowBackground(Color(.secondarySystemBackground))
                        .listRowSeparator(.hidden)
                        FeatureRow(icon: "sparkles",
                                   title: "앞으로 추가될 기능",
                                   subtitle: "업데이트 시 새 기능도 함께 누리세요")
                        .listRowBackground(Color(.secondarySystemBackground))
                        .listRowSeparator(.hidden)
                    }

                    // 하단 링크 + 안내 문구
                    Section(footer:
                        VStack(alignment: .leading, spacing: 8) {


                            HStack(spacing: 16) {
                                Button("개인정보 처리방침", action: {})
                                Button("이용약관", action: {})
                                Spacer()
                                Button("구매 복원", action: {})
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

                // 하단 고정 CTA 공간만큼 여유
                .safeAreaPadding(.bottom, 80)
            }
        }
        // 하단 고정 CTA 버튼
        .safeAreaInset(edge: .bottom) {
            VStack {
                Button {
                    onUpgradeTap?()
                } label: {
                    Text("업그레이드 · ₩3,000")
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
                 // 버튼 뒤 살짝 깔아주기

                Text("일회성 결제, 동일 Apple ID로 언제든 복원 가능")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .background(.ultraThinMaterial)
        }
    }
}

// 기능 한 줄 컴포넌트 (Form에서도 그대로 사용)
// 기능 한 줄 컴포넌트
struct FeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String

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
    PaywallView()
        .preferredColorScheme(.light)
}

#Preview("Paywall – Dark") {
    PaywallView()
        .preferredColorScheme(.dark)
}


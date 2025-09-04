//
//  OnboardingView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 9/4/25.
//

import SwiftUI

struct OnboardingView: View {
    struct Page: Identifiable, Hashable {
        let id = UUID()
        let imageName: String
        let title: String
        let caption: String
    }

    // 외부에서 닫기 처리
    var onFinish: (() -> Void)?

    private let pages: [Page] = [
        .init(imageName: "ob_tap",
              title: "탭 한 번으로 시작/정지",
              caption: "타이머 원을 한 번 탭하면 시작/정지할 수 있어요."),
        .init(imageName: "ob_drag",
              title: "드래그로 시간 설정",
              caption: "원을 드래그해서 직관적으로 시간을 맞추세요."),
        .init(imageName: "ob_doubletap",
              title: "더블탭으로 리셋",
              caption: "설정된 시간이 있다면 그 값으로 리셋돼요."),
        .init(imageName: "ob_longpress",
              title: "배경 꾹 눌러서 타이머 전환뷰 이동",
              caption: "배경을 길게 눌러 타이머 전환 화면으로 이동합니다.")
    ]

    @State private var selection = 0

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 16) {
                Spacer(minLength: 24)

                VStack(spacing: 6) {
                    Text("Minimal Timer")
                        .font(.system(.title2, design: .rounded).bold())
                    Text("간단한 제스처로 더 간결하게")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                TabView(selection: $selection) {
                    ForEach(pages.indices, id: \.self) { i in
                        OnboardingCard(imageName: pages[i].imageName)
                            .frame(maxWidth: 520)
                            .frame(height: 360)
                            .padding(.horizontal, 20)
                            .tag(i)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))

                VStack(spacing: 6) {
                    Text(pages[selection].title)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.9)

                    Text(pages[selection].caption)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.9)
                        .padding(.horizontal, 16)
                }
                .frame(height: 64)

                Spacer()

                HStack {
                    Button("건너뛰기") {
                        onFinish?()
                    }
                    .foregroundStyle(.secondary)

                    Spacer()

                    Button(action: {
                        if selection < pages.count - 1 {
                            withAnimation(.easeInOut) { selection += 1 }
                        } else {
                            onFinish?()
                        }
                    }) {
                        Text(selection < pages.count - 1 ? "다음" : "시작하기")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(width: 120, height: 44)
                            .foregroundColor(.white)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color.orange)
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
            .animation(.easeInOut(duration: 0.25), value: selection)
        }
        .onAppear {
            UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.label
            UIPageControl.appearance().pageIndicatorTintColor = UIColor.secondaryLabel
        }
    }
}

private struct OnboardingCard: View {
    let imageName: String

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.secondarySystemBackground))

            GeometryReader { geo in
                let side = min(geo.size.width * 0.78, geo.size.height * 0.78, 300)
                VStack {
                    Spacer(minLength: 0)
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: side, height: side)
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(20)
            }
        }
    }
}

//
//  OnboardingView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 9/4/25.
//

import SwiftUI

struct OnboardingView: View {
    @Environment(\.colorScheme) private var colorScheme

    struct Page: Identifiable {
        let id = UUID()
        let imageName: String
        let titleKey: LocalizedStringKey
        let captionKey: LocalizedStringKey
    }

    // 외부에서 닫기 처리
    var onFinish: (() -> Void)?

    // MARK: - Localized Pages
    private let pages: [Page] = [
        .init(
            imageName: "ob_tap",
            titleKey: "onboarding.page1.title",
            captionKey: "onboarding.page1.caption"
        ),
        .init(
            imageName: "ob_drag",
            titleKey: "onboarding.page2.title",
            captionKey: "onboarding.page2.caption"
        ),
        .init(
            imageName: "ob_doubletap",
            titleKey: "onboarding.page3.title",
            captionKey: "onboarding.page3.caption"
        ),
    ]

    @State private var selection = 0

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 16) {
                Spacer(minLength: 24)

                // Cards Pager
                TabView(selection: $selection) {
                    ForEach(pages.indices, id: \.self) { i in
                        OnboardingCard(imageName: {
                            let base = pages[i].imageName
                            let suffix = (colorScheme == .dark) ? "_dark" : "_light"
                            return base + suffix
                        }())
                            .frame(maxWidth: 520)
                            .frame(height: 360)
                            .padding(.horizontal, 20)
                            .tag(i)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))

                // Title & Caption below pager
                VStack(spacing: 6) {
                    Text(pages[selection].titleKey)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.9)

                    Text(pages[selection].captionKey)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.9)
                        .padding(.horizontal, 16)
                }
                .frame(height: 64)

                Spacer()

                // Footer Buttons
                HStack {
                    Button(action: { onFinish?() }) {
                        Text("onboarding.skip")
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
                        Text(selection < pages.count - 1 ? LocalizedStringKey("onboarding.next") : LocalizedStringKey("onboarding.start"))
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

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
        let titleKey: String
        let captionKey: String
    }

    var onFinish: (() -> Void)?

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

    @State private var selection: Int = 0

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 16) {
                Spacer(minLength: 24)

                pager
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .indexViewStyle(.page(backgroundDisplayMode: .always))
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel(L("onboarding.pages.label"))
                    .accessibilityValue(LF("onboarding.pages.value", selection + 1, pages.count))
                    .accessibilityHint(L("onboarding.pages.hint"))

                titleAndCaption
                    .frame(height: 64)

                Spacer()

                footer
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
            }
            .animation(.easeInOut(duration: 0.25), value: selection)
        }
        .onAppear { configurePageControlAppearance() }
    }
}

private extension OnboardingView {
    func resolvedImageName(for base: String) -> String {
        let suffix = (colorScheme == .dark) ? "_dark" : "_light"
        return base + suffix
    }

    func configurePageControlAppearance() {
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.label
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.secondaryLabel
    }

    func imageAccessibilityLabel(for baseName: String) -> LocalizedStringKey {
        switch baseName {
        case "ob_tap":
            return LocalizedStringKey("accessibility.ob_tap")
        case "ob_drag":
            return LocalizedStringKey("accessibility.ob_drag")
        case "ob_doubletap":
            return LocalizedStringKey("accessibility.ob_doubletap")
        default:
            // Fallback: use the base name so VoiceOver reads something meaningful
            return LocalizedStringKey(baseName)
        }
    }
}

private extension OnboardingView {
    var pager: some View {
        TabView(selection: $selection) {
            ForEach(pages.indices, id: \.self) { i in
                let baseName = pages[i].imageName
                OnboardingCard(
                    imageName: resolvedImageName(for: baseName),
                    imageAccessibilityLabel: imageAccessibilityLabel(for: baseName)
                )
                .frame(maxWidth: 520)
                .frame(height: 360)
                .padding(.horizontal, 20)
                .tag(i)
                .accessibilitySortPriority(3)
            }
        }
    }

    var titleAndCaption: some View {
        VStack(spacing: 6) {
            Text(L(pages[selection].titleKey))
                .font(.headline)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.9)

            Text(L(pages[selection].captionKey))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.9)
                .padding(.horizontal, 16)
        }
        .accessibilityElement(children: .combine)
        .accessibilitySortPriority(2)
    }

    var footer: some View {
        HStack {
            Button(action: { onFinish?() }) {
                Text(L("onboarding.skip"))
            }
            .foregroundStyle(.secondary)
            .accessibilityLabel(L("onboarding.skip"))
            .accessibilityHint(L("onboarding.skip.hint"))

            Spacer()

            Button(action: nextOrFinish) {
                if selection < pages.count - 1 {
                    Text(L("onboarding.next"))
                        .font(.system(size: 16, weight: .semibold))
                        .frame(width: 120, height: 44)
                        .foregroundColor(.primary)
                } else {
                    Text(L("onboarding.start"))
                        .font(.system(size: 16, weight: .semibold))
                        .frame(width: 120, height: 44)
                        .foregroundColor(.primary)
                }
            }
            .buttonStyle(.glass)
            .accessibilityLabel(selection < pages.count - 1 ? L("onboarding.next") : L("onboarding.start"))
            .accessibilityHint(selection < pages.count - 1 ? L("onboarding.next.hint") : L("onboarding.start.hint"))
            .accessibilityAddTraits(.isButton)
        }
    }

    func nextOrFinish() {
        if selection < pages.count - 1 {
            withAnimation(.easeInOut) { selection += 1 }
        } else {
            onFinish?()
        }
    }
}

private struct OnboardingCard: View {
    let imageName: String
    let imageAccessibilityLabel: LocalizedStringKey

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.secondary)
                .glassEffect(in: .rect(cornerRadius: 20.0))
                .accessibilityHidden(true)

            GeometryReader { geo in
                let side = min(geo.size.width * 0.78, geo.size.height * 0.78, 300)
                VStack {
                    Spacer(minLength: 0)
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: side, height: side)
                        .accessibilityLabel(Text(imageAccessibilityLabel))
                        .accessibilityAddTraits(.isImage)
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(20)
            }
        }
    }
}

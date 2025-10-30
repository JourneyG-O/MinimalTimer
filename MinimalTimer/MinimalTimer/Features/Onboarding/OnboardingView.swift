//
//  OnboardingView.swift
//  MinimalTimer
//
//  Created by KoJeongseok on 9/4/25.
//

import SwiftUI

struct OnboardingView: View {
    // MARK: - Dependencies
    @Environment(\.colorScheme) private var colorScheme

    // MARK: - Models
    struct Page: Identifiable {
        let id = UUID()
        let imageName: String
        let titleKey: LocalizedStringKey
        let captionKey: LocalizedStringKey
    }

    // MARK: - External Callbacks
    var onFinish: (() -> Void)?

    // MARK: - Initialization / Pages
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

    // MARK: - State
    @State private var selection: Int = 0

    // MARK: - Accessibility
    private var pageAccessibilityLabel: LocalizedStringKey {
        "onboarding.pages.label"
    }

    private var pageAccessibilityHint: LocalizedStringKey {
        "onboarding.pages.hint"
    }

    private var currentPageAccessibilityValue: String {
        let current = selection + 1
        let total = pages.count
        return String(localized: "onboarding.pages.value", defaultValue: "Page \(current) of \(total)")
    }

    private func imageAccessibilityLabel(for baseName: String) -> LocalizedStringKey {
        // Provide a localized key for image description, e.g., "accessibility.ob_tap"
        // You can supply localized strings later.
        return LocalizedStringKey("accessibility.\(baseName)")
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 16) {
                Spacer(minLength: 24)

                pager
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .indexViewStyle(.page(backgroundDisplayMode: .always))
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel(Text(pageAccessibilityLabel))
                    .accessibilityValue(Text(currentPageAccessibilityValue))
                    .accessibilityHint(Text(pageAccessibilityHint))

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

// MARK: - Private Helpers
private extension OnboardingView {
    func resolvedImageName(for base: String) -> String {
        let suffix = (colorScheme == .dark) ? "_dark" : "_light"
        return base + suffix
    }

    func configurePageControlAppearance() {
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.label
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.secondaryLabel
    }
}

// MARK: - Subviews
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
        .accessibilityElement(children: .combine)
        .accessibilitySortPriority(2)
    }

    var footer: some View {
        HStack {
            Button(action: { onFinish?() }) {
                Text("onboarding.skip")
            }
            .foregroundStyle(.secondary)
            .accessibilityLabel(Text("onboarding.skip"))
            .accessibilityHint(Text("onboarding.skip.hint"))

            Spacer()

            Button(action: nextOrFinish) {
                Text(selection < pages.count - 1 ? LocalizedStringKey("onboarding.next") : LocalizedStringKey("onboarding.start"))
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: 120, height: 44)
                    .foregroundColor(.primary)
            }
            .buttonStyle(.glass)
            .accessibilityLabel(selection < pages.count - 1 ? Text("onboarding.next") : Text("onboarding.start"))
            .accessibilityHint(selection < pages.count - 1 ? Text("onboarding.next.hint") : Text("onboarding.start.hint"))
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

// MARK: - Components
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

/*
 Accessibility Localization Keys to provide:
 - "onboarding.pages.label" = "Onboarding pages"; // Label for the pager
 - "onboarding.pages.hint" = "Swipe left or right with three fingers to change pages."; // Adjust gesture language as appropriate
 - "onboarding.pages.value" = "Page %lld of %lld"; // Used to announce current page out of total
 - "onboarding.skip.hint" = "Skip the introduction.";
 - "onboarding.next.hint" = "Go to the next page.";
 - "onboarding.start.hint" = "Finish onboarding and start using the app.";
 - "accessibility.ob_tap" = "Single tap to start or pause the timer."; // Example image alt text
 - "accessibility.ob_drag" = "Drag to adjust the timer duration."; // Example image alt text
 - "accessibility.ob_doubletap" = "Double-tap for a quick reset."; // Example image alt text
*/


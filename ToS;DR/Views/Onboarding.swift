import SwiftUI

#if os(iOS)
import UIKit
#endif

#if os(macOS)
import AppKit
#endif

struct OnboardingView: View {
    @Environment(\.openURL) var openURL

    let defaults = UserDefaults.standard

    @State private var selectedPage = 0
    @State private var done = false

    var body: some View {
        if done {
            ContentView()
            #if os(macOS)
                .frame(minWidth: 700)
            #endif
        } else {
            ZStack {
                backgroundColor
                    .ignoresSafeArea()

                #if os(macOS)
                ScrollView(.vertical, showsIndicators: false) {
                    onboardingContent
                        .padding(containerPadding)
                        .frame(maxWidth: 640, alignment: .center)
                        .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                #else
                onboardingContent
                    .padding(containerPadding)
                #endif
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                bottomBar
            }
        }
    }

    @ViewBuilder
    private var onboardingContent: some View {
        VStack(spacing: 32) {
            #if !os(macOS)
            Spacer(minLength: 0)
            #endif

            #if os(macOS)
            if let page = currentPage {
                OnboardingPageView(
                    model: page,
                    primaryAction: { handlePrimaryAction(for: page) },
                    secondaryAction: { handleSecondaryAction(for: page) },
                    showsActions: false
                )
                .transition(.opacity)
            }
            #else
            TabView(selection: $selectedPage) {
                ForEach(pages) { page in
                    OnboardingPageView(
                        model: page,
                        primaryAction: { handlePrimaryAction(for: page) },
                        secondaryAction: { handleSecondaryAction(for: page) },
                        showsActions: false
                    )
                    .tag(page.id)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            #endif

            Spacer(minLength: 0)
        }
    }

    private var pages: [OnboardingPageView.Model] {
        [
            welcomePage,
            safariPage,
            finalPage
        ]
    }
    
    private var welcomePage: OnboardingPageView.Model {
        .init(
            id: 0,
            illustration: .asset("DarkIcon-Preview"),
            title: String(localized: "onboarding_welcome_title"),
            description: String(localized: "onboarding_welcome_desc"),
            notice: nil,
            accentColor: .accentColor,
            primaryButtonTitle: String(localized: "onboarding_button_next"),
            primaryButtonColor: .accentColor,
            secondaryButtonTitle: nil,
            secondaryButtonColor: .clear
        )
    }
    
    private var safariPage: OnboardingPageView.Model {
        #if os(macOS)
        let secondaryTitle = "How to Enable Extension"
        #else
        let secondaryTitle = String(localized: "onboarding_button_enable")
        #endif
        
        return .init(
            id: 1,
            illustration: .system("safari"),
            title: String(localized: "onboarding_safari_title"),
            description: String(localized: "onboarding_safari_desc"),
            notice: String(localized: "onboarding_safari_notice"),
            accentColor: .blue,
            primaryButtonTitle: String(localized: "onboarding_button_next"),
            primaryButtonColor: .blue,
            secondaryButtonTitle: secondaryTitle,
            secondaryButtonColor: .blue
        )
    }
    
    private var finalPage: OnboardingPageView.Model {
        .init(
            id: 2,
            illustration: .system("party.popper"),
            title: String(localized: "onboarding_final_title"),
            description: String(localized: "onboarding_final_desc"),
            notice: nil,
            accentColor: .purple,
            primaryButtonTitle: String(localized: "onboarding_button_start"),
            primaryButtonColor: .purple,
            secondaryButtonTitle: nil,
            secondaryButtonColor: .clear
        )
    }

    private var currentPage: OnboardingPageView.Model? {
        pages.first(where: { $0.id == selectedPage })
    }

    private var currentAccentColor: Color {
        currentPage?.accentColor ?? .accentColor
    }

    private var backgroundColor: Color {
        #if os(macOS)
        return Color(nsColor: .windowBackgroundColor)
        #else
        return Color(uiColor: .systemGroupedBackground)
        #endif
    }

    private var containerPadding: EdgeInsets {
        #if os(macOS)
        return EdgeInsets(top: 32, leading: 40, bottom: 32, trailing: 40)
        #else
        return EdgeInsets(top: 44, leading: 0, bottom: 34, trailing: 0)
        #endif
    }

    private var bottomBarHorizontalPadding: CGFloat {
        #if os(macOS)
        return 20
        #else
        return 24
        #endif
    }

    private var bottomBarBottomPadding: CGFloat {
        #if os(macOS)
        return 10
        #else
        return 24
        #endif
    }

    private var bottomBarMaterial: Material {
        #if os(macOS)
        return .regularMaterial
        #else
        return .ultraThinMaterial
        #endif
    }

    private var bottomBarSeparatorColor: Color {
        Color.primary.opacity(0.08)
    }

    @ViewBuilder
    private var bottomBar: some View {
        if let page = currentPage {
            VStack(spacing: 16) {
                PageIndicator(count: pages.count,
                               selection: $selectedPage,
                               tint: currentAccentColor)

                VStack(spacing: 12) {
                    if let secondaryTitle = page.secondaryButtonTitle {
                        Button(action: { handleSecondaryAction(for: page) }) {
                            Text(secondaryTitle)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(OnboardingButtonStyle(tint: page.secondaryButtonColor,
                                                           prominence: .secondary))
                    }

                    if let primaryTitle = page.primaryButtonTitle {
                        Button(action: { handlePrimaryAction(for: page) }) {
                            Text(primaryTitle)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(OnboardingButtonStyle(tint: page.primaryButtonColor,
                                                           prominence: .primary))
                    }
                }
            }
            .padding(.horizontal, bottomBarHorizontalPadding)
            .padding(.top, 18)
            .padding(.bottom, bottomBarBottomPadding)
            .frame(maxWidth: .infinity)
            .background(
                Rectangle()
                    .fill(bottomBarMaterial)
            )
            .overlay(
                Rectangle()
                    .fill(bottomBarSeparatorColor)
                    .frame(height: 1),
                alignment: .top
            )
            .ignoresSafeArea(edges: .bottom)
        }
    }

    private func handlePrimaryAction(for page: OnboardingPageView.Model) {
        switch page.id {
        case 0, 1:
            goToNextPage(from: page.id)
        case 2:
            completeOnboarding()
        default:
            break
        }
    }

    private func handleSecondaryAction(for page: OnboardingPageView.Model) {
        switch page.id {
        case 1:
            #if os(iOS)
            openSafariSettings()
            #elseif os(macOS)
            openGuide()
            #endif
        default:
            break
        }
    }
    
    #if os(macOS)
    private func openGuide() {
        NSWorkspace.shared.open(URL(string: "https://docs.tosdr.org/documentation/getting-started/safari-macos")!)
    }
    #endif

    private func goToNextPage(from index: Int) {
        guard selectedPage == index else { return }
        withAnimation(.easeInOut(duration: 0.25)) {
            selectedPage = min(selectedPage + 1, pages.count - 1)
        }
    }

    #if os(iOS)
    private func openSafariSettings() {
        guard let url = URL(string: "App-Prefs:Safari&path=WEB_EXTENSIONS") else { return }
        openURL(url)
    }
    #endif

    private func completeOnboarding() {
        defaults.setValue(false, forKey: "firstStart")
        withAnimation(.easeInOut(duration: 0.25)) {
            done = true
        }
    }
}

struct OnboardingPageView: View {
    struct Model: Identifiable {
        enum Illustration {
            case asset(String)
            case system(String)
        }

        let id: Int
        let illustration: Illustration
        let title: String
        let description: String
        let notice: String?
        let accentColor: Color
        let primaryButtonTitle: String?
        let primaryButtonColor: Color
        let secondaryButtonTitle: String?
        let secondaryButtonColor: Color
    }

    let model: Model
    var primaryAction: () -> Void = {}
    var secondaryAction: () -> Void = {}
    var showsActions: Bool = true

    var body: some View {
        VStack(spacing: 32) {
            #if !os(macOS)
            Spacer(minLength: 0)
            #endif

            VStack(spacing: 24) {
                illustration

                VStack(spacing: 12) {
                    Text(model.title)
                        .font(.system(.largeTitle, design: .rounded, weight: .semibold))
                        .multilineTextAlignment(.center)

                    Text(model.description)
                        .font(.system(.body, design: .rounded))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: textMaxWidth)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if let notice = model.notice {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundColor(model.accentColor)
                            .font(.system(size: 20, weight: .semibold))

                        Text(notice)
                            .font(.subheadline)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(model.accentColor.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
            }

            Spacer(minLength: 0)

            if showsActions {
                VStack(spacing: 12) {
                    if let secondaryTitle = model.secondaryButtonTitle {
                        Button(action: secondaryAction) {
                            Text(secondaryTitle)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(OnboardingButtonStyle(tint: model.secondaryButtonColor,
                                                           prominence: .secondary))
                    }

                    if let primaryTitle = model.primaryButtonTitle {
                        Button(action: primaryAction) {
                            Text(primaryTitle)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(OnboardingButtonStyle(tint: model.primaryButtonColor,
                                                           prominence: .primary))
                    }
                }
            }
        }
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, 24)
        .frame(maxWidth: contentMaxWidth)
        .frame(maxWidth: .infinity)
        #if !os(macOS)
        .frame(maxHeight: .infinity)
        #endif
    }

    @ViewBuilder
    private var illustration: some View {
        switch model.illustration {
        case .system(let name):
            ZStack {
                Circle()
                    .fill(model.accentColor.opacity(0.15))
                    .frame(width: 140, height: 140)

                Image(systemName: name)
                    .symbolRenderingMode(.multicolor)
                    .font(.system(size: 48, weight: .semibold, design: .rounded))
                    .foregroundStyle(model.accentColor)
            }
        case .asset(let name):
            ZStack {
                RoundedRectangle(cornerRadius: 34, style: .continuous)
                    .fill(model.accentColor.opacity(0.12))
                    .frame(width: 220, height: 220)

                Image(name)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    .shadow(color: Color.black.opacity(0.06), radius: 20, y: 10)
            }
        }
    }

    private var horizontalPadding: CGFloat {
        #if os(macOS)
        return 24
        #else
        return 32
        #endif
    }

    private var contentMaxWidth: CGFloat? {
        #if os(macOS)
        return 620
        #else
        return 540
        #endif
    }

    private var textMaxWidth: CGFloat? {
        #if os(macOS)
        return nil
        #else
        return 420
        #endif
    }
}

private struct OnboardingButtonStyle: ButtonStyle {
    enum Prominence {
        case primary
        case secondary
    }

    var tint: Color
    var prominence: Prominence

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.headline, design: .rounded))
            .padding(.vertical, 14)
            .padding(.horizontal, 6)
            .foregroundColor(foregroundColor)
            .background(backgroundColor(for: configuration))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(borderColor, lineWidth: prominence == .secondary ? 1 : 0)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }

    private var foregroundColor: Color {
        switch prominence {
        case .primary:
            return .white
        case .secondary:
            return tint
        }
    }

    private var borderColor: Color {
        tint.opacity(prominence == .secondary ? 0.35 : 0)
    }

    private func backgroundColor(for configuration: Configuration) -> Color {
        let base: Color
        switch prominence {
        case .primary:
            base = tint
        case .secondary:
            base = tint.opacity(0.12)
        }
        return base.opacity(configuration.isPressed ? 0.85 : 1)
    }
}

private struct PageIndicator: View {
    let count: Int
    @Binding var selection: Int
    var tint: Color

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<count, id: \.self) { index in
                Capsule()
                    .fill(index == selection ? tint : Color.secondary.opacity(0.25))
                    .frame(width: index == selection ? 22 : 8, height: 6)
                    .animation(.easeInOut(duration: 0.25), value: selection)
            }
        }
    }
}

#Preview {
    OnboardingView()
}

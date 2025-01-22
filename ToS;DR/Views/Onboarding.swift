import SwiftUI

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
            TabView(selection: $selectedPage) {
                OnboardingPageView(
                    imageName: "DarkIcon-Preview",
                    title: String(localized: "onboarding_welcome_title"),
                    description: String(localized: "onboarding_welcome_desc"),
                    systemImage: false,
                    buttonText: String(localized: "onboarding_button_next"),
                    buttonAction: {
                        if (selectedPage == 0) {
                            withAnimation { selectedPage += 1 }
                        }
                    }
                ).tag(0)
                
                OnboardingPageView(
                    imageName: "safari",
                    title: String(localized: "onboarding_safari_title"),
                    description: String(localized: "onboarding_safari_desc"),
                    systemImage: true,
                    buttonText: String(localized: "onboarding_button_next"),
                    buttonAction: {
                        if (selectedPage == 1) {
                            withAnimation { selectedPage += 1 }
                        }
                    },
                    secondButtonText: String(localized: "onboarding_button_enable"),
                    secondButtonAction: {
                        openURL(URL(string: "App-Prefs:Safari&path=WEB_EXTENSIONS")!)
                    },
                    notice: String(localized: "onboarding_safari_notice")
                ).tag(1)
                
                OnboardingPageView(
                    imageName: "party.popper",
                    title: String(localized: "onboarding_final_title"),
                    description: String(localized: "onboarding_final_desc"),
                    systemImage: true,
                    buttonText: String(localized: "onboarding_button_start"),
                    buttonAction: {
                        defaults.setValue(false, forKey: "firstStart")
                        done = true
                    },
                    buttonColor: Color.purple
                ).tag(2)
            }
            #if os(iOS)
            .tabViewStyle(.page(indexDisplayMode: .never))
            #endif
        }
    }
}

struct OnboardingPageView: View {
    var imageName: String
    var title: String
    var description: String
    var systemImage: Bool = false
    
    var buttonText: String?
    var buttonAction: () -> Void = {}
    
    var buttonColor: Color = Color.blue
    
    var secondButtonText: String?
    var secondButtonAction: () -> Void = {}
    
    var secondButtonColor: Color = Color.teal
    
    var notice: String? = nil

    var body: some View {
        VStack {
            if systemImage {
                Image(systemName: imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
                    .padding()
            } else {
                Image("AppIcon-Preview")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .clipShape(RoundedRectangle(cornerSize: CGSize(width: 50, height: 50)))
                    .padding([.leading, .trailing], 5)
                    
            }

            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 10)

            Text(description)
                .multilineTextAlignment(.center)
                .padding()
            
            if notice != nil {
                Label(notice!, systemImage: "exclamationmark.circle")
                    .multilineTextAlignment(.center)
                    .padding()
            }
            
            Spacer()
            if secondButtonText != nil {
                Button(action: {
                    secondButtonAction()
                }) {
                    Text(secondButtonText!)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(secondButtonColor)
                        .cornerRadius(10)
                }
            }
            if buttonText != nil {
                Button(action: {
                    buttonAction()
                }) {
                    Text(buttonText!)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(buttonColor)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
    }
}

#Preview {
    OnboardingView()
}

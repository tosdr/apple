//
//  AppIconSet.swift
//  ToS;DR
//
//  Created by Erik on 06.11.23.
//

#if os(iOS)
import SwiftUI
import FluidGradient
struct AppIcon: Hashable {
    let icon: String
    let title: String
    var colors: [Color] = [.blue, .purple]
    var description: String?
}

struct AppIconSetting: View {
    @State private var selectedIcon: Int = 0
    @State private var appliedIcon: Int = 0
    @State private var hapticEnabled = false
    @State private var appIcons: [AppIcon] = [
        AppIcon(icon: "AppIcon", title: String(localized: "appicon_regular_title"), colors: [.green, .white, .yellow, .red, .gray], description: String(localized: "appicon_regular_desc")),
        AppIcon(icon: "DarkIcon", title: String(localized: "appicon_dark_title"), colors: [.green, .black, .yellow, .red, .gray], description: String(localized: "appicon_dark_desc")),
        AppIcon(icon: "GradientIcon", title: String(localized: "appicon_gradient_title"), colors: [.blue, .purple, .indigo], description: String(localized: "appicon_gradient_desc"))
    ]
    
    private let generator = UIImpactFeedbackGenerator(style: .medium)
    private let iconSize = 152.0
    
    private func getSpecialIcons() {
        if isMonth(month: 12) {
            appIcons.append(AppIcon(icon: "ChristmasIcon", title: String(localized: "appicon_christmas_title"), colors: [.red, .green], description: String(localized: "appicon_christmas_desc")))
        }
        if UserDefaults.standard.bool(forKey: "isBetaTester") {
            appIcons.append(AppIcon(icon: "DevIcon", title: String(localized: "appicon_beta_title"), colors: [.blue, .white], description: String(localized: "appicon_beta_desc")))
        }
    }
    
    var body: some View {
        ZStack {
            FluidGradient(blobs: appIcons[selectedIcon].colors,
                         highlights: [appIcons[selectedIcon].colors.randomElement()!],
                         speed: 1.0,
                         blur: 0.75)
            .ignoresSafeArea()
            
            VStack {
                TabView(selection: $selectedIcon) {
                    ForEach(appIcons.indices, id: \.self) { index in
                        Image(appIcons[index].icon + "-Preview")
                            .resizable()
                            .scaledToFit()
                            .frame(width: iconSize, height: iconSize)
                            .clipShape(RoundedRectangle(cornerSize: CGSize(width: iconSize / 6, height: iconSize / 6)))
                            .padding([.leading, .trailing], 5)
                            .shadow(radius: 10)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .automatic))
                .onChange(of: selectedIcon, initial: false) { _, _ in
                    if hapticEnabled {
                        generator.prepare()
                        generator.impactOccurred()
                    }
                }
                
                VStack {
                    Text(appIcons[selectedIcon].title)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                    if let description = appIcons[selectedIcon].description {
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding([.leading, .trailing], 5)
                    }
                    Button {
                        changeAppIcon(to: appIcons[selectedIcon].icon)
                    } label: {
                        Text(selectedIcon == appliedIcon ? String(localized: "appicon_applied") : String(localized: "appicon_apply"))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedIcon == appliedIcon ? Color.secondary : Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                    }
                    .disabled(selectedIcon == appliedIcon)
                    .padding()
                    .safeAreaPadding(.bottom)
                }
                .background(.ultraThinMaterial)
                .roundedCorner(20, corners: [.topLeft, .topRight])
            }
        }
        .navigationTitle(String(localized: "appicon_title"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .ignoresSafeArea(edges: .bottom)
        .onAppear {
            getSpecialIcons()
            changeCurrent()
            changeApplied()
            hapticEnabled = true
        }
    }
    
    private func changeAppIcon(to iconName: String) {
        if (iconName == "AppIcon") {
            UIApplication.shared.setAlternateIconName(nil) { error in
                if let error = error {
                    print("Error resetting app icon \(error.localizedDescription)")
                }
            }
            return
        }
        UIApplication.shared.setAlternateIconName(iconName) { error in
            if let error = error {
                print("Error setting alternate icon \(error.localizedDescription)")
            }
        }
    }
    
    private func isMonth(month: Int) -> Bool {
        let date = Date()
        let calendar = Calendar.current
        let monthCheck = calendar.component(.month, from: date)
        return monthCheck == month
    }
    
    func changeCurrent() {
        let icon = currentAppIcon()
        
        if let index = appIcons.firstIndex(where: { $0.icon == icon }) {
            selectedIcon = index
        }
    }
    
    func changeApplied() {
        let icon = currentAppIcon()
        if let index = appIcons.firstIndex(where: { $0.icon == icon }) {
            appliedIcon = index
        }
    }
    
    func currentAppIcon() -> String {
        if let iconName = UIApplication.shared.alternateIconName {
            return iconName
        } else {
            return "AppIcon"
        }
    }
}

extension View {
    func roundedCorner(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
#endif

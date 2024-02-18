//
//  AppIconSet.swift
//  ToS;DR
//
//  Created by Erik on 06.11.23.
//

import SwiftUI
#if os(iOS)
struct AppIcon: Hashable {
    let icon: String
    let title: String
    let description: String?
}

struct AppIconSetting: View {
    
    private func appIconButton(iconName: String, title: String, description: String? = nil) -> some View {
        Button {
            changeAppIcon(to: iconName)
            } label: {
                HStack {
                    Image(iconName + "-Preview")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 8.7, height: 8.7)))
                        .padding([.leading, .trailing], 5)
                    VStack(alignment: .leading) {
                        Text(title)
                        if (description != nil) {
                            Text(description!)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .foregroundStyle(.primary)
            .padding(5)
            .listRowInsets(EdgeInsets())
    }
    
    private func getSpecialIcons() -> [AppIcon] {
        var specialIcons: [AppIcon] = []
        if (isMonth(month: 12)) {
            specialIcons.append(AppIcon(icon: "ChristmasIcon", title: "Christmas App Icon", description: nil))
        }
        if (UserDefaults.standard.bool(forKey: "isBetaTester")) {
            specialIcons.append(AppIcon(icon: "DevIcon", title: "Beta Testing Icon", description: "Thank you for testing the App!"))
        }
        return specialIcons
    }
    
    private func isMonth(month: Int) -> Bool {
        let date = Date()
        let calendar = Calendar.current
        let monthCheck = calendar.component(.month, from: date)
        return monthCheck == month
    }
    
    @State private var isRegularIcon: Bool = true
        
    var body: some View {
        List {
            Section("Default App Icons") {
                appIconButton(iconName: "AppIcon", title: "Regular App Icon")
                appIconButton(iconName: "DarkIcon", title: "Dark App Icon")
                appIconButton(iconName: "GradientIcon", title: "Gradient App Icon")

            }
            Section("Limited Edition App Icons") {
                ForEach(getSpecialIcons(), id: \.self) { icon in
                    appIconButton(iconName: icon.icon, title: icon.title, description: icon.description)
                }
                if (getSpecialIcons().isEmpty) {
                    Text("No special App Icons currently available!")
                }
            }
        }
        .navigationTitle("Change App Icon")
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
}
#endif

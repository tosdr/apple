//
//  ThanksView.swift
//  ToS;DR
//
//  Created by Erik on 31.12.23.
//

import SwiftUI

struct ThanksView: View {
    @Environment(\.openURL) var openURL

    var body: some View {
        List {
            Label(String(localized: "thanks_header"), systemImage: "heart.fill").font(.title3)
            Text(String(localized: "thanks_desc"))
            
            Section(String(localized: "thanks_section_team")) {
                Text(String(localized: "thanks_team_desc"))
            }
            
            Section(String(localized: "thanks_section_libraries")) {
                fossButton(url: "https://github.com/lorenzofiamingo/swiftui-cached-async-image", name: "swiftui-cached-async-image")
                fossButton(url: "https://github.com/Cindori/FluidGradient", name: "FluidGradient")
            }
            
            Text(String(localized: "thanks_and_you"))
        }.navigationTitle(String(localized: "thanks_title"))
    }
    
    func fossButton(url: String, name: String) -> some View {
        Button {
            openURL(URL(string: url)!)
        } label: {
            HStack {
                Text(name)
                Spacer()
                Image(systemName: "globe")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    ThanksView()
}

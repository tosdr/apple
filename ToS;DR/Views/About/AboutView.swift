//
//  AboutView.swift
//  ToS;DR
//
//  Created by Erik on 01.11.23.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.openURL) var openURL

    var body: some View {
        List {
            Section(String(localized: "about_section_welcome")) {
                Label(String(localized: "about_welcome"), systemImage: "party.popper.fill").font(.title2)
                Text(String(localized: "about_welcome_desc"))
            }
            Section(String(localized: "about_section_organization")) {
                Text(String(localized: "about_organization_desc1"))
                Text(String(localized: "about_organization_desc2"))
            }
            
            Section(String(localized: "about_section_terminology")) {
                NavigationLink(destination: GradesExplained()) {
                    Label(String(localized: "about_terminology_grades"), systemImage: "graduationcap")
                }
                NavigationLink(destination: PointsExplained()) {
                    Label(String(localized: "about_terminology_points"), systemImage: "text.quote")
                }
                NavigationLink(destination: ServicesExplained()) {
                    Label(String(localized: "about_terminology_services"), systemImage: "server.rack")
                }
            }
            Section(String(localized: "about_section_contribute")) {
                Button {
                    openURL(URL(string: "https://edit.tosdr.org")!)
                } label: {
                    Label(String(localized: "about_contribute_curate"), systemImage: "text.magnifyingglass")
                }
                #if os(macOS)
                .buttonStyle(.plain)
                #endif
            }
            Section(String(localized: "about_section_app")) {
                NavigationLink(destination: ThanksView()) {
                    Label(String(localized: "about_app_thanks"), systemImage: "heart.fill")
                }
            }
            
        }.navigationTitle(String(localized: "label_about"))
    }
}

#Preview {
    AboutView()
}

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
            Section("Welcome!") {
                Label("Welcome to ToS;DR!", systemImage: "party.popper.fill").font(.title2)
                Text("This will guide you through everything there is to know about ToS;DR! Feel free to click anything below to learn more!")
            }
            Section("Organisation") {
                Text("“Terms of Service; Didn't Read” (short: ToS;DR) is a young project started in June 2012 to help fix the “biggest lie on the web”: almost no one really reads the terms of service we agree to all the time. We aim at rating popular web services Terms of Service and Privacy Policies by summarizing them in “convenient” grades from A to E with so called “Points”.")
                Text("ToS;DR is a non-profit organization, and all of our team members and contributors do their work as volunteers, with payment being rare. We rely on donations to keep our infrastructure and operations up, and our finances are laid out through our website and collective websites.")
            }
            
            Section("Terminology") {
                NavigationLink(destination: GradesExplained()) {
                    Label("Grades", systemImage: "graduationcap")
                }
                NavigationLink(destination: PointsExplained()) {
                    Label("Points", systemImage: "text.quote")
                }
                NavigationLink(destination: ServicesExplained()) {
                    Label("Services", systemImage: "server.rack")
                }
            }
            Section("Contribute") {
                Button {
                    openURL(URL(string: "https://edit.tosdr.org")!)
                } label: {
                    Label("Curate Terms of Service", systemImage: "text.magnifyingglass")
                }
                #if os(macOS)
                .buttonStyle(.plain)
                #endif
            }
            Section("This App") {
                NavigationLink(destination: ThanksView()) {
                    Label("Thanks", systemImage: "heart.fill")
                }
            }
            
        }.navigationTitle("About")
    }
}

#Preview {
    AboutView()
}

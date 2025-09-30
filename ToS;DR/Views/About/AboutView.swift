//
//  AboutView.swift
//  ToS;DR
//
//  Created by Erik on 01.11.23.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        GroupedList {
            GroupedListSection {
                Text(String(localized: "about_section_welcome"))
            } content: {
                GroupedListItem(
                    icon: { Image(systemName: "party.popper.fill") },
                    content: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(String(localized: "about_welcome"))
                                .font(.title3)
                            Text(String(localized: "about_welcome_desc"))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    },
                    isFirst: true,
                    isLast: true
                )
            }

            GroupedListSection {
                Text(String(localized: "about_section_organization"))
            } content: {
                GroupedListItem(
                    content: {
                        Text(String(localized: "about_organization_desc1"))
                    },
                    isFirst: true
                )
                GroupedListItem(
                    content: {
                        Text(String(localized: "about_organization_desc2"))
                    },
                    isLast: true
                )
            }

            GroupedListSection {
                Text(String(localized: "about_section_terminology"))
            } content: {
                GroupedListNavigationLink(
                    icon: { Image(systemName: "graduationcap") },
                    content: { Text(String(localized: "about_terminology_grades")) },
                    destination: { GradesExplained() },
                    isFirst: true
                )
                GroupedListNavigationLink(
                    icon: { Image(systemName: "text.quote") },
                    content: { Text(String(localized: "about_terminology_points")) },
                    destination: { PointsExplained() }
                )
                GroupedListNavigationLink(
                    icon: { Image(systemName: "server.rack") },
                    content: { Text(String(localized: "about_terminology_services")) },
                    destination: { ServicesExplained() },
                    isLast: true
                )
            }

            GroupedListSection {
                Text(String(localized: "about_section_contribute"))
            } content: {
                GroupedListButton(
                    icon: { Image(systemName: "text.magnifyingglass") },
                    content: { Text(String(localized: "about_contribute_curate")) },
                    action: {
                        if let url = URL(string: "https://edit.tosdr.org") {
                            openURL(url)
                        }
                    },
                    isFirst: true,
                    isLast: true
                )
            }

            GroupedListSection {
                Text(String(localized: "about_section_app"))
            } content: {
                GroupedListNavigationLink(
                    icon: { Image(systemName: "heart.fill") },
                    content: { Text(String(localized: "about_app_thanks")) },
                    destination: { ThanksView() },
                    isFirst: true,
                    isLast: true
                )
            }
        }
        .navigationTitle(String(localized: "label_about"))
    }
}

#Preview {
    AboutView()
}

//
//  ThanksView.swift
//  ToS;DR
//
//  Created by Erik on 31.12.23.
//

import SwiftUI

struct ThanksView: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        GroupedList {
            GroupedListSection {
                Text(String(localized: "thanks_title"))
            } content: {
                GroupedListItem(
                    icon: { Image(systemName: "heart.fill") },
                    content: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(String(localized: "thanks_header"))
                                .font(.title3)
                            Text(String(localized: "thanks_desc"))
                                .font(.subheadline)
                        }
                    },
                    isFirst: true,
                    isLast: true
                )
            }

            GroupedListSection {
                Text(String(localized: "thanks_section_team"))
            } content: {
                GroupedListItem(
                    content: {
                        Text(String(localized: "thanks_team_desc"))
                    },
                    isFirst: true,
                    isLast: true
                )
            }

            GroupedListSection {
                Text(String(localized: "thanks_section_libraries"))
            } content: {
                GroupedListButton(
                    content: { fossLabel(name: "swiftui-cached-async-image") },
                    action: { openLibrary(url: "https://github.com/lorenzofiamingo/swiftui-cached-async-image") },
                    isFirst: true
                )
                GroupedListButton(
                    content: { fossLabel(name: "FluidGradient") },
                    action: { openLibrary(url: "https://github.com/Cindori/FluidGradient") },
                    isLast: true
                )
            }

            GroupedListSection {
                EmptyView()
            } content: {
                GroupedListItem(
                    content: {
                        Text(String(localized: "thanks_and_you"))
                    },
                    isFirst: true,
                    isLast: true
                )
            }
        }
        .navigationTitle(String(localized: "thanks_title"))
    }

    private func fossLabel(name: String) -> some View {
        HStack {
            Text(name)
            Spacer()
            Image(systemName: "globe")
                .foregroundStyle(.secondary)
        }
    }

    private func openLibrary(url: String) {
        if let link = URL(string: url) {
            openURL(link)
        }
    }
}

#Preview {
    ThanksView()
}

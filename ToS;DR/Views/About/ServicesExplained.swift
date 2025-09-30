//
//  ServicesExplained.swift
//  ToS;DR
//
//  Created by Erik on 06.11.23.
//

import SwiftUI

struct ServicesExplained: View {
    var body: some View {
        GroupedList {
            GroupedListSection {
                Text(String(localized: "services_section_badges"))
            } content: {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Label(String(localized: "services_review_status"), systemImage: "checkmark.seal")
                            .font(.title2)
                        Text(String(localized: "services_review_status_desc"))
                            .font(.caption)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, innerPadding)
                .padding(.vertical, innerPadding)
                .background(Color.green)
                .foregroundColor(.white)
                .overlay(
                    Rectangle()
                        .frame(height: 0.5)
                        .foregroundColor(Color.platformSeparator)
                        .opacity(1),
                    alignment: .bottom
                )
            }

            GroupedListSection {
                Text(String(localized: "services_section_contents"))
            } content: {
                GroupedListItem(
                    content: {
                        Text(String(localized: "services_contents_desc"))
                    },
                    isFirst: true,
                    isLast: true
                )
            }
        }
        .navigationTitle(String(localized: "services_title"))
    }
}

#Preview {
    ServicesExplained()
}

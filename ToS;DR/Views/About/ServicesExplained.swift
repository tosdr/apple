//
//  ServicesExplained.swift
//  ToS;DR
//
//  Created by Erik on 06.11.23.
//

import SwiftUI

struct ServicesExplained: View {
    var body: some View {
        List {
            Section(String(localized: "services_section_badges")) {
                HStack() {
                    VStack(alignment: .leading) {
                        Label(String(localized: "services_review_status"), systemImage: "checkmark.seal").font(.title2)
                        Text(String(localized: "services_review_status_desc")).font(.caption)
                    }
                }
                .contentShape(Rectangle())
                .listRowBackground(Color.green)
                .foregroundStyle(Color.white)
            }
            Section(String(localized: "services_section_contents")) {
                Text(String(localized: "services_contents_desc"))
            }
        }.navigationTitle(String(localized: "services_title"))
    }
}

#Preview {
    ServicesExplained()
}

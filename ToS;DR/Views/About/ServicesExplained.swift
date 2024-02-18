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
            Section("Service Badges") {
                HStack() {
                    VStack(alignment: .leading) {
                        Label("Review Status", systemImage: "checkmark.seal").font(.title2)
                        Text("In ToS;DR clasically reffered to as 'Comprehensively Reviewed', meaning this service has enough curated points to be deemed accurate enough for an everyday rating.").font(.caption)
                    }
                }
                .contentShape(Rectangle())
                .listRowBackground(Color.green)
                    .foregroundStyle(Color.white)
            }
            Section("Service Contents") {
                Text("Each Service includes Points that determine a final Grade, Links to all policies that are relevant to ToS;DR and other useful information.")
            }
        }.navigationTitle("Services")
    }
}

#Preview {
    ServicesExplained()
}

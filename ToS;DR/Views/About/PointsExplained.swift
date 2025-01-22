//
//  PointsExplained.swift
//  ToS;DR
//
//  Created by Erik on 06.11.23.
//

import SwiftUI

struct PointsExplained: View {
    var body: some View {
        List {
            Section(String(localized: "points_section_classifications")) {
                HStack() {
                    VStack(alignment: .leading) {
                        Label(String(localized: "points_blocker"), systemImage: "hand.raised.fill").font(.title2)
                        Text(String(localized: "points_blocker_desc")).font(.caption)
                    }
                }
                .contentShape(Rectangle())
                .listRowBackground(Color.red)
                .foregroundStyle(Color.white)
                
                HStack() {
                    VStack(alignment: .leading) {
                        Label(String(localized: "points_bad"), systemImage: "exclamationmark.triangle.fill").font(.title2)
                        Text(String(localized: "points_bad_desc")).font(.caption)
                    }
                }
                .contentShape(Rectangle())
                .listRowBackground(Color.orange)
                .foregroundStyle(Color.white)
                
                HStack() {
                    VStack(alignment: .leading) {
                        Label(String(localized: "points_good"), systemImage: "hand.thumbsup").font(.title2)
                        Text(String(localized: "points_good_desc")).font(.caption)
                    }
                }
                .contentShape(Rectangle())
                .listRowBackground(Color.green)
                .foregroundStyle(Color.white)
                
                HStack() {
                    VStack(alignment: .leading) {
                        Label(String(localized: "points_neutral"), systemImage: "hand.point.up").font(.title2)
                        Text(String(localized: "points_neutral_desc")).font(.caption)
                    }
                }
                .contentShape(Rectangle())
                .listRowBackground(Color.gray)
                .foregroundStyle(Color.white)
            }
            
            Section(String(localized: "points_section_calculation")) {
                Text(String(localized: "points_calculation_intro")).font(.caption)
                Text(String(localized: "points_calculation_a")).font(.caption)
                Text(String(localized: "points_calculation_b")).font(.caption)
                Text(String(localized: "points_calculation_c")).font(.caption)
                Text(String(localized: "points_calculation_d")).font(.caption)
                Text(String(localized: "points_calculation_e")).font(.caption)
            }
        }.navigationTitle(String(localized: "points_title"))
    }
}

#Preview {
    PointsExplained()
}

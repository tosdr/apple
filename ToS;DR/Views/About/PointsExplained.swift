//
//  PointsExplained.swift
//  ToS;DR
//
//  Created by Erik on 06.11.23.
//

import SwiftUI

struct PointsExplained: View {
    var body: some View {
        GroupedList {
            GroupedListSection {
                Text(String(localized: "points_section_classifications"))
            } content: {
                PointClassificationCard(
                    title: String(localized: "points_blocker"),
                    description: String(localized: "points_blocker_desc"),
                    icon: "hand.raised.fill",
                    color: .red,
                    isFirst: true
                )
                PointClassificationCard(
                    title: String(localized: "points_bad"),
                    description: String(localized: "points_bad_desc"),
                    icon: "exclamationmark.triangle.fill",
                    color: .orange
                )
                PointClassificationCard(
                    title: String(localized: "points_good"),
                    description: String(localized: "points_good_desc"),
                    icon: "hand.thumbsup",
                    color: .green
                )
                PointClassificationCard(
                    title: String(localized: "points_neutral"),
                    description: String(localized: "points_neutral_desc"),
                    icon: "hand.point.up",
                    color: .gray,
                    isLast: true
                )
            }

            GroupedListSection {
                Text(String(localized: "points_section_calculation"))
            } content: {
                GroupedListItem(
                    content: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(String(localized: "points_calculation_intro"))
                            Text(String(localized: "points_calculation_a"))
                            Text(String(localized: "points_calculation_b"))
                            Text(String(localized: "points_calculation_c"))
                            Text(String(localized: "points_calculation_d"))
                            Text(String(localized: "points_calculation_e"))
                        }
                        .font(.caption)
                    },
                    isFirst: true,
                    isLast: true
                )
            }
        }
        .navigationTitle(String(localized: "points_title"))
    }
}

private struct PointClassificationCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    var isFirst: Bool = false
    var isLast: Bool = false

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
            }
            .foregroundColor(.white)
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, innerPadding)
        .padding(.vertical, innerPadding)
        .background(color)
        .foregroundColor(.white)
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color.platformSeparator)
                .opacity(isLast ? 0 : 1),
            alignment: .bottom
        )
    }
}

#Preview {
    PointsExplained()
}

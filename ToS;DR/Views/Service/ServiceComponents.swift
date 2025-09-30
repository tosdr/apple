//
//  ServiceComponents.swift
//  ToS;DR
//
//  Created by Erik on 07.11.23.
//

import SwiftUI

struct ServicePointsList: View {
    let serviceInfo: ToSDR
    @Binding var showLocalizedTitles: Bool

    var body: some View {
        GroupedListSection {
            Text(String(format: String(localized: "points_section_for"), serviceInfo.name))
        } content: {
            GroupedListItem(
                content: {
                    Text(String(format: String(localized: "service_badge_points"), String(serviceInfo.points.totalCount())))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                },
                isFirst: true,
                isLast: true
            )
        }

        ForEach(pointSections) { section in
            GroupedListSection {
                Text(section.title)
            } content: {
                ForEach(Array(section.points.enumerated()), id: \.offset) { index, point in
                    GroupedListNavigationLink(
                        content: {
                            HStack(spacing: 12) {
                                Image(systemName: section.iconName)
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(section.color)
                                Text(displayTitle(for: point))
#if os(macOS)
                                    .font(.title2)
#endif
                            }
                        },
                        destination: {
                            PointView(point: point)
                        },
                        isFirst: index == 0,
                        isLast: index == section.points.count - 1
                    )
                }
            }
        }
    }

    private func displayTitle(for point: Point) -> String {
        if showLocalizedTitles, let localized = point.localizedTitle {
            return localized
        }
        return point.title
    }

    private var pointSections: [PointSection] {
        [
            makeSection(
                key: "blocker",
                title: String(localized: "points_type_blocker"),
                icon: "hand.raised.fill",
                color: .red
            ),
            makeSection(
                key: "bad",
                title: String(localized: "points_type_bad"),
                icon: "exclamationmark.triangle.fill",
                color: .orange
            ),
            makeSection(
                key: "good",
                title: String(localized: "points_type_good"),
                icon: "hand.thumbsup",
                color: .green
            ),
            makeSection(
                key: "neutral",
                title: String(localized: "points_type_neutral"),
                icon: "hand.point.up",
                color: .gray
            )
        ].compactMap { $0 }
    }

    private func makeSection(key: String, title: String, icon: String, color: Color) -> PointSection? {
        guard let points = serviceInfo.points[key], !points.isEmpty else { return nil }
        return PointSection(title: title, iconName: icon, color: color, points: points)
    }

    private struct PointSection: Identifiable {
        var id: String { title }
        let title: String
        let iconName: String
        let color: Color
        let points: [Point]
    }
}

extension Dictionary where Value: Collection, Value.Element == Point {
    func totalCount() -> Int {
        values.reduce(into: 0) { $0 += $1.count }
    }
}

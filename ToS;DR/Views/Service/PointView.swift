//
//  PointView.swift
//  ToS;DR
//
//  Created by Erik on 06.11.23.
//

import SwiftUI

struct PointView: View {
    @Environment(\.openURL) private var openURL

    private let pointSelected: Point

    init(point: Point) {
        self.pointSelected = point
    }

    private var pointTypeView: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName(for: pointSelected.type))
                .foregroundColor(color(for: pointSelected.type))
            Text(pointSelected.title)
                .font(.headline)
        }
    }

    var body: some View {
        GroupedList {
            GroupedListSection {
                Text(String(localized: "point_section_details"))
            } content: {
                GroupedListItem(
                    content: {
                        pointTypeView
                    },
                    isFirst: true,
                    isLast: pointSelected.description.isEmpty && pointSelected.quote.isEmpty && pointSelected.tlDr.isEmpty
                )
            }

            if !pointSelected.description.isEmpty {
                GroupedListSection {
                    Text(String(localized: "point_section_description"))
                } content: {
                    GroupedListItem(
                        content: {
                            Text(pointSelected.description)
                                .contextMenu {
                                    Button {
#if os(iOS)
                                        UIPasteboard.general.string = pointSelected.description
#else
                                        NSPasteboard.general.clearContents()
                                        NSPasteboard.general.setString(pointSelected.description, forType: .string)
#endif
                                    } label: {
                                        Label(String(localized: "point_copy_to_clipboard"), systemImage: "doc.on.doc")
                                    }
                                }
                                .textSelection(.enabled)
                        },
                        isFirst: true,
                        isLast: true
                    )
                }
            }

            if !pointSelected.quote.isEmpty {
                GroupedListSection {
                    Text(String(localized: "point_section_quote"))
                } content: {
                    GroupedListButton(
                        content: {
                            Text(pointSelected.quote)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                        },
                        action: {
                            if pointSelected.quote.starts(with: "https://"), let url = URL(string: pointSelected.quote) {
                                openURL(url)
                            }
                        },
                        isFirst: true,
                        isLast: true
                    )
                }
            }

            if !pointSelected.tlDr.isEmpty && pointSelected.tlDr != "Generated through the annotate view" {
                GroupedListSection {
                    Text(String(localized: "point_section_tldr"))
                } content: {
                    GroupedListItem(
                        content: {
                            Text(pointSelected.tlDr)
                                .textSelection(.enabled)
                        },
                        isFirst: true,
                        isLast: true
                    )
                }
            }

            GroupedListSection {
                EmptyView()
            } content: {
                GroupedListButton(
                    icon: { Image(systemName: "globe") },
                    content: {
                        Text(String(localized: "point_open_on_tosdr"))
                    },
                    action: {
                        if let url = URL(string: "https://edit.tosdr.org/points/\(pointSelected.links)") {
                            openURL(url)
                        }
                    },
                    isFirst: true,
                    isLast: true
                )
            }
        }
        .navigationTitle(String(localized: "point_viewing_details"))
    }

    private func color(for type: String) -> Color {
        switch type {
        case "blocker": return .red
        case "bad": return .orange
        case "good": return .green
        case "neutral": return .yellow
        default: return .gray
        }
    }

    private func iconName(for type: String) -> String {
        switch type {
        case "blocker": return "hand.raised.fill"
        case "bad": return "exclamationmark.triangle.fill"
        case "good": return "hand.thumbsup"
        case "neutral": return "hand.point.up"
        default: return "questionmark"
        }
    }
}

#Preview {
    PointView(point: Point(localizedTitle: nil, title: "Test Point", tlDr: "Test TL;DR", description: "Test Description", quote: "https://example.com", type: "blocker", links: "1"))
}

//
//  ServiceView.swift
//  ToS;DR
//
//  Created by Erik on 01.11.23.
//

import SwiftUI
import CachedAsyncImage

struct ServiceView: View {
    @Environment(\.openURL) private var openURL
    @StateObject private var viewModel: ServiceViewModel

    init(searchResult: SearchResult?) {
        _viewModel = StateObject(wrappedValue: ServiceViewModel(searchResult: searchResult))
    }

    var body: some View {
        Group {
            if !viewModel.hasSelection {
                Text(String(localized: "service_no_selection"))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.isLoading && viewModel.serviceInfo == nil {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let errorMessage = viewModel.errorMessage, viewModel.serviceInfo == nil {
                ServiceErrorView(message: errorMessage) {
                    await viewModel.refresh()
                }
            } else if let serviceInfo = viewModel.serviceInfo {
                ServiceDetailView(
                    serviceInfo: serviceInfo,
                    showLocalizedTitles: $viewModel.showLocalizedTitles,
                    hasLocalizedTitles: viewModel.hasLocalizedTitles,
                    refreshAction: {
                        await viewModel.refresh()
                    }
                )
                .navigationTitle(serviceInfo.name)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task(id: viewModel.selectedResult?.id) {
            await viewModel.loadService()
        }
        .navigationTitle(viewModel.selectedResult?.name ?? String(localized: "search_title"))
    }
}

private struct ServiceDetailView: View {
    @Environment(\.openURL) private var openURL
    let serviceInfo: ToSDR
    @Binding var showLocalizedTitles: Bool
    let hasLocalizedTitles: Bool
    let refreshAction: @Sendable () async -> Void

    var body: some View {
        GroupedList {
            ServiceHeaderCard(serviceInfo: serviceInfo)

            ServicePointsList(
                serviceInfo: serviceInfo,
                showLocalizedTitles: $showLocalizedTitles
            )

            if hasLocalizedTitles {
                GroupedListSection {
                    Text(String(localized: "service_localization"))
                } content: {
                    GroupedListToggle(
                        icon: { Image(systemName: "globe") },
                        content: {
                            Text(String(localized: "service_localization_toggle"))
                        },
                        isOn: $showLocalizedTitles,
                        isFirst: true,
                        isLast: true
                    )
                }
            }

            GroupedListSection {
                Text(String(localized: "service_links"))
            } content: {
                ForEach(Array(serviceInfo.urls.enumerated()), id: \.element) { index, url in
                    GroupedListButton(
                        icon: { Image(systemName: "link") },
                        content: { Text(url).lineLimit(1) },
                        action: {
                            if let link = URL(string: url) {
                                openURL(link)
                            }
                        },
                        isFirst: index == 0,
                        isLast: index == serviceInfo.urls.count - 1
                    )
                }
            }
        }
        .refreshable {
            await refreshAction()
        }
    }
}

private struct ServiceErrorView: View {
    let message: String
    let retryAction: @Sendable () async -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "pc")
                .font(.system(size: 120))
                .foregroundColor(.secondary)
            Text(String(localized: "service_error_title"))
                .font(.headline)
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            Button(String(localized: "service_error_retry")) {
                Task { await retryAction() }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct ServiceHeaderCard: View {
    @Environment(\.openURL) private var openURL
    let serviceInfo: ToSDR

    var body: some View {
        VStack(spacing: 12) {
            CachedAsyncImage(
                url: URL(string: serviceInfo.icon),
                content: { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 75, maxHeight: 75)
                },
                placeholder: {
                    Image(systemName: "display")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                }
            )
            .cornerRadius(6)

            Text(serviceInfo.name)
                .font(.title)
                .fontWeight(.semibold)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    if serviceInfo.reviewed {
                        ServiceBadge(
                            text: String(localized: "service_badge_reviewed"),
                            systemImage: "checkmark.seal",
                            color: .green
                        )
                    }

                    ServiceBadge(
                        text: String(format: String(localized: "service_badge_grade"), serviceInfo.grade),
                        systemImage: "shield",
                        color: getColorForRating(rating: serviceInfo.grade)
                    )

                    ServiceBadge(
                        text: String(format: String(localized: "service_badge_points"), String(serviceInfo.points.totalCount())),
                        systemImage: "exclamationmark.triangle.fill",
                        color: .blue
                    )

                    ServiceBadge(
                        text: String(localized: "service_badge_open"),
                        systemImage: "globe",
                        color: .blue
                    ) {
                        if let link = URL(string: "https://tosdr.org/en/service/\(serviceInfo.id)") {
                            openURL(link)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.platformSecondaryGroupedBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .padding(.horizontal, 8)
    }
}

private struct ServiceBadge: View {
    let text: String
    let systemImage: String
    let color: Color
    var action: (() -> Void)?

    init(text: String, systemImage: String, color: Color, action: (() -> Void)? = nil) {
        self.text = text
        self.systemImage = systemImage
        self.color = color
        self.action = action
    }

    var body: some View {
        let badge = Label(text, systemImage: systemImage)
            .font(.footnote)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .foregroundColor(.white)
            .background(color)
            .clipShape(Capsule())

        if let action {
            Button(action: action) {
                badge
            }
            .buttonStyle(.plain)
        } else {
            badge
        }
    }
}

#Preview {
    ServiceView(searchResult: nil)
}

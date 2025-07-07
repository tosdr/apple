//
//  ServiceView.swift
//  ToS;DR
//
//  Created by Erik on 01.11.23.
//

import SwiftUI
import CachedAsyncImage

struct ServiceView: View {
    @Environment(\.openURL) var openURL
    
    private var searchResult: SearchResult?
    
    @State var serviceInfo: ToSDR?
    
    @State private var showLocalizedTitles = true
    
    @State private var showAlertError = false
    
    @State private var error = ""
    @State var errorAcknowledge = false
    
    init(searchResult: SearchResult?) {
        if (searchResult != nil) {
            self.searchResult = searchResult!
        } else {
            self.searchResult = nil
        }
    }
    
    // Check if any points have localized titles
    func hasLocalizedTitles() -> Bool {
        guard serviceInfo != nil else {
            return false
        }
        for points in serviceInfo!.points.values {
            for point in points {
                if point.localizedTitle != nil {
                    return true
                }
            }
        }
        return false
    }
    
    var grade = ""
    
    var body: some View {
        Group {
            if (searchResult == nil) {
                EmptySelectionView()
            } else if (serviceInfo == nil) {
                if (!errorAcknowledge) {
                    LoadingServiceView(searchResult: searchResult!)
                        .task(id: serviceInfo?.id) {
                            await loadServiceInfo()
                        }
                        .alert(isPresented: $showAlertError) {
                            Alert(
                                title: Text(String(localized: "service_error_title")),
                                message: Text(String(format: String(localized: "service_error_api"), error)),
                                dismissButton: .default(
                                    Text(String(localized: "ok")),
                                    action: {
                                        errorAcknowledge.toggle()
                                    }
                                )
                            )
                        }
                } else {
                    ServiceErrorView(
                        onRetry: {
                            errorAcknowledge.toggle()
                            error = ""
                        }
                    )
                }
            } else {
                ServiceContentView(
                    serviceInfo: serviceInfo!,
                    showLocalizedTitles: $showLocalizedTitles,
                    hasLocalizedTitles: hasLocalizedTitles()
                )
            }
        }
        .navigationTitle(searchResult?.name ?? "Service")
#if os(macOS)
        .navigationSubtitle(serviceInfo?.name ?? "")
        .frame(minWidth: 500)
#endif
    }
    
    private func loadServiceInfo() async {
        guard let searchResult = searchResult else { return }
        
        let service = await GetServicePageById(service: searchResult.id)
        if service.error {
            error = service.message ?? "No error message provided"
            print(error)
            showAlertError.toggle()
            return
        }
        serviceInfo = service.response
    }
}

// MARK: - Supporting Views

struct EmptySelectionView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text(String(localized: "service_no_selection"))
                .font(.title2)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

struct LoadingServiceView: View {
    let searchResult: SearchResult
    
    var body: some View {
        VStack(spacing: 20) {
            // Service icon with loading animation
            CachedAsyncImage(
                url: URL(string: searchResult.icon),
                content: { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                },
                placeholder: {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "display")
                                .foregroundStyle(.secondary)
                        )
                }
            )
            
            VStack(spacing: 8) {
                Text(searchResult.name)
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Loading service details...")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            ProgressView()
                .scaleEffect(1.2)
                .tint(.blue)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

struct ServiceErrorView: View {
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundStyle(.red)
            
            VStack(spacing: 12) {
                Text(String(localized: "service_error_title"))
                    .font(.title2)
                    .fontWeight(.semibold)
                
#if os(macOS)
                Text("Unable to load service details. Please check your connection and try again.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
#else
                Text(String(localized: "service_error_pull"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
#endif
            }
            
#if os(macOS)
            Button(String(localized: "service_error_retry")) {
                onRetry()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
#endif
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
#if os(iOS)
        .refreshable {
            onRetry()
        }
#endif
    }
}

struct ServiceContentView: View {
    let serviceInfo: ToSDR
    @Binding var showLocalizedTitles: Bool
    let hasLocalizedTitles: Bool
    
    var body: some View {
        List {
            // Enhanced service header
            Section {
                ServiceHeaderCard(serviceInfo: serviceInfo)
            }
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            
            // Service points
            ServicePoints(
                serviceInfo: serviceInfo,
                clickable: true,
                showLocalizedTitles: $showLocalizedTitles
            )
            
            // Localization settings
            if hasLocalizedTitles {
                Section(String(localized: "service_localization")) {
                    HStack {
                        Label {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(String(localized: "service_localization_warning"))
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text(String(localized: "service_localization_warning_desc"))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundStyle(.orange)
                        }
                        
                        Spacer()
                    }
                    
                    Toggle(String(localized: "service_localization_toggle"), isOn: $showLocalizedTitles)
                }
            }
        }
#if os(macOS)
        .listStyle(.insetGrouped)
#endif
        .background(Color(.systemGroupedBackground))
    }
}

struct ServiceHeaderCard: View {
    let serviceInfo: ToSDR
    @Environment(\.openURL) var openURL
    @State private var showAlert = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Service icon and name
            HStack(spacing: 16) {
                CachedAsyncImage(
                    url: URL(string: serviceInfo.icon),
                    content: { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    },
                    placeholder: {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 60, height: 60)
                            .overlay(
                                Image(systemName: "display")
                                    .foregroundStyle(.secondary)
                            )
                    }
                )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(serviceInfo.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    
                    Text("Grade: \(serviceInfo.grade)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            
            // Badges
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                // Review status badge
                if serviceInfo.reviewed {
                    ServiceBadge(
                        title: String(localized: "service_badge_reviewed"),
                        systemImage: "checkmark.seal.fill",
                        color: .green,
                        action: {
                            showAlert.toggle()
                        }
                    )
                }
                
                // Grade badge
                ServiceBadge(
                    title: String(format: String(localized: "service_badge_grade"), String(serviceInfo.grade)),
                    systemImage: "shield.fill",
                    color: getColorForRating(rating: serviceInfo.grade)
                )
                
                // Points count badge
                ServiceBadge(
                    title: String(format: String(localized: "service_badge_points"), String(serviceInfo.points.totalCount())),
                    systemImage: "exclamationmark.triangle.fill",
                    color: .blue
                )
                
                // Open on web badge
                ServiceBadge(
                    title: String(localized: "service_badge_open"),
                    systemImage: "globe",
                    color: .blue,
                    action: {
                        openURL(URL(string: "https://tosdr.org/en/service/\(String(serviceInfo.id))")!)
                    }
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(String(localized: "service_review_title")),
                message: Text(String(localized: "service_review_message")),
                dismissButton: .default(Text(String(localized: "ok")))
            )
        }
    }
}

struct ServiceBadge: View {
    let title: String
    let systemImage: String
    let color: Color
    let action: (() -> Void)?
    
    init(title: String, systemImage: String, color: Color, action: (() -> Void)? = nil) {
        self.title = title
        self.systemImage = systemImage
        self.color = color
        self.action = action
    }
    
    var body: some View {
        Button(action: action ?? {}) {
            Label(title, systemImage: systemImage)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(color)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .disabled(action == nil)
    }
}

#Preview {
    ServiceView(searchResult: SearchResult(name: "Steam", id: 180, icon: "", grade: "D", reviewed: true))
}

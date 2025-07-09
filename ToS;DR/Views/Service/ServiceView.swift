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
        if (searchResult == nil) {
            Text(String(localized: "service_no_selection"))
#if os(macOS)
                .font(.title2)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.controlBackgroundColor))
#endif
        } else if (serviceInfo == nil) {
            if (!errorAcknowledge) {
                ProgressView().frame(minWidth: 100, minHeight: 100).task(id: serviceInfo?.id) {
                    Task {
                        let service = await GetServicePageById(service: searchResult!.id)
                        if (service.error) {
                            error = service.message ?? "No error message provided"
                            print(error)
                            showAlertError.toggle()
                            return
                        }
                        serviceInfo = service.response
                    }
                }
                .alert(isPresented: $showAlertError, content: {
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
                })
            } else {
                GeometryReader { geometry in
                    ScrollView {
                        VStack(alignment: .center)  {
                            Image(systemName: "pc")
                                .font(.system(size: 150))
                                .padding([.bottom], 12.0)
#if os(macOS)
                                .foregroundColor(.secondary)
#endif
                            Text(String(localized: "service_error_title"))
#if os(macOS)
                                .font(.title2)
                                .foregroundColor(.primary)
#endif
#if os(macOS)
                            Button(String(localized: "service_error_retry")) {
                                errorAcknowledge.toggle()
                                error = ""
                            }
                            .buttonStyle(.borderedProminent)
                            .padding(.top, 8)
#else
                            Text(String(localized: "service_error_pull"))
#endif
                        }
                        .padding()
                        .frame(width: geometry.size.width)
                        .frame(minHeight: geometry.size.height)
                    }
                    .refreshable {
                        errorAcknowledge.toggle()
                        error = ""
                    }
                }
            }
        } else {
            List {
                HStack {
                    ServiceHeader(serviceInfo: serviceInfo!)
                }.listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
#if os(macOS)
                    .listRowBackground(Color.clear)
#endif
                ServicePoints(serviceInfo: serviceInfo!, clickable: true, showLocalizedTitles: $showLocalizedTitles)
                
                if hasLocalizedTitles() {
                    Section(String(localized: "service_localization")) {
                        Label {
                            VStack(alignment: .leading) {
                                Text(String(localized: "service_localization_warning"))
                                Text(String(localized: "service_localization_warning_desc"))
                                    .font(.caption).foregroundColor(.secondary)
                            }
                        } icon: {
                            Image(systemName: "exclamationmark.octagon.fill")
                                .foregroundStyle(.red)
                        }
#if os(macOS)
                        .padding(.vertical, 4)
#endif
                        Toggle(String(localized: "service_localization_toggle"), isOn: $showLocalizedTitles)
#if os(macOS)
                            .padding(.vertical, 4)
#endif
                    }
                    
                }
            }
#if os(macOS)
            .listStyle(.insetGrouped)
            .padding(.horizontal)
#endif
        }
    }
}

#Preview {
    ServiceView(searchResult: SearchResult(name: "Steam", id: 180, icon: "", grade: "D", reviewed: true))
}

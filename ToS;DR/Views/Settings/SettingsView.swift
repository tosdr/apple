//
//  SettingsView.swift
//  ToS;DR
//
//  Created by Erik on 01.11.23.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showUpdateError = false
    
    var body: some View {
        GroupedList {
            appSection
            databaseSection
            apiSection
            resetSection
        }
        .navigationTitle(String(localized: "label_settings"))
        .alert(isPresented: $showUpdateError) {
            Alert(
                title: Text(String(localized: "settings_error_title")),
                message: Text(viewModel.updateError ?? String(localized: "settings_error_db_update")),
                dismissButton: .default(Text(String(localized: "ok")))
            )
        }
    }
    
    private var appSection: some View {
        GroupedListSection {
            Text(String(localized: "settings_section_app"))
        } content: {
#if os(iOS)
            GroupedListNavigationLink(
                icon: { Image(systemName: "app.dashed") },
                content: { Text("App Icon") },
                destination: { AppIconSetting() },
                isFirst: true
            )
#endif
            GroupedListToggle(
                icon: { Image(systemName: "square.and.arrow.up") },
                content: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(String(localized: "settings_server_search_title"))
                        Text(String(localized: "settings_server_search_desc"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                },
                isOn: serverSearchBinding,
                isFirst: true,
                isLast: true
            )
        }
    }
    
    private var databaseSection: some View {
        GroupedListSection {
            Text(String(localized: "settings_section_database"))
        } content: {
            if let lastPull = viewModel.lastPull {
                GroupedListItem(
                    content: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Label(String(localized: "settings_db_date"), systemImage: "calendar.badge.clock")
                                Text(String(localized: "settings_db_date_desc"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text(lastPull)
                                .foregroundColor(.secondary)
                        }
                    },
                    isFirst: true
                )
                
                GroupedListItem(
                    content: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Label(String(localized: "settings_db_services"), systemImage: "globe")
                                Text(String(localized: "settings_db_services_desc"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text(String(viewModel.serviceCount ?? 0))
                                .foregroundColor(.secondary)
                        }
                    }
                )
            } else {
                GroupedListItem(
                    content: {
                        VStack(alignment: .leading, spacing: 4) {
                            Label(String(localized: "settings_db_not_pulled"), systemImage: "questionmark.folder")
                            Text(String(localized: "settings_db_not_pulled_desc"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    },
                    isFirst: true
                )
            }
            
            GroupedListButton(
                content: {
                    if viewModel.isUpdating {
                        HStack {
                            Label(String(localized: "settings_db_refreshing"), systemImage: "arrow.clockwise")
                            Spacer()
                            ProgressView()
#if os(macOS)
                                .frame(width: 16, height: 16)
#endif
                        }
                    } else {
                        Label(String(localized: "settings_db_refresh"), systemImage: "arrow.down.doc")
                    }
                },
                action: {
                    Task {
                        let success = await viewModel.refreshDatabase(context: modelContext)
                        showUpdateError = !success
                    }
                }
            )
            
            GroupedListButton(
                content: {
                    Label(String(localized: "settings_db_delete"), systemImage: "minus.circle")
                        .foregroundColor(.red)
                },
                action: {
                    if !viewModel.deleteDatabase(context: modelContext) {
                        showUpdateError = true
                    }
                },
                isLast: true
            )
        }
    }
    
    private var apiSection: some View {
        GroupedListSection {
            Text(String(localized: "settings_section_api"))
        } content: {
            GroupedListItem(
                content: {
                    Picker(String(localized: "settings_api_server"), selection: serverSelectionBinding) {
                        ForEach(viewModel.servers, id: \.self) { server in
                            Text(server).tag(server)
                        }
                    }
                    .pickerStyle(.menu)
                },
                isFirst: true,
                isLast: viewModel.serverSelected != "Custom"
            )
            
            if viewModel.serverSelected == "Custom" {
                GroupedListItem(
                    content: {
                        HStack {
                            Text(String(localized: "settings_api_custom"))
                            TextField("api.tosdr.org", text: customServerBinding)
                                .textFieldStyle(.roundedBorder)
                                .disableAutocorrection(true)
                        }
                    },
                    isLast: true
                )
            }
        }
    }
    
    private var resetSection: some View {
        GroupedListSection {
            Text(String(localized: "settings_section_reset"))
        } content: {
            GroupedListButton(
                content: {
                    Label(String(localized: "settings_reset_onboarding"), systemImage: "restart.circle")
                },
                action: {
                    viewModel.resetOnboarding()
                },
                isFirst: true,
                isLast: true
            )
        }
    }
    
    private var serverSearchBinding: Binding<Bool> {
        Binding(
            get: { viewModel.serverSearch },
            set: { viewModel.updateServerSearch($0) }
        )
    }
    
    private var serverSelectionBinding: Binding<String> {
        Binding(
            get: { viewModel.serverSelected },
            set: { newValue in viewModel.updateServerSelection(newValue) }
        )
    }
    
    private var customServerBinding: Binding<String> {
        Binding(
            get: { viewModel.customServer },
            set: { newValue in viewModel.updateCustomServer(newValue) }
        )
    }
}

#Preview {
    SettingsView()
}

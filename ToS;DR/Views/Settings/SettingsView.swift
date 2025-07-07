//
//  SettingsView.swift
//  ToS;DR
//
//  Created by Erik on 01.11.23.
//

import SwiftUI

struct SettingsView: View {
    let defaults = UserDefaults.standard
    @State private var refresh: Bool = false
    @Environment(\.modelContext) private var modelContext
    
    var servers = ["api.tosdr.org", "api.staging.tosdr.org", "Custom"]
    
    @State var isLoading = false
    @State var isShown = false
    
    @AppStorage("server") var serverSelected = "api.tosdr.org"
    @AppStorage("serverUrl") var customServer = ""
    @AppStorage("server-search") var serverSearch = false
    
    var body: some View {
        List {
            // App Settings Section
            Section(header: 
                HStack {
                    Image(systemName: "gear")
                        .foregroundStyle(.blue)
                    Text(String(localized: "settings_section_app"))
                        .font(.headline)
                        .fontWeight(.semibold)
                    Spacer()
                }
            ) {
#if os(iOS)
                NavigationLink(destination: AppIconSetting()) {
                    SettingsRowView(
                        icon: "app.dashed",
                        iconColor: .purple,
                        title: "App Icon",
                        subtitle: "Change app icon style"
                    )
                }
#endif
                
                // Server search setting
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "magnifyingglass.circle.fill")
                            .foregroundStyle(.green)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(String(localized: "settings_server_search_title"))
                                .font(.headline)
                                .fontWeight(.medium)
                            Text(String(localized: "settings_server_search_desc"))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $serverSearch)
                            .labelsHidden()
                    }
                }
                .padding(.vertical, 4)
            }
            
            // Database Section
            Section(header: 
                HStack {
                    Image(systemName: "database")
                        .foregroundStyle(.orange)
                    Text(String(localized: "settings_section_database"))
                        .font(.headline)
                        .fontWeight(.semibold)
                    Spacer()
                }
            ) {
                // Database status
                if (getDBCount() == nil) {
                    DatabaseStatusView(
                        icon: "questionmark.folder",
                        iconColor: .gray,
                        title: String(localized: "settings_db_not_pulled"),
                        subtitle: String(localized: "settings_db_not_pulled_desc")
                    )
                } else {
                    DatabaseInfoView(
                        icon: "calendar.badge.clock",
                        iconColor: .blue,
                        title: String(localized: "settings_db_date"),
                        subtitle: String(localized: "settings_db_date_desc"),
                        value: defaults.string(forKey: "lastPull") ?? "Never"
                    )
                    
                    DatabaseInfoView(
                        icon: "globe",
                        iconColor: .green,
                        title: String(localized: "settings_db_services"),
                        subtitle: String(localized: "settings_db_services_desc"),
                        value: String(getDBCount() ?? 0)
                    )
                }
                
                // Database actions
                Button {
                    Task {
                        isLoading = true
                        if (await updateDB(context: modelContext).value) {
                            refresh.toggle()
                            isLoading = false
                        } else {
                            isLoading = false
                            isShown.toggle()
                        }
                    }
                } label: {
                    HStack {
                        if (isLoading) {
                            ProgressView()
                                .scaleEffect(0.8)
                                .frame(width: 20, height: 20)
                            
                            Text(String(localized: "settings_db_refreshing"))
                                .font(.headline)
                                .fontWeight(.medium)
                        } else {
                            Image(systemName: "arrow.clockwise.circle.fill")
                                .foregroundStyle(.blue)
                                .font(.title2)
                            
                            Text(String(localized: "settings_db_refresh"))
                                .font(.headline)
                                .fontWeight(.medium)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
                .disabled(isLoading)
                .contentShape(Rectangle())
                .alert(isPresented: $isShown) {
                    Alert(
                        title: Text(String(localized: "settings_error_title")),
                        message: Text(String(localized: "settings_error_db_update")),
                        dismissButton: .default(Text("OK"))
                    )
                }
#if os(macOS)
                .buttonStyle(.plain)
#endif
                
                Button {
                    if (deleteDB(context: modelContext)) {
                        refresh.toggle()
                    }
                } label: {
                    HStack {
                        Image(systemName: "trash.circle.fill")
                            .foregroundStyle(.red)
                            .font(.title2)
                        
                        Text(String(localized: "settings_db_delete"))
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundStyle(.red)
                        
                        Spacer()
                    }
                    .padding(.vertical, 4)
                }
                .contentShape(Rectangle())
#if os(macOS)
                .buttonStyle(.plain)
#endif
            }
            .id(refresh)
            
            // API Settings Section
            Section(header: 
                HStack {
                    Image(systemName: "server.rack")
                        .foregroundStyle(.purple)
                    Text(String(localized: "settings_section_api"))
                        .font(.headline)
                        .fontWeight(.semibold)
                    Spacer()
                }
            ) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "server.rack")
                            .foregroundStyle(.purple)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(String(localized: "settings_api_server"))
                                .font(.headline)
                                .fontWeight(.medium)
                            Text("Choose your API server")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                    }
                    
                    Picker(String(localized: "settings_api_server"), selection: $serverSelected) {
                        ForEach(servers, id: \.self) { server in
                            Text(server)
                                .tag(server)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.vertical, 4)
                
                if (serverSelected == "Custom") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "text.cursor")
                                .foregroundStyle(.gray)
                                .font(.title2)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(String(localized: "settings_api_custom"))
                                    .font(.headline)
                                    .fontWeight(.medium)
                                Text("Enter your custom API URL")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                        }
                        
                        TextField("api.tosdr.org", text: $customServer)
                            .textFieldStyle(.roundedBorder)
                            .disableAutocorrection(true)
                            .onChange(of: customServer, initial: false) { _, value in
                                defaults.setValue(value, forKey: "serverUrl")
                            }
                    }
                    .padding(.vertical, 4)
                }
            }
            .onChange(of: serverSelected, initial: false) { _, value in
                customServer = ""
                defaults.setValue(value, forKey: "server")
                defaults.removeObject(forKey: "serverUrl")
            }
            
#if os(iOS)
            // Reset Section
            Section(header: 
                HStack {
                    Image(systemName: "restart")
                        .foregroundStyle(.red)
                    Text(String(localized: "settings_section_reset"))
                        .font(.headline)
                        .fontWeight(.semibold)
                    Spacer()
                }
            ) {
                Button {
                    defaults.setValue(true, forKey: "firstStart")
                } label: {
                    SettingsRowView(
                        icon: "restart.circle",
                        iconColor: .red,
                        title: String(localized: "settings_reset_onboarding"),
                        subtitle: "Reset the onboarding flow"
                    )
                }
                .contentShape(Rectangle())
            }
#endif
        }
        .navigationTitle(String(localized: "label_settings"))
#if os(macOS)
        .listStyle(.insetGrouped)
        .frame(minWidth: 500)
#endif
    }
}

// MARK: - Supporting Views

struct SettingsRowView: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(iconColor)
                .font(.title2)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct DatabaseStatusView: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(iconColor)
                .font(.title2)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct DatabaseInfoView: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(iconColor)
                .font(.title2)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.gray.opacity(0.1))
                .clipShape(Capsule())
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    SettingsView()
}

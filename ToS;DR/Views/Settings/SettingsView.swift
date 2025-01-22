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
            Section(String(localized: "settings_section_app")) {
#if os(iOS)
                NavigationLink(destination: AppIconSetting()) {
                    Label("App Icon", systemImage: "app.dashed")
                }
#endif
                // local/server search setting
                Toggle(isOn: $serverSearch) {
                    Label(title: {
                        VStack(alignment: .leading) {
                            Text(String(localized: "settings_server_search_title"))
                            Text(String(localized: "settings_server_search_desc")).font(.caption).foregroundColor(.secondary)
                            
                        }}, icon: { Image(systemName: "square.and.arrow.up") }
                    )
                }.toggleStyle(.switch)
            }
            Section(String(localized: "settings_section_database")) {
                if (getDBCount() == nil) {
                    VStack(alignment: .leading) {
                        Label(String(localized: "settings_db_not_pulled"), systemImage: "questionmark.folder")
                        Text(String(localized: "settings_db_not_pulled_desc")).font(.caption).foregroundColor(.secondary)
                    }
                } else {
                    HStack {
                        VStack(alignment: .leading) {
                            Label(String(localized: "settings_db_date"), systemImage: "calendar.badge.clock")
                            Text(String(localized: "settings_db_date_desc")).font(.caption).foregroundColor(.secondary)
                        }
                        Spacer()
                        Text(defaults.string(forKey: "lastPull") ?? "None").foregroundColor(.secondary)
                    }
                    HStack {
                        VStack(alignment: .leading) {
                            Label(String(localized: "settings_db_services"), systemImage: "globe")
                            Text(String(localized: "settings_db_services_desc")).font(.caption).foregroundColor(.secondary)
                        }
                        Spacer()
                        Text(String(getDBCount() ?? 0)).foregroundColor(.secondary)
                    }
                }
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
                    if (isLoading) {
                        HStack {
                            Label(String(localized: "settings_db_refreshing"), systemImage: "arrow.clockwise")
                            Spacer()
                            ProgressView()
                        }
                    } else {
                        Label(String(localized: "settings_db_refresh"), systemImage: "arrow.down.doc")
                    }
                }
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
                    Label(String(localized: "settings_db_delete"), systemImage: "minus.circle")
                }.foregroundStyle(.red)
                    .contentShape(Rectangle())
                
#if os(macOS)
                    .buttonStyle(.plain)
#endif
            }
            .id(refresh)
            Section(String(localized: "settings_section_api")) {
                Picker(String(localized: "settings_api_server"), selection: $serverSelected) {
                    ForEach(servers, id: \.self) { server in
                        Text(server)
                    }
                }
                
                if (serverSelected == "Custom") {
                    HStack {
                        Text(String(localized: "settings_api_custom"))
                        TextField("api.tosdr.org", text: $customServer)
                            .textFieldStyle(.roundedBorder)
                            .disableAutocorrection(true)
                            .onChange(of: customServer, initial: false) { _, value in
                                defaults.setValue(value, forKey: "serverUrl")
                            }
                    }
                }
                
            }.onChange(of: serverSelected, initial: false) { _, value in
                customServer = ""
                defaults.setValue(value, forKey: "server")
                defaults.removeObject(forKey: "serverUrl")
            }
            #if os(iOS)
            Section(String(localized: "settings_section_reset")) {
                Button {
                    defaults.setValue(true, forKey: "firstStart")
                } label: {
                    Label(String(localized: "settings_reset_onboarding"), systemImage: "restart.circle")
                }
                    .contentShape(Rectangle())
            }
            #endif
        }.navigationTitle(String(localized: "label_settings"))
    }
}

#Preview {
    SettingsView()
}

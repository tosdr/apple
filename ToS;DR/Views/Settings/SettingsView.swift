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
    
    var servers = ["api.tosdr.org", "api.staging.tosdr.org", "Custom"]
    
    @State var isLoading = false
    @State var isShown = false
    
    @AppStorage("server") var serverSelected = "api.tosdr.org"
    @AppStorage("serverUrl") var customServer = ""
    
    @AppStorage("server-search") var serverSearch = false
    
    var body: some View {
        List {
            Section("App Settings") {
#if os(iOS)
                NavigationLink(destination: AppIconSetting()) {
                    Label("App Icon", systemImage: "app.dashed")
                }
#endif
                // local/server search setting
                Toggle(isOn: $serverSearch) {
                    VStack(alignment: .leading) {
                        Label("Prefer Server-Side Search", systemImage: "magnifyingglass")
                        Text("Instead of searching using the local database, it will use the online search. Will show unverified Services as well.").font(.caption).foregroundColor(.secondary)
                    }
                }.toggleStyle(.switch)
            }
            Section("Database") {
                if (getDBCount() == nil) {
                    VStack(alignment: .leading) {
                        Label("Database not pulled yet", systemImage: "questionmark.folder")
                        Text("The database has not been pulled from the server yet. Please pull the database first.").font(.caption).foregroundColor(.secondary)
                    }
                } else {
                    HStack {
                        VStack(alignment: .leading) {
                            Label("Database Date", systemImage: "calendar.badge.clock")
                            Text("The date where the Database was last pulled from the server.").font(.caption).foregroundColor(.secondary)
                        }
                        Spacer()
                        Text(defaults.string(forKey: "lastPull") ?? "None").foregroundColor(.secondary)
                    }
                    HStack {
                        VStack(alignment: .leading) {
                            Label("Services Indexed", systemImage: "globe")
                            Text("The number of services that are indexed in the database and available offline.").font(.caption).foregroundColor(.secondary)
                        }
                        Spacer()
                        Text(String(getDBCount() ?? 0)).foregroundColor(.secondary)
                    }
                    HStack {
                        VStack(alignment: .leading) {
                            Label("Database Size", systemImage: "externaldrive")
                            Text("The size of the database saved on your device.").font(.caption).foregroundColor(.secondary)
                        }
                        Spacer()
                        Text(getDBSize() ?? "None").foregroundColor(.secondary)
                    }
                }
                Button {
                    Task {
                        isLoading = true
                        if (await updateDB().value) {
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
                            Label("Refreshing Database", systemImage: "arrow.clockwise")
                            Spacer()
                            ProgressView()
                        }
                    } else {
                        Label("Refresh Database now", systemImage: "arrow.down.doc")
                    }
                }
                .contentShape(Rectangle())
                .alert(isPresented: $isShown) {
                    Alert(title: Text("Error"), message: Text("Could not update Database. Please try again later."), dismissButton: .default(Text("OK")))
                }
#if os(macOS)
                .buttonStyle(.plain)
#endif
                Button {
                    if (deleteDB()) {
                        refresh.toggle()
                    }
                } label: {
                    Label("Delete local Database", systemImage: "minus.circle")
                }.foregroundStyle(.red)
                    .contentShape(Rectangle())
                
#if os(macOS)
                    .buttonStyle(.plain)
#endif
            }
            .id(refresh)
            Section("API Options") {
                // Selection of stable, staging and custom server which is editable
                Picker("Server", selection: $serverSelected) {
                    ForEach(servers, id: \.self) { server in
                        Text(server)
                    }
                }
                
                if (serverSelected == "Custom") {
                    HStack {
                        Text("Custom Server")
                        TextField("api.tosdr.org", text: $customServer)
                            .textFieldStyle(.roundedBorder)
                            .disableAutocorrection(true)
                            .onChange(of: customServer) { value in
                                defaults.setValue(value, forKey: "serverUrl")
                            }
                    }
                }
                
            }.onChange(of: serverSelected) { value in
                customServer = ""
                defaults.setValue(value, forKey: "server")
                defaults.removeObject(forKey: "serverUrl")
            }
            #if os(iOS)
            Section("Reset") {
                Button {
                    defaults.setValue(true, forKey: "firstStart")
                } label: {
                    Label("Reset Onboarding State", systemImage: "restart.circle")
                }
                    .contentShape(Rectangle())
            }
            #endif
        }.navigationTitle("Settings")
    }
}

#Preview {
    SettingsView()
}

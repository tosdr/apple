//
//  ContentView.swift
//  ToS;DR
//
//  Created by Erik on 01.11.23.
//

import SwiftUI
import OSLog
import CachedAsyncImage
import SwiftData

struct ContentView: View {
    @State private var searchText = ""
    @State private var searchResult: SearchResult?
    @State var searchTask: Task<(), Error>?
    @State private var loadingState = LoadingState.idle
    @State private var isRefreshing = false
    @StateObject private var networkMonitor = NetworkMonitor()
    
    @Environment(\.openURL) var openURL
    @Environment(\.modelContext) private var modelContext
    
    let logger = Logger(subsystem: "org.tosdr.app", category: "ContentView")
    
    var body: some View {
        NavigationView {
            VStack {
                if !networkMonitor.isConnected {
                    HStack {
                        Image(systemName: "wifi.slash")
                            .foregroundColor(.white)
                        Text(String(localized: "offline_mode"))
                            .foregroundColor(.white)
                            .font(.subheadline)
                            .bold()
                        Spacer()
                    }
                    .padding()
                    .background(Color.red.opacity(0.8))
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                if searchResults.isEmpty && (UserDefaults.standard.bool(forKey: "server-search") || searchText == "") {
                    mainMenuView
                } else {
                    searchResultsView
                }
                
                if loadingState.status == .loading {
                    LoadingView(state: loadingState)
                }
            }
#if os(iOS)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: String(localized: "search_prompt"))
#elseif os(macOS)
            .searchable(text: $searchText, placement: .toolbar, prompt: String(localized: "search_prompt"))
#endif
            
#if os(macOS)
            NavigationStack {
                AboutView()
            }
#endif
        }
        .onSubmit(of: .search, runSearch)
        .navigationTitle("ToS;DR")
        .toolbar {
#if os(macOS)
            ToolbarItem(placement: .navigation) {
                Button(action: toggleSidebar, label: {
                    Image(systemName: "sidebar.left")
                        .accessibilityLabel(String(localized: "toggle_sidebar"))
                })
            }
#endif
            // Database refresh button
            ToolbarItem(placement: .primaryAction) {
                Button {
                    Task {
                        await refreshDatabase()
                    }
                } label: {
                    Label(String(localized: "refresh_database"), systemImage: "arrow.clockwise")
                }
                .disabled(isRefreshing || !networkMonitor.isConnected)
            }
        }
        .onChange(of: searchText, initial: false) { _, query in
            if UserDefaults.standard.bool(forKey: "server-search") {
                checkClear()
            } else {
                runSearch()
            }
        }
        // Show last database update time
        .overlay(alignment: .bottom) {
            if let lastUpdate = UserDefaults.standard.string(forKey: "lastPullDisplay") {
                Text(String(format: String(localized: "last_updated"), lastUpdate))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 4)
            }
        }
    }
    
    private var mainMenuView: some View {
        List {
            Section(String(localized: "about_section")) {
                NavigationLink {
#if os(macOS)
                    NavigationStack {
                        AboutView()
                    }
#else
                    AboutView()
#endif
                } label: {
                    Label(String(localized: "label_about"), systemImage: "person")
                }
                NavigationLink {
                    TeamView()
                } label: {
                    Label(String(localized: "label_team"), systemImage: "person.2")
                }
                NavigationLink {
                    SettingsView()
                } label: {
                    Label(String(localized: "label_settings"), systemImage: "gear")
                }
                NavigationLink {
                    DonateView()
                } label: {
                    Label(String(localized: "label_donate"), systemImage: "dollarsign")
                }
            }
            
            // Featured services section - uncomment when implemented
            /* 
            Section(String(localized: "featured_section")) {
                FeaturedServices()
            }
            */
        }
        .navigationTitle("ToS;DR")
#if os(macOS)
        .listStyle(.sidebar)
#endif
        .refreshable {
            await refreshDatabase()
        }
    }
    
    // Search results view
    private var searchResultsView: some View {
        List(searchResults, id:\.self, selection: $searchResult) { result in
            NavigationLink {
#if os(macOS)
                NavigationStack {
                    ServiceView(searchResult: result)
                }
#else
                ServiceView(searchResult: result).navigationTitle(result.name)
#endif
            } label: {
                Label {
                    VStack(alignment: .leading) {
                        Text(result.name)
                            .font(.headline)
                        
                        // This service might be from a database, so we don't have URLs directly
                        // We'll leave it without showing a domain for now
                    }
                } icon: {
                    CachedAsyncImage(
                        url: URL(string: result.icon),
                        content: { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 32, height: 32)
                        },
                        placeholder: {
                            Image(systemName: "display")
                                .frame(width: 32, height: 32)
                        }
                    )
                }
                .padding(.vertical, 4)
            }
            .accessibilityLabel(String(format: String(localized: "service_result_a11y"), result.name, result.grade))
        }
        .navigationTitle(String(localized: "search_title"))
        .listStyle(.sidebar)
        .overlay {
            if loadingState.status == .error {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(.red)
                        .padding()
                    
                    Text(loadingState.message ?? String(localized: "search_error"))
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    Button(String(localized: "retry_button")) {
                        if let retryAction = loadingState.retryAction {
                            retryAction()
                        } else {
                            runSearch()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            } else if searchResults.isEmpty && loadingState.status != .loading {
                VStack {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                        .padding()
                    
                    Text(String(localized: "no_results_found"))
                        .foregroundColor(.secondary)
                }
                .padding()
            }
        }
    }
    
    private func toggleSidebar() {
#if os(macOS)
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
#endif
    }
    
    @State var searchResults: [SearchResult] = []
    
    func runSearch() {
        guard !searchText.isEmpty else {
            searchResults = []
            return
        }
        
        // If offline and trying to do server search, show error
        if UserDefaults.standard.bool(forKey: "server-search") && !networkMonitor.isConnected {
            loadingState = .error(
                message: String(localized: "offline_search_error"),
                retryAction: { 
                    // Switch to local search as a fallback
                    UserDefaults.standard.set(false, forKey: "server-search")
                    runSearch()
                }
            )
            return
        }
        
        loadingState = .loading
        
        searchTask?.cancel()
        searchTask = Task {
            do {
                searchResults = await search() ?? []
                if Task.isCancelled { return }
                loadingState = searchResults.isEmpty ? 
                    .error(message: String(localized: "no_results_found")) : .success()
            } catch {
                if Task.isCancelled { return }
                loadingState = .error(
                    message: error.localizedDescription,
                    retryAction: { runSearch() }
                )
            }
        }
    }
    
    func checkClear() {
        if searchText.isEmpty {
            searchResults = []
            loadingState = .idle
        }
    }
    
    @MainActor
    func search() async -> [SearchResult]? {
        logger.debug("Searching for \(searchText)")
        if searchText.isEmpty {
            return []
        } else {
            if (UserDefaults.standard.bool(forKey: "server-search")) {
                let result = await SearchByName(name: searchText)
                if !result.error {
                    return result.response
                }
                return nil
            }
            let result = await SearchInDB(name: searchText, context: modelContext)
            if !result.error {
                return result.response
            }
            return nil
        }
    }
    
    @MainActor
    func refreshDatabase() async {
        guard networkMonitor.isConnected else {
            loadingState = .error(
                message: String(localized: "offline_refresh_error"),
                retryAction: { Task { await refreshDatabase() } }
            )
            return
        }
        
        isRefreshing = true
        loadingState = .loading
        
        logger.info("Refreshing local database")
        let result = await updateDB(context: modelContext)
        
        if result.value {
            logger.info("Refreshed local database")
            loadingState = .success(message: String(localized: "database_updated"))
            Task {
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                loadingState = .idle
            }
        } else {
            logger.error("Failed to refresh local database: \(result.error ?? "Unknown error")")
            loadingState = .error(
                message: result.error ?? String(localized: "database_update_failed"),
                retryAction: { Task { await refreshDatabase() } }
            )
        }
        
        isRefreshing = false
    }
}

#Preview {
    ContentView()
}

struct PlaceholderView: View {
    var body: some View {
        Text("Placeholder")
    }
}

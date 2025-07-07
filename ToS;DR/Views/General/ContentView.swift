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
            VStack(spacing: 0) {
                // Network status banner
                if !networkMonitor.isConnected {
                    networkStatusBanner
                }
                
                // Main content
                Group {
                    if searchResults.isEmpty && (UserDefaults.standard.bool(forKey: "server-search") || searchText == "") {
                        mainMenuView
                    } else {
                        searchResultsView
                    }
                }
                
                // Loading overlay
                if loadingState.status == .loading {
                    LoadingView(state: loadingState)
                }
            }
            .background(Color(.systemBackground))
#if os(iOS)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: String(localized: "search_prompt"))
#elseif os(macOS)
            .searchable(text: $searchText, placement: .toolbar, prompt: String(localized: "search_prompt"))
#endif
            
#if os(macOS)
            // macOS detail view
            NavigationStack {
                VStack {
                    Image(systemName: "shield.lefthalf.filled")
                        .font(.system(size: 60))
                        .foregroundStyle(.blue.gradient)
                        .padding(.bottom, 16)
                    
                    Text("ToS;DR")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom, 8)
                    
                    Text("Select a service or search to get started")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.controlBackgroundColor))
            }
            .frame(minWidth: 400)
#endif
        }
        .onSubmit(of: .search, runSearch)
        .navigationTitle("ToS;DR")
        .toolbar {
#if os(macOS)
            ToolbarItem(placement: .navigation) {
                Button(action: toggleSidebar) {
                    Image(systemName: "sidebar.left")
                        .foregroundStyle(.primary)
                }
                .help("Toggle Sidebar")
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
                .help("Refresh Database")
            }
        }
        .onChange(of: searchText, initial: false) { _, query in
            if UserDefaults.standard.bool(forKey: "server-search") {
                checkClear()
            } else {
                runSearch()
            }
        }
        // Status bar
        .safeAreaInset(edge: .bottom) {
            if let lastUpdate = UserDefaults.standard.string(forKey: "lastPullDisplay") {
                HStack {
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(String(format: String(localized: "last_updated"), lastUpdate))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 6)
                .background(Color(.systemBackground).opacity(0.8))
                .background(.regularMaterial)
            }
        }
    }
    
    // MARK: - Network Status Banner
    private var networkStatusBanner: some View {
        HStack {
            Image(systemName: "wifi.slash")
                .foregroundStyle(.white)
                .fontWeight(.semibold)
            Text(String(localized: "offline_mode"))
                .foregroundStyle(.white)
                .font(.subheadline)
                .fontWeight(.medium)
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(
            LinearGradient(
                colors: [Color.red, Color.red.opacity(0.8)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .transition(.move(edge: .top).combined(with: .opacity))
    }
    
    // MARK: - Main Menu View
    private var mainMenuView: some View {
        List {
            // Welcome section for macOS
#if os(macOS)
            Section {
                HStack {
                    Image(systemName: "shield.lefthalf.filled")
                        .font(.system(size: 32))
                        .foregroundStyle(.blue.gradient)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Welcome to ToS;DR")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("Terms of Service; Didn't Read")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding(.vertical, 8)
                .listRowBackground(Color.clear)
            }
#endif
            
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
                    Label(String(localized: "label_about"), systemImage: "info.circle")
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
                    Label(String(localized: "label_donate"), systemImage: "heart")
                }
            }
            
            // Quick stats section
            Section("Database Statistics") {
                HStack {
                    Label("Services", systemImage: "globe")
                    Spacer()
                    if let count = getDBCount() {
                        Text("\(count)")
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Not loaded")
                            .foregroundStyle(.secondary)
                    }
                }
                
                HStack {
                    Label("Last Update", systemImage: "clock")
                    Spacer()
                    Text(UserDefaults.standard.string(forKey: "lastPull") ?? "Never")
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("ToS;DR")
#if os(macOS)
        .listStyle(.sidebar)
        .frame(minWidth: 250)
#endif
        .refreshable {
            await refreshDatabase()
        }
    }
    
    // MARK: - Search Results View
    private var searchResultsView: some View {
        List(searchResults, id: \.self, selection: $searchResult) { result in
            NavigationLink {
#if os(macOS)
                NavigationStack {
                    ServiceView(searchResult: result)
                }
#else
                ServiceView(searchResult: result).navigationTitle(result.name)
#endif
            } label: {
                ServiceRowView(result: result)
            }
            .accessibilityLabel(String(format: String(localized: "service_result_a11y"), result.name, result.grade))
        }
        .navigationTitle(String(localized: "search_title"))
#if os(macOS)
        .listStyle(.sidebar)
#endif
        .overlay {
            if loadingState.status == .error {
                ErrorStateView(
                    title: "Search Error",
                    message: loadingState.message ?? String(localized: "search_error"),
                    retryAction: loadingState.retryAction ?? { runSearch() }
                )
            } else if searchResults.isEmpty && loadingState.status != .loading {
                EmptyStateView(
                    title: "No Results",
                    message: String(localized: "no_results_found"),
                    systemImage: "magnifyingglass"
                )
            }
        }
    }
    
    // MARK: - Helper Methods
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

// MARK: - Supporting Views

struct ServiceRowView: View {
    let result: SearchResult
    
    var body: some View {
        HStack(spacing: 12) {
            // Service icon
            CachedAsyncImage(
                url: URL(string: result.icon),
                content: { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                },
                placeholder: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "display")
                                .foregroundStyle(.secondary)
                        )
                }
            )
            
            // Service info
            VStack(alignment: .leading, spacing: 4) {
                Text(result.name)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                
                Text("Grade: \(result.grade)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Grade badge
            Text(result.grade)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(getColorForRating(rating: result.grade))
                .clipShape(Capsule())
        }
        .padding(.vertical, 4)
    }
}

struct ErrorStateView: View {
    let title: String
    let message: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundStyle(.red)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button("Retry", action: retryAction)
                .buttonStyle(.borderedProminent)
        }
        .padding(32)
        .frame(maxWidth: 300)
    }
}

struct EmptyStateView: View {
    let title: String
    let message: String
    let systemImage: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.system(size: 50))
                .foregroundStyle(.secondary)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(32)
        .frame(maxWidth: 300)
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

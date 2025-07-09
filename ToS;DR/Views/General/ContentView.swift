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
    @Environment(\.openURL) var openURL
    @Environment(\.modelContext) private var modelContext
    
    let logger = Logger()
    
//    let featured = getFeaturedServices()
    
    var body: some View {
        NavigationView {
            VStack {
                if (searchResults.isEmpty && (UserDefaults.standard.bool(forKey: "server-search") || searchText == "")) {
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
#if os(macOS)
                                    .padding(.vertical, 4)
#endif
                            }
                            NavigationLink {
                                TeamView()
                            } label: {
                                Label(String(localized: "label_team"), systemImage: "person.2")
#if os(macOS)
                                    .padding(.vertical, 4)
#endif
                            }
                            NavigationLink {
                                SettingsView()
                            } label: {
                                Label(String(localized: "label_settings"), systemImage: "gear")
#if os(macOS)
                                    .padding(.vertical, 4)
#endif
                            }
                            NavigationLink {
                                DonateView()
                            } label: {
                                Label(String(localized: "label_donate"), systemImage: "dollarsign")
#if os(macOS)
                                    .padding(.vertical, 4)
#endif
                            }
                        }
                    }
                    .navigationTitle("ToS;DR")
#if os(macOS)
                    .listStyle(.insetGrouped)
                    .padding(.horizontal)
#endif
                    .refreshable {
                        logger.info("Refreshing local database")
                        if (await updateDB(context: modelContext).value) {
                            logger.info("Refreshed local database")
                        } else {
                            logger.error("Failed to refresh local database")
                        }
                    }
                    
                } else {
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
                                Text(result.name)
                            } icon: {
                                CachedAsyncImage(
                                    url: URL(string: result.icon),
                                    content: { image in
                                        image.resizable()
                                            .aspectRatio(contentMode: .fit)
                                    },
                                    placeholder: {
                                        Image(systemName: "display")
                                    }
                                )
                            }
                        }
#if os(macOS)
                        .padding(.vertical, 2)
#endif
                    }
                    .navigationTitle(String(localized: "search_title"))
#if os(macOS)
                    .listStyle(.insetGrouped)
                    .padding(.horizontal)
#else
                    .listStyle(.sidebar)
#endif
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
                })
            }
            
#endif
        }
        .onChange(of: searchText, initial: false) { _, query in
            if (UserDefaults.standard.bool(forKey: "server-search")) {
                checkClear()
            } else {
                runSearch()
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
        searchTask?.cancel()
        searchTask = Task {
            searchResults = await search() ?? []
        }
    }
    
    func checkClear() {
        if searchText.isEmpty {
            searchResults = []
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
}

#Preview {
    ContentView()
}

struct PlaceholderView: View {
    var body: some View {
        Text("Placeholder")
    }
}

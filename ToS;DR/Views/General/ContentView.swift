//
//  ContentView.swift
//  ToS;DR
//
//  Created by Erik on 01.11.23.
//

import SwiftUI
import OSLog
import CachedAsyncImage

struct ContentView: View {
    @State private var searchText = ""
    @State private var searchResult: SearchResult?
    @State var searchTask: Task<(), Error>?
    @Environment(\.openURL) var openURL
    
    let logger = Logger()
    
    let featured = getFeaturedServices()
    
    var body: some View {
        NavigationView {
            VStack {
                if (searchResults.isEmpty && (UserDefaults.standard.bool(forKey: "server-search") || searchText == "")) {
                    List {
#if os(macOS)
                        if (!featured.isEmpty) {
                            Section("Featured") {
                                ForEach(featured, id: \.self) { feature in
                                    NavigationLink {
#if os(macOS)
                                        NavigationStack {
                                            ServiceView(searchResult: feature)
                                        }
#else
                                        ServiceView(searchResult: featured).navigationTitle(featured.name)
#endif
                                    } label: {
                                        Label {
                                            Text(feature.name)
                                        } icon: {
                                            CachedAsyncImage(
                                                url: URL(string: feature.icon),
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
                                    
                                }
                            }
                        }
#endif
                        Section("About") {
                            NavigationLink {
#if os(macOS)
                                NavigationStack {
                                    AboutView()
                                }
#else
                                AboutView()
#endif
                            } label: {
                                Label("About", systemImage: "person")
                            }
                            /*Button {
                                openURL(URL(string: "https://tosdr.org/en/about")!)
                            } label: {
                                Label {
                                    Text("Team")
                                    Spacer()
                                    Image(systemName: "globe")
                                        .foregroundStyle(.secondary)
                                } icon: {
                                    Image(systemName: "person.2")
                                }
                            }
#if os(macOS)
                            .buttonStyle(.plain)
#endif
                            .contentShape(Rectangle())*/
                            NavigationLink {
                                SettingsView()
                            } label: {
                                Label("Settings", systemImage: "gear")
                            }
                            NavigationLink {
                                DonateView()
                            } label: {
                                Label("Donate", systemImage: "dollarsign")
                            }
                        }
                    }
                    .navigationTitle("ToS;DR")
#if os(macOS)
                    .listStyle(.sidebar)
#endif
                    .refreshable {
                        logger.info("Refreshing local database")
                        if (await updateDB().value) {
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
                    }
                    .navigationTitle("Search")
                    .listStyle(.sidebar)
                }
            }
#if os(iOS)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search ToS;DR")
#elseif os(macOS)
            .searchable(text: $searchText, placement: .toolbar, prompt: "Search ToS;DR")
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
        .onChange(of: searchText) {query in
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
            let result = await SearchInDB(name: searchText)
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

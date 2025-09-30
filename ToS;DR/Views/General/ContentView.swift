//
//  ContentView.swift
//  ToS;DR
//
//  Created by Erik on 01.11.23.
//

import SwiftUI
import CachedAsyncImage
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = ContentViewModel()
    @State private var showRefreshError = false

    var body: some View {
        NavigationView {
            mainContent
                .navigationTitle("ToS;DR")
                .refreshable {
                    let success = await viewModel.refreshDatabase(using: modelContext)
                    showRefreshError = !success && viewModel.refreshError != nil
                }
                .alert(isPresented: $showRefreshError) {
                    Alert(
                        title: Text(String(localized: "settings_error_title")),
                        message: Text(viewModel.refreshError ?? String(localized: "settings_error_db_update")),
                        dismissButton: .default(Text(String(localized: "ok")))
                    )
                }
#if os(iOS)
                .searchable(
                    text: $viewModel.searchText,
                    placement: .toolbar,
                    prompt: String(localized: "search_prompt")
                )
#elseif os(macOS)
                .searchable(
                    text: $viewModel.searchText,
                    placement: .toolbar,
                    prompt: String(localized: "search_prompt")
                )
#endif
                .onSubmit(of: .search) {
                    viewModel.submitSearch(with: modelContext)
                }
                .onChange(of: viewModel.searchText, initial: false) { _, _ in
                    viewModel.handleSearchTextChange(using: modelContext)
                }
#if os(macOS)
            NavigationStack {
                AboutView()
            }
#endif
        }
#if os(macOS)
        .frame(minWidth: 700)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: toggleSidebar) {
                    Image(systemName: "sidebar.left")
                }
            }
        }
#endif
    }

#if os(macOS)
    private var mainContent: some View {
        Group {
            if viewModel.shouldShowDefaultContent {
                defaultSections
            } else {
                searchResultsSection
            }
        }
    }

    private var searchResultsSection: some View {
        List(viewModel.searchResults, id: \.id) { result in
            NavigationLink {
                NavigationStack { ServiceView(searchResult: result) }
            } label: {
                SearchResultRow(result: result)
            }
        }
        .frame(minWidth: 200, maxWidth: 400)
        .listStyle(.sidebar)
    }

    private var defaultSections: some View {
        List {
            Section(String(localized: "about_section")) {
                NavigationLink {
                    NavigationStack { AboutView() }
                } label: {
                    Label(String(localized: "label_about"), systemImage: "person")
                }
                NavigationLink {
                    NavigationStack { TeamView() }
                } label: {
                    Label(String(localized: "label_team"), systemImage: "person.2")
                }
                NavigationLink {
                    NavigationStack { SettingsView() }
                } label: {
                    Label(String(localized: "label_settings"), systemImage: "gear")
                }
                NavigationLink {
                    NavigationStack { DonateView() }
                } label: {
                    Label(String(localized: "label_donate"), systemImage: "dollarsign")
                }
            }
        }
        .frame(minWidth: 100, maxWidth: 300)
        .listStyle(.sidebar)
    }
#else
    private var mainContent: some View {
        GroupedList {
            if viewModel.shouldShowDefaultContent {
                defaultSections
            } else {
                searchResultsSection
            }
        }
    }

    private var searchResultsSection: some View {
        GroupedListSection {
            Text(String(localized: "search_title"))
        } content: {
            ForEach(Array(viewModel.searchResults.enumerated()), id: \.element.id) { index, result in
                GroupedListNavigationLink(
                    content: {
                        SearchResultRow(result: result)
                    },
                    destination: {
                        ServiceView(searchResult: result)
                    },
                    isFirst: index == 0,
                    isLast: index == viewModel.searchResults.count - 1
                )
            }
        }
    }

    private var defaultSections: some View {
        GroupedListSection {
            Text(String(localized: "about_section"))
        } content: {
            GroupedListNavigationLink(
                icon: { Image(systemName: "person") },
                content: { Text(String(localized: "label_about")) },
                destination: { AboutView() },
                isFirst: true
            )
            GroupedListNavigationLink(
                icon: { Image(systemName: "person.2") },
                content: { Text(String(localized: "label_team")) },
                destination: { TeamView() }
            )
            GroupedListNavigationLink(
                icon: { Image(systemName: "gear") },
                content: { Text(String(localized: "label_settings")) },
                destination: { SettingsView() }
            )
            GroupedListNavigationLink(
                icon: { Image(systemName: "dollarsign") },
                content: { Text(String(localized: "label_donate")) },
                destination: { DonateView() },
                isLast: true
            )
        }
    }
#endif

    private func toggleSidebar() {
#if os(macOS)
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
#endif
    }

}

private struct SearchResultRow: View {
    let result: SearchResult

    var body: some View {
        HStack(spacing: 16) {
            CachedAsyncImage(
                url: URL(string: result.icon),
                content: { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .cornerRadius(8)
                },
                placeholder: {
                    Image(systemName: "display")
                        .frame(width: 40, height: 40)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(result.name)
                    .font(.headline)
                HStack {
                    Text("Grade \(result.grade)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if result.reviewed {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                }
            }

            Spacer()
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ContentView()
}

import Foundation
import OSLog
import SwiftData

@MainActor
final class ContentViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published private(set) var searchResults: [SearchResult] = []
    @Published private(set) var isRefreshing: Bool = false
    @Published private(set) var refreshError: String?

    private var searchTask: Task<Void, Never>?
    private let logger = Logger()
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var isServerSearchEnabled: Bool {
        defaults.bool(forKey: "server-search")
    }

    var shouldShowDefaultContent: Bool {
        searchResults.isEmpty && (isServerSearchEnabled || searchText.isEmpty)
    }

    func submitSearch(with context: ModelContext) {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            searchResults = []
            return
        }

        searchTask?.cancel()
        let query = searchText

        searchTask = Task { [weak self] in
            guard let self else { return }
            await self.performSearch(query: query, context: context)
        }
    }

    func handleSearchTextChange(using context: ModelContext) {
        if isServerSearchEnabled {
            guard !searchText.isEmpty else {
                searchResults = []
                return
            }
        } else {
            submitSearch(with: context)
        }
    }

    func cancelSearch() {
        searchTask?.cancel()
        searchTask = nil
    }

    func refreshDatabase(using context: ModelContext) async -> Bool {
        isRefreshing = true
        refreshError = nil
        defer { isRefreshing = false }

        logger.info("Refreshing local database")
        let response = await updateDB(context: context)

        if response.value {
            logger.info("Refreshed local database")
            return true
        } else {
            refreshError = response.error
            logger.error("Failed to refresh local database")
            return false
        }
    }

    private func performSearch(query: String, context: ModelContext) async {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            searchResults = []
            return
        }

        logger.debug("Searching for \(trimmedQuery)")

        if isServerSearchEnabled {
            let result = await SearchByName(name: trimmedQuery)
            guard !Task.isCancelled else { return }
            searchResults = result.response ?? []
        } else {
            let result = await SearchInDB(name: trimmedQuery, context: context)
            guard !Task.isCancelled else { return }
            searchResults = result.response ?? []
        }
    }
}

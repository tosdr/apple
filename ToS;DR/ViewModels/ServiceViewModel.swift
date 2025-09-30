import Foundation

@MainActor
final class ServiceViewModel: ObservableObject {
    @Published private(set) var serviceInfo: ToSDR?
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    @Published var showLocalizedTitles: Bool = true

    let selectedResult: SearchResult?

    init(searchResult: SearchResult?) {
        self.selectedResult = searchResult
    }

    var hasSelection: Bool {
        selectedResult != nil
    }

    func loadService(force: Bool = false) async {
        guard let selectedResult, !isLoading else { return }
        if serviceInfo != nil && !force { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        let service = await GetServicePageById(service: selectedResult.id)
        if service.error {
            errorMessage = service.message ?? "Unknown error"
        } else {
            serviceInfo = service.response
        }
    }

    var hasLocalizedTitles: Bool {
        guard let serviceInfo else { return false }
        return serviceInfo.points.values.flatMap { $0 }.contains { $0.localizedTitle != nil }
    }

    func resetError() {
        errorMessage = nil
    }

    func refresh() async {
        serviceInfo = nil
        await loadService(force: true)
    }
}

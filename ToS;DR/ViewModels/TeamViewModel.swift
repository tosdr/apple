import Foundation

@MainActor
final class TeamViewModel: ObservableObject {
    @Published private(set) var team: Team?
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?

    func loadTeam() async {
        guard !isLoading else { return }
        if team != nil { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        if let team = await GetTeam() {
            self.team = team
        } else {
            errorMessage = "Failed to load team"
        }
    }

    func refresh() async {
        team = nil
        await loadTeam()
    }
}

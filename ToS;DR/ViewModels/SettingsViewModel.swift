import Foundation
import SwiftData

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var serverSelected: String
    @Published var customServer: String
    @Published var serverSearch: Bool
    @Published private(set) var lastPull: String?
    @Published private(set) var serviceCount: Int?
    @Published private(set) var isUpdating: Bool = false
    @Published private(set) var updateError: String?

    let servers = ["api.tosdr.org", "api.staging.tosdr.org", "Custom"]

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.serverSelected = defaults.string(forKey: "server") ?? "api.tosdr.org"
        self.customServer = defaults.string(forKey: "serverUrl") ?? ""
        self.serverSearch = defaults.bool(forKey: "server-search")
        self.lastPull = defaults.string(forKey: "lastPull")
        self.serviceCount = getDBCount()
    }

    func updateServerSearch(_ newValue: Bool) {
        serverSearch = newValue
        defaults.set(newValue, forKey: "server-search")
    }

    func updateServerSelection(_ newSelection: String) {
        serverSelected = newSelection
        defaults.set(newSelection, forKey: "server")
        if newSelection != "Custom" {
            customServer = ""
            defaults.removeObject(forKey: "serverUrl")
        }
    }

    func updateCustomServer(_ value: String) {
        customServer = value
        defaults.set(value, forKey: "serverUrl")
    }

    func refreshDatabase(context: ModelContext) async -> Bool {
        isUpdating = true
        updateError = nil
        defer { isUpdating = false }

        let response = await updateDB(context: context)
        if response.value {
            lastPull = defaults.string(forKey: "lastPull")
            serviceCount = getDBCount()
            return true
        } else {
            updateError = response.error
            return false
        }
    }

    func deleteDatabase(context: ModelContext) -> Bool {
        if deleteDB(context: context) {
            serviceCount = getDBCount()
            lastPull = defaults.string(forKey: "lastPull")
            return true
        }
        return false
    }

    func resetOnboarding() {
        defaults.setValue(true, forKey: "firstStart")
    }
}

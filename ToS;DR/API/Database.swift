import Foundation
import SwiftData

struct DBResponse {
    let value: Bool
    let error: String?
}

struct AppDBResponse: Codable {
    let id: Int
    let name: String
    let url: String
    let rating: String
}

@MainActor
func updateDB(context: ModelContext) async -> DBResponse {
    do {
        let url = URL(string: "https://\(getServiceURL())/appdb/version/v2")!
        var request = URLRequest(url: url)
        request.setValue("congrats on getting the key :P", forHTTPHeaderField: "apikey")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            return DBResponse(value: false, error: "Invalid response type")
        }
        
        guard httpResponse.statusCode == 200 else {
            return DBResponse(value: false, error: "HTTP Error: \(httpResponse.statusCode)")
        }
        
        let services = try JSONDecoder().decode([AppDBResponse].self, from: data)
        
        // Delete existing database
        try context.delete(model: ServiceModel.self)
        
        // Insert new services
        for service in services {
            let newService = ServiceModel(
                id: service.id,
                name: service.name,
                urls: service.url,
                rating: service.rating
            )
            context.insert(newService)
        }
        
        // Save current date
        UserDefaults.standard.set(
            DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none),
            forKey: "lastPull"
        )
        
        try context.save()
        return DBResponse(value: true, error: nil)
        
    } catch {
        return DBResponse(value: false, error: error.localizedDescription)
    }
}

@MainActor
func getDBCount() -> Int? {
    do {
        let descriptor = FetchDescriptor<ServiceModel>()
        let context = try ModelContext(ModelContainer(for: ServiceModel.self))
        let count = try context.fetchCount(descriptor)
        return count
    } catch {
        return nil
    }
}

@MainActor
func deleteDB(context: ModelContext) -> Bool {
    do {
        try context.delete(model: ServiceModel.self)
        try context.save()
        UserDefaults.standard.removeObject(forKey: "lastPull")
        return true
    } catch {
        return false
    }
}

@MainActor
func searchDB(term: String, context: ModelContext) -> [ServiceModel] {
    do {
        var descriptor = FetchDescriptor<ServiceModel>()
        descriptor.predicate = #Predicate<ServiceModel> { service in
            service.name.localizedStandardContains(term)
        }
        return try context.fetch(descriptor)
    } catch {
        return []
    }
}

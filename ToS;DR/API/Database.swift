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

private func getAPIKey() -> String {
    return "congrats on getting the key :P"
}

@MainActor
func updateDB(context: ModelContext) async -> DBResponse {
    do {
        guard let url = URL(string: "https://\(getServiceURL())/appdb/version/v2") else {
            return DBResponse(value: false, error: APIErrorType.invalidURL.localizedDescription)
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 30
        
        let apiKey = getAPIKey()
        if !apiKey.isEmpty {
            request.setValue(apiKey, forHTTPHeaderField: "apikey")
        }
        

        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            return DBResponse(value: false, error: APIErrorType.unknown.localizedDescription)
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorMessage = APIError.getErrorMessage(statusCode: httpResponse.statusCode)
            return DBResponse(value: false, error: errorMessage)
        }
        
        let services = try JSONDecoder().decode([AppDBResponse].self, from: data)
        
        try context.transaction {
            do {
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
                
                let formatter = ISO8601DateFormatter()
                UserDefaults.standard.set(
                    formatter.string(from: Date()),
                    forKey: "lastPull"
                )
                
                UserDefaults.standard.set(
                    DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none),
                    forKey: "lastPullDisplay"
                )
            } catch {
                print("Transaction error: \(error.localizedDescription)")
                throw error
            }
        }
        
        return DBResponse(value: true, error: nil)
        
    } catch let decodingError as DecodingError {
        print("Database decoding error: \(decodingError)")
        return DBResponse(value: false, error: APIErrorType.parsingError.localizedDescription)
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

//
//  Search.swift
//  ToS;DR
//
//  Created by Erik on 01.11.23.
//

import Foundation
import SwiftData

// API URL: https://api.tosdr.org/search/v5/
// Parameters:
// query: The search query

struct ResponseSearch {
    let error: Bool
    let message: String?
    let response: [SearchResult]?
}

struct SearchResult: Hashable {
    let name: String
    let id: Int
    let icon: String
    let grade: String
    let reviewed: Bool
}


struct SearchResponse: Codable {
    struct Service: Codable {
        let id: Int
        let name: String
        let is_comprehensively_reviewed: Bool
        let urls: [String]
        let rating: String
        let updated_at: String
        let created_at: String
        let slug: String?
    }
    
    let services: [Service]
}

@MainActor
func SearchInDB(name: String, context: ModelContext) async -> ResponseSearch {
    let search = searchDB(term: name, context: context)
    
    var results = [SearchResult]()
    
    for searchResult in search {
        results.append(SearchResult(name: searchResult.name, id: searchResult.id, icon: "https://s3.tosdr.org/logos/\(searchResult.id).png", grade: searchResult.rating, reviewed: true))
    }
    
    return ResponseSearch(error: false, message: nil, response: results)
}

func SearchByName(name: String) async -> ResponseSearch {
    do {
        guard let encodedQuery = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return ResponseSearch(error: true, message: "Invalid search query", response: nil)
        }
        
        let url = URL(string: "https://\(getServiceURL())/search/v5/?query=\(encodedQuery)")!
        
        let timeoutInterval: TimeInterval = 10
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeoutInterval
        configuration.timeoutIntervalForResource = timeoutInterval
        
        let session = URLSession(configuration: configuration)
        
        // Fetch data and handle HTTP response
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            return ResponseSearch(error: true, message: "Invalid response type", response: nil)
        }
        
        guard httpResponse.statusCode == 200 else {
            print("HTTP Error: \(httpResponse.statusCode)")
            return ResponseSearch(error: true, message: "HTTP Error: \(httpResponse.statusCode)", response: nil)
        }
        
        // Decode the services array
        let decoder = JSONDecoder()
        let serviceResponse = try decoder.decode(SearchResponse.self, from: data)
        
        // Map to SearchResult objects
        let results = serviceResponse.services.map { service in
            SearchResult(
                name: service.name,
                id: service.id,
                icon: "https://s3.tosdr.org/logos/\(service.id).png",
                grade: service.rating,
                reviewed: service.is_comprehensively_reviewed
            )
        }
        
        return ResponseSearch(error: false, message: nil, response: results)
        
    } catch let decodingError as DecodingError {
        print("Decoding error: \(decodingError)")
        return ResponseSearch(error: true, message: "Parsing error: \(decodingError.localizedDescription)", response: nil)
    } catch {
        print("General error: \(error)")
        return ResponseSearch(error: true, message: error.localizedDescription, response: nil)
    }
}

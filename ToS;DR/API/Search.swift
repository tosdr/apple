//
//  Search.swift
//  ToS;DR
//
//  Created by Erik on 01.11.23.
//

import Foundation
import SwiftyJSON

// API URL: https://api.tosdr.org/search/v4/
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

func SearchInDB(name: String) async -> ResponseSearch {
    let search = searchDB(term: name)
    
    var results = [SearchResult]()
    
    for searchResult in search {
        results.append(SearchResult(name: searchResult.name, id: searchResult.id, icon: "https://s3.tosdr.org/logos/\(searchResult.id).png", grade: searchResult.rating, reviewed: true))
    }
    
    return ResponseSearch(error: false, message: nil, response: results)
}

func SearchByName(name: String) async -> ResponseSearch {
    do {
        let url = URL(string: "https://\(getServiceURL())/search/v4/?query=\(name)")!
        let timeoutInterval: TimeInterval = 10
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeoutInterval
        configuration.timeoutIntervalForResource = timeoutInterval
        
        let session = URLSession(configuration: configuration)
        
        let data = try await session.data(from: url)
        let json = try JSON(data: data.0)
        
        let error = json["error"].intValue
        
        if (error != 256) {
            print("Error: \(error)")
            return ResponseSearch(error: true, message: json["message"].stringValue, response: nil)
        }
        
        let response = json["parameters"]
        
        var results = [SearchResult]()
        
        for result in response["services"].arrayValue {
            let name = result["name"].stringValue
            let id = result["id"].intValue
            let icon = "https://s3.tosdr.org/logos/\(id).png"
            let grade = result["rating"]["letter"].stringValue
            let reviewed = result["is_comprehensively_reviewed"].boolValue
            
            results.append(SearchResult(name: name, id: id, icon: icon, grade: grade, reviewed: reviewed))
        }
        
        return ResponseSearch(error: false, message: nil, response: results)
    } catch {
        return ResponseSearch(error: true, message: error.localizedDescription, response: nil)
    }
}

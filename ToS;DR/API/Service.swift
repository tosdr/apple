//
//  Service.swift
//  ToS;DR
//
//  Created by Erik on 01.11.23.
//

import Foundation
import SwiftUI

// API URL: https://api.tosdr.org/service/v2/
// Parameters:
// id: The service ID
// page: (optional) The page number of the results

struct Response {
    let error: Bool
    let message: String?
    let response: ToSDR?
}

struct ToSDR {
    let name: String
    let id: Int
    let icon: String
    let grade: String
    var points: Dictionary<String, [Point]>
    let reviewed: Bool
    let urls: [String]
}

struct Point: Hashable {
    var localizedTitle: String?
    var title: String
    var tlDr: String
    var description: String
    let quote: String
    let type: String
    let links: String
}

struct ServiceResponse: Codable {
    let id: Int
    let is_comprehensively_reviewed: Bool
    let name: String
    let updated_at: String
    let created_at: String
    let slug: String
    let rating: String
    let urls: [String]
    let image: String
    let documents: [Document]
    let points: [Point]
    
    struct Document: Codable {
        let id: Int
        let name: String
        let url: String
        let updated_at: String
        let created_at: String
    }
    
    struct Point: Codable {
        let id: Int
        let title: String?
        let source: String?
        let status: String?
        let analysis: String?
        let case_info: Case?
        let document_id: Int?
        let updated_at: String
        let created_at: String
        
        struct Case: Codable {
            let id: Int
            let weight: Int
            let title: String?
            let localized_title: String?
            let description: String?
            let updated_at: String
            let created_at: String
            let topic_id: Int
            let classification: String
            
            enum CodingKeys: String, CodingKey {
                case id, weight, title, localized_title, description
                case updated_at, created_at, topic_id, classification
            }
        }
        
        enum CodingKeys: String, CodingKey {
            case id, title, source, status, analysis
            case case_info = "case"
            case document_id, updated_at, created_at
        }
    }
}

func GetServicePageById(service: Int) async -> Response {
    do {
        // Get current locale and extract language code
        let languageCode = Locale.current.language.languageCode?.identifier ?? ""
        
        // Base URL
        var urlString = "https://\(getServiceURL())/service/v3/?id=\(service)"
        
        // Add language parameter for supported languages
        switch languageCode {
        case "de", "nl", "fr", "es":
            urlString += "&lang=\(languageCode)"
        default:
            break
        }
        
        let url = URL(string: urlString)!
        let timeoutInterval: TimeInterval = 10
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeoutInterval
        configuration.timeoutIntervalForResource = timeoutInterval
        
        let session = URLSession(configuration: configuration)
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            return Response(error: true, message: "Invalid response type", response: nil)
        }
        
        guard httpResponse.statusCode == 200 else {
            return Response(error: true, message: "HTTP Error: \(httpResponse.statusCode)", response: nil)
        }
        
        let serviceResponse = try JSONDecoder().decode(ServiceResponse.self, from: data)
        
        // Convert API points to our Point model
        var points: [Point] = []
        for point in serviceResponse.points {
            guard let status = point.status, status == "approved" else { continue }
            
            let title = point.case_info?.title.flatMap { $0.isEmpty || $0 == "none" ? nil : $0 }
                ?? point.title
                ?? "Unknown Title"
                
            points.append(Point(
                localizedTitle: point.case_info?.localized_title,
                title: title,
                tlDr: point.analysis ?? "",
                description: point.case_info?.description ?? "",
                quote: point.source ?? "",
                type: point.case_info?.classification ?? "unknown",
                links: String(point.id)
            ))
        }
        
        let dict = Dictionary(grouping: points, by: { $0.type })
        
        let tosdr = ToSDR(
            name: serviceResponse.name,
            id: serviceResponse.id,
            icon: serviceResponse.image,
            grade: serviceResponse.rating,
            points: dict,
            reviewed: serviceResponse.is_comprehensively_reviewed,
            urls: serviceResponse.urls
        )
        
        return Response(error: false, message: nil, response: tosdr)
        
    } catch let decodingError as DecodingError {
        print("Decoding error: \(decodingError)")
        return Response(error: true, message: "Failed to parse response: \(decodingError.localizedDescription)", response: nil)
    } catch {
        return Response(error: true, message: error.localizedDescription, response: nil)
    }
}

func getColorForRating(rating: String) -> Color {
    var hexcode = ""
    switch(rating) {
    case "A": hexcode = "408558"
    case "B": hexcode = "87b55f"
    case "C": hexcode = "#f5c344"
    case "D": hexcode = "c9753d"
    case "E": hexcode = "cb444b"
    default:  hexcode = "222529"
    }
    return Color.init(hex: hexcode)
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

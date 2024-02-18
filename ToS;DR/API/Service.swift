//
//  Service.swift
//  ToS;DR
//
//  Created by Erik on 01.11.23.
//

import Foundation
import SwiftUI
import SwiftyJSON

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
    var title: String
    var tlDr: String
    var description: String
    let quote: String
    let type: String
    let links: String
    var translated: Bool = false
}



func GetServicePageById(service: Int) async -> Response {
    do {
        let url = URL(string: "https://\(getServiceURL())/service/v2/?id=\(service)")!
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
            return Response(error: true, message: json["message"].stringValue, response: nil)
        }
        
        let response = json["parameters"]
        
        let name = response["name"].stringValue
        let id = response["id"].intValue
        let icon = response["image"].stringValue
        var grade = response["rating"].stringValue
        let reviewed = response["is_comprehensively_reviewed"].boolValue
        let urls = response["urls"].arrayValue.map { $0.stringValue }
        
        if (grade == "") {
            grade = "N/A"
        }
        
        
        var points: [Point] = []
        for point in response["points"].arrayValue {
            if (point["status"] != "approved") {
                continue
            }
            var title = point["case"]["title"].stringValue
            if (title == "" || title == "none") {
                title = point["title"].stringValue
            }
            let tlDr = point["analysis"].stringValue
            let description = point["case"]["description"].stringValue
            let quote = point["source"].stringValue
            let type = point["case"]["classification"].stringValue
            let links = point["id"].stringValue
            
            points.append(Point(title: title, tlDr: tlDr, description: description, quote: quote, type: type, links: links))
        }
        
        let dict = Dictionary<String, [Point]>(grouping: points, by: {$0.type})
        
        let tosdr = ToSDR(name: name, id: id, icon: icon, grade: grade, points: dict, reviewed: reviewed, urls: urls)
        
        return Response(error: false, message: nil, response: tosdr)
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

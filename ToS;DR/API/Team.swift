//
//  Team.swift
//  ToS;DR
//
//  Created by Erik on 16/1/25.
//

import Foundation

struct TeamMemberLinks: Codable {
    let email: String?
    let github: String?
    let twitter: String?
    let website: String?
    let mastodon: String?
}

struct TeamMember: Codable {
    let photo: String
    let name: String
    let title: String
    let description: String
    let links: TeamMemberLinks
}

struct Team: Codable {
    let founders: [TeamMember]
    let current: [TeamMember]
    let past: [TeamMember]
}

func GetTeam() async -> Team? {
    do {
        let url = URL(string: "https://tosdr.org/api/teams")!
        let timeoutInterval: TimeInterval = 10
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeoutInterval
        configuration.timeoutIntervalForResource = timeoutInterval
        
        let session = URLSession(configuration: configuration)
        
        let (data, _) = try await session.data(from: url)
        let decoder = JSONDecoder()
        let team = try decoder.decode(Team.self, from: data)
        
        return team
    } catch {
        print("Error fetching team data: \(error)")
        return nil
    }
}


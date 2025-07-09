//
//  ServiceModel.swift
//  ToS;DR
//
//  Created by Erik on 22/1/25.
//


import Foundation
import SwiftData

@Model
final class ServiceModel {
    var id: Int
    var name: String
    var urls: String
    var rating: String
    
    init(id: Int, name: String, urls: String, rating: String) {
        self.id = id
        self.name = name
        self.urls = urls
        self.rating = rating
    }
} 

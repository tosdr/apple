//
//  GetServerURL.swift
//  ToS;DR
//
//  Created by Erik on 16.11.23.
//

import Foundation

func getServiceURL() -> String {
    let defaults = UserDefaults.standard
    let server = defaults.string(forKey: "server") ?? "api.tosdr.org"
    let customServer = defaults.string(forKey: "customServer") ?? ""
    
    if (server == "Custom") {
        if (customServer == "") {
            return "api.tosdr.org"
        }
        return customServer
    } else {
        return server
    }
}

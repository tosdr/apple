//
//  Database.swift
//  ToS;DR
//
//  Created by Erik on 06.11.23.
//

import Foundation
import CryptoKit
import SwiftyJSON
import ZIPFoundation
import SQLite

struct appdbParameters {
    let version: String
    let signed_url: String
    let last_modified: String
}

struct ResponseDB {
    let value: Bool
    let error: Bool
    let message: String?
}

struct Database {
    let id: Int
    let name: String
    let rating: String
    let url: [String]
}

private func generateSHA512Checksum(filePath: String) -> String? {
    do {
        let fileData = try Data(contentsOf: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(filePath))
        let checksum = SHA512.hash(data: fileData)
        return checksum.map { String(format: "%02hhx", $0) }.joined()
    } catch {
        print("Error reading file:", error.localizedDescription)
        return nil
    }
}

//MARK: DB Updating/Validation

func checkIfValid() async -> ResponseDB {
    do {
        // check our locally saved db.json checksum
        let sha = generateSHA512Checksum(filePath: "tosdr/db.json")
        if sha == nil {
            // we couldnt get the md5 sum, so we assume its not valid/missing
            return ResponseDB(value: false, error: false, message: nil)
        }
        
        // check the md5 sum against the one in appdb
        let url = URL(string: "https://\(getServiceURL())/appdb/version/v1")!
        let timeoutInterval: TimeInterval = 10
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeoutInterval
        configuration.timeoutIntervalForResource = timeoutInterval
        
        let session = URLSession(configuration: configuration)
        
        let data = try await session.data(from: url)
        let json = try JSON(data: data.0)
        
        let version = json["parameters"]["version"].stringValue
        
        return ResponseDB(value: sha == version, error: false, message: nil)
        
    } catch {
        return ResponseDB(value: false, error: true, message: error.localizedDescription)
    }
}

func updateDB() async -> ResponseDB {
    do {
        
        let url = URL(string: "https://\(getServiceURL())/appdb/version/v1")!
        
        let timeoutInterval: TimeInterval = 10
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeoutInterval
        configuration.timeoutIntervalForResource = timeoutInterval
        
        let session = URLSession(configuration: configuration)
        
        let data = try await session.data(from: url)
        let json = try JSON(data: data.0)
        
        let error = json["error"].intValue
        if error != 256 {
            return ResponseDB(value: false, error: true, message: json["message"].stringValue)
        }
        
        let version = json["parameters"]["version"].stringValue
        let download = json["parameters"]["signed_url"].stringValue
        
        // download the zip
        let zipUrl = URL(string: download)!
        let zipData = try Data(contentsOf: zipUrl)
        
        // save the zip
        let zipPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("db.zip")
        
        print(zipPath)
        
        try zipData.write(to: zipPath)
        
        // delete the old db.json
        if (deleteDB()) {
            print("Deleted old db.json")
        }
        
        // unzip the zip
        let unzipPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        try FileManager.default.unzipItem(at: zipPath, to: unzipPath)
        
        // delete the zip
        try FileManager.default.removeItem(at: zipPath)
        
        // check the md5 sum
        let sha = generateSHA512Checksum(filePath: "tosdr/db.json")
        if sha == nil {
            // we couldnt get the md5 sum, so we assume its not valid/missing
            return ResponseDB(value: false, error: false, message: nil)
        }
        
        let defaults = UserDefaults.standard
        defaults.set(json["parameters"]["last_modified"].stringValue.split(separator: "T")[0], forKey: "lastPull")
        
        return putDBtoSQL()
    } catch {
        print(error.localizedDescription)
        return ResponseDB(value: false, error: true, message: error.localizedDescription)
    }
}

func putDBtoSQL() -> ResponseDB {
    // load the downloaded json and insert it into an sqlite db
    let dbPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("tosdr/db.json")
    let sqlPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("tosdr/db.db")

    do {
        let data = try Data(contentsOf: dbPath)
        let json = try JSON(data: data)
        
        let db = try Connection(sqlPath.path)
        let dbTable = Table("db")
        let urlTable = Table("url")
        
        // drop all existing data
        try db.run(dbTable.drop(ifExists: true))
        try db.run(urlTable.drop(ifExists: true))

        try db.run(dbTable.create(ifNotExists: true) { t in
            t.column(Expression<Int64>("id"), primaryKey: true)
            t.column(Expression<String?>("name"))
            t.column(Expression<String?>("rating"))
        })
        
        try db.run(urlTable.create(ifNotExists: true) { t in
            t.column(Expression<Int64>("id"))
            t.column(Expression<String?>("url"), unique: true)
        })
        
        for (_, value) in json {
            let id = value["id"].intValue
            let name = value["name"].stringValue
            let rating = value["rating"].stringValue
            let urls = value["url"].stringValue.split(separator: ",")
            
            try db.run(dbTable.insert(or: .replace, Expression("id") <- id, Expression("name") <- name, Expression("rating") <- rating))
            for url in urls {
                try db.run(urlTable.insert(or: .replace, Expression("id") <- id, Expression("url") <- String(url)))
            }
            
        }
        
        // delete json
        try FileManager.default.removeItem(at: dbPath)
        
        return ResponseDB(value: true, error: false, message: nil)
    } catch {
        return ResponseDB(value: false, error: true, message: error.localizedDescription)
    }
}

//MARK: DB Operations

func getDBCount() -> Int? {
    do {
        // open sqlite db
        let dbPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("tosdr/db.db")
        let db = try Connection(dbPath.path)
        
        // get count
        let count = try db.scalar("SELECT COUNT(*) FROM db") as! Int64
        
        return Int(count)
    } catch {
        print("Error: \(error)")
        return nil
    }
}

func getDBSize() -> String? {
    var fileSize : UInt64
    
    do {
        var attr:  [FileAttributeKey : Any]? = nil
        if #available(iOS 16.0, *) {
            attr = try FileManager.default.attributesOfItem(atPath: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("tosdr/db.db").path())
        } else {
            attr = try FileManager.default.attributesOfItem(atPath: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("tosdr/db.db").path)
        }
        
        if (attr == nil) {
            return nil
        }
        fileSize = attr![FileAttributeKey.size] as! UInt64
        
        let dict = attr! as NSDictionary
        fileSize = dict.fileSize()
        
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useKB, .useMB] // optional: restricts the units to MB only
        bcf.countStyle = .file
        let string = bcf.string(fromByteCount: Int64(fileSize))
        return string
    } catch {
        print("Error: \(error)")
    }
    return nil
}

func deleteDB() -> Bool {
    do {
        // if file exists
        if FileManager.default.fileExists(atPath: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("tosdr/db.db").path) {
            try FileManager.default.removeItem(at: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("tosdr/db.db"))
        }
        
        // if json exists
        if FileManager.default.fileExists(atPath: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("tosdr/db.json").path) {
            try FileManager.default.removeItem(at: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("tosdr/db.json"))
        }
        return true
    } catch {
        return false
    }
}

func searchDB(term: String) -> [Database] {
    do {
        let sqlPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("tosdr/db.db")
        let db = try Connection(sqlPath.path)
        
        var results: [Database] = []
        
        for row in try db.prepare("SELECT * FROM db WHERE name LIKE '%\(term)%'") {
            let id = row[0] as! Int64
            let name = row[1] as! String
            let rating = row[2] as! String
            
            var urls = [String]()
            for row in try db.prepare("SELECT * FROM url WHERE id = ?") {
                urls.append(row[1] as! String)
            }
            
            results.append(Database(id: Int(id), name: name, rating: rating, url: urls))
        }
        
        return results
    } catch {
        print("Error: \(error)")
        return []
    }
}

func getFeaturedServices() -> [SearchResult] {
    do {
        let data = try Data(contentsOf: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("tosdr/db.json"))
        let json = try JSON(data: data)
        
        var results: [SearchResult] = []
        
        let featuredKeys = [182, 190, 194, 265, 222, 274, 1815, 314, 315, 175, 225, 318, 158]
        
        for (_, value) in json {
            if featuredKeys.contains(value["id"].intValue) {
                results.append(SearchResult(name: value["name"].stringValue, id: value["id"].intValue, icon: "https://s3.tosdr.org/logos/\(value["id"].stringValue).png", grade: value["rating"].stringValue, reviewed: true))
            }
        }
        
        return results
    } catch {
        print("Error: \(error)")
        return []
    }
}

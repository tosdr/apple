import Foundation
import SwiftUI

struct Validators {
    static func isValidURL(_ string: String) -> Bool {
        let urlString = string.lowercased().hasPrefix("http") ? string : "https://" + string
        guard let url = URL(string: urlString) else { return false }
        
        #if os(iOS)
        return UIApplication.shared.canOpenURL(url)
        #elseif os(macOS)
        return NSWorkspace.shared.urlForApplication(toOpen: url) != nil
        #else
        return url.scheme != nil && url.host != nil
        #endif
    }
    
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    static func extractDomain(from urlString: String) -> String? {
        guard let url = URL(string: urlString.lowercased().hasPrefix("http") ? urlString : "https://" + urlString),
              let host = url.host else { return nil }
        
        let domain = host.hasPrefix("www.") ? String(host.dropFirst(4)) : host
        return domain
    }
    
    static func formatURLForDisplay(_ urlString: String) -> String {
        var formatted = urlString
            .replacingOccurrences(of: "https://", with: "")
            .replacingOccurrences(of: "http://", with: "")
        
        if formatted.hasSuffix("/") {
            formatted = String(formatted.dropLast())
        }
        
        return formatted
    }
}

extension Array where Element == String {
    func joinedWithCommas(transform: ((String) -> String)? = nil) -> String {
        if let transform = transform {
            return self.map(transform).joined(separator: ", ")
        } else {
            return self.joined(separator: ", ")
        }
    }
}

extension String {
    func capturedGroups(withRegex pattern: String) -> [String]? {
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let nsString = self as NSString
        guard let match = regex?.firstMatch(in: self, options: [], range: NSRange(location: 0, length: nsString.length)) else { return nil }
        
        var groups = [String]()
        for rangeIndex in 1..<match.numberOfRanges {
            let range = match.range(at: rangeIndex)
            if range.location != NSNotFound {
                groups.append(nsString.substring(with: range))
            }
        }
        return groups
    }
}
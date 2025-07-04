import Foundation

enum APIErrorType: Error {
    case badRequest                // 400
    case unauthorized              // 401
    case forbidden                 // 403
    case notFound                  // 404
    case rateLimited               // 429
    case serverError               // 500
    case badGateway                // 502
    case serviceUnavailable        // 503
    case gatewayTimeout            // 504
    case networkError              // No internet
    case parsingError              // JSON decoding failed
    case invalidURL                // URL construction failed
    case unknown                   // Fallback
    
    var localizedDescription: String {
        switch self {
        case .badRequest:
            return String(localized: "api_error_400")
        case .unauthorized:
            return String(localized: "api_error_401")
        case .forbidden:
            return String(localized: "api_error_403")
        case .notFound:
            return String(localized: "api_error_404")
        case .rateLimited:
            return String(localized: "api_error_429")
        case .serverError:
            return String(localized: "api_error_500")
        case .badGateway:
            return String(localized: "api_error_502")
        case .serviceUnavailable:
            return String(localized: "api_error_503")
        case .gatewayTimeout:
            return String(localized: "api_error_504")
        case .networkError:
            return String(localized: "api_error_network")
        case .parsingError:
            return String(localized: "api_error_parsing")
        case .invalidURL:
            return String(localized: "api_error_invalid_url")
        case .unknown:
            return String(localized: "api_error_unknown")
        }
    }
}

class APIError {
    static func getErrorMessage(statusCode: Int, defaultMessage: String? = nil) -> String {
        return errorTypeFor(statusCode: statusCode).localizedDescription
    }
    
    static func errorTypeFor(statusCode: Int) -> APIErrorType {
        switch statusCode {
        // Client Errors (4xx)
        case 400:
            return .badRequest
        case 401:
            return .unauthorized
        case 403:
            return .forbidden
        case 404:
            return .notFound
        case 429:
            return .rateLimited
        
        // Server Errors (5xx)
        case 500:
            return .serverError
        case 502:
            return .badGateway
        case 503:
            return .serviceUnavailable
        case 504:
            return .gatewayTimeout
            
        default:
            return .unknown
        }
    }
    
    static func isClientError(_ statusCode: Int) -> Bool {
        return statusCode >= 400 && statusCode < 500
    }
    
    static func isServerError(_ statusCode: Int) -> Bool {
        return statusCode >= 500 && statusCode < 600
    }
} 
//
//  NetworkError.swift
//  SevenDaysWeatherApp
//
//  Created by Manyuchi, Carrington C on 2026/08/08.
//

import Foundation

// MARK: - Network Error
enum NetworkError: Error, LocalizedError {
    case invalidResponse
    case invalidURL(path: String)
    case noData
    case cityNotFound
    case noInternetConnection(underlyingError: URLError?)
    case requestTimeout(underlyingError: URLError?)
    case decodingFailed(statusCode: Int, data: Data)
    case serverError(statusCode: Int, message: String?)
    case rateLimited(retryAfter: TimeInterval?)
    case cancelled
    
    // MARK: - Error Description
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
            
        case .invalidURL(let path):
            return "Invalid URL: \(path)"
            
        case .noData:
            return "No data received from server"
            
        case .cityNotFound:
            return "City not found. Please check the spelling and try again."
            
        case .noInternetConnection(let error):
            return "No internet connection: \(error?.localizedDescription ?? "unknown network error")"
            
        case .requestTimeout(let error):
            return "Request timed out: \(error?.localizedDescription ?? "Timeout occurred")"
            
        case .decodingFailed(let statusCode, let data):
            let message = String(data: data, encoding: .utf8) ?? "Unable to parse response"
            return "Failed to decode response (Status \(statusCode)): \(message)"
            
        case .serverError(let statusCode, let message):
            return "Server error \(statusCode): \(message ?? "Unknown server error")"
            
        case .rateLimited(let retryAfter):
            if let retryAfter = retryAfter {
                return "Rate limited. Please retry after \(Int(retryAfter)) seconds"
            }
            return "Rate limited. Please try again later"
            
        case .cancelled:
            return "Request was cancelled"
        }
    }
    
    // MARK: - Recovery Suggestion
    var recoverySuggestion: String? {
        switch self {
        case .noInternetConnection:
            return "Please check your network connection and try again"
            
        case .requestTimeout:
            return "The request took too long. Please try again"
            
        case .rateLimited:
            return "Too many requests. Please wait a moment"
            
        case .serverError(500, _):
            return "Server error. Please try again later"
            
        case .cityNotFound:
            return "Try searching for a different city"
            
        case .noData:
            return "The server returned an empty response. Please try again"
            
        default:
            return nil
        }
    }
    
    // MARK: - Retry Logic
    var isRetryable: Bool {
        switch self {
        case .noInternetConnection, .requestTimeout, .rateLimited:
            return true
            
        case .serverError(let statusCode, _):
            // Retry on 5xx server errors, not on 4xx client errors
            return statusCode >= 500 && statusCode <= 599
            
        case .cancelled, .invalidResponse, .decodingFailed, .invalidURL, .noData, .cityNotFound:
            return false
        }
    }
    
    // MARK: - User-Friendly Message
    var userFriendlyMessage: String {
        switch self {
        case .noInternetConnection:
            return "📡 No Internet Connection"
            
        case .requestTimeout:
            return "⏱️ Request Timed Out"
            
        case .rateLimited:
            return "🐌 Too Many Requests"
            
        case .cityNotFound:
            return "📍 City Not Found"
            
        case .serverError(404, _):
            return "🔍 Resource Not Found"
            
        case .serverError(401, _):
            return "🔒 Authentication Required"
            
        case .serverError(403, _):
            return "🚫 Access Denied"
            
        case .decodingFailed:
            return "📊 Data Parsing Error"
            
        default:
            return "⚠️ Something Went Wrong"
        }
    }
}

// MARK: - Convenience Initializers
extension NetworkError {
    static func from(statusCode: Int, data: Data) -> NetworkError {
        let message = String(data: data, encoding: .utf8)
        
        switch statusCode {
        case 400...499:
            switch statusCode {
            case 401:
                return .serverError(statusCode: statusCode, message: "Authentication required. Check your API key.")
            case 404:
                return .cityNotFound
            case 429:
                return .rateLimited(retryAfter: nil)
            default:
                return .serverError(statusCode: statusCode, message: message)
            }
            
        case 500...599:
            return .serverError(statusCode: statusCode, message: "Server error. Please try again later.")
            
        default:
            return .serverError(statusCode: statusCode, message: message)
        }
    }
    
    static func from(urlError: URLError) -> NetworkError {
        switch urlError.code {
        case .notConnectedToInternet, .networkConnectionLost:
            return .noInternetConnection(underlyingError: urlError)
        case .timedOut:
            return .requestTimeout(underlyingError: urlError)
        case .cancelled:
            return .cancelled
        default:
            return .serverError(statusCode: urlError.errorCode, message: urlError.localizedDescription)
        }
    }
}

// MARK: - Equatable Conformance for Testing
extension NetworkError: Equatable {
    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidResponse, .invalidResponse):
            return true
        case (.invalidURL(let lhsPath), .invalidURL(let rhsPath)):
            return lhsPath == rhsPath
        case (.noData, .noData):
            return true
        case (.cityNotFound, .cityNotFound):
            return true
        case (.noInternetConnection, .noInternetConnection):
            return true
        case (.requestTimeout, .requestTimeout):
            return true
        case (.decodingFailed(let lhsCode, _), .decodingFailed(let rhsCode, _)):
            return lhsCode == rhsCode
        case (.serverError(let lhsCode, _), .serverError(let rhsCode, _)):
            return lhsCode == rhsCode
        case (.rateLimited, .rateLimited):
            return true
        case (.cancelled, .cancelled):
            return true
        default:
            return false
        }
    }
}

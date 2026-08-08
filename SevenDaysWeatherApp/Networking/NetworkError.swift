//
//  NetworkError.swift
//  SevenDaysWeatherApp
//
//  Created by Manyuchi, Carrington C on 2026/08/08.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidResponse
    case invalidURL(path: String)
    case noInternetConnection(underlyingError: URLError?)
    case requestTimeout(underlyingError: URLError?)
    case decodingFailed(statusCode: Int, data: Data)
    case serverError(statusCode: Int, message: String?)
    case rateLimited(retryAfter: TimeInterval?)
    case cancelled
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .invalidURL(let path):
            return "Invalid URL: \(path)"
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
    
    // This is useful for showing user-friendly messages
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
        default:
            return nil
        }
    }
}

extension NetworkError {
    var isRetryable: Bool {
        switch self {
        case .noInternetConnection, .requestTimeout, .rateLimited:
            return true
        case .serverError(let statusCode, _):
            // Retry on 5xx server errors, not on 4xx client errors
            return statusCode >= 500 && statusCode <= 599
        case .cancelled, .invalidResponse, .decodingFailed, .invalidURL:
            return false
        }
    }
}

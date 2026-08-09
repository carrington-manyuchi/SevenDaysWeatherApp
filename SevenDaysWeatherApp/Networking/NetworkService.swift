//
//  NetworkService.swift
//  SevenDaysWeatherApp
//
//  Created by Manyuchi, Carrington C on 2026/08/08.
//

import Foundation


// MARK: - Network Service Protocol
protocol NetworkService {
    func post<T: Encodable, U: Decodable>(_ request: T, to path: String) async throws -> U
    func put<T: Encodable, U: Decodable>(_ request: T, to path: String) async throws -> U
    func delete<U: Decodable>(_ path: String) async throws -> U
    func get<U: Decodable>(_ path: String) async throws -> U
    
    //MARK: - Retry Methods
    func getWithRetry<U: Decodable>(_ path: String, retries: Int) async throws -> U
    func postWithRetry<T: Encodable, U: Decodable>(_ request: T, to path: String, retries: Int) async throws -> U
}


final class NetworkServiceImplementation: NetworkService {
    private let baseURL: String
    private let apiKey: String
    private let session: URLSessionProtocol
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private var authToken: String?
    
    func setAuthToken(_ token: String) {
        self.authToken = token
    }
    
    init(
        baseURL: String = "https://api.openweathermap.org/data/2.5/",
        apiKey: String = "8c200300740e9affe7daea59ed32b71",
        session: URLSessionProtocol = URLSession.shared
    ) {
        self.baseURL = baseURL
        self.apiKey = apiKey
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        self.session = session
        
        self.decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        
        self.encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
    }
    
    private func addAuthHeaders(to request: inout URLRequest) {
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "API-Key")
        
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
    }
    
    func post<T: Encodable, U: Decodable>(_ request: T, to path: String) async throws -> U  {
        guard let url = URL(string: baseURL + path) else {
            throw NetworkError.invalidURL(path: baseURL + path)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        addAuthHeaders(to: &urlRequest)
        urlRequest.httpBody = try encoder.encode(request)
        return try await performRequest(urlRequest)
    }
    
    func put<T: Encodable, U: Decodable>(_ request: T, to path: String) async throws -> U  {
        guard let url = URL(string: baseURL + path) else {
            throw NetworkError.invalidURL(path: baseURL + path)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        addAuthHeaders(to: &urlRequest)
        urlRequest.httpBody = try encoder.encode(request)
        return try await performRequest(urlRequest)
    }
    
    func delete<U: Decodable>(_ path: String) async throws -> U {
        guard let url = URL(string: baseURL + path) else {
            throw NetworkError.invalidURL(path: baseURL + path)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        addAuthHeaders(to: &urlRequest)
        return try await performRequest(urlRequest)
    }
    
    func get<U: Decodable>(_ path: String) async throws -> U {
        guard let url = URL(string: baseURL + path) else {
            throw NetworkError.invalidURL(path: baseURL + path)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        addAuthHeaders(to: &urlRequest)
        return try await performRequest(urlRequest)
    }
    
    private func performRequest<T: Decodable>(_ request: URLRequest) async throws -> T {
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            switch httpResponse.statusCode {
            case 200..<300:
                do {
                    return try decoder.decode(T.self, from: data)
                } catch {
                    throw NetworkError.decodingFailed(statusCode: httpResponse.statusCode, data: data)
                }
                
            case 429:
                let retryAfter = httpResponse.allHeaderFields["Retry-After"] as? String
                let retryInterval = retryAfter.flatMap(TimeInterval.init)
                throw NetworkError.rateLimited(retryAfter: retryInterval)
                
            case 401:
                throw NetworkError.serverError(statusCode: 401, message: "Authentication required")
                
            case 404:
                throw NetworkError.invalidURL(path: request.url?.absoluteString ?? "unknown")
                
            case 400...499:
                throw NetworkError.serverError(statusCode: httpResponse.statusCode, message: "Client error")
                
            case 500...599:
                throw NetworkError.serverError(statusCode: httpResponse.statusCode, message: "Server error")
                
            default:
                throw NetworkError.serverError(statusCode: httpResponse.statusCode, message: "Unexpected status code")
            }
            
        } catch let urlError as URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                throw NetworkError.noInternetConnection(underlyingError: urlError)
            case .timedOut:
                throw NetworkError.requestTimeout(underlyingError: urlError)
            case .cancelled:
                throw NetworkError.cancelled
            default:
                throw NetworkError.serverError(statusCode: urlError.errorCode, message: urlError.localizedDescription)
            }
        }
    }
    
    func getWithRetry<U: Decodable>(_ path: String, retries: Int = 2) async throws -> U {
        var lastError: Error?
        
        for attempt in 0...retries {
            do {
                return try await get(path)
            } catch let error as NetworkError where error.isRetryable {
                lastError = error
                if attempt < retries {
                    // Exponential backoff: 1s, 2s, 4s
                    let delay = pow(2.0, Double(attempt))
                    print("🔄 Retry \(attempt + 1)/\(retries) after \(delay)s delay")
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    continue
                }
            } catch {
                throw error // Non-retryable error, throw immediately
            }
        }
        
        throw lastError ?? NetworkError.serverError(statusCode: 0, message: "Max retries exceeded")
    }
    
    func postWithRetry<T: Encodable, U: Decodable>(_ request: T, to path: String, retries: Int = 2) async throws -> U {
        var lastError: Error?
        
        for attempt in 0...retries {
            do {
                return try await post(request, to: path)
            } catch let error as NetworkError where error.isRetryable {
                lastError = error
                if attempt < retries {
                    let delay = pow(2.0, Double(attempt))
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    continue
                }
            } catch {
                throw error
            }
        }
        
        throw lastError ?? NetworkError.serverError(statusCode: 0, message: "Max retries exceeded")
    }
}

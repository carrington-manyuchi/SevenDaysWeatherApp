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
    
    // MARK: - Retry Methods
    func getWithRetry<U: Decodable>(_ path: String, retries: Int) async throws -> U
    func postWithRetry<T: Encodable, U: Decodable>(_ request: T, to path: String, retries: Int) async throws -> U
}

// MARK: - Network Service Implementation
final class NetworkServiceImplementation: NetworkService {
    private let baseURL: String
    private let apiKey: String
    private let session: URLSessionProtocol
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private var authToken: String?
    private let maxRetries: Int
    
    // MARK: - Initialization
    init(
        baseURL: String = "https://api.openweathermap.org/data/2.5/",
        apiKey: String = "f8c200300740e9affe7daea59ed32b71",
        session: URLSessionProtocol = URLSession.shared,
        maxRetries: Int = 3
    ) {
        self.baseURL = baseURL
        self.apiKey = apiKey
        self.session = session
        self.maxRetries = maxRetries
        
        self.decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .secondsSince1970
        
        self.encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .secondsSince1970
    }
    
    // MARK: - Auth Management
    func setAuthToken(_ token: String) {
        self.authToken = token
    }
    
    // MARK: - Public Methods
    func get<U: Decodable>(_ path: String) async throws -> U {
        let urlRequest = try buildRequest(path: path, method: "GET")
        return try await performRequest(urlRequest)
    }
    
    func post<T: Encodable, U: Decodable>(_ request: T, to path: String) async throws -> U {
        var urlRequest = try buildRequest(path: path, method: "POST")
        urlRequest.httpBody = try encoder.encode(request)
        return try await performRequest(urlRequest)
    }
    
    func put<T: Encodable, U: Decodable>(_ request: T, to path: String) async throws -> U {
        var urlRequest = try buildRequest(path: path, method: "PUT")
        urlRequest.httpBody = try encoder.encode(request)
        return try await performRequest(urlRequest)
    }
    
    func delete<U: Decodable>(_ path: String) async throws -> U {
        let urlRequest = try buildRequest(path: path, method: "DELETE")
        return try await performRequest(urlRequest)
    }
    
    // MARK: - Retry Methods
    func getWithRetry<U: Decodable>(_ path: String, retries: Int = 3) async throws -> U {
        return try await performWithRetry(retries: retries) {
            try await self.get(path)
        }
    }
    
    func postWithRetry<T: Encodable, U: Decodable>(_ request: T, to path: String, retries: Int = 3) async throws -> U {
        return try await performWithRetry(retries: retries) {
            try await self.post(request, to: path)
        }
    }
    
    // MARK: - Private Helpers
    private func buildRequest(path: String, method: String) throws -> URLRequest {
        guard let url = URL(string: baseURL + path) else {
            throw NetworkError.invalidURL(path: baseURL + path)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.timeoutInterval = 30
        
        // Add headers
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if let token = authToken {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return urlRequest
    }
    
    private func performRequest<T: Decodable>(_ request: URLRequest) async throws -> T {
        print("🌐 Request: \(request.httpMethod ?? "GET") \(request.url?.absoluteString ?? "")")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            print("📡 Response: \(httpResponse.statusCode)")
            
            // Print response data for debugging
            #if DEBUG
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📦 Response Data: \(jsonString.prefix(500))...")
            }
            #endif
            
            switch httpResponse.statusCode {
            case 200...299:
                return try decodeResponse(data: data, statusCode: httpResponse.statusCode)
                
            case 400:
                throw NetworkError.serverError(statusCode: 400, message: "Bad Request")
                
            case 401:
                throw NetworkError.serverError(statusCode: 401, message: "Authentication required. Please check your API key.")
                
            case 404:
                throw NetworkError.cityNotFound
                
            case 429:
                let retryAfter = httpResponse.allHeaderFields["Retry-After"] as? String
                let retryInterval = retryAfter.flatMap(TimeInterval.init)
                throw NetworkError.rateLimited(retryAfter: retryInterval)
                
            case 400...499:
                let message = String(data: data, encoding: .utf8) ?? "Client error"
                throw NetworkError.serverError(statusCode: httpResponse.statusCode, message: message)
                
            case 500...599:
                let message = String(data: data, encoding: .utf8) ?? "Server error"
                throw NetworkError.serverError(statusCode: httpResponse.statusCode, message: message)
                
            default:
                throw NetworkError.serverError(statusCode: httpResponse.statusCode, message: "Unexpected status code")
            }
            
        } catch let urlError as URLError {
            print("❌ URL Error: \(urlError)")
            throw handleURLError(urlError)
            
        } catch let networkError as NetworkError {
            print("❌ Network Error: \(networkError)")
            throw networkError
            
        } catch {
            print("❌ Unknown Error: \(error)")
            throw NetworkError.serverError(statusCode: 0, message: error.localizedDescription)
        }
    }
    
    private func decodeResponse<T: Decodable>(data: Data, statusCode: Int) throws -> T {
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            print("❌ Decoding Error: \(error)")
            
            // Print the raw JSON for debugging
            #if DEBUG
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📄 Raw JSON: \(jsonString)")
            }
            #endif
            
            throw NetworkError.decodingFailed(statusCode: statusCode, data: data)
        }
    }
    
    private func handleURLError(_ error: URLError) -> NetworkError {
        switch error.code {
        case .notConnectedToInternet, .networkConnectionLost:
            return .noInternetConnection(underlyingError: error)
            
        case .timedOut:
            return .requestTimeout(underlyingError: error)
            
        case .cancelled:
            return .cancelled
            
        case .badURL, .unsupportedURL:
            return .invalidURL(path: error.failureURLString ?? "unknown")
            
        default:
            return .serverError(statusCode: error.errorCode, message: error.localizedDescription)
        }
    }
    
    private func performWithRetry<T>(retries: Int, operation: @escaping () async throws -> T) async throws -> T {
        var lastError: Error?
        
        for attempt in 0...retries {
            do {
                if attempt > 0 {
                    print("🔄 Retry attempt \(attempt)/\(retries)")
                }
                return try await operation()
                
            } catch let error as NetworkError where error.isRetryable {
                lastError = error
                
                if attempt < retries {
                    // Exponential backoff with jitter
                    let baseDelay = pow(2.0, Double(attempt))
                    let jitter = Double.random(in: 0.8...1.2)
                    let delay = baseDelay * jitter
                    
                    print("⏳ Waiting \(String(format: "%.1f", delay))s before retry...")
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    continue
                }
                
            } catch {
                // Non-retryable error
                throw error
            }
        }
        
        throw lastError ?? NetworkError.serverError(statusCode: 0, message: "Max retries exceeded")
    }
}

// MARK: - Convenience Methods for Weather API
extension NetworkServiceImplementation {
    func buildWeatherPath(endpoint: String, queryItems: [String: String]) -> String {
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: "metric")
        ]
        
        for (key, value) in queryItems {
            components.queryItems?.append(URLQueryItem(name: key, value: value))
        }
        
        let queryString = components.percentEncodedQuery ?? ""
        return "\(endpoint)?\(queryString)"
    }
    
    func fetchWeather(lat: Double, lon: Double) async throws -> WeatherResponse {
        let path = buildWeatherPath(
            endpoint: "forecast",
            queryItems: [
                "lat": String(lat),
                "lon": String(lon)
            ]
        )
        return try await get(path)
    }
    
    func fetchWeather(city: String) async throws -> WeatherResponse {
        // First geocode the city
        let geoPath = buildWeatherPath(
            endpoint: "geo/1.0/direct",
            queryItems: [
                "q": city,
                "limit": "1"
            ]
        )
        
        let geoResponse: [GeoLocation] = try await get(geoPath)
        
        guard let location = geoResponse.first else {
            throw NetworkError.cityNotFound
        }
        
        // Then fetch weather
        return try await fetchWeather(lat: location.lat, lon: location.lon)
    }
}


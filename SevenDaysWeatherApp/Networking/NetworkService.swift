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
    }
    
    private func addAuthHeaders(to request: inout URLRequest) {
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "API-Key")
        
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
    }
    
    func post<T, U>(_ request: T, to path: String) async throws -> U where T : Encodable, U : Decodable {
        <#code#>
    }
    
    func put<T, U>(_ request: T, to path: String) async throws -> U where T : Encodable, U : Decodable {
        <#code#>
    }
    
    func delete<U>(_ path: String) async throws -> U where U : Decodable {
        <#code#>
    }
    
    func get<U>(_ path: String) async throws -> U where U : Decodable {
        <#code#>
    }
    
    func getWithRetry<U>(_ path: String, retries: Int) async throws -> U where U : Decodable {
        <#code#>
    }
    
    func postWithRetry<T, U>(_ request: T, to path: String, retries: Int) async throws -> U where T : Encodable, U : Decodable {
        <#code#>
    }
}

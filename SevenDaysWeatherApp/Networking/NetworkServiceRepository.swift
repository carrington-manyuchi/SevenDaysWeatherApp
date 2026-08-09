//
//  protocol NetworkServiceRepository.swift
//  SevenDaysWeatherApp
//
//  Created by Manyuchi, Carrington C on 2026/08/09.
//

import Foundation
import SwiftUI


// MARK: - Repository Protocol
protocol NetworkServiceRepository {
    // Weather endpoints
    func fetchWeatherForecast(lat: Double, lon: Double) async throws -> WeatherResponse
    func fetchWeatherByCity(city: String) async throws -> WeatherResponse
}

// MARK: - Repository Implementation
final class NetworkServiceRepositoryImplementation: NetworkServiceRepository {
    private let networkService: NetworkService
    private let apiKey = "8c200300740e9affe7daea59ed32b71"
    
    init(networkService: NetworkService) {
        self.networkService = networkService
    }
    
    // MARK: - Private Helpers
    
    private func buildWeatherPath(endpoint: String, queryItems: [String: String]) -> String {
        let baseQuery = "appid=\(apiKey)&units=metric"
        let additionalQuery = queryItems.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
        let fullQuery = additionalQuery.isEmpty ? baseQuery : "\(additionalQuery)&\(baseQuery)"
        return "\(endpoint)?\(fullQuery)"
    }
    
    // MARK: - Weather Endpoints
    
    /// Fetches weather data using coordinates (lat/lon)
    /// - Parameters:
    ///   - lat: Latitude
    ///   - lon: Longitude
    /// - Returns: WeatherResponse containing current, hourly, and daily weather
    func fetchWeatherForecast(lat: Double, lon: Double) async throws -> WeatherResponse {
        let path = buildWeatherPath(
            endpoint: "onecall",
            queryItems: [
                "lat": String(lat),
                "lon": String(lon),
                "exclude": "minutely,alerts" // Exclude minutely and alerts to keep response size manageable
            ]
        )
        return try await networkService.get(path)
    }
    
    /// Fetches weather data by city name
    /// - Parameter city: City name (e.g., "London", "New York")
    /// - Returns: WeatherResponse containing current, hourly, and daily weather
    func fetchWeatherByCity(city: String) async throws -> WeatherResponse {
        guard let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            throw NetworkError.invalidURL(path: city)
        }
        
        // First get the coordinates for the city
        let geoPath = "geo/1.0/direct?q=\(encodedCity)&limit=1&appid=\(apiKey)"
        let geoResponse: [GeoLocation] = try await networkService.get(geoPath)
        
        guard let location = geoResponse.first else {
            throw NetworkError.serverError(statusCode: 404, message: "City not found")
        }
        
        // Then fetch weather using the coordinates
        return try await fetchWeatherForecast(lat: location.lat, lon: location.lon)
    }
}

// MARK: - GeoLocation Model
struct GeoLocation: Codable {
    let name: String
    let lat: Double
    let lon: Double
    let country: String
    let state: String?
}

//
//  protocol NetworkServiceRepository.swift
//  SevenDaysWeatherApp
//
//  Created by Manyuchi, Carrington C on 2026/08/09.
//

import Foundation

// MARK: - Repository Protocol
protocol NetworkServiceRepository {
    func fetchWeatherForecast(lat: Double, lon: Double) async throws -> WeatherResponse
    func fetchWeatherByCity(city: String) async throws -> WeatherResponse
}

// MARK: - Repository Implementation
final class NetworkServiceRepositoryImplementation: NetworkServiceRepository {
    private let networkService: NetworkService
    private let apiKey: String
    
    // MARK: - Initialization
    init(
        networkService: NetworkService = NetworkServiceImplementation(),
        apiKey: String = "f8c200300740e9affe7daea59ed32b71"
    ) {
        self.networkService = networkService
        self.apiKey = apiKey
    }
    
    // MARK: - Public Methods
    
    /// Fetches weather forecast using coordinates
    /// - Parameters:
    ///   - lat: Latitude
    ///   - lon: Longitude
    /// - Returns: WeatherResponse containing forecast data
    func fetchWeatherForecast(lat: Double, lon: Double) async throws -> WeatherResponse {
        let path = buildWeatherPath(
            endpoint: "forecast",
            queryItems: [
                "lat": String(lat),
                "lon": String(lon)
            ]
        )
        return try await networkService.get(path)
    }
    
    /// Fetches weather by city name (geocodes first, then fetches forecast)
    /// - Parameter city: City name (e.g., "Mutare", "London")
    /// - Returns: WeatherResponse containing forecast data
    func fetchWeatherByCity(city: String) async throws -> WeatherResponse {
        // Step 1: Geocode the city to get coordinates
        let coordinates = try await geocodeCity(city)
        
        // Step 2: Fetch weather using the coordinates
        return try await fetchWeatherForecast(lat: coordinates.lat, lon: coordinates.lon)
    }
    
    // MARK: - Private Helpers
    
    private func geocodeCity(_ city: String) async throws -> (lat: Double, lon: Double) {
        var components = URLComponents(string: "https://api.openweathermap.org/geo/1.0/direct")!
        components.queryItems = [
            URLQueryItem(name: "q", value: city),
            URLQueryItem(name: "limit", value: "1"),
            URLQueryItem(name: "appid", value: apiKey)
        ]
        
        guard let fullURL = components.url?.absoluteString else {
            throw NetworkError.invalidURL(path: city)
        }
        
        let geoResponse: [GeoLocation] = try await networkService.get(fullURL)
        
        guard let location = geoResponse.first else {
            throw NetworkError.cityNotFound
        }
        
        return (lat: location.lat, lon: location.lon)
    }
    
    private func buildWeatherPath(endpoint: String, queryItems: [String: String]) -> String {
        var components = URLComponents()
        var items = [
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: "metric")
        ]
        
        for (key, value) in queryItems {
            items.append(URLQueryItem(name: key, value: value))
        }
        
        components.queryItems = items
        let queryString = components.percentEncodedQuery ?? ""
        return "\(endpoint)?\(queryString)"
    }
}

// MARK: - Mock Repository for Testing
final class MockNetworkServiceRepository: NetworkServiceRepository {
    var shouldSucceed = true
    var mockWeatherResponse: WeatherResponse?
    var mockError: Error?
    
    func fetchWeatherForecast(lat: Double, lon: Double) async throws -> WeatherResponse {
        if shouldSucceed {
            return mockWeatherResponse ?? WeatherResponse.empty()
        } else {
            throw mockError ?? NetworkError.serverError(statusCode: 500, message: "Mock error")
        }
    }
    
    func fetchWeatherByCity(city: String) async throws -> WeatherResponse {
        if shouldSucceed {
            return mockWeatherResponse ?? WeatherResponse.empty()
        } else {
            throw mockError ?? NetworkError.cityNotFound
        }
    }
}


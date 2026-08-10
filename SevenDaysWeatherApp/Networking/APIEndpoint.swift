//
//  APIEndpoint.swift
//  SevenDaysWeatherApp
//
//  Created by Manyuchi, Carrington C on 2026/08/09.
//

import Foundation

// MARK: - API Endpoints
enum APIEndpoint {
    case weather(lat: Double, lon: Double)
    case geocode(city: String)
    
    var path: String {
        switch self {
        case .weather(let lat, let lon):
            return "forecast?lat=\(lat)&lon=\(lon)"
        case .geocode(let city):
            return "geo/1.0/direct?q=\(city)&limit=1"
        }
    }
}

// MARK: - API Configuration
struct APIConfig {
    static let baseURL = "https://api.openweathermap.org/data/2.5/"
    static let apiKey = "f8c200300740e9affe7daea59ed32b71"
    static let units = "metric"
}

//
//  WeatherResponse.swift
//  SevenDaysWeatherApp
//
//  Created by Manyuchi, Carrington C on 2026/08/09.
//

import Foundation

// MARK: - Weather Response
struct WeatherResponse: Codable {
    let cod: String
    let message: Int
    let cnt: Int
    let list: [WeatherList]
    let city: City
}

// MARK: - City
struct City: Codable {
    let id: Int
    let name: String
    let coord: Coord
    let country: String
    let population: Int
    let timezone: Int
    let sunrise: Int
    let sunset: Int
}

// MARK: - Coordinates
struct Coord: Codable {
    let lat: Double
    let lon: Double
}

// MARK: - Weather List Item
struct WeatherList: Codable, Identifiable {
    public let id = UUID()
    let dt: Int
    let main: Main
    let weather: [WeatherDetail]
    let clouds: Clouds
    let wind: Wind
    let visibility: Int
    let pop: Double
    let sys: Sys
    let dtTxt: String
    let rain: Rain?
    
    enum CodingKeys: String, CodingKey {
        case dt
        case main
        case weather
        case clouds
        case wind
        case visibility
        case pop
        case sys
        case dtTxt = "dt_txt"
        case rain
    }
}

// MARK: - Main Weather Data
struct Main: Codable {
    let temp: Double
    let feelsLike: Double
    let tempMin: Double
    let tempMax: Double
    let pressure: Int
    let seaLevel: Int
    let grndLevel: Int
    let humidity: Int
    let tempKf: Double
    let dewPoint: Double?
    
    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure
        case seaLevel = "sea_level"
        case grndLevel = "grnd_level"
        case humidity
        case tempKf = "temp_kf"
        case dewPoint = "dew_point"
    }
}

// MARK: - Weather Detail
struct WeatherDetail: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

// MARK: - Clouds
struct Clouds: Codable {
    let all: Int
}

// MARK: - Wind
struct Wind: Codable {
    let speed: Double
    let deg: Int
    let gust: Double?
}

// MARK: - Rain
struct Rain: Codable {
    let the3H: Double?
    
    enum CodingKeys: String, CodingKey {
        case the3H = "3h"
    }
}

// MARK: - System
struct Sys: Codable {
    let pod: String
}

// MARK: - GeoLocation (for geocoding)
struct GeoLocation: Codable {
    let name: String
    let lat: Double
    let lon: Double
    let country: String
    let state: String?
}

// MARK: - WeatherResponse Extension
extension WeatherResponse {
    static func empty() -> WeatherResponse {
        return WeatherResponse(
            cod: "",
            message: 0,
            cnt: 0,
            list: [],
            city: City(
                id: 0,
                name: "",
                coord: Coord(lat: 0, lon: 0),
                country: "",
                population: 0,
                timezone: 0,
                sunrise: 0,
                sunset: 0
            )
        )
    }
}

// MARK: - WeatherList Extension for Computed Properties
extension WeatherList {
    var date: Date {
        return Date(timeIntervalSince1970: TimeInterval(dt))
    }
    
    var temperature: Double {
        return main.temp
    }
    
    var feelsLike: Double {
        return main.feelsLike
    }
    
    var humidity: Int {
        return main.humidity
    }
    
    var windSpeed: Double {
        return wind.speed
    }
    
    var condition: String {
        return weather.first?.main ?? ""
    }
    
    var icon: String {
        return weather.first?.icon ?? "01d"
    }
    
    var conditionDescription: String {
        return weather.first?.description ?? ""
    }
}

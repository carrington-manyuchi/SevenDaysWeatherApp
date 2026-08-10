//
//  WeatherResponse.swift
//  SevenDaysWeatherApp
//
//  Created by Manyuchi, Carrington C on 2026/08/09.
//

import Foundation

//struct WeatherResponse: Codable {
//    let cod: String
//        let message: Int
//        let cnt: Int
//        let list: [WeatherList]
//        let city: City
//
//        enum CodingKeys: String, CodingKey {
//            case cod = "cod"
//            case message = "message"
//            case cnt = "cnt"
//            case list = "list"
//            case city = "city"
//        }
//}
//
//struct City: Codable {
//    let id: Int
//    let name: String
//    let coord: Coord
//    let country: String
//    let population: Int
//    let timezone: Int
//    let sunrise: Int
//    let sunset: Int
//
//    enum CodingKeys: String, CodingKey {
//        case id = "id"
//        case name = "name"
//        case coord = "coord"
//        case country = "country"
//        case population = "population"
//        case timezone = "timezone"
//        case sunrise = "sunrise"
//        case sunset = "sunset"
//    }
//}
//
//struct Coord: Codable {
//    let lat: Double
//    let lon: Double
//
//    enum CodingKeys: String, CodingKey {
//        case lat = "lat"
//        case lon = "lon"
//    }
//}
//
//struct WeatherList: Codable, Identifiable {
//    let id: UUID = UUID()
//    
//    let dt: Int
//    let main: [String: Double]
//    let weather: [Weather]
//    let clouds: Clouds
//    let wind: Wind
//    let visibility: Int
//    let pop: Double
//    let sys: Sys
//    let dtTxt: String
//    let rain: Rain?
//    
//    enum CodingKeys: String, CodingKey {
//        case dt = "dt"
//        case main = "main"
//        case weather = "weather"
//        case clouds = "clouds"
//        case wind = "wind"
//        case visibility = "visibility"
//        case pop = "pop"
//        case sys = "sys"
//        case dtTxt = "dt_txt"
//        case rain = "rain"
//    }
//}
//// MARK: - Clouds
//struct Clouds: Codable {
//    let all: Int
//
//    enum CodingKeys: String, CodingKey {
//        case all = "all"
//    }
//}
//
//// MARK: - Rain
//struct Rain: Codable {
//    let the3H: Double
//
//    enum CodingKeys: String, CodingKey {
//        case the3H = "3h"
//    }
//}
//
//// MARK: - Sys
//struct Sys: Codable {
//    let pod: Pod
//
//    enum CodingKeys: String, CodingKey {
//        case pod = "pod"
//    }
//}
//
//enum Pod: String, Codable {
//    case d = "d"
//    case n = "n"
//}
//
//// MARK: - Weather
//struct Weather: Codable {
//    let id: Int
//    let main: Main
//    let description: Description
//    let icon: String
//
//    enum CodingKeys: String, CodingKey {
//        case id = "id"
//        case main = "main"
//        case description = "description"
//        case icon = "icon"
//    }
//}
//
//enum Description: String, Codable {
//    case brokenClouds = "broken clouds"
//    case clearSky = "clear sky"
//    case fewClouds = "few clouds"
//    case lightRain = "light rain"
//    case overcastClouds = "overcast clouds"
//    case scatteredClouds = "scattered clouds"
//}
//
//enum Main: String, Codable {
//    case clear = "Clear"
//    case clouds = "Clouds"
//    case rain = "Rain"
//}
//
//// MARK: - Wind
//struct Wind: Codable {
//    let speed: Double
//    let deg: Int
//    let gust: Double
//
//    enum CodingKeys: String, CodingKey {
//        case speed = "speed"
//        case deg = "deg"
//        case gust = "gust"
//    }
//}


// Models/WeatherResponse.swift
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
    let main: [String: Double]
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

struct GeoLocation: Codable {
    let name: String
    let lat: Double
    let lon: Double
    let country: String
    let state: String?
}


//
//  DisplayModels.swift
//  SevenDaysWeatherApp
//
//  Created by Manyuchi, Carrington C on 2026/08/09.
//

import Foundation

// MARK: - Weather Display Model
struct WeatherDisplay {
    let date: Date
    let temperature: Double
    let feelsLike: Double
    let condition: String
    let icon: String
    let humidity: Int
    let windSpeed: Double
    let pressure: Int
    let weatherDetails: [WeatherDetail]
    
    // Empty state for loading/error
    static func empty() -> WeatherDisplay {
        return WeatherDisplay(
            date: Date(),
            temperature: 0,
            feelsLike: 0,
            condition: "",
            icon: "01d",
            humidity: 0,
            windSpeed: 0,
            pressure: 0,
            weatherDetails: []
        )
    }
}

// MARK: - Hourly Weather Display
struct HourlyWeatherDisplay {
    let time: Date
    let temperature: Double
    let icon: String
    let condition: String
}

// MARK: - Daily Weather Display
struct DailyWeatherDisplay {
    let date: Date
    let minTemperature: Double
    let maxTemperature: Double
    let condition: String
    let icon: String
}

// MARK: - Current Weather Display
struct CurrentWeatherDisplay {
    let cityName: String
    let temperature: String
    let condition: String
    let icon: String
    let highLow: String
    let humidity: String
    let windSpeed: String
    let feelsLike: String
}

// MARK: - City Display Model
struct CityDisplay {
    let name: String
    let country: String
    let coordinates: (lat: Double, lon: Double)
}

////
////  Weather.swift
////  SevenDaysWeatherApp
////
////  Created by Manyuchi, Carrington C on 2026/08/09.
////
//
//import Foundation
//
//// In Weather.swift
//struct Weather: Codable, Identifiable {
//    var dt: Int
//    var temp: Double
//    var feels_like: Double
//    var pressure: Int
//    var humidity: Int
//    var dew_point: Double
//    var clouds: Int
//    var wind_speed: Double
//    var wind_deg: Int
//    var weather: [WeatherDetail]
//    
//    // MARK: - Custom Initializer
//    init(dt: Int = 0,
//         temp: Double = 0.0,
//         feels_like: Double = 0.0,
//         pressure: Int = 0,
//         humidity: Int = 0,
//         dew_point: Double = 0.0,
//         clouds: Int = 0,
//         wind_speed: Double = 0.0,
//         wind_deg: Int = 0,
//         weather: [WeatherDetail] = []) {
//        self.dt = dt
//        self.temp = temp
//        self.feels_like = feels_like
//        self.pressure = pressure
//        self.humidity = humidity
//        self.dew_point = dew_point
//        self.clouds = clouds
//        self.wind_speed = wind_speed
//        self.wind_deg = wind_deg
//        self.weather = weather
//    }
//    
//    // Empty initializer for default values
//    init() {
//        self.dt = 0
//        self.temp = 0.0
//        self.feels_like = 0.0
//        self.pressure = 0
//        self.humidity = 0
//        self.dew_point = 0.0
//        self.clouds = 0
//        self.wind_speed = 0.0
//        self.wind_deg = 0
//        self.weather = []
//    }
//}
//
//extension Weather {
//    var id: UUID {
//        return UUID()
//    }
//}
////
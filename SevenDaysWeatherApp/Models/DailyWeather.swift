//
//  DailyWeather.swift
//  SevenDaysWeatherApp
//
//  Created by Manyuchi, Carrington C on 2026/08/09.
//

//import Foundation
//
//struct DailyWeather: Codable, Identifiable {
//    var dt: Int
//    var temp: Temperature
//    var weather: [WeatherDetail]
//    
//    // MARK: - Custom Initializer
//    init(dt: Int, temp: Temperature, weather: [WeatherDetail]) {
//        self.dt = dt
//        self.temp = temp
//        self.weather = weather
//    }
//    
//    // Empty initializer for default values
//    init() {
//        self.dt = 0
//        self.temp = Temperature(min: 0.0, max: 0.0)
//        self.weather = [WeatherDetail(main: "", description: "", icon: "")]
//    }
//    
//    enum CodingKeys: String, CodingKey {
//        case dt
//        case temp
//        case weather
//    }
//}
//
//extension DailyWeather {
//    var id: UUID {
//        return UUID()
//    }
//}

//
//  API+Extension.swift
//  SevenDaysWeatherApp
//
//  Created by Manyuchi, Carrington C on 2026/08/08.
//

import Foundation

extension API {
    static let baseURLString = "https://api.openweathermap.org/data/2.5/"
    static func getURLFor(lat: Double, lon: Double) -> String {
        return "\(baseURLString)forecast?lat=\(lat)&lon=\(lon)&exclude=minutely&appid=\(key)&units=metric"
    }
}

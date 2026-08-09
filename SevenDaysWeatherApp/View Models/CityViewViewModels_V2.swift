//
//  CityViewViewModel.swift
//  SevenDaysWeatherApp
//
//  Created by Manyuchi, Carrington C on 2026/08/09.
//

import SwiftUI
import CoreLocation
internal import Combine

final class CityViewViewModels_V2: ObservableObject {
    @Published var weather = WeatherResponse.empty()
    
    @Published var city: String = "Mutare" {
        didSet {
            //MARK: - call get location here
            getLocation()
        }
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let Formatter = DateFormatter()
        Formatter.dateStyle = .full
        return Formatter
    }()
    
    private lazy var dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter
    }()
    
    private lazy var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh a"
        return formatter
    }()
    
    init() {
        getLocation()
    }
    
    var date: String {
        return dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(weather.current.dt)))
    }
    
    var weatherIcon: String {
        if weather.current.weather.count > 0 {
            return weather.current.weather[0].icon
        }
        return "sun.max.fill"
    }
    
    
    var temperature: String {
        return getTemFor(temp: weather.current.temp)
    }
    
    var conditions: String {
        if weather.current.weather.count > 0 {
            return weather.current.weather[0].main
        }
        return ""
    }
    
    var windSpeed: String {
        return String(format: "%0.1f", weather.current.wind_speed)
    }
    
    var humidity: String {
        return String(format: "%d%%", weather.current.humidity)
    }
    
    var rainfChances: String {
        return String(format: "%0.0f%%", weather.current.dew_point)
    }
    
    func getTimeFor(timestamp: Int) -> String {
        return timeFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(timestamp)))
    }
    
    func getTemFor(temp: Double) -> String {
        return String(format: "%0..1f", temp)
    }
    
    func getDayFor(timestamp: Int) -> String {
        return dayFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(timestamp)))
    }
    
    private func getLocation() {
        CLGeocoder().geocodeAddressString(city) { placemarks, error in
            if let places = placemarks, let place = places.first {
                self.getWeather(cord: place.location?.coordinate)
            }
        }
    }
    
    private func getWeather(cord: CLLocationCoordinate2D?) {
        if let cord = cord {
            let urlString = API.getURLFor(lat: cord.latitude, lon: cord.longitude)
            getWeatherInternal(city: city, for: urlString)
        } else {
            let urlString = API.getURLFor(lat: 37.5485, lon: -121.9886)
            getWeatherInternal(city: city, for: urlString)
        }
    }
    
    private func getWeatherInternal(city: String, for urlString: String) {
//        NetworkManager<WeatherResponse>.fetch(for: URL(string: urlString)!) { Result in
//            switch Result {
//            case .success(let response):
//                DispatchQueue.main.async {
//                    self.weather = response
//                }
//            case .failure(let error):
//                print(error)
//            }
//        }
    }
    
}

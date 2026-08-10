//
//  CityViewViewModel.swift
//  SevenDaysWeatherApp
//
//  Created by Manyuchi, Carrington C on 2026/08/09.
//

import Foundation
import SwiftUI
import CoreLocation
import Combine

// MARK: - ViewModel
@MainActor
final class CityViewViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var weatherResponse: WeatherResponse?
    @Published var city: String = "Mutare" {
        didSet {
            if !oldValue.isEmpty && oldValue != city {
                Task {
                    await fetchWeather(for: city)
                }
            }
        }
    }
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    
    // MARK: - Display Models (Computed)
    
    var currentWeather: WeatherDisplay {
        guard let response = weatherResponse,
              let first = response.list.first else {
            return .empty()
        }
        
        return WeatherDisplay(
            date: Date(timeIntervalSince1970: TimeInterval(first.dt)),
            temperature: first.main["temp"] ?? 0,
            feelsLike: first.main["feels_like"] ?? 0,
            condition: first.weather.first?.main ?? "",
            icon: first.weather.first?.icon ?? "01d",
            humidity: Int(first.main["humidity"] ?? 0),
            windSpeed: first.wind.speed,
            pressure: Int(first.main["pressure"] ?? 0),
            weatherDetails: first.weather,
        )
    }
    
    var hourlyForecast: [HourlyWeatherDisplay] {
        guard let response = weatherResponse else { return [] }
        
        return response.list.prefix(24).map { forecast in
            HourlyWeatherDisplay(
                time: Date(timeIntervalSince1970: TimeInterval(forecast.dt)),
                temperature: forecast.main["temp"] ?? 0,
                icon: forecast.weather.first?.icon ?? "01d",
                condition: forecast.weather.first?.main ?? ""
            )
        }
    }
    
    var dailyForecast: [DailyWeatherDisplay] {
        guard let response = weatherResponse else { return [] }
        
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: response.list) { forecast in
            let date = Date(timeIntervalSince1970: TimeInterval(forecast.dt))
            return calendar.startOfDay(for: date)
        }
        
        return grouped.compactMap { (date, forecasts) in
            guard let first = forecasts.first else { return nil }
            
            let minTemp = forecasts.min { ($0.main["temp_min"] ?? 0) < ($1.main["temp_min"] ?? 0) }?.main["temp_min"] ?? 0
            let maxTemp = forecasts.max { ($0.main["temp_max"] ?? 0) < ($1.main["temp_max"] ?? 0) }?.main["temp_max"] ?? 0
            
            return DailyWeatherDisplay(
                date: date,
                minTemperature: minTemp,
                maxTemperature: maxTemp,
                condition: first.weather.first?.main ?? "",
                icon: first.weather.first?.icon ?? "01d"
            )
        }.sorted { $0.date < $1.date }
    }
    
    // MARK: - UI Display Properties
    
    var cityName: String {
        return weatherResponse?.city.name ?? city
    }
    
    var date: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: currentWeather.date)
    }
    
    var temperatureDisplay: String {
        return String(format: "%.1f°C", currentWeather.temperature)
    }
    
    var feelsLikeDisplay: String {
        return String(format: "%.1f°C", currentWeather.feelsLike)
    }
    
    var conditionDisplay: String {
        return currentWeather.condition
    }
    
    var humidityDisplay: String {
        return "\(currentWeather.humidity)%"
    }
    
    var windSpeedDisplay: String {
        return String(format: "%.1f km/h", currentWeather.windSpeed)
    }
    
    var pressureDisplay: String {
        return "\(currentWeather.pressure) hPa"
    }
    
    var rainChancesDisplay: String {
        return String(format: "%.0f%%", currentWeather.feelsLike)
    }
    
    // MARK: - Formatters
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
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
    
    // MARK: - Dependencies
    private let repository: NetworkServiceRepository
    private let geocoder = CLGeocoder()
    private var fetchTask: Task<Void, Never>?
    
    // MARK: - Initialization
    init(repository: NetworkServiceRepository = NetworkServiceRepositoryImplementation(
        networkService: NetworkServiceImplementation()
    )) {
        self.repository = repository
        Task {
            await fetchWeather(for: city)
        }
    }
    
    // MARK: - Public Methods
    func refreshWeather() {
        Task {
            await fetchWeather(for: city)
        }
    }
    
    func searchCity(_ newCity: String) {
        let trimmedCity = newCity.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedCity.isEmpty else { return }
        city = trimmedCity
    }
    
    func getTimeFor(timestamp: Int) -> String {
        return timeFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(timestamp)))
    }
    
    func getDayFor(timestamp: Int) -> String {
        return dayFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(timestamp)))
    }
    
    func getLottieAnimationFor(icon: String) -> String {
        switch icon {
        case "01d": return "dayClearSky"
        case "01n": return "nightClearSky"
        case "02d": return "dayFewClouds"
        case "02n": return "nightFewClouds"
        case "03d": return "dayScatteredClouds"
        case "03n": return "nightScatteredClouds"
        case "04d": return "dayBrokenClouds"
        case "04n": return "nightBrokenClouds"
        case "09d": return "dayShowerRains"
        case "09n": return "nightShowerRains"
        case "10d": return "dayRain"
        case "10n": return "nightRain"
        case "11d": return "dayThunderstorm"
        case "11n": return "nightThunderstorm"
        case "13d": return "daySnow"
        case "13n": return "nightSnow"
        case "50d": return "dayMist"
        case "50n": return "nightMist"
        default: return "dayClearSky"
        }
    }
    
    func getWeatherImageFor(icon: String) -> Image {
        switch icon {
        case "01d": return Image(systemName: "sun.max.fill")
        case "01n": return Image(systemName: "moon.fill")
        case "02d": return Image(systemName: "cloud.sun.fill")
        case "02n": return Image(systemName: "cloud.moon.fill")
        case "03d", "03n": return Image(systemName: "cloud.fill")
        case "04d", "04n": return Image(systemName: "cloud.fill")
        case "09d", "09n": return Image(systemName: "cloud.drizzle.fill")
        case "10d", "10n": return Image(systemName: "cloud.heavyrain.fill")
        case "11d", "11n": return Image(systemName: "cloud.bolt.fill")
        case "13d", "13n": return Image(systemName: "cloud.snow.fill")
        case "50d", "50n": return Image(systemName: "cloud.fog.fill")
        default: return Image(systemName: "sun.max.fill")
        }
    }
    
    // MARK: - Private Methods
    @MainActor
    private func fetchWeather(for city: String) async {
        // Cancel any existing task
        fetchTask?.cancel()
        
        isLoading = true
        errorMessage = nil
        showError = false
        
        fetchTask = Task {
            do {
                let response = try await repository.fetchWeatherByCity(city: city)
                
                // Check if task was cancelled
                guard !Task.isCancelled else { return }
                
                self.weatherResponse = response
                self.isLoading = false
                print("✅ Successfully fetched weather for \(city)")
                
            } catch {
                // Check if task was cancelled
                guard !Task.isCancelled else { return }
                
                self.isLoading = false
                self.handleError(error, for: city)
            }
        }
        
        await fetchTask?.value
    }
    
    @MainActor
    private func handleError(_ error: Error, for city: String) {
        // Handle specific network errors
        if let networkError = error as? NetworkError {
            switch networkError {
            case .cityNotFound:
                errorMessage = "City '\(city)' not found. Please check the spelling."
                showError = true
                
                // Try fallback to Mutare
                Task {
                    await fetchFallbackWeather()
                }
                
            case .noInternetConnection:
                errorMessage = "No internet connection. Please check your network settings."
                showError = true
                
            case .requestTimeout:
                errorMessage = "Request timed out. Please try again."
                showError = true
                
            case .rateLimited:
                errorMessage = "Too many requests. Please wait a moment and try again."
                showError = true
                
            case .serverError(let statusCode, let message):
                if statusCode == 401 {
                    errorMessage = "Authentication failed. Please check your API key."
                } else if statusCode == 404 {
                    errorMessage = "Weather data not found for '\(city)'."
                    showError = true
                    Task {
                        await fetchFallbackWeather()
                    }
                } else {
                    errorMessage = "Server error: \(message ?? "Unknown error")"
                }
                showError = true
                
            default:
                errorMessage = "Failed to fetch weather: \(networkError.localizedDescription)"
                showError = true
            }
        } else {
            errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
            showError = true
        }
        
        print("❌ Failed to fetch weather for \(city): \(error)")
    }
    
    @MainActor
    private func fetchFallbackWeather() async {
        print("🔄 Trying fallback to Mutare coordinates...")
        
        do {
            let fallbackResponse = try await repository.fetchWeatherForecast(
                lat: -18.974656,
                lon: 32.670473
            )
            
            self.weatherResponse = fallbackResponse
            self.city = "Mutare"
            self.errorMessage = nil
            self.showError = false
            print("✅ Fallback successful!")
            
        } catch {
            print("❌ Fallback failed: \(error)")
            if errorMessage == nil {
                errorMessage = "Unable to load weather data. Please try again later."
                showError = true
            }
        }
    }
}

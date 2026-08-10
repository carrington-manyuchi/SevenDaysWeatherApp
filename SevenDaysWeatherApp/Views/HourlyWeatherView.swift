//
//  HourlyWeatherView.swift
//  SevenDaysWeatherApp
//
//  Created by Manyuchi, Carrington C on 2026/08/10.
//

import SwiftUI

struct HourlyWeatherView: View {
    @ObservedObject var cityVM: CityViewViewModel
    
    var body: some View {
        ScrollView(.horizontal) {
            VStack(spacing: 20) {
                ForEach(cityVM.weather.hourly) { weather in
                    let icon = cityVM.getWeatherFor(icon: weather.weather.count > 0 ? weather.weather[0].icon : "sun.max.fill")
                    
                    let hour = cityVM.getTimeFor(timestamp: weather.dt)
                    let temp = cityVM.getTempFor(temp: weather.temp)
                    getHourlyView(hour: hour, image: icon, temp: temp)
                }
            }
        }
    }
    
    private func  getHourlyView(hour: String, image: Image, temp: String) -> some View {
        VStack(spacing: 20) {
            Text(hour)
                .foregroundStyle(.yellow)
            Text(temp)
                .foregroundStyle(.yellow)
        }
        .foregroundStyle(.white)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [.blue.opacity(0.5), .blue]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        )
        .shadow(color: .white.opacity(0.1), radius: 2, x: -2, y: -2)
        .shadow(color: .black.opacity(0.2), radius: 2, x: 2, y: 2)
    }
}

#Preview {
    HourlyWeatherView(cityVM: CityViewViewModel())
}

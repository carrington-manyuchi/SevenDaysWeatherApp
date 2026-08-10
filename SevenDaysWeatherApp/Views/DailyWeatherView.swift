//
//  DailyWeatherView.swift
//  SevenDaysWeatherApp
//
//  Created by Manyuchi, Carrington C on 2026/08/10.
//

import SwiftUI

struct DailyWeatherView: View {
    @ObservedObject var cityVM: CityViewViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("7-Day Forecast")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.leading, 20)
            
            VStack(spacing: 6) {
                ForEach(cityVM.dailyForecast, id: \.date) { weather in
                    dailyCell(weather: weather)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 10)
    }
    
    private func dailyCell(weather: DailyWeatherDisplay) -> some View {
        HStack {
            Text(formatDay(weather.date))
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(width: 70, alignment: .leading)
            
            cityVM.getWeatherImageFor(icon: weather.icon)
                .font(.title3)
                .foregroundColor(.yellow)
                .frame(width: 30)
            
            Spacer()
            
            Text(String(format: "%.0f°", weather.minTemperature))
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
            
            Text("-")
                .foregroundColor(.white.opacity(0.5))
            
            Text(String(format: "%.0f°", weather.maxTemperature))
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.blue.opacity(0.2))
                .background(.ultraThinMaterial)
        )
        .shadow(color: .white.opacity(0.05), radius: 1, x: -1, y: -1)
        .shadow(color: .black.opacity(0.1), radius: 1, x: 1, y: 1)
    }
    
    private func formatDay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
}

#Preview {
    DailyWeatherView(cityVM: CityViewViewModel())
        .background(Color.blue)
}

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
        VStack(alignment: .leading, spacing: 10) {
            Text("Hourly Forecast")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.leading, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(cityVM.hourlyForecast, id: \.time) { hour in
                        getHourlyView(hour: hour)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
            }
        }
        .padding(.vertical, 10)
    }
    
    private func getHourlyView(hour: HourlyWeatherDisplay) -> some View {
        VStack(spacing: 12) {
            Text(formatTime(hour.time))
                .font(.subheadline)
                .fontWeight(.medium)
            
            cityVM.getWeatherImageFor(icon: hour.icon)
                .font(.title2)
                .foregroundColor(.yellow)
            
            Text(String(format: "%.0f°", hour.temperature))
                .font(.headline)
        }
        .foregroundStyle(.white)
        .frame(width: 70)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blue.opacity(0.3))
                .background(.ultraThinMaterial)
        )
        .shadow(color: .white.opacity(0.1), radius: 2, x: -2, y: -2)
        .shadow(color: .black.opacity(0.2), radius: 2, x: 2, y: 2)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "ha"
        return formatter.string(from: date)
    }
}

#Preview {
    HourlyWeatherView(cityVM: CityViewViewModel())
        .background(Color.blue)
}

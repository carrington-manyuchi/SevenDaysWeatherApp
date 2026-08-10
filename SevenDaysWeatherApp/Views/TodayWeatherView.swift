//
//  TodayWeatherView.swift
//  SevenDaysWeatherApp
//
//  Created by Manyuchi, Carrington C on 2026/08/10.
//

import SwiftUI

struct TodayWeatherView: View {
    @ObservedObject var cityVM: CityViewViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Today")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            HStack(spacing: 25) {
                LottieView(name: cityVM.getLottieAnimationFor(icon: cityVM.currentWeather.icon))
                    .frame(width: 100, height: 100)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(cityVM.temperatureDisplay)
                        .font(.system(size: 48, weight: .thin))
                    
                    Text(cityVM.conditionDisplay)
                        .font(.title3)
                        .opacity(0.8)
                }
            }
            
            HStack(spacing: 20) {
                Spacer()
                widgetView(
                    image: "wind",
                    color: .green,
                    title: cityVM.windSpeedDisplay
                )
                Spacer()
                widgetView(
                    image: "drop.fill",
                    color: .blue,
                    title: cityVM.humidityDisplay
                )
                Spacer()
                widgetView(
                    image: "umbrella.fill",
                    color: .red,
                    title: "\(String(format: "%.0f%%", cityVM.currentWeather.feelsLike))"
                )
                Spacer()
            }
        }
        .padding()
        .foregroundStyle(.white)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.blue.opacity(0.3))
                .background(.ultraThinMaterial)
        )
        .shadow(color: .white.opacity(0.1), radius: 2, x: -2, y: -2)
        .shadow(color: .black.opacity(0.2), radius: 2, x: 2, y: 2)
    }
    
    private func widgetView(image: String, color: Color, title: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: image)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 44, height: 44)
                .background(Circle().fill(.white.opacity(0.2)))
            
            Text(title)
                .font(.caption)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
    }
}

#Preview {
    TodayWeatherView(cityVM: CityViewViewModel())
        .background(Color.blue)
}

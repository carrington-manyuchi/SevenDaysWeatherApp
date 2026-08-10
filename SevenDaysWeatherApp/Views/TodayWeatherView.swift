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
        VStack(spacing: 10) {
            Text("Today")
                .font(.largeTitle)
                .bold()
            
            HStack(spacing: 20) {
                LottieView(name: cityVM.getLottieAnimationFor(icon: cityVM.weatherIcon))
                    .background(.red)
                    .frame(width: 100, height: 100)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("\(cityVM.temperature)℃")
                        .font(.system(size: 42))
                    
                    Text("\(cityVM.conditions)")
                }
            }
            
            HStack {
                Spacer()
                widgetView(image: "wind", color: .green, title: "\(cityVM.windSpeed)km/hr")
                Spacer()
                widgetView(image: "drop.fill", color: .blue, title: "\(cityVM.humidity)km/hr")
                Spacer()
                widgetView(image: "umbrella.fill", color: .red, title: "\(cityVM.rainChances)km/hr")
                Spacer()
            }            
        }
        .padding()
        .foregroundStyle(.white)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [.blue.opacity(0.5), .blue]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                ).opacity(0.5)
        )
        .shadow(color: .white.opacity(0.1), radius: 2, x: -2, y: -2)
        .shadow(color: .black.opacity(0.2), radius: 2, x: 2, y: 2)
    }
    
    private func widgetView(image: String, color: Color, title: String) -> some View {
        VStack {
            Image(systemName: image)
                .padding()
                .font(.title)
                .foregroundColor(color)
                .background(RoundedRectangle(cornerRadius: 10).fill(.white))
            
            Text(title)
            
        }
    }
}

#Preview {
    TodayWeatherView(cityVM: CityViewViewModel())
}

//
//  CityView.swift
//  SevenDaysWeatherApp
//
//  Created by Manyuchi, Carrington C on 2026/08/10.
//

import SwiftUI

struct CityView: View {
    @ObservedObject var cityVM: CityViewViewModel
    
    var body: some View {
        if cityVM.isLoading {
            VStack {
                Spacer()
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
                Text("Loading weather...")
                    .foregroundColor(.white)
                    .padding(.top, 10)
                Spacer()
            }
        } else if cityVM.showError {
            VStack(spacing: 20) {
                Spacer()
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 50))
                    .foregroundColor(.orange)
                
                Text("Oops!")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(cityVM.errorMessage ?? "Something went wrong")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal)
                
                Button(action: {
                    cityVM.refreshWeather()
                }) {
                    Text("Try Again")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                Spacer()
            }
            .padding()
        } else {
            VStack(spacing: 0) {
                CityNameView(
                    city: cityVM.cityName,
                    date: cityVM.date
                )
                .shadow(radius: 0)
                .padding(.top, 10)
                
                TodayWeatherView(cityVM: cityVM)
                    .padding()
                
                HourlyWeatherView(cityVM: cityVM)
                
                DailyWeatherView(cityVM: cityVM)
            }
            .padding(.bottom, 30)
        }
    }
}

#Preview {
    CityView(cityVM: CityViewViewModel())
}

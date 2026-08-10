//
//  ContentView.swift
//  SevenDaysWeatherApp
//
//  Created by Manyuchi, Carrington C on 2026/08/08.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var cityVM = CityViewViewModel()
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.8),
                    Color.blue
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Main Content
            VStack(spacing: 0) {
                MenuHeaderView(cityVM: cityVM)
                    .padding(.top, 50)
                
                ScrollView(.vertical, showsIndicators: false) {
                    CityView(cityVM: cityVM)
                }
                .refreshable {
                    cityVM.refreshWeather()
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}

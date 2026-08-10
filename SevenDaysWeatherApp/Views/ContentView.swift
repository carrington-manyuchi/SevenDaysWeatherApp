//
//  ContentView.swift
//  SevenDaysWeatherApp
//
//  Created by Manyuchi, Carrington C on 2026/08/08.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var cityVM = CityViewViewModel()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                MenuHeaderView(cityVM: cityVM)
                ScrollView(.vertical) {
                    CityView(cityVM: cityVM)
                }
            }
            .padding(.top, 30)
        }
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
        .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}

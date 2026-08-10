//
//  CityNameView.swift
//  SevenDaysWeatherApp
//
//  Created by Manyuchi, Carrington C on 2026/08/10.
//

import SwiftUI

struct CityNameView: View {
    var city: String
    var date: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(city)
                .font(.title)
                .fontWeight(.bold)
            
            Text(date)
                .font(.subheadline)
                .opacity(0.8)
        }
        .foregroundStyle(.white)
    }
}

#Preview {
    CityNameView(city: "Harare", date: "11 August 2026")
        .background(Color.blue)
}

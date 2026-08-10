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
        HStack(alignment: .center, spacing: 10) {
            Text(city)
                .font(.title)
            
            Text(date)
            
        }
        .foregroundStyle(.white)
    }
}

#Preview {
    CityNameView(city: "Harare", date: "11 August 2026")
}

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
        VStack {
            CityNameView(city: cityVM.city, date: cityVM.date)
                .shadow(radius: 0)
            
            TodayWeatherView(cityVM: cityVM)
                .padding()
            
            HourlyWeatherView(cityVM: cityVM)
            
            DailyWeatherView(cityVM: cityVM)
        }
        .padding(.bottom, 30)
    }
}

#Preview {
    CityView(cityVM: CityViewViewModel())
}

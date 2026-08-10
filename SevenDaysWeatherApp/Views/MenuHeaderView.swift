//
//  MenuHeaderVIew.swift
//  SevenDaysWeatherApp
//
//  Created by Manyuchi, Carrington C on 2026/08/10.
//

import SwiftUI

struct MenuHeaderView: View {
    @ObservedObject var cityVM: CityViewViewModel
    @State private var searchTerm = "Mutare"
    
    
    var body: some View {
        HStack {
            TextField("", text: $searchTerm)
                .padding(.leading, 20)
            
            Button {
                cityVM.city = searchTerm
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.blue)
                    
                    Image(systemName: "location.fill")
                }
            }
            .frame(width: 50, height: 50)
        }
        .foregroundStyle(.white)
        .padding()
        .background(
            ZStack(alignment: .leading, content: {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.white)
                    .padding(.leading, 10)
                
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.blue.opacity(0.5))
            })
        )
        
    }
}

#Preview {
    MenuHeaderView(cityVM: CityViewViewModel())
}

//
//  MenuHeaderView.swift
//  SevenDaysWeatherApp
//
//  Created by Manyuchi, Carrington C on 2026/08/10.
//

import SwiftUI

struct MenuHeaderView: View {
    @ObservedObject var cityVM: CityViewViewModel
    @State private var searchTerm: String = ""
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.leading, 8)
                
                TextField("Search city...", text: $searchTerm)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(.white)
                    .focused($isSearchFocused)
                    .onSubmit {
                        performSearch()
                    }
                    .submitLabel(.search)
                
                if !searchTerm.isEmpty {
                    Button(action: {
                        searchTerm = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.trailing, 8)
                }
            }
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.15))
                    .background(.ultraThinMaterial)
            )
            
            Button(action: {
                performSearch()
            }) {
                Image(systemName: "location.fill")
                    .font(.title3)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color.blue)
                    )
            }
            .disabled(searchTerm.isEmpty)
            .opacity(searchTerm.isEmpty ? 0.5 : 1)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .onAppear {
            searchTerm = cityVM.city
        }
    }
    
    private func performSearch() {
        guard !searchTerm.isEmpty else { return }
        isSearchFocused = false
        cityVM.searchCity(searchTerm)
    }
}

#Preview {
    MenuHeaderView(cityVM: CityViewViewModel())
        .background(Color.blue)
}

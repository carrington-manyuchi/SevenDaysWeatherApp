//
//  NetworkService.swift
//  SevenDaysWeatherApp
//
//  Created by Manyuchi, Carrington C on 2026/08/08.
//

import Foundation


// MARK: - Network Service Protocol
protocol NetworkService {
    func post<T: Encodable, U: Decodable>(_ request: T, to path: String) async throws -> U
    func put<T: Encodable, U: Decodable>(_ request: T, to path: String) async throws -> U
    func delete<U: Decodable>(_ path: String) async throws -> U
    func get<U: Decodable>(_ path: String) async throws -> U
    
    //MARK: - Retry Methods
    func getWithRetry<U: Decodable>(_ path: String, retries: Int) async throws -> U
    func postWithRetry<T: Encodable, U: Decodable>(_ request: T, to path: String, retries: Int) async throws -> U
}



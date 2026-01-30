//
//  DataService.swift
//  IzmirBusApp
//
//  Created for Izmir Open Data Portal Integration.
//

import Foundation

protocol DataService {
    func fetchBusLines() async throws -> [BusLine]
    func fetchStops(for line: BusLine) async throws -> [BusStop]
    func fetchLiveLocations(for line: BusLine) async throws -> [BusLocation]
}

enum APIError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case serverError(String)
}

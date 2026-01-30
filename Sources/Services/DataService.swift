//
//  DataService.swift
//  IzmirBusApp
//
//  Created for Izmir Open Data Portal Integration.
//

import Foundation

protocol DataService {
    func fetchBusLines() async throws -> [BusLine]
    func fetchAllStops() async throws -> [BusStop]
    func fetchStops(for line: BusLine) async throws -> [BusStop] // Kept for compatibility
    func fetchLiveLocations(for line: BusLine) async throws -> [BusLocation]

    // New methods
    func fetchIncomingBuses(stopId: String) async throws -> [IncomingBus]
    func fetchNearbyStops(lat: Double, lon: Double) async throws -> [BusStop]
}

enum APIError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case serverError(String)
}

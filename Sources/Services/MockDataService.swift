//
//  MockDataService.swift
//  IzmirBusApp
//
//  Created for Izmir Open Data Portal Integration.
//

import Foundation

class MockDataService: DataService {

    func fetchBusLines() async throws -> [BusLine] {
        try await Task.sleep(nanoseconds: 500_000_000)
        return [
            BusLine(id: "1", number: "105", name: "Buca - Konak", routeDescription: "Buca - Konak", startPoint: "Buca", endPoint: "Konak"),
            BusLine(id: "2", number: "171", name: "Buca - Konak", routeDescription: "Buca - Konak", startPoint: "Buca", endPoint: "Konak")
        ]
    }

    func fetchAllStops() async throws -> [BusStop] {
        try await Task.sleep(nanoseconds: 500_000_000)
        return [
            BusStop(id: "10005", name: "Bahribaba", latitude: 38.4152, longitude: 27.1276, passingLines: "105-171"),
            BusStop(id: "10030", name: "Konak", latitude: 38.4162, longitude: 27.1263, passingLines: "105")
        ]
    }

    func fetchStops(for line: BusLine) async throws -> [BusStop] {
        return try await fetchAllStops().filter { $0.passingLines.contains(line.number) }
    }

    func fetchLiveLocations(for line: BusLine) async throws -> [BusLocation] {
        return []
    }

    func fetchIncomingBuses(stopId: String) async throws -> [IncomingBus] {
        try await Task.sleep(nanoseconds: 500_000_000)
        return [
            IncomingBus(lineNumber: "105", remainingTime: 5, remainingStops: 2, plateNumber: "35 ESHOT 123"),
            IncomingBus(lineNumber: "171", remainingTime: 12, remainingStops: 5, plateNumber: "35 ESHOT 456")
        ]
    }

    func fetchNearbyStops(lat: Double, lon: Double) async throws -> [BusStop] {
        return try await fetchAllStops()
    }
}

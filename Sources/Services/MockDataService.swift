//
//  MockDataService.swift
//  IzmirBusApp
//
//  Created for Izmir Open Data Portal Integration.
//

import Foundation

class MockDataService: DataService {

    // Simulating a network delay
    func fetchBusLines() async throws -> [BusLine] {
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

        return [
            BusLine(id: "1", number: "105", description: "Buca - Konak", routePolyline: nil),
            BusLine(id: "2", number: "484", description: "Gaziemir - Halkapınar", routePolyline: nil),
            BusLine(id: "3", number: "253", description: "Halkapınar - Konak", routePolyline: nil)
        ]
    }

    func fetchStops(for line: BusLine) async throws -> [BusStop] {
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 second

        // Return dummy stops for the requested line
        return [
            BusStop(id: "S1", name: "Konak Meydanı", latitude: 38.4189, longitude: 27.1287, incomingBuses: []),
            BusStop(id: "S2", name: "Çankaya", latitude: 38.4237, longitude: 27.1354, incomingBuses: []),
            BusStop(id: "S3", name: "Basmane Gar", latitude: 38.4285, longitude: 27.1428, incomingBuses: [])
        ]
    }

    func fetchLiveLocations(for line: BusLine) async throws -> [BusLocation] {
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 second

        return [
            BusLocation(id: "B1", busId: "BUS-101", lineNumber: line.number, latitude: 38.4200, longitude: 27.1300, speed: 45.0),
            BusLocation(id: "B2", busId: "BUS-102", lineNumber: line.number, latitude: 38.4250, longitude: 27.1380, speed: 30.0)
        ]
    }
}

//
//  BusStop.swift
//  IzmirBusApp
//
//  Created for Izmir Open Data Portal Integration.
//

import Foundation

struct BusStop: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let latitude: Double
    let longitude: Double
    let incomingBuses: [IncomingBus]?

    // Conforming to Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct IncomingBus: Identifiable, Codable, Hashable {
    let id: String
    let lineNumber: String
    let estimatedArrival: Int // minutes

    // Conforming to Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

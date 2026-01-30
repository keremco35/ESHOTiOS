//
//  BusLine.swift
//  IzmirBusApp
//
//  Created for Izmir Open Data Portal Integration.
//

import Foundation

struct BusLine: Identifiable, Codable, Hashable {
    let id: String
    let number: String
    let description: String
    // Routes are often complex arrays of coordinates.
    // For simplicity in this demo, we might just store start/end points or a polyline string.
    let routePolyline: String?

    // Conforming to Hashable for SwiftUI Lists
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

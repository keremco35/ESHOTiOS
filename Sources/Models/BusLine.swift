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
    let name: String
    let routeDescription: String
    let startPoint: String
    let endPoint: String

    // Conforming to Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

//
//  BusLocation.swift
//  IzmirBusApp
//
//  Created for Izmir Open Data Portal Integration.
//

import Foundation

struct BusLocation: Identifiable, Codable {
    let id: String
    let busId: String
    let lineNumber: String
    let latitude: Double
    let longitude: Double
    let speed: Double?
}

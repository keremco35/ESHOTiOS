//
//  Configuration.swift
//  IzmirBusApp
//
//  Created for Izmir Open Data Portal Integration.
//

import Foundation

struct Configuration {
    // MARK: - API Configuration

    // Defaulting to a placeholder. Replace with the actual API Base URL if available.
    // Example: "https://openapi.izmir.bel.tr/api/eshot/"
    static let baseURL = "https://openapi.izmir.bel.tr/api/eshot/"

    // API Key (if required)
    // In a real app, this should be fetched from secure storage or environment variables.
    static let apiKey = ProcessInfo.processInfo.environment["API_KEY"] ?? ""

    // MARK: - Map Configuration

    // Initial coordinates for Izmir
    static let initialLatitude = 38.4237
    static let initialLongitude = 27.1428
    static let defaultSpan = 0.05
}

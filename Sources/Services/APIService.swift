//
//  APIService.swift
//  IzmirBusApp
//
//  Created for Izmir Open Data Portal Integration.
//

import Foundation

class APIService: DataService {

    private let session = URLSession.shared
    private let baseURL = Configuration.baseURL

    // Generic helper for network requests
    private func fetch<T: Decodable>(endpoint: String) async throws -> T {
        // Construct URL
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        // Add headers if API requires authentication
        // request.setValue("Bearer \(Configuration.apiKey)", forHTTPHeaderField: "Authorization")

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.serverError("Invalid Response")
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError.serverError("Status Code: \(httpResponse.statusCode)")
            }

            let decoder = JSONDecoder()
            // Adjust date decoding strategy if API uses custom dates
            // decoder.dateDecodingStrategy = .iso8601

            return try decoder.decode(T.self, from: data)
        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch {
            throw APIError.networkError(error)
        }
    }

    // MARK: - DataService Implementation

    func fetchBusLines() async throws -> [BusLine] {
        // Explicitly specifying the type [BusLine] for generic T
        let lines: [BusLine] = try await fetch(endpoint: "lines")
        return lines
    }

    func fetchStops(for line: BusLine) async throws -> [BusStop] {
        // Example endpoint: "/transport/lines/{id}/stops"
        let stops: [BusStop] = try await fetch(endpoint: "lines/\(line.id)/stops")
        return stops
    }

    func fetchLiveLocations(for line: BusLine) async throws -> [BusLocation] {
        // Example endpoint: "/transport/live/locations?line={number}"
        let locations: [BusLocation] = try await fetch(endpoint: "live/locations?line=\(line.number)")
        return locations
    }
}

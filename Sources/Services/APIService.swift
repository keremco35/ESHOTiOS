//
//  APIService.swift
//  IzmirBusApp
//
//  Created for Izmir Open Data Portal Integration.
//

import Foundation

class APIService: DataService {

    private let session = URLSession.shared

    // Real URLs provided by the user
    private let busLinesCSVURL = "https://openfiles.izmir.bel.tr/211488/docs/eshot-otobus-hatlari.csv"
    private let busStopsCSVURL = "https://openfiles.izmir.bel.tr/211488/docs/eshot-otobus-duraklari.csv"
    private let nearbyStopsAPI = "https://openapi.izmir.bel.tr/api/ibb/cbs/noktayayakinduraklar"
    private let incomingBusesAPI = "https://openapi.izmir.bel.tr/api/iztek/duragayaklasanotobusler"

    // Generic helper for network requests
    private func fetch<T: Decodable>(url: URL) async throws -> T {
        let request = URLRequest(url: url)

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw APIError.serverError("Invalid Response Code")
            }

            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }

    // Helper to fetch Raw Data (for CSVs)
    private func fetchRaw(urlStr: String) async throws -> String {
        guard let url = URL(string: urlStr) else { throw APIError.invalidURL }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError("Invalid Response Code for CSV")
        }

        // Try decoding with UTF-8 first, fallback to Windows-1254 (common in Turkish CSVs) if needed
        if let str = String(data: data, encoding: .utf8) {
            return str
        } else if let str = String(data: data, encoding: .windowsCP1254) {
             return str
        } else {
             throw APIError.decodingError(NSError(domain: "Encoding", code: 0, userInfo: nil))
        }
    }


    // MARK: - DataService Implementation

    func fetchBusLines() async throws -> [BusLine] {
        let csvString = try await fetchRaw(urlStr: busLinesCSVURL)
        return CSVParser.parseBusLines(from: csvString)
    }

    func fetchAllStops() async throws -> [BusStop] {
        let csvString = try await fetchRaw(urlStr: busStopsCSVURL)
        return CSVParser.parseBusStops(from: csvString)
    }

    // Original interface method - deprecated logic, now returns all stops to filter locally or uses new nearby API
    func fetchStops(for line: BusLine) async throws -> [BusStop] {
        // This is tricky because the CSV lines data doesn't link directly to stops easily without processing "Passing Lines" column in stops.
        // We will fetch ALL stops and filter them.
        let allStops = try await fetchAllStops()
        return allStops.filter { $0.passingLines.components(separatedBy: "-").contains(line.number) }
    }

    func fetchLiveLocations(for line: BusLine) async throws -> [BusLocation] {
        // The provided APIs didn't explicitly give "Live Bus Locations for a Line".
        // They gave "Incoming Buses for a Stop".
        // We will return empty here or mock it, as the user only provided stop-based real-time data.
        return []
    }

    // New Method: Fetch Incoming Buses for a specific Stop
    func fetchIncomingBuses(stopId: String) async throws -> [IncomingBus] {
        guard let url = URL(string: "\(incomingBusesAPI)/\(stopId)") else {
             throw APIError.invalidURL
        }
        return try await fetch(url: url)
    }

    // New Method: Fetch Nearby Stops
    func fetchNearbyStops(lat: Double, lon: Double) async throws -> [BusStop] {
        // Construct URL: ?x=...&y=...&inCoordSys=WGS84&outCoordSys=WGS84
        var components = URLComponents(string: nearbyStopsAPI)
        components?.queryItems = [
            URLQueryItem(name: "x", value: "\(lon)"),
            URLQueryItem(name: "y", value: "\(lat)"),
            URLQueryItem(name: "inCoordSys", value: "WGS84"),
            URLQueryItem(name: "outCoordSys", value: "WGS84")
        ]

        guard let url = components?.url else { throw APIError.invalidURL }

        // This API returns a specific JSON structure. We need a temporary struct to decode it if it differs from BusStop
        // Based on analysis: [{"durakId":"10005","enlem":...,"adi":"...","mesafe":...,"boylam":...}]
        struct NearbyStopResponse: Decodable {
            let durakId: String
            let adi: String
            let enlem: Double
            let boylam: Double
            let mesafe: Double
        }

        let responses: [NearbyStopResponse] = try await fetch(url: url)

        return responses.map {
            // Note: The API returns Lat/Lon but earlier analysis showed they might be projected.
            // However, we will trust the API response or use our CSV cache if needed.
            // For now, mapping directly.
            BusStop(id: $0.durakId, name: $0.adi, latitude: $0.enlem, longitude: $0.boylam, passingLines: "")
        }
    }
}

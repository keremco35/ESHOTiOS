//
//  BusStop.swift
//  IzmirBusApp
//
//  Created for Izmir Open Data Portal Integration.
//

import Foundation
import CoreLocation

struct BusStop: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let latitude: Double
    let longitude: Double
    let passingLines: String // "32" or "29-30"

    // Incoming buses will be fetched separately, so we don't store them here directly in the base model
    // to keep the CSV parsing clean. We can handle them in the ViewModel.

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: BusStop, rhs: BusStop) -> Bool {
        return lhs.id == rhs.id
    }
}

// Incoming bus model for the real-time API
struct IncomingBus: Identifiable, Codable, Hashable {
    // We will need to adjust these fields based on the actual JSON response we get.
    // Since the API returned [], I will make a best-guess and update if we see real data.
    // Common fields: HatNo, KalanSuredk, KalanDurakSayisi

    let id: String // Unique ID if available, or generate one
    let lineNumber: String
    let remainingTime: Int? // Minutes
    let remainingStops: Int?
    let plateNumber: String?

    // Mapping keys to match potential Turkish API response keys
    enum CodingKeys: String, CodingKey {
        case id = "Id" // Guess
        case lineNumber = "HatNo"
        case remainingTime = "KalanSure"
        case remainingStops = "KalanDurak"
        case plateNumber = "Plaka"
    }

    init(id: String = UUID().uuidString, lineNumber: String, remainingTime: Int?, remainingStops: Int?, plateNumber: String?) {
        self.id = id
        self.lineNumber = lineNumber
        self.remainingTime = remainingTime
        self.remainingStops = remainingStops
        self.plateNumber = plateNumber
    }

    // Custom decoding to handle potential inconsistencies or generate UUIDs
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Use provided ID or generate one
        self.id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        self.lineNumber = try container.decodeIfPresent(String.self, forKey: .lineNumber) ?? "Unknown"

        // Handle time as String or Int
        if let timeInt = try? container.decode(Int.self, forKey: .remainingTime) {
            self.remainingTime = timeInt
        } else if let timeStr = try? container.decode(String.self, forKey: .remainingTime) {
            self.remainingTime = Int(timeStr)
        } else {
            self.remainingTime = nil
        }

        self.remainingStops = try container.decodeIfPresent(Int.self, forKey: .remainingStops)
        self.plateNumber = try container.decodeIfPresent(String.self, forKey: .plateNumber)
    }
}

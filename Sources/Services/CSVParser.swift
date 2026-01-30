//
//  CSVParser.swift
//  IzmirBusApp
//
//  Created for Izmir Open Data Portal Integration.
//

import Foundation

class CSVParser {

    static func parseBusLines(from csvString: String) -> [BusLine] {
        var lines: [BusLine] = []
        let rows = csvString.components(separatedBy: "\n")

        // Skip header row if exists (HAT_NO;HAT_ADI...)
        let startIndex = rows.first?.contains("HAT_NO") == true ? 1 : 0

        for i in startIndex..<rows.count {
            let row = rows[i]
            let columns = row.components(separatedBy: ";")

            if columns.count >= 2 {
                let number = columns[0].trimmingCharacters(in: .whitespacesAndNewlines)
                let name = columns[1].trimmingCharacters(in: .whitespacesAndNewlines)

                // Optional fields
                let routeDesc = columns.count > 2 ? columns[2].trimmingCharacters(in: .whitespacesAndNewlines) : ""
                let startPoint = columns.count > 4 ? columns[4].trimmingCharacters(in: .whitespacesAndNewlines) : ""
                let endPoint = columns.count > 5 ? columns[5].trimmingCharacters(in: .whitespacesAndNewlines) : ""

                if !number.isEmpty && !name.isEmpty {
                    let line = BusLine(
                        id: number, // Use number as ID
                        number: number,
                        name: name,
                        routeDescription: routeDesc,
                        startPoint: startPoint,
                        endPoint: endPoint
                    )
                    lines.append(line)
                }
            }
        }

        return lines
    }

    static func parseBusStops(from csvString: String) -> [BusStop] {
        var stops: [BusStop] = []
        let rows = csvString.components(separatedBy: "\n")

        // Skip header (DURAK_ID;DURAK_ADI...)
        let startIndex = rows.first?.contains("DURAK_ID") == true ? 1 : 0

        for i in startIndex..<rows.count {
            let row = rows[i]
            let columns = row.components(separatedBy: ";")

            if columns.count >= 4 {
                let id = columns[0].trimmingCharacters(in: .whitespacesAndNewlines)
                let name = columns[1].trimmingCharacters(in: .whitespacesAndNewlines)
                let latStr = columns[2].trimmingCharacters(in: .whitespacesAndNewlines)
                let lonStr = columns[3].trimmingCharacters(in: .whitespacesAndNewlines)
                let passingLines = columns.count > 4 ? columns[4].trimmingCharacters(in: .whitespacesAndNewlines) : ""

                if let lat = Double(latStr), let lon = Double(lonStr), !id.isEmpty {
                    let stop = BusStop(
                        id: id,
                        name: name,
                        latitude: lat,
                        longitude: lon,
                        passingLines: passingLines
                    )
                    stops.append(stop)
                }
            }
        }
        return stops
    }
}

//
//  HomeViewModel.swift
//  IzmirBusApp
//
//  Created for Izmir Open Data Portal Integration.
//

import Foundation
import Combine
import CoreLocation

@MainActor
class HomeViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var busLines: [BusLine] = []
    @Published var filteredBusLines: [BusLine] = []
    @Published var selectedLine: BusLine?
    @Published var selectedStop: BusStop?
    @Published var stops: [BusStop] = []
    @Published var allStops: [BusStop] = [] // Cache of all stops
    @Published var liveLocations: [BusLocation] = []
    @Published var incomingBuses: [IncomingBus] = []

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showMap = false

    @Published var searchQuery = ""

    // MARK: - Dependencies

    private let dataService: DataService
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(useMock: Bool = false) { // Default to False now to use real data
        self.dataService = useMock ? MockDataService() : APIService()

        setupSearchSubscription()
    }

    private func setupSearchSubscription() {
        $searchQuery
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .combineLatest($busLines)
            .map { query, lines in
                if query.isEmpty { return lines }
                return lines.filter {
                    $0.number.contains(query) || $0.name.localizedCaseInsensitiveContains(query)
                }
            }
            .assign(to: &$filteredBusLines)
    }

    // MARK: - Actions

    func fetchInitialData() async {
        isLoading = true
        errorMessage = nil
        do {
            // Load Lines
            async let linesTask = dataService.fetchBusLines()
            // Load All Stops (Heavy operation, might want to cache or optimize)
            async let stopsTask = dataService.fetchAllStops()

            let (fetchedLines, fetchedStops) = try await (linesTask, stopsTask)

            busLines = fetchedLines
            allStops = fetchedStops
        } catch {
            errorMessage = "Data loading error: \(error.localizedDescription)"
        }
        isLoading = false
    }

    func selectLine(_ line: BusLine) {
        selectedLine = line
        selectedStop = nil
        liveLocations = []
        incomingBuses = []
        isLoading = true
        showMap = true

        // Filter stops for this line from our cache
        // The CSV format for passing lines is usually "10-20-30"
        // We perform a local filter.
        let targetNumber = line.number
        stops = allStops.filter { stop in
            let lines = stop.passingLines.components(separatedBy: "-")
            return lines.contains(targetNumber)
        }

        if stops.isEmpty {
             errorMessage = "No stops found for this line."
        }

        isLoading = false
    }

    func selectStop(_ stop: BusStop) {
        selectedStop = stop
        fetchIncomingBuses(for: stop)
    }

    func fetchIncomingBuses(for stop: BusStop) {
        Task {
            do {
                incomingBuses = try await dataService.fetchIncomingBuses(stopId: stop.id)
            } catch {
                print("Error fetching incoming buses: \(error)")
                // Don't block UI, just maybe show empty
                incomingBuses = []
            }
        }
    }

    func clearSelection() {
        selectedLine = nil
        selectedStop = nil
        stops = []
        liveLocations = []
        incomingBuses = []
        showMap = false
    }
}

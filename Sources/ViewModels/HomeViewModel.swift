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
    @Published var liveLocations: [BusLocation] = []

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showMap = false // To toggle map view

    @Published var searchQuery = ""

    // MARK: - Dependencies

    private let dataService: DataService
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(useMock: Bool = true) {
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
                    $0.number.contains(query) || $0.description.localizedCaseInsensitiveContains(query)
                }
            }
            .assign(to: &$filteredBusLines)
    }

    // MARK: - Actions

    func fetchBusLines() async {
        isLoading = true
        errorMessage = nil
        do {
            busLines = try await dataService.fetchBusLines()
            // Initial filter update happens via Combine pipeline automatically
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func selectLine(_ line: BusLine) async {
        selectedLine = line
        stops = []
        liveLocations = []
        isLoading = true
        showMap = true

        // Fetch stops and locations concurrently
        do {
            async let fetchedStops = dataService.fetchStops(for: line)
            async let fetchedLocations = dataService.fetchLiveLocations(for: line)

            let (newStops, newLocations) = try await (fetchedStops, fetchedLocations)

            stops = newStops
            liveLocations = newLocations
        } catch {
            errorMessage = "Failed to load route data: \(error.localizedDescription)"
        }
        isLoading = false
    }

    func refreshLiveLocations() async {
        guard let line = selectedLine else { return }
        do {
            liveLocations = try await dataService.fetchLiveLocations(for: line)
        } catch {
            // Silently fail on refresh or show a toast
            print("Failed to refresh locations: \(error)")
        }
    }

    func selectStop(_ stop: BusStop) {
        selectedStop = stop
    }

    func clearSelection() {
        selectedLine = nil
        selectedStop = nil
        stops = []
        liveLocations = []
        showMap = false
    }
}

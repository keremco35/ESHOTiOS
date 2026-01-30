//
//  ContentView.swift
//  IzmirBusApp
//
//  Created for Izmir Open Data Portal Integration.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationView {
            VStack {
                BusListView(viewModel: viewModel)
            }
            .navigationTitle("Izmir Bus Tracker")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        Task { await viewModel.refreshLiveLocations() }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
        .onAppear {
            Task { await viewModel.fetchBusLines() }
        }
        .sheet(isPresented: $viewModel.showMap) {
            MapView(viewModel: viewModel)
        }
    }
}

//
//  BusListView.swift
//  IzmirBusApp
//
//  Created for Izmir Open Data Portal Integration.
//

import SwiftUI

struct BusListView: View {
    @ObservedObject var viewModel: HomeViewModel

    var body: some View {
        List {
            if viewModel.isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            }

            if let error = viewModel.errorMessage {
                Text("Error: \(error)")
                    .foregroundColor(.red)
                    .padding()
            }

            // Search Results
            ForEach(viewModel.filteredBusLines) { line in
                Button(action: {
                    Task { await viewModel.selectLine(line) }
                }) {
                    VStack(alignment: .leading) {
                        Text(line.number)
                            .font(.headline)
                        Text(line.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .searchable(text: $viewModel.searchQuery, prompt: "Search Bus Line")
        .listStyle(PlainListStyle())
    }
}

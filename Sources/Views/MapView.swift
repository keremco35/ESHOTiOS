//
//  MapView.swift
//  IzmirBusApp
//
//  Created for Izmir Open Data Portal Integration.
//

import SwiftUI
import MapKit

struct MapView: View {
    @ObservedObject var viewModel: HomeViewModel

    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: Configuration.initialLatitude, longitude: Configuration.initialLongitude),
        span: MKCoordinateSpan(latitudeDelta: Configuration.defaultSpan, longitudeDelta: Configuration.defaultSpan)
    )

    var body: some View {
        ZStack {
            Map(coordinateRegion: $region, annotationItems: allAnnotations) { item in
                MapAnnotation(coordinate: item.coordinate) {
                    if let bus = item.busLocation {
                        Image(systemName: "bus.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                            .foregroundColor(.blue)
                            .padding(5)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 3)
                    } else if let stop = item.busStop {
                        Image(systemName: "circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 15, height: 15)
                            .foregroundColor(.red)
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            .onTapGesture {
                                viewModel.selectStop(stop)
                            }
                    }
                }
            }
            .ignoresSafeArea()
            .onAppear {
                centerMapOnFirstStop()
            }
            .onChange(of: viewModel.stops) { _ in
                centerMapOnFirstStop()
            }
            .sheet(item: $viewModel.selectedStop) { stop in
                StopDetailView(stop: stop, incomingBuses: viewModel.incomingBuses)
                    .presentationDetents([.medium, .fraction(0.5)])
            }

            // Close Button Overlay
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        viewModel.clearSelection()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .shadow(radius: 3)
                            .padding()
                    }
                }
                Spacer()

                // Legend
                HStack {
                    Text("🔴 Stop")
                        .font(.caption)
                        .padding(5)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(5)
                    Text("🔵 Bus")
                        .font(.caption)
                        .padding(5)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(5)
                }
                .padding(.bottom)
            }
        }
    }

    private func centerMapOnFirstStop() {
        if let firstStop = viewModel.stops.first {
            region.center = CLLocationCoordinate2D(latitude: firstStop.latitude, longitude: firstStop.longitude)
            region.span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        }
    }

    // Helper Model for Map Annotations
    struct MapItem: Identifiable {
        let id: String
        let coordinate: CLLocationCoordinate2D
        let busStop: BusStop?
        let busLocation: BusLocation?
    }

    var allAnnotations: [MapItem] {
        var items: [MapItem] = []

        items.append(contentsOf: viewModel.stops.map {
            MapItem(id: "Stop-\($0.id)",
                    coordinate: CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude),
                    busStop: $0,
                    busLocation: nil)
        })

        items.append(contentsOf: viewModel.liveLocations.map {
            MapItem(id: "Bus-\($0.id)",
                    coordinate: CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude),
                    busStop: nil,
                    busLocation: $0)
        })

        return items
    }
}

struct StopDetailView: View {
    let stop: BusStop
    let incomingBuses: [IncomingBus]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(stop.name)
                .font(.title2)
                .bold()
                .padding(.top)

            Text("Stop ID: \(stop.id)")
                .font(.caption)
                .foregroundColor(.secondary)

            Divider()

            if !incomingBuses.isEmpty {
                Text("Incoming Buses")
                    .font(.headline)

                List(incomingBuses) { bus in
                    HStack {
                        Text(bus.lineNumber)
                            .font(.headline)
                            .padding(8)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)

                        VStack(alignment: .leading) {
                            if let plate = bus.plateNumber {
                                Text(plate).font(.caption).foregroundColor(.secondary)
                            }
                        }

                        Spacer()

                        if let time = bus.remainingTime {
                            Text("\(time) min")
                                .bold()
                                .foregroundColor(.blue)
                        } else {
                            Text("Approaching")
                                .italic()
                        }
                    }
                }
                .listStyle(PlainListStyle())
            } else {
                VStack {
                    Spacer()
                    Text("No incoming buses info available.")
                        .foregroundColor(.secondary)
                        .padding()
                    Spacer()
                }
            }
        }
        .padding(.horizontal)
    }
}

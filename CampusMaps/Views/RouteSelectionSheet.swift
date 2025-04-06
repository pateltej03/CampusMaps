//
//  RouteSelectionSheet.swift
//  CampusMaps
//
//  Created by Tej Patel on 15/10/24.
//


import SwiftUI
import MapKit


struct RouteSelectionSheet: View {
    @Binding var startLocation: Building?
    @Binding var destinationLocation: Building?
    var onRouteSelected: () -> Void
    @EnvironmentObject var manager: BuildingManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Spacer()
                    Button("Dismiss") {
                        dismiss()
                    }
                    .padding()
                    Spacer()
                }

                Text("Select Start Location")
                    .font(.headline)
                    .padding(.top)

                List(manager.filteredBuildings.sorted { $0.name < $1.name }) { building in
                    HStack {
                        Text(building.name)
                        Spacer()
                        if startLocation?.id == building.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        startLocation = building
                    }
                }

                Text("Select Destination Location")
                    .font(.headline)
                    .padding(.top)

                List(manager.filteredBuildings.sorted { $0.name < $1.name }) { building in
                    HStack {
                        Text(building.name)
                        Spacer()
                        if destinationLocation?.id == building.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        destinationLocation = building
                    }
                }

                Button(action: {
                    onRouteSelected()
                    dismiss()
                }) {
                    Text("See Route")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Capsule().fill(Color.blue))
                        .foregroundColor(.white)
                }
                .disabled(startLocation == nil || destinationLocation == nil) 
                .padding()
            }
            .navigationTitle("Select Route")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

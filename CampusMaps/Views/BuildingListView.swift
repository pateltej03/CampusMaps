//
//  BuildingListView.swift
//  CampusMaps
//
//  Created by Tej Patel on 07/10/24.
//


import SwiftUI

struct BuildingListView: View {
    @EnvironmentObject var manager: BuildingManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button("Dismiss") {
                    dismiss()
                }
                .font(.headline)
                .padding()
                Spacer()
            }
            
            Picker("Filter Buildings", selection: $manager.filter) {
                Text("All").tag(BuildingFilter.all)
                Text("Favorites").tag(BuildingFilter.favorites)
                Text("Selected").tag(BuildingFilter.selected)
                Text("Nearby").tag(BuildingFilter.nearby)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding([.horizontal, .bottom])
            .onChange(of: manager.filter) { _, newFilter in
                manager.filterBuildings(by: newFilter)
            }

            List(manager.filteredBuildings.sorted { $0.name < $1.name }) { building in
                HStack {
                    Image(systemName: building.isMapped ? "checkmark.square.fill" : "square")
                    Text(building.name)
                    Spacer()
                    if building.isFavorite {
                        Image(systemName: "heart.fill").foregroundColor(.red)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    manager.toggleMapped(building: building)
                }
            }
            .navigationTitle("Select Buildings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Dismiss") {
                        dismiss()
                    }
                }
            }
        }
    }
}

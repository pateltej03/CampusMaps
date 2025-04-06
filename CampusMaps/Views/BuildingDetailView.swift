//
//  BuildingDetailView.swift
//  CampusMaps
//
//  Created by Tej Patel on 07/10/24.
//

import SwiftUI

struct BuildingDetailView: View {
    var building: Building
    @EnvironmentObject var manager: BuildingManager
    @State private var isFavorite: Bool
    
    init(building: Building) {
        self.building = building
        _isFavorite = State(initialValue: building.isFavorite)
    }
    
    var body: some View {
        VStack {
            if let photo = building.photo {
                Image(photo)
                    .resizable()
                    .scaledToFit()
            }
            Text(building.name).font(.largeTitle)
            
            if let year = building.year_constructed {
                Text("Constructed in \(String(format: "%d", year))").font(.subheadline)
            }
            
            Button(action: {
                isFavorite.toggle()
                manager.toggleFavorite(building: building)
            }) {
                Text(isFavorite ? "Unfavorite" : "Favorite")
            }
            .padding()
        }
    }
}

//
//  CampusMapsApp.swift
//  CampusMaps
//
//  Created by Tej Patel on 07/10/24.
//

import SwiftUI

@main
struct CampusMapsApp: App {
    @StateObject var buildingManager = BuildingManager()
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(buildingManager)
        }
    }
}

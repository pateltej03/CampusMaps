//
//  BuildingManager.swift
//  CampusMaps
//
//  Created by Tej Patel on 07/10/24.
//

import Foundation
import SwiftUI
import MapKit
import CoreLocation

class BuildingManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var buildings: [Building] = []
    @Published var filteredBuildings: [Building] = []
    @Published var favoriteBuildings: [Building] = []
    @Published var filter: BuildingFilter = .all
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 40.798481, longitude: -77.860907),
        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
    )
    @Published var userLocation: CLLocationCoordinate2D? = nil
    @Published var isCenteredOnUser = false
    @Published var locationPermissionDenied = false
    @Published var isMapPanned = false
    @Published var currentRoute: MKRoute?
    @Published var routeSteps: [MKRoute.Step] = []
    @Published var currentStepIndex = 0
    @Published var showLocationDescription: String? = nil
    @Published var showAlert: Bool = false
    
    private let locationManager = CLLocationManager()
    private let buildingsKey = "savedBuildings"
    
    @Published var currentCircularRegion: CircleRegion?
    @Published var circularRegions: [CircleRegion] = []
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        requestLocationAccess()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        loadBuildingsFromUserDefaults()
        filterBuildings(by: filter)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
            locationPermissionDenied = false
        case .denied, .restricted:
            locationPermissionDenied = true
            manager.stopUpdatingLocation()
        default:
            break
        }
    }
    
    func requestLocationAccess() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            locationPermissionDenied = true
        case .authorizedWhenInUse, .authorizedAlways:
            locationPermissionDenied = false
            locationManager.startUpdatingLocation()
        @unknown default:
            locationPermissionDenied = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            userLocation = location.coordinate
            if isCenteredOnUser {
                region = MKCoordinateRegion(center: location.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func updateCurrentRegion(center: CLLocationCoordinate2D, edge: CLLocationCoordinate2D) {
        let radius = center.distance(from: edge)
        if currentCircularRegion == nil {
            currentCircularRegion = CircleRegion(center: center.coord, radius: radius)
        } else {
            currentCircularRegion!.updateRadius(to: radius)
        }
    }
    
    func addRegion() {
        if let region = currentCircularRegion {
            circularRegions.append(region)
            currentCircularRegion = nil
        }
    }
    
    func centerOnUserLocation() {
        if let userLocation = userLocation {
            region = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
            isCenteredOnUser = true
            isMapPanned = false
        }
    }
    
    func userMovedMap() {
        isCenteredOnUser = false
        isMapPanned = true
    }
    
    func geocodeCurrentLocation() {
        guard let currentLocation = self.locationManager.location else { return }
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(currentLocation) { placeMarks, error in
            guard error == nil else { return }
            if let placeMark = placeMarks?.first {
                self.showLocationDescription = placeMark.thoroughfare ?? ""
                self.showAlert = true
            }
        }
    }
    
    func calculateRoute(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: start))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: end))
        request.transportType = .walking
        
        let directions = MKDirections(request: request)
        directions.calculate { [weak self] response, error in
            if let route = response?.routes.first {
                self?.currentRoute = route
                self?.routeSteps = route.steps
                self?.currentStepIndex = 0
            } else {
                print("Error calculating route: \(String(describing: error))")
            }
        }
    }
    
    func nextStep() {
        if currentStepIndex < routeSteps.count - 1 {
            currentStepIndex += 1
        }
    }
    
    func previousStep() {
        if currentStepIndex > 0 {
            currentStepIndex -= 1
        }
    }
    
    func loadBuildingsFromUserDefaults() {
        if let savedData = UserDefaults.standard.data(forKey: buildingsKey) {
            do {
                let decoder = JSONDecoder()
                buildings = try decoder.decode([Building].self, from: savedData)
                filterBuildings(by: filter)
            } catch {
                loadBuildingsFromJSON()
            }
        } else {
            loadBuildingsFromJSON()
        }
    }
    
    func loadBuildingsFromJSON() {
        if let url = Bundle.main.url(forResource: "buildings", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                buildings = try decoder.decode([Building].self, from: data)
                saveBuildingsToUserDefaults()
                filterBuildings(by: filter)
            } catch {
                print("Error loading buildings from JSON: \(error)")
            }
        }
    }
    
    func saveBuildingsToUserDefaults() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(buildings)
            UserDefaults.standard.set(data, forKey: buildingsKey)
        } catch {
            print("Error encoding buildings for UserDefaults: \(error)")
        }
    }
    
    func toggleFavorite(building: Building) {
        
        if let index = buildings.firstIndex(where: { $0.name == building.name }) {
            var updatedBuilding = buildings[index]
            updatedBuilding.isFavorite.toggle()
            buildings[index] = updatedBuilding
            saveBuildingsToUserDefaults()
            updateFavoriteBuildings()
            filterBuildings(by: filter)
        }
    }

    func updateFavoriteBuildings() {
        favoriteBuildings = buildings.filter { $0.isFavorite }
    }
    
    func toggleMapped(building: Building) {
        if let index = buildings.firstIndex(where: { $0.id == building.id }) {
            buildings[index].isMapped.toggle()
            saveBuildingsToUserDefaults()
            filterBuildings(by: filter)
        }
    }
    
    func selectAllFavorites() {
        for index in buildings.indices {
            if buildings[index].isFavorite {
                buildings[index].isMapped = true
            }
        }
        updateFavoriteBuildings()
        filterBuildings(by: filter)
        saveBuildingsToUserDefaults()
    }
    
    func deselectFavorites() {
        for index in buildings.indices {
            if buildings[index].isFavorite {
                buildings[index].isMapped = false
            }
        }
        updateFavoriteBuildings()
        filterBuildings(by: filter)
        saveBuildingsToUserDefaults()
    }
    
    func deselectAll() {
        for index in buildings.indices {
            buildings[index].isMapped = false
        }
        updateFavoriteBuildings()
        filterBuildings(by: filter)
        saveBuildingsToUserDefaults()
    }
    
    func filterBuildings(by filter: BuildingFilter) {
        switch filter {
        case .all:
            filteredBuildings = buildings
        case .favorites:
            filteredBuildings = buildings.filter { $0.isFavorite }
        case .selected:
            filteredBuildings = buildings.filter { $0.isMapped }
        case .nearby:
            if let userLocation = userLocation {
                filteredBuildings = buildings.filter { $0.isNearby(to: userLocation) }
            } else {
                filteredBuildings = []
            }
        }
        updateFavoriteBuildings()  
    }
}

enum BuildingFilter {
    case all, favorites, selected, nearby
}

extension Building {
    func isNearby(to location: CLLocationCoordinate2D, threshold: CLLocationDistance = 1000) -> Bool {
        let buildingLocation = CLLocation(latitude: latitude, longitude: longitude)
        let userLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        return buildingLocation.distance(from: userLocation) <= threshold
    }
}

class CircleRegion {
    var center: Coord
    var radius: Double
    
    init(center: Coord, radius: Double) {
        self.center = center
        self.radius = radius
    }
    
    func updateRadius(to newRadius: Double) {
        self.radius = newRadius
    }
}

extension CLLocationCoordinate2D {
    func distance(from other: CLLocationCoordinate2D) -> CLLocationDistance {
        let origin = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let destination = CLLocation(latitude: other.latitude, longitude: other.longitude)
        return origin.distance(from: destination)
    }
    
    var coord: Coord {
        return Coord(latitude: self.latitude, longitude: self.longitude)
    }
}

struct Coord {
    var latitude: Double
    var longitude: Double
}

extension Coord {
    var coord: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}




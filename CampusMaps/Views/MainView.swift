//
//  MainView.swift
//  CampusMaps
//
//  Created by Tej Patel on 07/10/24.
//


import SwiftUI
import MapKit

struct MainView: View {
    @EnvironmentObject var manager: BuildingManager
    @State private var mapType: MKMapType = .standard
    @State private var markers: [MKPointAnnotation] = []
    @State private var customMarkers: [MKPointAnnotation] = []
    @State private var userLocation: CLLocationCoordinate2D?
    @State private var showBuildingList = false
    @State private var showRouteSheet = false
    @State private var startBuilding: Building?
    @State private var areFavoritesSelected = false
    @State private var destinationBuilding: Building?
    @State private var isRouteActive: Bool = false
    @State private var currentStepIndex: Int = 0
    @State private var showLocationAlert = false
    @State private var selectedBuilding: Building? = nil
    @State private var selectedMapType: String = "Standard"
    
    @State private var isAddingMarker = false
    @State private var isRemovingMarker = false
    
    let mapTypes = ["Standard", "Hybrid", "Imagery"]

    var body: some View {
        NavigationStack {
            ZStack {
                 MapViewRepresentable(
                    mapType: $mapType,
                    markers: $markers,
                    customMarkers: $customMarkers,
                    userLocation: $userLocation,
                    region: $manager.region,
                    onMarkerAdded: { newMarker in
                        markers.append(newMarker)
                    },
                    onMarkerTapped: { building in
                        selectedBuilding = building
                    },
                    isAddingMarker: $isAddingMarker,
                    favoriteBuildings: manager.favoriteBuildings.map { $0.id },
                    currentRoute: $manager.currentRoute,
                    buildings: manager.buildings
                )

                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    if let userLoc = manager.userLocation {
                        userLocation = userLoc
                    }
                    updateMarkers()
                }
                
                VStack {
                    VStack {
                        Picker("Map Type", selection: $selectedMapType) {
                            ForEach(mapTypes, id: \.self) { mapType in
                                Text(mapType).tag(mapType)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding([.horizontal, .top])
                        .background(Color.white)
                        .opacity(1.0)
                        .onChange(of: selectedMapType) { newValue in
                            switch newValue {
                            case "Hybrid":
                                mapType = .hybrid
                            case "Imagery":
                                mapType = .satellite
                            default:
                                mapType = .standard
                            }
                        }
                        
                        Picker("Filter Buildings", selection: $manager.filter) {
                            Text("All").tag(BuildingFilter.all)
                            Text("Favorites").tag(BuildingFilter.favorites)
                            Text("Selected").tag(BuildingFilter.selected)
                            Text("Nearby").tag(BuildingFilter.nearby)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding([.horizontal, .bottom])
                        .background(Color.white)
                        .opacity(1.0)
                        .onChange(of: manager.filter) { _, newFilter in
                            manager.filterBuildings(by: newFilter)
                            updateMarkers()
                        }
                    }
                    .background(Color.white)
                    .opacity(1.0)
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        VStack {
                             Button(action: {
                                showRouteSheet.toggle()
                            }) {
                                Text("Route")
                                    .padding()
                                    .background(Capsule().fill(Color.blue))
                                    .foregroundColor(.white)
                                    .shadow(radius: 10)
                            }
                            .padding(.bottom, 10)
                            
                            Button(action: {
                                if manager.locationPermissionDenied {
                                    showLocationAlert = true
                                } else {
                                    manager.centerOnUserLocation()
                                }
                            }) {
                                Image(systemName: "location.fill")
                                    .padding()
                                    .background(Circle().fill(Color.blue))
                                    .foregroundColor(.white)
                                    .shadow(radius: 10)
                            }
                            .disabled(manager.isCenteredOnUser || manager.userLocation == nil)
                        }
                        .padding()
                    }
                }
                
                if isRouteActive {
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                exitRoute()
                            }) {
                                Text("Exit Route")
                                    .padding()
                                    .background(Capsule().fill(Color.red))
                                    .foregroundColor(.white)
                                    .shadow(radius: 10)
                            }
                            .padding(.trailing)
                            .padding(.top, 100)
                        }
                        Spacer()
                    }
                }
            }
            .alert(isPresented: $showLocationAlert) {
                Alert(
                    title: Text("Location Permission Denied"),
                    message: Text("Please enable location permissions in Settings to use this feature."),
                    dismissButton: .default(Text("OK"))
                )
            }
            .sheet(isPresented: $showBuildingList) {
                BuildingListView()
                    .environmentObject(manager)
            }
            .sheet(isPresented: $showRouteSheet) {
                RouteSelectionSheet(
                    startLocation: $startBuilding,
                    destinationLocation: $destinationBuilding,
                    onRouteSelected: startRoute
                )
            }
            .sheet(item: $selectedBuilding) { building in
                BuildingDetailView(building: building)
                    .environmentObject(manager)
                    .presentationDetents([.fraction(0.4)])
                    .presentationDragIndicator(.visible)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Show Building List") {
                        showBuildingList.toggle()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(areFavoritesSelected ? "Deselect All Favorites" : "Select All Favorites") {
                        if areFavoritesSelected {
                            manager.deselectFavorites()
                        } else {
                            manager.selectAllFavorites()
                        }
                        updateFavoriteButtonState()
                        updateMarkers()
                    }
                    .disabled(manager.favoriteBuildings.isEmpty)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Deselect All") {
                            manager.deselectAll()
                            updateFavoriteButtonState()
                            updateMarkers()
                        }
                        Button("Add Marker (Long Press)") {
                            isAddingMarker.toggle()
                            isRemovingMarker = false
                        }
                        Button("Remove Marker") {
                            isRemovingMarker.toggle()
                            isAddingMarker = false
                        }
                        Button("Delete All Markers") {
                            customMarkers.removeAll()
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
    }

    func updateFavoriteButtonState() {
        let favoriteCount = manager.favoriteBuildings.count
        let mappedFavorites = manager.favoriteBuildings.filter { $0.isMapped }.count
        areFavoritesSelected = (favoriteCount > 0 && mappedFavorites == favoriteCount)
    }

    func removeMarker(_ marker: MKPointAnnotation) {
        if let index = customMarkers.firstIndex(of: marker) {
            customMarkers.remove(at: index)
        }
    }

    func updateMarkers() {
        markers.removeAll()
        if !isRouteActive {
            for building in manager.filteredBuildings {
                let annotation = MKPointAnnotation()
                annotation.coordinate = building.coordinate
                annotation.title = building.name
                annotation.subtitle = building.id.uuidString
                markers.append(annotation)
            }
        }
    }

    func startRoute() {
        if let startLocation = startBuilding?.coordinate, let destinationLocation = destinationBuilding?.coordinate {
            manager.calculateRoute(from: startLocation, to: destinationLocation)
            currentStepIndex = 0
            isRouteActive = true
            markers.removeAll()
            
            if let startBuilding = startBuilding {
                let startAnnotation = MKPointAnnotation()
                startAnnotation.coordinate = startBuilding.coordinate
                startAnnotation.title = "Start: \(startBuilding.name)"
                markers.append(startAnnotation)
            }
            if let destinationBuilding = destinationBuilding {
                let destinationAnnotation = MKPointAnnotation()
                destinationAnnotation.coordinate = destinationBuilding.coordinate
                destinationAnnotation.title = "Destination: \(destinationBuilding.name)"
                markers.append(destinationAnnotation)
            }
        }
    }

    func exitRoute() {
        isRouteActive = false
        manager.currentRoute = nil
        startBuilding = nil
        destinationBuilding = nil
        updateMarkers()
    }
}



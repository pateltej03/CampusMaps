//
//  MapViewRepresentable.swift
//  CampusMaps
//
//  Created by Tej Patel on 21/10/24.
//

import SwiftUI
import MapKit

struct MapViewRepresentable: UIViewControllerRepresentable {
    @Binding var mapType: MKMapType
    @Binding var markers: [MKPointAnnotation]
    @Binding var customMarkers: [MKPointAnnotation]
    @Binding var userLocation: CLLocationCoordinate2D?
    @Binding var region: MKCoordinateRegion
    var onMarkerAdded: (MKPointAnnotation) -> Void
    var onMarkerTapped: (Building) -> Void
    @Binding var isAddingMarker: Bool
    var favoriteBuildings: [UUID]
    @Binding var currentRoute: MKRoute?
    var buildings: [Building]
    @EnvironmentObject var manager: BuildingManager

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewRepresentable

        init(parent: MapViewRepresentable) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let pointAnnotation = annotation as? MKPointAnnotation else { return nil }
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "marker") as? MKMarkerAnnotationView ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "marker")
            annotationView.canShowCallout = true
            annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)

            if let annotationTitle = annotation.title {
                if annotationTitle?.contains("Start") ?? false {
                    annotationView.markerTintColor = .green
                    annotationView.glyphImage = UIImage(systemName: "mappin.circle.fill")
                } else if annotationTitle?.contains("Destination") ?? false {
                    annotationView.markerTintColor = .red
                    annotationView.glyphImage = UIImage(systemName: "flag.circle.fill")
                } else {
                    if let annotationSubtitle = annotation.subtitle, let uuid = UUID(uuidString: annotationSubtitle ?? "") {
                        if parent.manager.favoriteBuildings.contains(where: { $0.id == uuid }) {
                            annotationView.markerTintColor = .red
                            annotationView.glyphImage = UIImage(systemName: "star.fill")
                        } else {
                            annotationView.markerTintColor = .red
                            annotationView.glyphImage = UIImage(systemName: "mappin")
                        }
                    }
                }
            }

            return annotationView
        }

        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            guard let annotation = view.annotation as? MKPointAnnotation else { return }

            if let building = parent.buildings.first(where: { $0.name == annotation.title }) {
                parent.onMarkerTapped(building)
            }
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .blue
                renderer.lineWidth = 4.0
                return renderer
            }
            return MKOverlayRenderer()
        }


        @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
            guard parent.isAddingMarker else { return }
            let mapView = gestureRecognizer.view as! MKMapView
            if gestureRecognizer.state == .began {
                let touchPoint = gestureRecognizer.location(in: mapView)
                let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "Custom Marker"
                parent.onMarkerAdded(annotation)
                parent.customMarkers.append(annotation)
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> MKMapViewController {
        let mapViewController = MKMapViewController()
        let mapView = mapViewController.mapView

        mapView.delegate = context.coordinator
        mapView.mapType = mapType
        mapView.setRegion(region, animated: true)

        let longPress = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleLongPress(_:)))
        mapView.addGestureRecognizer(longPress)

        return mapViewController
    }

    func updateUIViewController(_ uiViewController: MKMapViewController, context: Context) {
        uiViewController.mapView.mapType = mapType

         if !areRegionsEqual(uiViewController.mapView.region, region) {
            uiViewController.mapView.setRegion(region, animated: true)
        }

        uiViewController.mapView.removeAnnotations(uiViewController.mapView.annotations)
        uiViewController.mapView.addAnnotations(markers)
        uiViewController.mapView.addAnnotations(customMarkers)

        if let route = currentRoute {
            uiViewController.mapView.removeOverlays(uiViewController.mapView.overlays)
            uiViewController.mapView.addOverlay(route.polyline)
        } else {
            uiViewController.mapView.removeOverlays(uiViewController.mapView.overlays)
        }

        if let userLocation = userLocation {
            let userAnnotation = MKPointAnnotation()
            userAnnotation.coordinate = userLocation
            uiViewController.mapView.addAnnotation(userAnnotation)
        }
    }

    private func areRegionsEqual(_ region1: MKCoordinateRegion, _ region2: MKCoordinateRegion) -> Bool {
        return region1.center.latitude == region2.center.latitude &&
        region1.center.longitude == region2.center.longitude &&
        region1.span.latitudeDelta == region2.span.latitudeDelta &&
        region1.span.longitudeDelta == region2.span.longitudeDelta
    }
}

class MKMapViewController: UIViewController {
    var mapView = MKMapView()
    var onMarkerAdded: ((MKPointAnnotation) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.frame = view.frame
        view.addSubview(mapView)

        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "marker")

        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(addMarker(_:)))
        mapView.addGestureRecognizer(longPress)
    }

    @objc func addMarker(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: mapView)
            let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)

            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "New Marker"
            mapView.addAnnotation(annotation)

            onMarkerAdded?(annotation)
        }
    }
}

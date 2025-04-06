# 🗺️ CampusMaps

**CampusMaps** is a SwiftUI iOS app that helps users explore and navigate buildings around Penn State’s campus using an interactive map. The app combines MapKit with a custom UI to provide building details, routes between locations, filtering, favorite selections, and marker customization — all in one smooth experience.

---

## 📱 Features

-   **Interactive Map (MapKit + SwiftUI Integration)**  
    View campus buildings as markers on a map with zoom and region controls.

-   **Filter Views**  
    Filter buildings by:

    -   All
    -   Favorites
    -   Selected (mapped)
    -   Nearby (within 1000m of your location)

-   **Favorite and Select Buildings**  
    Mark buildings as favorites and toggle selection on/off. Use the "Select All Favorites" feature for quick map highlighting.

-   **Custom Markers**  
    Long-press on the map to drop your own custom markers.

-   **Route Directions (MKRoute)**  
    Select any two buildings and get walking directions with start/destination pins and step-based navigation.

-   **Map Type Picker**  
    Switch between Standard, Hybrid, and Satellite map styles on the fly.

-   **Persistent Building Data**  
    All building selections and favorites are saved using `UserDefaults` — even after relaunching the app.

-   **Building Detail Sheet**  
    Tap any building marker to see an image (if available), construction year, and favorite toggle.

---

## 💡 Technologies Used

-   SwiftUI & UIKit Interop (via `UIViewControllerRepresentable`)
-   MapKit (`MKMapView`, `MKAnnotation`, `MKRoute`)
-   CoreLocation for user tracking
-   JSON parsing for building data
-   UserDefaults for persistence

---

## 🏗️ Architecture

-   `BuildingManager`: ObservableObject for handling buildings, filtering, persistence, and map state
-   `MainView`: Core UI for map + toolbar + filters
-   `MapViewRepresentable`: SwiftUI wrapper around MKMapView
-   `BuildingListView` & `RouteSelectionSheet`: Modal interfaces for selection
-   `BuildingDetailView`: Per-building info sheet

---

## 📂 Sample Data

Over 30 real Penn State campus buildings loaded from JSON, including details like:

-   Name
-   Coordinates
-   Year constructed
-   Photos (for some buildings)
-   OPP building code

---

## 📸 Screenshots (Optional)

You can include screenshots here for:

-   Full map view
-   Route in progress
-   Building list modal
-   Detail view with photo

---

## 🧠 Let’s Connect!

**Tej Jaideep Patel**  
B.S. Computer Engineering  
📍 Penn State University  
✉️ tejpatelce@gmail.com  
📞 814-826-5544

---

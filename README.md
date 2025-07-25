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
    Select any two buildings and get walking directions with route overlays, start/end pins, and step-by-step instructions.

-   **Map Type Picker**  
    Switch between Standard, Hybrid, and Satellite map styles on the fly.

-   **Persistent Building Data**  
    All building selections and favorites are saved using `UserDefaults` — even after relaunching the app.

-   **Building Detail Sheet**  
    Tap any building marker to see an image (if available), construction year, and favorite toggle.

---

## 🎥 Preview

**Map Modes and Marker Interaction**

<div align="center">
    <img src="./Maps_1.gif" width="300">
</div>

**Favorites Filtering on Map**

<div align="center">
    <img src="./Maps_2.gif" width="300">
</div>

**List View and Dynamic Filters**

<div align="center">
    <img src="./Maps_3.gif" width="300">
</div>

**Detail View – Smart Handling of Data**

<div align="center">
    <img src="./Maps_4.gif" width="300">
</div>

**Real-Time List Updates and Marker Consistency**

<div align="center">
    <img src="./Maps_5.gif" width="300">
</div>

**App Relaunch – Persistence Check**

<div align="center">
    <img src="./Maps_6.gif" width="300">
</div>

**Route Directions Between Selected Buildings**

<div align="center">
    <img src="./Maps_7.gif" width="300">
</div>

---

## 💡 Technologies Used

-   SwiftUI & UIKit Interop (via `UIViewControllerRepresentable`)
-   MapKit (`MKMapView`, `MKAnnotation`, `MKRoute`)
-   CoreLocation for user tracking
-   JSON parsing for building data
-   UserDefaults for persistence

---

## 🏗️ Architecture

-   `BuildingManager`: Handles buildings, filtering, persistence, and map state
-   `MainView`: Core UI for map, toolbar, and filters
-   `MapViewRepresentable`: SwiftUI wrapper for `MKMapView`
-   `BuildingListView` & `RouteSelectionSheet`: Modal selection views
-   `BuildingDetailView`: Shows per-building info

---

## 📂 Sample Data

Over 350 real Penn State campus buildings loaded from JSON, including:

-   Name
-   Coordinates
-   Year constructed
-   Photos (for some buildings)
-   OPP building code

---

## 🧠 Let’s Connect!

**Tej Jaideep Patel**  
B.S. Computer Engineering  
📍 Penn State University  
✉️ tejpatelce@gmail.com  
📞 814-826-5544

---

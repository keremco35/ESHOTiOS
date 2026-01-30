# Izmir ESHOT iOS App

This is a SwiftUI application for tracking Izmir Bus transportation using the **Izmir Open Data Portal (İzmir Açık Veri Portalı)** API.

## Features

*   **Real-time Bus Tracking:** View incoming buses for selected stops.
*   **Interactive Map:** See bus stops and your location on an interactive map.
*   **Bus Line Search:** Search for bus lines by number or name.
*   **Live Data:** Uses official Izmir Municipality open data sources.

## Data Sources

The application uses the following data sources from the Izmir Open Data Portal:

*   **Bus Stops (CSV):** Fetched dynamically from `eshot-otobus-duraklari.csv`.
*   **Bus Lines (CSV):** Fetched dynamically from `eshot-otobus-hatlari.csv`.
*   **Nearby Stops:** Uses the `noktayayakinduraklar` API endpoint.
*   **Incoming Buses:** Uses the `duragayaklasanotobusler` API endpoint for real-time estimates.

## Project Setup Instructions

### Option A: Using XcodeGen (Recommended)

This project is configured with `XcodeGen` to generate the `.xcodeproj` file automatically. This ensures a clean project structure and simplifies CI/CD.

1.  **Install XcodeGen:**
    ```bash
    brew install xcodegen
    ```
2.  **Generate Project:**
    Run the following command in the project root:
    ```bash
    xcodegen generate
    ```
3.  **Open Project:**
    Open the generated `IzmirBusApp.xcodeproj`.

### Option B: Manual Setup

If you prefer to set up the project manually in Xcode:

1.  **Create a New Xcode Project:**
    *   Open Xcode.
    *   Select **File > New > Project**.
    *   Choose **App** under iOS.
    *   Set the Product Name to `IzmirBusApp`.
    *   Ensure **Interface** is set to **SwiftUI**.
    *   Ensure **Language** is set to **Swift**.

2.  **Import Source Files:**
    *   In the Project Navigator, select the `IzmirBusApp` folder.
    *   Drag and drop the `Sources` folder from this repository into Xcode.
    *   Check **"Copy items if needed"** and **"Create groups"**.

3.  **App Entry Point:**
    *   Locate `IzmirBusAppApp.swift` (created by Xcode).
    *   Replace its content or modify it to use `ContentView()` from `Sources/Views/ContentView.swift`.

4.  **Info.plist:**
    *   Ensure your `Info.plist` includes keys for Location usage (`NSLocationWhenInUseUsageDescription`) if you plan to enable user location features in the future.

## Architecture

This app uses the **MVVM (Model-View-ViewModel)** pattern:

*   **Models:** `BusLine`, `BusStop`, `IncomingBus`.
*   **ViewModels:** `HomeViewModel` handles data fetching, business logic, and state management.
*   **Views:** `ContentView`, `MapView`, `BusListView`.
*   **Services:**
    *   `APIService`: Handles fetching CSVs and calling REST APIs.
    *   `CSVParser`: Parses the specific semicolon-separated CSV format used by Izmir Open Data.

## CI/CD

A GitHub Actions workflow is provided in `.github/workflows/ios-ci.yml`. It:
1.  Installs `xcodegen`.
2.  Generates the Xcode project.
3.  Builds the app for the **iOS Simulator** (Code Signing is disabled to allow easy forking and testing).

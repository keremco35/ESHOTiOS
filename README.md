# Izmir ESHOT iOS App

This is a SwiftUI application for tracking Izmir Bus transportation using the Izmir Open Data Portal (Açık Veri Portalı) API.

## Project Setup Instructions

Since I cannot generate a valid `.xcodeproj` file directly, please follow these steps to set up the project in Xcode:

1.  **Create a New Xcode Project:**
    *   Open Xcode.
    *   Select **File > New > Project**.
    *   Choose **App** under iOS.
    *   Set the Product Name to `IzmirBusApp`.
    *   Ensure **Interface** is set to **SwiftUI**.
    *   Ensure **Language** is set to **Swift**.

2.  **Import Source Files:**
    *   In the Project Navigator (left sidebar), select the `IzmirBusApp` folder (the one containing `IzmirBusAppApp.swift`).
    *   Drag and drop the `Sources` folder from this repository into that folder in Xcode.
    *   Make sure **"Copy items if needed"** is checked.
    *   Make sure **"Create groups"** is selected.

3.  **App Entry Point:**
    *   Locate `IzmirBusAppApp.swift` (created by Xcode).
    *   Replace its content or modify it to use `ContentView()` from `Sources/Views/ContentView.swift`.

4.  **Configuration:**
    *   Open `Sources/App/Configuration.swift`.
    *   If you have the specific API endpoints for Izmir Open Data, update the `baseURL`.

## Architecture

This app uses the MVVM (Model-View-ViewModel) pattern:

*   **Models:** Data structures representing API responses (`BusLine`, `BusStop`).
*   **ViewModels:** Logic for fetching data and managing UI state (`HomeViewModel`).
*   **Views:** SwiftUI views (`ContentView`, `MapView`, `BusListView`).
*   **Services:** Networking logic (`APIService`, `MockDataService`).

## API Integration

The app is currently configured with a `MockDataService` for demonstration purposes. To use real live data:

1.  Obtain the API documentation for Izmir Open Data Portal.
2.  Update `Sources/Services/APIService.swift` with the correct endpoints.
3.  Set `useMockData = false` in `HomeViewModel`.

## CI/CD

A GitHub Actions workflow is provided in `.github/workflows/ios-ci.yml` to automatically build and test the app on every push.

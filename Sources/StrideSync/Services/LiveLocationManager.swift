import Foundation
import CoreLocation
import SwiftUI

/// Live hardware GPS location manager bridging iOS CLLocationManager events to RecordViewModel.
@Observable
@MainActor
public final class LiveLocationManager: NSObject, CLLocationManagerDelegate {
    public var authorizationStatus: CLAuthorizationStatus = .notDetermined
    public var isLocationServicesEnabled: Bool = true
    public var lastLocation: CLLocation?
    
    private let locationManager = CLLocationManager()
    public var onLocationUpdate: ((CLLocation) -> Void)?
    
    public override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.distanceFilter = 1.0 // Update every 1 meter
        self.authorizationStatus = locationManager.authorizationStatus
        
        #if os(iOS)
        self.locationManager.activityType = .fitness
        self.locationManager.pausesLocationUpdatesAutomatically = false
        #endif
    }
    
    /// Requests user authorization for location tracking.
    public func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
        #if os(iOS)
        locationManager.requestAlwaysAuthorization()
        #endif
    }
    
    /// Starts real-time hardware GPS location updates.
    public func startUpdatingLocation() {
        #if os(iOS)
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true
        #endif
        locationManager.startUpdatingLocation()
    }
    
    /// Stops hardware GPS location updates.
    public func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        #if os(iOS)
        locationManager.allowsBackgroundLocationUpdates = false
        #endif
    }
    
    // MARK: - CLLocationManagerDelegate
    
    public nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            self.authorizationStatus = status
        }
    }
    
    public nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latest = locations.last else { return }
        Task { @MainActor in
            self.lastLocation = latest
            self.onLocationUpdate?(latest)
        }
    }
    
    public nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Fallback or log location error
    }
}


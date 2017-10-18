//
//  LocationManager.swift
//  chatspot
//
//  Created by Varun on 10/14/17.
//  Copyright © 2017 g7. All rights reserved.
//

import Foundation
import CoreLocation

// let locationChangeNotification = Notification.Name("locationChangeNotification")

class LocationManager: NSObject {
    
    static let instance = LocationManager()
    
    private let manager: CLLocationManager = CLLocationManager()
    
    override private init() {
        super.init()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
    }
    
    func listenForRealtimeLocationChanges() {
        
        if CLLocationManager.authorizationStatus() == .authorizedAlways ||
            CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            print("listenForRealtimeLocationChange")
            manager.requestLocation()
        } else if (CLLocationManager.authorizationStatus() != .denied && CLLocationManager.authorizationStatus() != .restricted) {
            print("Requesting user to allow Chatspot to access their location")
            manager.requestAlwaysAuthorization()
        } else {
            print("location permission denied !! ")
        }
    }
    
    func listenForSignificantLocationChanges() {
        
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            print("listenForSignificantLocationChanges")
            manager.allowsBackgroundLocationUpdates = true
            manager.startMonitoringSignificantLocationChanges()
        } else {
            print("User has not permitted chatspot to get location in background")
        }
    }
    
    func stopListeningSignificantChanges() {
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            print("stopListeningSignificantChange")
            manager.stopMonitoringSignificantLocationChanges()
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            manager.requestLocation()
        } else if (status == .notDetermined) {
            manager.requestAlwaysAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations.last?.coordinate ?? "No location?")
        // TODO: send location to server
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("location fetch failed \(error.localizedDescription)")
    }
    
}
